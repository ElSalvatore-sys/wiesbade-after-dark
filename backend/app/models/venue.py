"""
Venue model for WiesbadenAfterDark
"""
from sqlalchemy import Column, String, Integer, Text, DECIMAL, DateTime, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class Venue(Base):
    __tablename__ = "venues"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Basic Info
    name = Column(String(200), nullable=False)
    type = Column(String(50), nullable=False)  # bar, club, restaurant, cafe
    description = Column(Text)
    image_url = Column(String(500))

    # Location
    address = Column(String(500))
    latitude = Column(DECIMAL(10, 8))
    longitude = Column(DECIMAL(11, 8))

    # Metrics
    rating = Column(DECIMAL(3, 2), default=0, nullable=False)
    member_count = Column(Integer, default=0, nullable=False)

    # Contact
    phone_number = Column(String(20))
    email = Column(String(255))
    website = Column(String(500))

    # Business Configuration (Margin percentages for points calculation)
    food_margin_percent = Column(DECIMAL(5, 2), default=30, nullable=False)
    beverage_margin_percent = Column(DECIMAL(5, 2), default=80, nullable=False)
    default_margin_percent = Column(DECIMAL(5, 2), default=50, nullable=False)

    # Points multiplier for special promotions
    points_multiplier = Column(DECIMAL(3, 2), default=1.0, nullable=False)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    venue_memberships = relationship("VenueMembership", back_populates="venue", cascade="all, delete-orphan")
    products = relationship("Product", back_populates="venue", cascade="all, delete-orphan")
    check_ins = relationship("CheckIn", back_populates="venue", cascade="all, delete-orphan")
    events = relationship("Event", back_populates="venue", cascade="all, delete-orphan")
    venue_tier_configs = relationship("VenueTierConfig", back_populates="venue", cascade="all, delete-orphan")

    # Constraints
    __table_args__ = (
        CheckConstraint('rating >= 0 AND rating <= 5', name='check_rating_range'),
        CheckConstraint('member_count >= 0', name='check_member_count_positive'),
        CheckConstraint('food_margin_percent >= 0 AND food_margin_percent <= 100', name='check_food_margin_range'),
        CheckConstraint('beverage_margin_percent >= 0 AND beverage_margin_percent <= 100', name='check_beverage_margin_range'),
        CheckConstraint('default_margin_percent >= 0 AND default_margin_percent <= 100', name='check_default_margin_range'),
        CheckConstraint('points_multiplier > 0', name='check_points_multiplier_positive'),
        Index('idx_venue_type', 'type'),
        Index('idx_venue_location', 'latitude', 'longitude'),
        Index('idx_venue_rating', 'rating'),
    )

    def __repr__(self):
        return f"<Venue {self.name} ({self.type})>"
