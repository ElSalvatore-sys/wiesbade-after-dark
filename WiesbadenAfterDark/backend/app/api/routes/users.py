"""
User Management API routes.
Handles user profile, points summary, referrals, and FCM token management.
"""

from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.db.session import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.models.user_points import UserPoints
from app.models.referral import Referral, ReferralChain
from app.models.venue import Venue
from app.schemas.user import (
    UserResponse,
    UserUpdate,
    UserPointsSummary,
    VenuePointsDetail,
    ReferralStats,
    ReferredUser,
    FCMTokenUpdate,
)


router = APIRouter()


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user)
):
    """
    Get current user's profile information.

    Returns complete user profile including loyalty statistics.

    Args:
        current_user: Authenticated user from JWT token

    Returns:
        UserResponse with full profile data
    """
    return UserResponse.model_validate(current_user)


@router.put("/me", response_model=UserResponse)
async def update_current_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Update current user's profile information.

    Allows updating: first_name, last_name, phone_number, birth_date

    Args:
        user_update: Updated user data
        current_user: Authenticated user
        db: Database session

    Returns:
        Updated UserResponse

    Raises:
        HTTPException: 400 if validation fails
    """
    # Update only provided fields
    update_data = user_update.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(current_user, field, value)

    await db.commit()
    await db.refresh(current_user)

    return UserResponse.model_validate(current_user)


@router.get("/me/points", response_model=UserPointsSummary)
async def get_user_points_summary(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get comprehensive points summary for current user across all venues.

    Returns aggregated points data and per-venue breakdown.

    Args:
        current_user: Authenticated user
        db: Database session

    Returns:
        UserPointsSummary with total points and venue-specific details
    """
    # Get all user points records with venue information
    result = await db.execute(
        select(UserPoints, Venue)
        .join(Venue, UserPoints.venue_id == Venue.id)
        .where(UserPoints.user_id == current_user.id)
        .order_by(UserPoints.points_available.desc())
    )
    user_points_with_venues = result.all()

    # Calculate totals
    total_points_earned = sum(up.points_earned for up, _ in user_points_with_venues)
    total_points_spent = sum(up.points_spent for up, _ in user_points_with_venues)
    total_points_available = sum(up.points_available for up, _ in user_points_with_venues)

    # Build venue-specific details
    venues_breakdown = []
    for user_points, venue in user_points_with_venues:
        venues_breakdown.append(
            VenuePointsDetail(
                venue_id=venue.id,
                venue_name=venue.name,
                venue_slug=venue.slug,
                points_earned=user_points.points_earned,
                points_spent=user_points.points_spent,
                points_available=user_points.points_available,
                current_streak=user_points.current_streak,
                longest_streak=user_points.longest_streak,
                total_visits=user_points.total_visits,
                last_visit_date=user_points.last_visit_date,
            )
        )

    return UserPointsSummary(
        total_points_earned=total_points_earned,
        total_points_spent=total_points_spent,
        total_points_available=total_points_available,
        venues=venues_breakdown,
    )


@router.get("/me/referrals", response_model=ReferralStats)
async def get_user_referrals(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get referral statistics for current user.

    Returns:
        - Total referrals count
        - List of users directly referred
        - Total points earned from referral bonuses (calculated from transactions)

    Args:
        current_user: Authenticated user
        db: Database session

    Returns:
        ReferralStats with referral information
    """
    # Get all direct referrals (users this user referred)
    result = await db.execute(
        select(Referral, User)
        .join(User, Referral.referred_id == User.id)
        .where(Referral.referrer_id == current_user.id)
        .order_by(Referral.created_at.desc())
    )
    referrals_with_users = result.all()

    # Build referred users list
    referred_users = []
    for referral, referred_user in referrals_with_users:
        referred_users.append(
            ReferredUser(
                id=referred_user.id,
                first_name=referred_user.first_name,
                last_name=referred_user.last_name,
                email=referred_user.email,
                referred_at=referral.created_at,
                is_active=referral.is_active,
            )
        )

    # Calculate total referral bonus points earned
    # This would normally query Transaction model with type=referral_bonus
    # For now, we'll use a placeholder calculation
    from app.models.transaction import Transaction, TransactionType

    result = await db.execute(
        select(func.sum(Transaction.points_earned))
        .where(
            Transaction.user_id == current_user.id,
            Transaction.transaction_type == TransactionType.REFERRAL_BONUS
        )
    )
    total_referral_points_earned = result.scalar() or 0.0

    return ReferralStats(
        total_referrals=current_user.total_referrals,
        referral_code=current_user.referral_code,
        referred_users=referred_users,
        total_referral_points_earned=float(total_referral_points_earned),
    )


@router.post("/me/fcm-token", status_code=status.HTTP_200_OK)
async def update_fcm_token(
    token_data: FCMTokenUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Update user's Firebase Cloud Messaging (FCM) token for push notifications.

    Args:
        token_data: FCM token data
        current_user: Authenticated user
        db: Database session

    Returns:
        Success message
    """
    current_user.fcm_token = token_data.fcm_token
    await db.commit()

    return {
        "message": "FCM token updated successfully",
        "fcm_token": token_data.fcm_token,
    }
