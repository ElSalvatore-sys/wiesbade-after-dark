"""
Product model for WiesbadenAfterDark
Tracks products/items available at venues with pricing and bonus points
"""
from sqlalchemy import Column, String, Integer, Boolean, DECIMAL, DateTime, ForeignKey, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class Product(Base):
    __tablename__ = "products"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    venue_id = Column(UUID(as_uuid=True), ForeignKey("venues.id", ondelete="CASCADE"), nullable=False)

    # Basic Info
    name = Column(String(200), nullable=False)
    category = Column(String(50), nullable=False)  # beverages, food, merchandise, etc.
    description = Column(String(500))
    image_url = Column(String(500))

    # Pricing (DECIMAL for financial precision)
    price = Column(DECIMAL(10, 2), nullable=False)
    cost = Column(DECIMAL(10, 2))  # For margin calculation
    margin_percent = Column(DECIMAL(5, 2))  # Calculated: (price - cost) / price * 100

    # Inventory
    stock_quantity = Column(Integer, default=0, nullable=False)
    is_available = Column(Boolean, default=True, nullable=False)

    # Bonus Points System
    bonus_points_active = Column(Boolean, default=False, nullable=False)
    bonus_multiplier = Column(DECIMAL(3, 2), default=1.0, nullable=False)  # 1.0 = 1x, 2.0 = 2x, etc.
    bonus_description = Column(String(200))
    bonus_start_date = Column(DateTime(timezone=True))
    bonus_end_date = Column(DateTime(timezone=True))

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    venue = relationship("Venue", back_populates="products")

    # Constraints
    __table_args__ = (
        CheckConstraint('price >= 0', name='check_price_positive'),
        CheckConstraint('cost >= 0', name='check_cost_positive'),
        CheckConstraint('margin_percent >= 0 AND margin_percent <= 100', name='check_margin_range'),
        CheckConstraint('stock_quantity >= 0', name='check_stock_positive'),
        CheckConstraint('bonus_multiplier > 0', name='check_bonus_multiplier_positive'),
        Index('idx_product_venue', 'venue_id'),
        Index('idx_product_category', 'category'),
        Index('idx_product_bonus_active', 'bonus_points_active'),
        Index('idx_product_available', 'is_available'),
        Index('idx_product_venue_category', 'venue_id', 'category'),
    )

    def __repr__(self):
        return f"<Product {self.name} at venue={self.venue_id}>"
