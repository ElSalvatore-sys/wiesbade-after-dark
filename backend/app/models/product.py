"""
Product model
"""
from sqlalchemy import Column, String, DateTime, Boolean, Float, Integer, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.core.database import Base


class Product(Base):
    """Product model for items/services available at venues"""

    __tablename__ = "products"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    venue_id = Column(String, ForeignKey("venues.id"), nullable=False)

    # Product Info
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String, nullable=False)  # drink, food, service, etc.
    subcategory = Column(String, nullable=True)

    # Pricing
    price = Column(Float, nullable=False)
    currency = Column(String, default="EUR", nullable=False)

    # Points & Bonuses
    points_value = Column(Integer, default=0, nullable=False)  # Base points earned
    has_bonus = Column(Boolean, default=False, nullable=False)
    bonus_multiplier = Column(Float, nullable=True)  # e.g., 1.5 for 50% bonus
    bonus_description = Column(String, nullable=True)

    # Availability
    is_available = Column(Boolean, default=True, nullable=False)
    stock_quantity = Column(Integer, nullable=True)

    # Media
    image_url = Column(String, nullable=True)
    images = Column(String, nullable=True)  # JSON array

    # Metadata
    tags = Column(String, nullable=True)  # JSON array
    allergens = Column(String, nullable=True)  # JSON array

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    venue = relationship("Venue", back_populates="products")

    def __repr__(self):
        return f"<Product(id={self.id}, name={self.name}, category={self.category})>"
