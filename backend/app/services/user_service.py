"""
User service - Business logic for user operations
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func
from sqlalchemy.orm import joinedload
from typing import Optional, List
from datetime import datetime, timedelta
from fastapi import HTTPException

from app.models.user import User
from app.models.venue_membership import VenueMembership
from app.models.venue import Venue
from app.models.transaction import Transaction
from app.schemas.user import (
    UserUpdate,
    PointsSummary,
    VenuePointsBreakdown,
    ExpiringPoints,
    ExpiringPointsDetail,
)
from app.core.config import settings


class UserService:
    """Service for user-related operations"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_user_by_id(self, user_id: str) -> Optional[User]:
        """
        Get user by ID
        Endpoint #6: GET /users/:userId
        """
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()

    async def update_user(self, user_id: str, user_update: UserUpdate) -> User:
        """
        Update user profile
        Endpoint #7: PUT /users/:userId
        """
        # Get user
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Update fields
        update_data = user_update.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(user, field, value)

        user.updated_at = datetime.utcnow()

        await self.db.commit()
        await self.db.refresh(user)

        return user

    async def get_points_summary(self, user_id: str) -> PointsSummary:
        """
        Get user points summary with venue breakdown
        Endpoint #8: GET /users/:userId/points
        """
        # Get all venue memberships for user with venue details
        result = await self.db.execute(
            select(VenueMembership, Venue)
            .join(Venue, VenueMembership.venue_id == Venue.id)
            .where(VenueMembership.user_id == user_id)
            .where(VenueMembership.is_active == True)
            .order_by(VenueMembership.total_points.desc())
        )

        memberships_venues = result.all()

        # Build venue breakdown
        venue_breakdowns = []
        total_points = 0

        for membership, venue in memberships_venues:
            venue_breakdowns.append(
                VenuePointsBreakdown(
                    venue_id=venue.id,
                    venue_name=venue.name,
                    venue_logo_url=venue.logo_url,
                    total_points=membership.total_points,
                    current_tier=membership.current_tier,
                    tier_progress=membership.tier_progress,
                    last_visit_at=membership.last_visit_at,
                )
            )
            total_points += membership.total_points

        return PointsSummary(
            user_id=user_id,
            total_points_all_venues=total_points,
            total_venues=len(venue_breakdowns),
            venues=venue_breakdowns,
        )

    async def get_expiring_points(
        self, user_id: str, days_ahead: int = 30
    ) -> ExpiringPoints:
        """
        Get points expiring within specified days
        Endpoint #9: GET /users/:userId/expiring-points
        """
        # Calculate expiration window
        now = datetime.utcnow()
        expiry_threshold = now + timedelta(days=days_ahead)

        # Get transactions with points that will expire soon
        result = await self.db.execute(
            select(Transaction, Venue)
            .join(VenueMembership, Transaction.membership_id == VenueMembership.id)
            .join(Venue, Transaction.venue_id == Venue.id)
            .where(Transaction.user_id == user_id)
            .where(Transaction.points_earned > 0)
            .where(Transaction.is_expired == False)
            .where(Transaction.points_expire_at.isnot(None))
            .where(Transaction.points_expire_at <= expiry_threshold)
            .where(Transaction.points_expire_at >= now)
            .order_by(Transaction.points_expire_at.asc())
        )

        transactions_venues = result.all()

        # Build expiring points details
        expiring_details = []
        total_expiring = 0

        for transaction, venue in transactions_venues:
            days_until = (transaction.points_expire_at - now).days

            expiring_details.append(
                ExpiringPointsDetail(
                    transaction_id=transaction.id,
                    venue_id=venue.id,
                    venue_name=venue.name,
                    points=transaction.points_earned,
                    expires_at=transaction.points_expire_at,
                    days_until_expiry=days_until,
                )
            )
            total_expiring += transaction.points_earned

        return ExpiringPoints(
            user_id=user_id,
            total_expiring_points=total_expiring,
            days_ahead=days_ahead,
            expiring_transactions=expiring_details,
        )

    async def update_activity(
        self, user_id: str, venue_id: str, activity_type: str
    ) -> dict:
        """
        Update user's last activity timestamp
        Endpoint #10: PUT /users/:userId/activity
        """
        now = datetime.utcnow()

        # Update user's last activity
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        user.last_activity_at = now

        # Update venue membership if it exists
        membership_result = await self.db.execute(
            select(VenueMembership)
            .where(VenueMembership.user_id == user_id)
            .where(VenueMembership.venue_id == venue_id)
        )
        membership = membership_result.scalar_one_or_none()

        venue_last_visit = None
        if membership:
            membership.last_visit_at = now
            membership.total_visits += 1
            venue_last_visit = now

        await self.db.commit()

        return {
            "success": True,
            "message": f"Activity updated: {activity_type}",
            "last_activity_at": now,
            "venue_last_visit_at": venue_last_visit,
        }
