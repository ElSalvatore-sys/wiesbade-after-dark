"""
User model for WiesbadenAfterDark
"""
from sqlalchemy import Column, String, Integer, Date, DECIMAL, DateTime, ForeignKey, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class User(Base):
    __tablename__ = "users"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Authentication
    phone_number = Column(String(20), unique=True, nullable=False, index=True)

    # Basic Info
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, index=True)
    date_of_birth = Column(Date)
    profile_image_url = Column(String(500))

    # Points System (DECIMAL for financial precision)
    total_points_earned = Column(DECIMAL(10, 2), default=0, nullable=False)
    total_points_spent = Column(DECIMAL(10, 2), default=0, nullable=False)
    total_points_available = Column(DECIMAL(10, 2), default=0, nullable=False)

    # Referral System
    total_referrals = Column(Integer, default=0, nullable=False)
    referral_code = Column(String(10), unique=True, nullable=False, index=True)
    referred_by = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    referrer = relationship("User", remote_side=[id], backref="referrals")
    venue_memberships = relationship("VenueMembership", back_populates="user", cascade="all, delete-orphan")
    check_ins = relationship("CheckIn", back_populates="user", cascade="all, delete-orphan")
    point_transactions = relationship("PointTransaction", back_populates="user", cascade="all, delete-orphan")
    referral_chains = relationship("ReferralChain", back_populates="user", cascade="all, delete-orphan")
    event_rsvps = relationship("EventRSVP", back_populates="user", cascade="all, delete-orphan")
    wallet_passes = relationship("WalletPass", back_populates="user", cascade="all, delete-orphan")
    user_badges = relationship("UserBadge", back_populates="user", cascade="all, delete-orphan")

    # Constraints
    __table_args__ = (
        CheckConstraint('total_points_earned >= 0', name='check_points_earned_positive'),
        CheckConstraint('total_points_spent >= 0', name='check_points_spent_positive'),
        CheckConstraint('total_points_available >= 0', name='check_points_available_positive'),
        CheckConstraint('total_referrals >= 0', name='check_referrals_positive'),
        Index('idx_user_phone', 'phone_number'),
        Index('idx_user_email', 'email'),
        Index('idx_user_referral_code', 'referral_code'),
        Index('idx_user_referred_by', 'referred_by'),
    )

    def __repr__(self):
        return f"<User {self.first_name} {self.last_name} ({self.phone_number})>"
