"""
Verification Code model for phone number verification.
Stores SMS verification codes with expiration.
"""

import uuid
from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy import Column, String, Boolean, DateTime, Integer
from sqlalchemy.dialects.postgresql import UUID

from app.db.session import Base


class VerificationCode(Base):
    """Model for storing phone verification codes."""

    __tablename__ = "verification_codes"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Phone number (E.164 format)
    phone_number = Column(String(20), nullable=False, index=True)

    # Verification code (6 digits)
    code = Column(String(6), nullable=False)

    # Status
    is_used = Column(Boolean, default=False)

    # Expiration (5 minutes from creation)
    expires_at = Column(DateTime, nullable=False)

    # Attempt tracking
    attempts = Column(Integer, default=0)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    used_at = Column(DateTime, nullable=True)

    def __repr__(self) -> str:
        return f"<VerificationCode {self.phone_number}>"

    @property
    def is_expired(self) -> bool:
        """Check if verification code has expired."""
        return datetime.utcnow() > self.expires_at

    @property
    def is_valid(self) -> bool:
        """Check if verification code is valid (not used and not expired)."""
        return not self.is_used and not self.is_expired

    @staticmethod
    def create_expiration_time() -> datetime:
        """Create expiration timestamp (5 minutes from now)."""
        return datetime.utcnow() + timedelta(minutes=5)
