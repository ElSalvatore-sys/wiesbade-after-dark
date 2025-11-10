"""
User model for authentication and user management.
Tracks user profile, points, referrals, and authentication details.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import Column, String, Boolean, DateTime, Integer, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.session import Base


class User(Base):
    """User model with authentication and loyalty program features."""

    __tablename__ = "users"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Authentication
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=True)  # Optional for social auth
    is_verified = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)

    # Profile
    first_name = Column(String(100))
    last_name = Column(String(100))
    phone = Column(String(20))
    avatar_url = Column(String(500))
    date_of_birth = Column(DateTime)

    # Points Summary (aggregated from UserPoints)
    total_points_earned = Column(Numeric(10, 2), default=0)
    total_points_spent = Column(Numeric(10, 2), default=0)
    total_points_available = Column(Numeric(10, 2), default=0)

    # Referral System
    referral_code = Column(String(20), unique=True, nullable=False, index=True)
    referred_by_code = Column(String(20), index=True)  # Who referred this user
    total_referrals = Column(Integer, default=0)  # Count of users they referred
    total_referral_earnings = Column(Numeric(10, 2), default=0)  # Points earned from referrals

    # Push Notifications
    fcm_token = Column(String(255))  # Firebase Cloud Messaging token

    # Preferences
    preferred_language = Column(String(5), default="de")  # de, en
    notification_preferences = Column(Text)  # JSON string of notification settings

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login_at = Column(DateTime)
    email_verified_at = Column(DateTime)

    # Relationships
    user_points = relationship("UserPoints", back_populates="user", cascade="all, delete-orphan")
    transactions = relationship("Transaction", back_populates="user", cascade="all, delete-orphan")
    referrals_made = relationship(
        "Referral",
        foreign_keys="Referral.referrer_id",
        back_populates="referrer",
        cascade="all, delete-orphan"
    )
    referrals_received = relationship(
        "Referral",
        foreign_keys="Referral.referred_id",
        back_populates="referred",
        cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<User {self.email}>"

    @property
    def full_name(self) -> str:
        """Get user's full name."""
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.email

    @property
    def points_available(self) -> float:
        """Calculate total available points across all venues."""
        return float(self.total_points_available or 0)
