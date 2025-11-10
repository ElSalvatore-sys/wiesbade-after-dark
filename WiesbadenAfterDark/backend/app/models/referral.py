"""
Referral models for tracking referral relationships and chains.
Supports 5-level referral system with 25% commission per level.
"""

import uuid
from datetime import datetime

from sqlalchemy import Column, String, ForeignKey, DateTime, Numeric, Integer, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.session import Base


class Referral(Base):
    """Individual referral relationship between two users."""

    __tablename__ = "referrals"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    referrer_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    referred_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)

    # Referral Details
    referral_code_used = Column(String(20), nullable=False)  # Code that was used

    # Statistics
    total_earnings = Column(Numeric(10, 2), default=0)  # Total points earned from this referral
    total_referred_purchases = Column(Integer, default=0)  # Number of purchases by referred user

    # Status
    is_active = Column(Boolean, default=True)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    first_purchase_at = Column(DateTime)  # When referred user made first purchase

    # Relationships
    referrer = relationship("User", foreign_keys=[referrer_id], back_populates="referrals_made")
    referred = relationship("User", foreign_keys=[referred_id], back_populates="referrals_received")

    def __repr__(self) -> str:
        return f"<Referral referrer={self.referrer_id} referred={self.referred_id}>"


class ReferralChain(Base):
    """
    5-level referral chain for a user.
    Stores the complete chain of referrers for efficient reward distribution.
    """

    __tablename__ = "referral_chains"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # User this chain belongs to
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)

    # 5-Level Referral Chain
    # Level 1 is the direct referrer, Level 2 referred Level 1, etc.
    level_1_referrer_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))
    level_2_referrer_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))
    level_3_referrer_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))
    level_4_referrer_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))
    level_5_referrer_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))

    # Statistics per level
    level_1_earnings = Column(Numeric(10, 2), default=0)
    level_2_earnings = Column(Numeric(10, 2), default=0)
    level_3_earnings = Column(Numeric(10, 2), default=0)
    level_4_earnings = Column(Numeric(10, 2), default=0)
    level_5_earnings = Column(Numeric(10, 2), default=0)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self) -> str:
        return f"<ReferralChain user={self.user_id}>"

    def get_chain_ids(self) -> list:
        """
        Get list of all referrer IDs in the chain.

        Returns:
            List of UUIDs from level 1 to 5 (None values excluded)
        """
        chain = [
            self.level_1_referrer_id,
            self.level_2_referrer_id,
            self.level_3_referrer_id,
            self.level_4_referrer_id,
            self.level_5_referrer_id,
        ]
        return [ref_id for ref_id in chain if ref_id is not None]

    def add_earnings(self, level: int, amount: float) -> None:
        """
        Add earnings to a specific level in the chain.

        Args:
            level: Level number (1-5)
            amount: Amount to add
        """
        if level == 1:
            self.level_1_earnings += amount
        elif level == 2:
            self.level_2_earnings += amount
        elif level == 3:
            self.level_3_earnings += amount
        elif level == 4:
            self.level_4_earnings += amount
        elif level == 5:
            self.level_5_earnings += amount

        self.updated_at = datetime.utcnow()
