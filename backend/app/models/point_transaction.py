"""
PointTransaction model for WiesbadenAfterDark
Tracks all point-related transactions (earn, spend, expire, adjust)
"""
from sqlalchemy import Column, String, DECIMAL, DateTime, ForeignKey, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class PointTransaction(Base):
    __tablename__ = "point_transactions"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Transaction Details
    transaction_type = Column(String(20), nullable=False)  # earn, spend, expire, adjust, referral_bonus
    points_amount = Column(DECIMAL(10, 2), nullable=False)  # Positive for earn, negative for spend

    # Balance Snapshot
    balance_before = Column(DECIMAL(10, 2), nullable=False)
    balance_after = Column(DECIMAL(10, 2), nullable=False)

    # Description
    description = Column(String(500), nullable=False)

    # Related Entities (optional references)
    related_venue_id = Column(UUID(as_uuid=True), ForeignKey("venues.id", ondelete="SET NULL"))
    related_check_in_id = Column(UUID(as_uuid=True), ForeignKey("check_ins.id", ondelete="SET NULL"))
    related_user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))  # For referrals

    # Expiration (for earned points)
    expires_at = Column(DateTime(timezone=True))  # Points expire after X days

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    # Relationships
    user = relationship("User", foreign_keys=[user_id], back_populates="point_transactions")
    related_venue = relationship("Venue", foreign_keys=[related_venue_id])
    related_check_in = relationship("CheckIn", foreign_keys=[related_check_in_id])
    related_user = relationship("User", foreign_keys=[related_user_id])

    # Constraints
    __table_args__ = (
        CheckConstraint('balance_before >= 0', name='check_balance_before_positive'),
        CheckConstraint('balance_after >= 0', name='check_balance_after_positive'),
        Index('idx_transaction_user', 'user_id'),
        Index('idx_transaction_type', 'transaction_type'),
        Index('idx_transaction_date', 'created_at'),
        Index('idx_transaction_venue', 'related_venue_id'),
        Index('idx_transaction_expiry', 'expires_at'),
        Index('idx_transaction_user_date', 'user_id', 'created_at'),
    )

    def __repr__(self):
        return f"<PointTransaction user={self.user_id} type={self.transaction_type} amount={self.points_amount}>"
