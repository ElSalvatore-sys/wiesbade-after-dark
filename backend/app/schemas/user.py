"""
User schemas for request/response validation
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime


class UserBase(BaseModel):
    """Base user schema"""
    email: EmailStr
    username: str
    full_name: Optional[str] = None
    phone_number: Optional[str] = None


class UserResponse(BaseModel):
    """User response schema for GET /users/:userId"""
    id: str
    email: str
    username: str
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    date_of_birth: Optional[datetime] = None
    profile_image_url: Optional[str] = None
    bio: Optional[str] = None
    is_active: bool
    is_verified: bool
    created_at: datetime
    updated_at: datetime
    last_login_at: Optional[datetime] = None
    last_activity_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    """User update schema for PUT /users/:userId"""
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    date_of_birth: Optional[datetime] = None
    profile_image_url: Optional[str] = None
    bio: Optional[str] = None
    notification_preferences: Optional[str] = None
    privacy_settings: Optional[str] = None


class VenuePointsBreakdown(BaseModel):
    """Points breakdown per venue"""
    venue_id: str
    venue_name: str
    venue_logo_url: Optional[str] = None
    total_points: int
    current_tier: str
    tier_progress: float
    last_visit_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class PointsSummary(BaseModel):
    """Points summary response for GET /users/:userId/points"""
    user_id: str
    total_points_all_venues: int
    total_venues: int
    venues: List[VenuePointsBreakdown]

    class Config:
        from_attributes = True


class ExpiringPointsDetail(BaseModel):
    """Expiring points detail for a single transaction"""
    transaction_id: str
    venue_id: str
    venue_name: str
    points: int
    expires_at: datetime
    days_until_expiry: int

    class Config:
        from_attributes = True


class ExpiringPoints(BaseModel):
    """Expiring points response for GET /users/:userId/expiring-points"""
    user_id: str
    total_expiring_points: int
    days_ahead: int
    expiring_transactions: List[ExpiringPointsDetail]

    class Config:
        from_attributes = True


class ActivityUpdate(BaseModel):
    """Activity update schema for PUT /users/:userId/activity"""
    venue_id: str
    activity_type: str = Field(..., description="Type of activity: visit, purchase, check-in")


class ActivityUpdateResponse(BaseModel):
    """Activity update response"""
    success: bool
    message: str
    last_activity_at: datetime
    venue_last_visit_at: Optional[datetime] = None
