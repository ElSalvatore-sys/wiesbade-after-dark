"""
Venue schemas for request/response validation
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class VenueBase(BaseModel):
    """Base venue schema"""
    name: str
    type: str
    description: Optional[str] = None
    address: str
    city: str = "Wiesbaden"
    postal_code: str
    latitude: float
    longitude: float


class VenueResponse(BaseModel):
    """Venue response schema"""
    id: str
    name: str
    type: str
    description: Optional[str] = None
    address: str
    city: str
    postal_code: str
    latitude: float
    longitude: float
    phone: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None
    logo_url: Optional[str] = None
    cover_image_url: Optional[str] = None
    opening_hours: Optional[str] = None
    is_active: bool
    is_verified: bool
    has_events: bool
    distance: Optional[float] = None  # Calculated distance in km
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class VenueList(BaseModel):
    """Venue list response for GET /venues"""
    venues: List[VenueResponse]
    total: int
    limit: int
    offset: int


class VenueDetail(BaseModel):
    """Detailed venue response for GET /venues/:venueId"""
    id: str
    name: str
    type: str
    description: Optional[str] = None
    address: str
    city: str
    postal_code: str
    latitude: float
    longitude: float
    phone: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None
    logo_url: Optional[str] = None
    cover_image_url: Optional[str] = None
    images: Optional[str] = None
    opening_hours: Optional[str] = None
    is_active: bool
    is_verified: bool
    has_events: bool
    amenities: Optional[str] = None
    tags: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ProductResponse(BaseModel):
    """Product response schema"""
    id: str
    venue_id: str
    name: str
    description: Optional[str] = None
    category: str
    subcategory: Optional[str] = None
    price: float
    currency: str
    points_value: int
    has_bonus: bool
    bonus_multiplier: Optional[float] = None
    bonus_description: Optional[str] = None
    is_available: bool
    image_url: Optional[str] = None
    tags: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class ProductList(BaseModel):
    """Product list response for GET /venues/:venueId/products"""
    products: List[ProductResponse]
    total: int


class TierLevel(BaseModel):
    """Tier level configuration"""
    name: str
    min_points: int
    max_points: Optional[int] = None
    color: str
    benefits: List[str]
    discount_percentage: Optional[float] = None
    bonus_multiplier: Optional[float] = None


class TierConfig(BaseModel):
    """Tier configuration response for GET /venues/:venueId/tier-config"""
    venue_id: str
    venue_name: str
    tiers: List[TierLevel]
    points_expiration_days: int = 180

    class Config:
        from_attributes = True
