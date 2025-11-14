"""
WalletPass model for WiesbadenAfterDark
Tracks Apple Wallet passes for users
"""
from sqlalchemy import Column, String, DateTime, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID, JSON
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class WalletPass(Base):
    __tablename__ = "wallet_passes"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Apple Wallet Identifiers
    pass_type_identifier = Column(String(255), nullable=False)  # e.g., "pass.com.wiesbaden.loyalty"
    serial_number = Column(String(100), unique=True, nullable=False)  # Unique serial for this pass
    authentication_token = Column(String(100), nullable=False)  # For secure updates

    # Pass Data (JSON for flexibility)
    pass_data = Column(JSON, nullable=False)  # Complete pass.json structure

    # Status
    status = Column(String(20), default="active", nullable=False)  # active, revoked, expired

    # Device Registration (for push notifications)
    device_library_identifier = Column(String(100))  # Device ID that has the pass
    push_token = Column(String(100))  # For sending updates

    # Version Control
    version = Column(String(20), default="1.0", nullable=False)
    last_updated = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    expires_at = Column(DateTime(timezone=True))  # Optional expiration

    # Relationships
    user = relationship("User", back_populates="wallet_passes")

    # Constraints
    __table_args__ = (
        Index('idx_wallet_user', 'user_id'),
        Index('idx_wallet_serial', 'serial_number'),
        Index('idx_wallet_device', 'device_library_identifier'),
        Index('idx_wallet_status', 'status'),
        Index('idx_wallet_token', 'authentication_token'),
    )

    def __repr__(self):
        return f"<WalletPass user={self.user_id} serial={self.serial_number}>"
