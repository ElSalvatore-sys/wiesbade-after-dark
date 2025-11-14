"""
Transaction model
"""
from sqlalchemy import Column, String, DateTime, Integer, Float, ForeignKey, Text, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime, timedelta
import uuid

from app.core.database import Base


class Transaction(Base):
    """
    Transaction model for tracking points, purchases, and redemptions
    """

    __tablename__ = "transactions"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    venue_id = Column(String, ForeignKey("venues.id"), nullable=False)
    membership_id = Column(String, ForeignKey("venue_memberships.id"), nullable=False)

    # Transaction Type
    type = Column(String, nullable=False)  # purchase, redemption, bonus, adjustment

    # Points
    points_earned = Column(Integer, default=0, nullable=False)
    points_redeemed = Column(Integer, default=0, nullable=False)
    points_balance_after = Column(Integer, nullable=False)

    # Purchase Details
    amount = Column(Float, nullable=True)  # Purchase amount in currency
    currency = Column(String, default="EUR", nullable=True)
    products = Column(String, nullable=True)  # JSON array of product IDs

    # Expiration
    points_expire_at = Column(DateTime, nullable=True)
    is_expired = Column(Boolean, default=False, nullable=False)

    # Metadata
    description = Column(Text, nullable=True)
    metadata = Column(String, nullable=True)  # JSON for additional data

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    user = relationship("User", back_populates="transactions")
    membership = relationship("VenueMembership", back_populates="transactions")

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Set expiration date to 180 days from creation if not provided
        if self.points_earned > 0 and not self.points_expire_at:
            self.points_expire_at = datetime.utcnow() + timedelta(days=180)

    def __repr__(self):
        return f"<Transaction(id={self.id}, type={self.type}, points_earned={self.points_earned}, points_redeemed={self.points_redeemed})>"
