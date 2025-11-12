"""
Pydantic schemas for User-related API requests and responses.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field, validator


# Request Schemas

class UserRegister(BaseModel):
    """Schema for user registration."""
    email: EmailStr
    password: str = Field(..., min_length=8)
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    referred_by_code: Optional[str] = None

    @validator('password')
    def validate_password(cls, v):
        """Ensure password meets requirements."""
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v


class UserLogin(BaseModel):
    """Schema for user login."""
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    """Schema for updating user profile."""
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    birth_date: Optional[datetime] = None


class TokenRefresh(BaseModel):
    """Schema for refreshing access token."""
    refresh_token: str


class EmailVerification(BaseModel):
    """Schema for email verification request."""
    email: EmailStr


class CodeVerification(BaseModel):
    """Schema for verifying code."""
    email: EmailStr
    code: str = Field(..., min_length=6, max_length=6)


class ForgotPassword(BaseModel):
    """Schema for forgot password request."""
    email: EmailStr


class ResetPassword(BaseModel):
    """Schema for resetting password."""
    token: str
    new_password: str = Field(..., min_length=8)


class FCMTokenUpdate(BaseModel):
    """Schema for updating FCM token."""
    fcm_token: str


# Response Schemas

class UserResponse(BaseModel):
    """Schema for user data in responses."""
    id: UUID
    email: Optional[str] = None  # Optional for phone-only auth
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None  # Changed from 'phone' to match model
    phone_country_code: Optional[str] = None
    phone_verified: bool = False
    avatar_url: Optional[str] = None
    referral_code: str
    referred_by_code: Optional[str] = None
    total_referrals: int
    total_points_earned: float
    total_points_spent: float
    total_points_available: float
    is_verified: bool
    is_active: bool
    created_at: datetime
    last_login_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    """Schema for authentication token response."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int  # seconds
    user: Optional[UserResponse] = None  # Optional for phone verification before registration


class VenuePointsDetail(BaseModel):
    """Schema for points at a specific venue."""
    venue_id: UUID
    venue_name: str
    venue_slug: str
    points_available: float
    points_earned: float
    points_spent: float
    current_streak: int
    longest_streak: int
    total_visits: int
    last_visit_date: Optional[datetime]


class UserPointsSummary(BaseModel):
    """Schema for user's points summary across venues."""
    total_points_available: float
    total_points_earned: float
    total_points_spent: float
    venues: list[VenuePointsDetail]


class ReferredUser(BaseModel):
    """Schema for a user who was referred."""
    id: UUID
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None  # Optional for phone-only users
    phone_number: Optional[str] = None
    referred_at: datetime
    is_active: bool


class ReferralStats(BaseModel):
    """Schema for user's referral statistics."""
    total_referrals: int
    referral_code: str
    referred_users: list[ReferredUser]
    total_referral_points_earned: float
