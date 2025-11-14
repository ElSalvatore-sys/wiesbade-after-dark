"""
User model
"""
from sqlalchemy import Column, String, DateTime, Boolean, Integer, func
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.core.database import Base


class User(Base):
    """User model for storing user account information"""

    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String, unique=True, nullable=False, index=True)
    username = Column(String, unique=True, nullable=False, index=True)
    full_name = Column(String, nullable=True)
    phone_number = Column(String, nullable=True)
    date_of_birth = Column(DateTime, nullable=True)

    # Authentication
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)

    # Profile
    profile_image_url = Column(String, nullable=True)
    bio = Column(String, nullable=True)

    # Settings
    notification_preferences = Column(String, nullable=True)  # JSON string
    privacy_settings = Column(String, nullable=True)  # JSON string

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    last_login_at = Column(DateTime, nullable=True)
    last_activity_at = Column(DateTime, nullable=True)

    # Relationships
    venue_memberships = relationship("VenueMembership", back_populates="user", cascade="all, delete-orphan")
    transactions = relationship("Transaction", back_populates="user", cascade="all, delete-orphan")
    owned_venues = relationship("Venue", back_populates="owner", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<User(id={self.id}, email={self.email}, username={self.username})>"
