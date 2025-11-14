"""
Badge models for WiesbadenAfterDark
Includes Badge (achievement definitions) and UserBadge (user ownership)
"""
from sqlalchemy import Column, String, Integer, Text, Boolean, DateTime, ForeignKey, Index, UniqueConstraint, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class Badge(Base):
    """Achievement badges that users can earn"""
    __tablename__ = "badges"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Badge Info
    name = Column(String(100), unique=True, nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String(50), nullable=False)  # achievement, milestone, social, venue_specific

    # Requirements (for automatic awarding)
    requirement_type = Column(String(50))  # check_ins, points_earned, referrals, events_attended, etc.
    requirement_value = Column(Integer)  # Number needed to earn
    venue_specific = Column(Boolean, default=False, nullable=False)

    # Visual
    icon_url = Column(String(500))
    color = Column(String(50))  # Hex color or color name
    rarity = Column(String(20), default="common", nullable=False)  # common, rare, epic, legendary

    # Status
    is_active = Column(Boolean, default=True, nullable=False)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user_badges = relationship("UserBadge", back_populates="badge", cascade="all, delete-orphan")

    # Constraints
    __table_args__ = (
        CheckConstraint('requirement_value >= 0', name='check_requirement_value_positive'),
        Index('idx_badge_category', 'category'),
        Index('idx_badge_rarity', 'rarity'),
        Index('idx_badge_active', 'is_active'),
        Index('idx_badge_venue_specific', 'venue_specific'),
    )

    def __repr__(self):
        return f"<Badge {self.name} ({self.category})>"


class UserBadge(Base):
    """Tracks which badges users have earned"""
    __tablename__ = "user_badges"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    badge_id = Column(UUID(as_uuid=True), ForeignKey("badges.id", ondelete="CASCADE"), nullable=False)

    # Earning Context
    earned_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    progress = Column(Integer, default=100, nullable=False)  # 0-100, usually 100 when earned

    # Notification
    notified = Column(Boolean, default=False, nullable=False)

    # Relationships
    user = relationship("User", back_populates="user_badges")
    badge = relationship("Badge", back_populates="user_badges")

    # Constraints
    __table_args__ = (
        UniqueConstraint('user_id', 'badge_id', name='unique_user_badge'),
        CheckConstraint('progress >= 0 AND progress <= 100', name='check_progress_range'),
        Index('idx_user_badge_user', 'user_id'),
        Index('idx_user_badge_badge', 'badge_id'),
        Index('idx_user_badge_earned', 'earned_at'),
        Index('idx_user_badge_user_badge', 'user_id', 'badge_id'),
    )

    def __repr__(self):
        return f"<UserBadge user={self.user_id} badge={self.badge_id}>"
