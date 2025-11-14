"""
ReferralChain model for WiesbadenAfterDark
Tracks 5-level referral rewards when users make purchases
"""
from sqlalchemy import Column, String, Integer, DECIMAL, DateTime, ForeignKey, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class ReferralChain(Base):
    __tablename__ = "referral_chains"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    check_in_id = Column(UUID(as_uuid=True), ForeignKey("check_ins.id", ondelete="CASCADE"), nullable=False)

    # Referral Level (1-5)
    referral_level = Column(Integer, nullable=False)  # 1 = direct referral, 2-5 = indirect

    # Referrer Information
    referrer_user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Purchase Information (DECIMAL for precision)
    purchase_amount = Column(DECIMAL(10, 2), nullable=False)
    base_points_earned = Column(DECIMAL(10, 2), nullable=False)  # Points earned by the purchaser

    # Referral Reward
    reward_percentage = Column(DECIMAL(5, 2), nullable=False)  # Percentage of base points
    reward_points = Column(DECIMAL(10, 2), nullable=False)  # Actual points rewarded to referrer

    # Status
    status = Column(String(20), default="pending", nullable=False)  # pending, processed, expired

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    processed_at = Column(DateTime(timezone=True))

    # Relationships
    user = relationship("User", foreign_keys=[user_id], back_populates="referral_chains")
    referrer = relationship("User", foreign_keys=[referrer_user_id])
    check_in = relationship("CheckIn", foreign_keys=[check_in_id])

    # Constraints
    __table_args__ = (
        CheckConstraint('referral_level >= 1 AND referral_level <= 5', name='check_referral_level_range'),
        CheckConstraint('purchase_amount >= 0', name='check_purchase_amount_positive'),
        CheckConstraint('base_points_earned >= 0', name='check_base_points_positive'),
        CheckConstraint('reward_percentage >= 0 AND reward_percentage <= 100', name='check_reward_percentage_range'),
        CheckConstraint('reward_points >= 0', name='check_reward_points_positive'),
        Index('idx_referral_user', 'user_id'),
        Index('idx_referral_referrer', 'referrer_user_id'),
        Index('idx_referral_check_in', 'check_in_id'),
        Index('idx_referral_level', 'referral_level'),
        Index('idx_referral_status', 'status'),
        Index('idx_referral_date', 'created_at'),
    )

    def __repr__(self):
        return f"<ReferralChain user={self.user_id} referrer={self.referrer_user_id} level={self.referral_level}>"
