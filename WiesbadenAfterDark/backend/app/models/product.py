"""
Product model for venue inventory management.
Supports bonus point promotions to move excess inventory.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import Column, String, ForeignKey, DateTime, Numeric, Integer, Boolean, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.session import Base


class Product(Base):
    """Product/item available at a venue."""

    __tablename__ = "products"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Key
    venue_id = Column(UUID(as_uuid=True), ForeignKey("venues.id", ondelete="CASCADE"), nullable=False, index=True)

    # Basic Information
    name = Column(String(255), nullable=False)
    description = Column(Text)
    category = Column(String(100), nullable=False, index=True)  # food, beverage, cocktail, beer, wine, etc.
    sku = Column(String(100))  # Stock Keeping Unit

    # Pricing
    price = Column(Numeric(10, 2), nullable=False)  # Selling price
    cost = Column(Numeric(10, 2))  # Cost to venue
    margin_percent = Column(Numeric(5, 2))  # Profit margin percentage

    # Inventory
    stock_quantity = Column(Integer, default=0)
    low_stock_threshold = Column(Integer, default=10)
    is_available = Column(Boolean, default=True)

    # Bonus Points Promotion (KEY FEATURE!)
    bonus_points_active = Column(Boolean, default=False)
    bonus_multiplier = Column(Numeric(5, 2), default=1.0)  # e.g., 2.0 for double points
    bonus_start_date = Column(DateTime)
    bonus_end_date = Column(DateTime)
    bonus_reason = Column(String(255))  # e.g., "Excess inventory", "Happy hour"

    # Media
    image_url = Column(String(500))

    # orderbird Integration
    orderbird_product_id = Column(String(255), index=True)
    orderbird_last_sync = Column(DateTime)

    # Statistics
    total_sold = Column(Integer, default=0)
    total_revenue = Column(Numeric(12, 2), default=0)

    # Status
    is_featured = Column(Boolean, default=False)
    sort_order = Column(Integer, default=0)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    venue = relationship("Venue", back_populates="products")

    def __repr__(self) -> str:
        return f"<Product {self.name} at venue={self.venue_id}>"

    @property
    def effective_points_multiplier(self) -> float:
        """
        Get the effective points multiplier including active bonuses.

        Returns:
            Multiplier to apply when calculating points
        """
        if self.is_bonus_active:
            return float(self.bonus_multiplier)
        return 1.0

    @property
    def is_bonus_active(self) -> bool:
        """
        Check if bonus promotion is currently active.

        Returns:
            True if bonus is active, False otherwise
        """
        if not self.bonus_points_active:
            return False

        now = datetime.utcnow()

        # Check date range
        if self.bonus_start_date and now < self.bonus_start_date:
            return False

        if self.bonus_end_date and now > self.bonus_end_date:
            return False

        return True

    @property
    def is_low_stock(self) -> bool:
        """Check if product is low on stock."""
        return self.stock_quantity <= self.low_stock_threshold

    @property
    def margin_amount(self) -> float:
        """Calculate profit margin in currency."""
        if self.cost:
            return float(self.price - self.cost)
        return 0.0

    def activate_bonus(
        self,
        multiplier: float,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        reason: Optional[str] = None
    ) -> None:
        """
        Activate bonus points promotion for this product.

        Args:
            multiplier: Points multiplier (e.g., 2.0 for double points)
            start_date: When bonus starts (None for immediate)
            end_date: When bonus ends (None for indefinite)
            reason: Reason for bonus (optional)
        """
        self.bonus_points_active = True
        self.bonus_multiplier = multiplier
        self.bonus_start_date = start_date or datetime.utcnow()
        self.bonus_end_date = end_date
        self.bonus_reason = reason
        self.updated_at = datetime.utcnow()

    def deactivate_bonus(self) -> None:
        """Deactivate bonus points promotion."""
        self.bonus_points_active = False
        self.updated_at = datetime.utcnow()
