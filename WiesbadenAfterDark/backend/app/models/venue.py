"""
Venue model for nightlife establishments.
Includes business information, margins, and orderbird integration.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import Column, String, Boolean, DateTime, Numeric, Text, Integer
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship

from app.db.session import Base


class Venue(Base):
    """Venue model representing nightlife establishments."""

    __tablename__ = "venues"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Basic Information
    name = Column(String(255), nullable=False, index=True)
    slug = Column(String(255), unique=True, nullable=False, index=True)
    description = Column(Text)
    venue_type = Column(String(50))  # club, bar, restaurant, lounge, etc.

    # Contact Information
    email = Column(String(255))
    phone = Column(String(20))
    website = Column(String(500))
    instagram = Column(String(100))
    facebook = Column(String(100))

    # Address
    address_line1 = Column(String(255))
    address_line2 = Column(String(255))
    city = Column(String(100))
    postal_code = Column(String(20))
    country = Column(String(2), default="DE")  # ISO country code
    latitude = Column(Numeric(10, 8))
    longitude = Column(Numeric(11, 8))

    # Operating Hours (JSON: {"monday": {"open": "18:00", "close": "02:00"}, ...})
    operating_hours = Column(JSONB)

    # Media
    logo_url = Column(String(500))
    cover_image_url = Column(String(500))
    gallery_urls = Column(JSONB)  # Array of image URLs

    # Margin Configuration (for points calculation)
    # These determine how many points customers earn
    food_margin_percent = Column(Numeric(5, 2), default=30.0)  # e.g., 30%
    beverage_margin_percent = Column(Numeric(5, 2), default=60.0)  # e.g., 60%
    default_margin_percent = Column(Numeric(5, 2), default=40.0)  # e.g., 40%
    points_multiplier = Column(Numeric(5, 2), default=1.0)  # Global multiplier for venue

    # orderbird Integration
    orderbird_location_id = Column(String(100), unique=True, index=True)
    orderbird_api_key = Column(String(255))
    orderbird_enabled = Column(Boolean, default=False)
    orderbird_last_sync = Column(DateTime)

    # Features & Settings
    is_active = Column(Boolean, default=True)
    is_featured = Column(Boolean, default=False)
    accepts_reservations = Column(Boolean, default=False)
    min_age = Column(Integer, default=18)
    dress_code = Column(String(100))

    # Statistics
    total_customers = Column(Integer, default=0)
    total_revenue = Column(Numeric(12, 2), default=0)
    total_points_issued = Column(Numeric(12, 2), default=0)
    avg_rating = Column(Numeric(3, 2), default=0)
    total_reviews = Column(Integer, default=0)

    # Ownership
    owner_id = Column(UUID(as_uuid=True), index=True)  # Reference to User who owns venue

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user_points = relationship("UserPoints", back_populates="venue", cascade="all, delete-orphan")
    transactions = relationship("Transaction", back_populates="venue", cascade="all, delete-orphan")
    products = relationship("Product", back_populates="venue", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<Venue {self.name}>"

    def get_margin_for_category(self, category: str) -> float:
        """
        Get the profit margin percentage for a product category.

        Args:
            category: Product category (food, beverage, etc.)

        Returns:
            Margin percentage as a float
        """
        category_lower = category.lower()

        if "food" in category_lower:
            return float(self.food_margin_percent or self.default_margin_percent)
        elif "beverage" in category_lower or "drink" in category_lower:
            return float(self.beverage_margin_percent or self.default_margin_percent)
        else:
            return float(self.default_margin_percent)

    @property
    def is_open_now(self) -> bool:
        """Check if venue is currently open based on operating hours."""
        # TODO: Implement actual logic based on operating_hours JSON
        return self.is_active
