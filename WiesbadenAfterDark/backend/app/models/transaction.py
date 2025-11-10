"""
Transaction model for tracking all monetary and points transactions.
Supports purchases, point redemptions, refunds, and referral bonuses.
"""

import uuid
from datetime import datetime
from enum import Enum as PyEnum

from sqlalchemy import Column, String, ForeignKey, DateTime, Numeric, Enum, Text, Integer
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship

from app.db.session import Base


class TransactionType(str, PyEnum):
    """Types of transactions in the system."""
    PURCHASE = "purchase"  # Customer bought something with cash/card
    POINTS_REDEMPTION = "points_redemption"  # Customer used points
    REFERRAL_BONUS = "referral_bonus"  # Earned from someone's purchase
    STREAK_BONUS = "streak_bonus"  # Bonus for visit streaks
    ADMIN_ADJUSTMENT = "admin_adjustment"  # Manual adjustment by admin
    REFUND = "refund"  # Refund of a previous transaction


class TransactionStatus(str, PyEnum):
    """Status of a transaction."""
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    REFUNDED = "refunded"
    CANCELLED = "cancelled"


class Transaction(Base):
    """Transaction model for all monetary and points activity."""

    __tablename__ = "transactions"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    venue_id = Column(UUID(as_uuid=True), ForeignKey("venues.id", ondelete="CASCADE"), nullable=False, index=True)

    # Transaction Details
    transaction_type = Column(Enum(TransactionType), nullable=False, index=True)
    status = Column(Enum(TransactionStatus), default=TransactionStatus.PENDING, nullable=False)

    # Amounts
    amount_total = Column(Numeric(10, 2), nullable=False)  # Total transaction amount
    amount_cash = Column(Numeric(10, 2), default=0)  # Amount paid in cash/card
    amount_points = Column(Numeric(10, 2), default=0)  # Amount paid in points

    # Points
    points_earned = Column(Numeric(10, 2), default=0)  # Points earned from this transaction
    points_spent = Column(Numeric(10, 2), default=0)  # Points spent in this transaction
    points_multiplier = Column(Numeric(5, 2), default=1.0)  # Multiplier applied

    # Payment Information
    payment_method = Column(String(50))  # cash, card, stripe, etc.
    payment_reference = Column(String(255))  # External payment ID (e.g., Stripe charge ID)
    stripe_payment_intent_id = Column(String(255), index=True)

    # Order Details
    order_items = Column(JSONB)  # Array of {product_id, name, quantity, price, category}
    category = Column(String(50))  # Primary category (food, beverage, etc.)
    notes = Column(Text)

    # orderbird Integration
    orderbird_receipt_id = Column(String(255), index=True)
    orderbird_order_id = Column(String(255))
    orderbird_synced_at = Column(DateTime)

    # Referral Information (for REFERRAL_BONUS transactions)
    referral_level = Column(Integer)  # 1-5 for referral chain level
    original_transaction_id = Column(UUID(as_uuid=True))  # Transaction that triggered this bonus

    # Metadata
    extra_data = Column(JSONB)  # Additional flexible data

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    completed_at = Column(DateTime)
    refunded_at = Column(DateTime)

    # Relationships
    user = relationship("User", back_populates="transactions")
    venue = relationship("Venue", back_populates="transactions")

    def __repr__(self) -> str:
        return f"<Transaction {self.id} type={self.transaction_type} amount={self.amount_total}>"

    @property
    def net_points_change(self) -> float:
        """Calculate net change in points (earned - spent)."""
        return float(self.points_earned - self.points_spent)

    def mark_completed(self) -> None:
        """Mark transaction as completed."""
        self.status = TransactionStatus.COMPLETED
        self.completed_at = datetime.utcnow()

    def mark_refunded(self) -> None:
        """Mark transaction as refunded."""
        self.status = TransactionStatus.REFUNDED
        self.refunded_at = datetime.utcnow()
