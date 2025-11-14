"""
Venue Membership model
"""
from sqlalchemy import Column, String, DateTime, Integer, ForeignKey, Float, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.core.database import Base


class VenueMembership(Base):
    """
    Tracks user membership and points at each venue
    """

    __tablename__ = "venue_memberships"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    venue_id = Column(String, ForeignKey("venues.id"), nullable=False)

    # Points & Tier
    total_points = Column(Integer, default=0, nullable=False)
    current_tier = Column(String, default="bronze", nullable=False)  # bronze, silver, gold, platinum
    tier_progress = Column(Float, default=0.0, nullable=False)  # 0.0 to 1.0

    # Activity Tracking
    total_visits = Column(Integer, default=0, nullable=False)
    total_spent = Column(Float, default=0.0, nullable=False)
    last_visit_at = Column(DateTime, nullable=True)
    last_purchase_at = Column(DateTime, nullable=True)

    # Status
    is_active = Column(Boolean, default=True, nullable=False)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    user = relationship("User", back_populates="venue_memberships")
    venue = relationship("Venue", back_populates="memberships")
    transactions = relationship("Transaction", back_populates="membership", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<VenueMembership(user_id={self.user_id}, venue_id={self.venue_id}, tier={self.current_tier}, points={self.total_points})>"
