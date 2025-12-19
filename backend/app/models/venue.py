"""
Venue model
"""
from sqlalchemy import Column, String, DateTime, Boolean, Float, Integer, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.core.database import Base


class Venue(Base):
    """Venue model for bars, clubs, and other establishments"""

    __tablename__ = "venues"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False, index=True)
    type = Column(String, nullable=False)  # bar, club, restaurant, etc.
    description = Column(Text, nullable=True)

    # Owner
    owner_id = Column(String, ForeignKey("users.id"), nullable=False)

    # Location
    address = Column(String, nullable=False)
    city = Column(String, nullable=False, default="Wiesbaden")
    postal_code = Column(String, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)

    # Contact
    phone = Column(String, nullable=True)
    email = Column(String, nullable=True)
    website = Column(String, nullable=True)

    # Media
    logo_url = Column(String, nullable=True)
    cover_image_url = Column(String, nullable=True)
    images = Column(String, nullable=True)  # JSON array of image URLs

    # Hours & Status
    opening_hours = Column(String, nullable=True)  # JSON string
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)

    # Features
    has_events = Column(Boolean, default=False, nullable=False)
    amenities = Column(String, nullable=True)  # JSON array
    tags = Column(String, nullable=True)  # JSON array

    # Tier Configuration
    tier_config = Column(String, nullable=True)  # JSON configuration for tiers

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    owner = relationship("User", back_populates="owned_venues")
    products = relationship("Product", back_populates="venue", cascade="all, delete-orphan")
    memberships = relationship("VenueMembership", back_populates="venue", cascade="all, delete-orphan")
    special_offers = relationship("SpecialOffer", back_populates="venue", cascade="all, delete-orphan")
    events = relationship("Event", back_populates="venue", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Venue(id={self.id}, name={self.name}, type={self.type})>"
