"""
Venue service - Business logic for venue operations
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from typing import Optional, List, Tuple
from fastapi import HTTPException
import json

from app.models.venue import Venue
from app.models.product import Product
from app.schemas.venue import TierConfig, TierLevel


class VenueService:
    """Service for venue-related operations"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def list_venues(
        self,
        venue_type: Optional[str] = None,
        has_events: Optional[bool] = None,
        user_location: Optional[Tuple[float, float]] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> List[Venue]:
        """
        List venues with filters
        Endpoint #11: GET /venues
        """
        # Build query
        query = select(Venue).where(Venue.is_active == True)

        # Apply filters
        if venue_type:
            query = query.where(Venue.type == venue_type)

        if has_events is not None:
            query = query.where(Venue.has_events == has_events)

        # Apply pagination
        query = query.limit(limit).offset(offset)

        # Execute query
        result = await self.db.execute(query)
        venues = result.scalars().all()

        # Note: Distance calculation is done in the endpoint using geopy
        # because it requires user location

        return list(venues)

    async def get_venue_by_id(self, venue_id: str) -> Optional[Venue]:
        """
        Get venue details by ID
        Endpoint #12: GET /venues/:venueId
        """
        result = await self.db.execute(
            select(Venue).where(Venue.id == venue_id)
        )
        return result.scalar_one_or_none()

    async def get_products(
        self,
        venue_id: str,
        has_bonus: Optional[bool] = None,
        category: Optional[str] = None,
    ) -> List[Product]:
        """
        Get venue products with filters
        Endpoint #13: GET /venues/:venueId/products
        """
        # Build query
        query = select(Product).where(
            and_(
                Product.venue_id == venue_id,
                Product.is_available == True,
            )
        )

        # Apply filters
        if has_bonus is not None:
            query = query.where(Product.has_bonus == has_bonus)

        if category:
            query = query.where(Product.category == category)

        # Order by name
        query = query.order_by(Product.name)

        # Execute query
        result = await self.db.execute(query)
        products = result.scalars().all()

        return list(products)

    async def is_owner(self, user_id: str, venue_id: str) -> bool:
        """
        Check if user is the owner of the venue
        """
        result = await self.db.execute(
            select(Venue)
            .where(Venue.id == venue_id)
            .where(Venue.owner_id == user_id)
        )
        venue = result.scalar_one_or_none()
        return venue is not None

    async def get_tier_config(self, venue_id: str) -> TierConfig:
        """
        Get tier configuration for a venue (owner only)
        Endpoint #14: GET /venues/:venueId/tier-config
        """
        # Get venue
        result = await self.db.execute(
            select(Venue).where(Venue.id == venue_id)
        )
        venue = result.scalar_one_or_none()

        if not venue:
            raise HTTPException(status_code=404, detail="Venue not found")

        # Parse tier config or use default
        if venue.tier_config:
            try:
                tier_data = json.loads(venue.tier_config)
                tiers = [TierLevel(**tier) for tier in tier_data.get("tiers", [])]
            except (json.JSONDecodeError, Exception):
                tiers = self._get_default_tiers()
        else:
            tiers = self._get_default_tiers()

        return TierConfig(
            venue_id=venue.id,
            venue_name=venue.name,
            tiers=tiers,
            points_expiration_days=180,
        )

    def _get_default_tiers(self) -> List[TierLevel]:
        """Get default tier configuration"""
        return [
            TierLevel(
                name="bronze",
                min_points=0,
                max_points=999,
                color="#CD7F32",
                benefits=["Earn 1 point per €1 spent", "Birthday reward"],
                discount_percentage=0.0,
                bonus_multiplier=1.0,
            ),
            TierLevel(
                name="silver",
                min_points=1000,
                max_points=4999,
                color="#C0C0C0",
                benefits=[
                    "Earn 1.25 points per €1 spent",
                    "5% discount on all purchases",
                    "Priority booking for events",
                    "Birthday reward",
                ],
                discount_percentage=5.0,
                bonus_multiplier=1.25,
            ),
            TierLevel(
                name="gold",
                min_points=5000,
                max_points=14999,
                color="#FFD700",
                benefits=[
                    "Earn 1.5 points per €1 spent",
                    "10% discount on all purchases",
                    "VIP event access",
                    "Free drink on birthday",
                    "Bring a friend bonus",
                ],
                discount_percentage=10.0,
                bonus_multiplier=1.5,
            ),
            TierLevel(
                name="platinum",
                min_points=15000,
                max_points=None,
                color="#E5E4E2",
                benefits=[
                    "Earn 2 points per €1 spent",
                    "15% discount on all purchases",
                    "Exclusive VIP lounge access",
                    "Complimentary bottle service (monthly)",
                    "Personal concierge",
                    "Free guest list entries",
                ],
                discount_percentage=15.0,
                bonus_multiplier=2.0,
            ),
        ]
