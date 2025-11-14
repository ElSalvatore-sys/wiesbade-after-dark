"""
CheckIn model for WiesbadenAfterDark
Tracks user check-ins at venues with purchase details
"""
from sqlalchemy import Column, String, DECIMAL, DateTime, ForeignKey, Index, CheckConstraint, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class CheckIn(Base):
    __tablename__ = "check_ins"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    venue_id = Column(UUID(as_uuid=True), ForeignKey("venues.id", ondelete="CASCADE"), nullable=False)

    # Purchase Information (DECIMAL for financial precision)
    purchase_amount = Column(DECIMAL(10, 2), nullable=False)
    margin_percent = Column(DECIMAL(5, 2), nullable=False)  # Margin used for points calculation

    # Points Earned (DECIMAL for precision)
    base_points = Column(DECIMAL(10, 2), nullable=False)  # purchase_amount * margin_percent / 100
    tier_bonus = Column(DECIMAL(10, 2), default=0, nullable=False)
    product_bonus = Column(DECIMAL(10, 2), default=0, nullable=False)
    venue_multiplier_bonus = Column(DECIMAL(10, 2), default=0, nullable=False)
    total_points_earned = Column(DECIMAL(10, 2), nullable=False)

    # Purchase Details (JSON for flexibility)
    items_purchased = Column(JSON)  # Array of {product_id, name, quantity, price, points}

    # Receipt/Verification
    receipt_number = Column(String(100))
    verification_code = Column(String(50))
    verified = Column(String(20), default="pending", nullable=False)  # pending, approved, rejected

    # Location (optional - for verification)
    check_in_latitude = Column(DECIMAL(10, 8))
    check_in_longitude = Column(DECIMAL(11, 8))

    # Timestamps
    checked_in_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    # Relationships
    user = relationship("User", back_populates="check_ins")
    venue = relationship("Venue", back_populates="check_ins")

    # Constraints
    __table_args__ = (
        CheckConstraint('purchase_amount >= 0', name='check_purchase_amount_positive'),
        CheckConstraint('margin_percent >= 0 AND margin_percent <= 100', name='check_margin_percent_range'),
        CheckConstraint('base_points >= 0', name='check_base_points_positive'),
        CheckConstraint('tier_bonus >= 0', name='check_tier_bonus_positive'),
        CheckConstraint('product_bonus >= 0', name='check_product_bonus_positive'),
        CheckConstraint('venue_multiplier_bonus >= 0', name='check_venue_multiplier_bonus_positive'),
        CheckConstraint('total_points_earned >= 0', name='check_total_points_positive'),
        Index('idx_checkin_user', 'user_id'),
        Index('idx_checkin_venue', 'venue_id'),
        Index('idx_checkin_user_venue', 'user_id', 'venue_id'),
        Index('idx_checkin_date', 'checked_in_at'),
        Index('idx_checkin_verified', 'verified'),
    )

    def __repr__(self):
        return f"<CheckIn user={self.user_id} venue={self.venue_id} amount={self.purchase_amount}>"
