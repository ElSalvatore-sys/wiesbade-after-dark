"""
VenueMembership model for WiesbadenAfterDark
Tracks user membership status at specific venues with tier progression
"""
from sqlalchemy import Column, String, Integer, DECIMAL, DateTime, ForeignKey, Index, UniqueConstraint, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class VenueMembership(Base):
    __tablename__ = "venue_memberships"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    venue_id = Column(UUID(as_uuid=True), ForeignKey("venues.id", ondelete="CASCADE"), nullable=False)

    # Tier System
    current_tier = Column(String(50), default="Bronze", nullable=False)  # Bronze, Silver, Gold, Platinum, Diamond
    tier_level = Column(Integer, default=1, nullable=False)  # 1-5

    # Points (DECIMAL for precision)
    points_balance = Column(DECIMAL(10, 2), default=0, nullable=False)
    lifetime_points = Column(DECIMAL(10, 2), default=0, nullable=False)
    points_to_next_tier = Column(DECIMAL(10, 2), default=0, nullable=False)

    # Activity Metrics
    visit_count = Column(Integer, default=0, nullable=False)
    last_visit_date = Column(DateTime(timezone=True))

    # Tier Progress (percentage: 0-100)
    tier_progress_percent = Column(DECIMAL(5, 2), default=0, nullable=False)

    # Timestamps
    joined_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="venue_memberships")
    venue = relationship("Venue", back_populates="venue_memberships")

    # Constraints
    __table_args__ = (
        UniqueConstraint('user_id', 'venue_id', name='unique_user_venue_membership'),
        CheckConstraint('tier_level >= 1 AND tier_level <= 5', name='check_tier_level_range'),
        CheckConstraint('points_balance >= 0', name='check_points_balance_positive'),
        CheckConstraint('lifetime_points >= 0', name='check_lifetime_points_positive'),
        CheckConstraint('points_to_next_tier >= 0', name='check_points_to_next_tier_positive'),
        CheckConstraint('visit_count >= 0', name='check_visit_count_positive'),
        CheckConstraint('tier_progress_percent >= 0 AND tier_progress_percent <= 100', name='check_tier_progress_range'),
        Index('idx_membership_user', 'user_id'),
        Index('idx_membership_venue', 'venue_id'),
        Index('idx_membership_tier', 'current_tier'),
        Index('idx_membership_user_venue', 'user_id', 'venue_id'),
    )

    def __repr__(self):
        return f"<VenueMembership user={self.user_id} venue={self.venue_id} tier={self.current_tier}>"
