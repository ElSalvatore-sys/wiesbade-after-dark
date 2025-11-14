"""
Special Offer model
"""
from sqlalchemy import Column, String, DateTime, Boolean, Integer, ForeignKey, Text, Float
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.core.database import Base


class SpecialOffer(Base):
    """
    Special offers and promotions at venues
    """

    __tablename__ = "special_offers"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    venue_id = Column(String, ForeignKey("venues.id"), nullable=False)

    # Offer Details
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    type = Column(String, nullable=False)  # happy_hour, event, promotion, etc.

    # Points & Rewards
    points_required = Column(Integer, nullable=True)
    discount_percentage = Column(Float, nullable=True)
    bonus_multiplier = Column(Float, nullable=True)

    # Validity
    valid_from = Column(DateTime, nullable=False)
    valid_until = Column(DateTime, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)

    # Restrictions
    min_tier = Column(String, nullable=True)  # Minimum tier required
    max_redemptions = Column(Integer, nullable=True)
    current_redemptions = Column(Integer, default=0, nullable=False)

    # Media
    image_url = Column(String, nullable=True)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    venue = relationship("Venue", back_populates="special_offers")

    def __repr__(self):
        return f"<SpecialOffer(id={self.id}, title={self.title}, venue_id={self.venue_id})>"
