"""
Pydantic schemas for Venue-related API requests and responses.
"""

from datetime import datetime
from typing import Optional, Dict
from uuid import UUID
from decimal import Decimal

from pydantic import BaseModel, Field


class VenueResponse(BaseModel):
    """Complete venue response schema with all details."""

    id: UUID
    name: str
    slug: str
    venue_type: Optional[str] = None
    description: Optional[str] = None

    # Contact Information
    address: str
    city: str
    postal_code: str
    latitude: Optional[Decimal] = None
    longitude: Optional[Decimal] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None
    instagram_handle: Optional[str] = None

    # Operating Information
    operating_hours: Optional[Dict] = None

    # Pricing & Margins
    default_margin_percent: Decimal = Field(default=Decimal("50.0"))
    food_margin_percent: Optional[Decimal] = None
    beverage_margin_percent: Optional[Decimal] = None

    # Branding
    logo_url: Optional[str] = None
    cover_image_url: Optional[str] = None
    primary_color: Optional[str] = None

    # Status
    is_active: bool = True
    is_featured: bool = False

    # Integration IDs
    orderbird_location_id: Optional[str] = None
    stripe_account_id: Optional[str] = None

    # Timestamps
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True,
    }


class VenueListItem(BaseModel):
    """Simplified venue schema for list views with optional distance."""

    id: UUID
    name: str
    slug: str
    venue_type: Optional[str] = None
    description: Optional[str] = None
    address: str
    city: str
    postal_code: str
    latitude: Optional[Decimal] = None
    longitude: Optional[Decimal] = None
    phone: Optional[str] = None
    website: Optional[str] = None
    instagram_handle: Optional[str] = None
    is_featured: bool = False
    logo_url: Optional[str] = None
    cover_image_url: Optional[str] = None
    distance_km: Optional[float] = Field(
        None,
        description="Distance from user's location in kilometers (only set when location provided)"
    )

    model_config = {
        "from_attributes": True,
    }


class UserPointsAtVenue(BaseModel):
    """User's points data at a specific venue."""

    points_earned: Decimal
    points_spent: Decimal
    points_available: Decimal
    current_streak: int
    longest_streak: int
    total_visits: int
    last_visit_date: Optional[datetime] = None


class VenueWithUserPoints(VenueResponse):
    """Venue response with user's points data (if authenticated)."""

    user_points: Optional[UserPointsAtVenue] = Field(
        None,
        description="User's points and activity at this venue (only present if authenticated)"
    )
