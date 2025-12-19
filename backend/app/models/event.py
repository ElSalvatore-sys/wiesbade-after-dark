"""
Event model for WiesbadenAfterDark
Tracks events hosted at venues
"""
from sqlalchemy import Column, String, Integer, Boolean, Text, DECIMAL, DateTime, ForeignKey, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.core.database import Base


class Event(Base):
    __tablename__ = "events"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    venue_id = Column(UUID(as_uuid=True), ForeignKey("venues.id", ondelete="CASCADE"), nullable=False)

    # Basic Info
    title = Column(String(200), nullable=False)
    description = Column(Text)
    event_type = Column(String(50), nullable=False)  # concert, party, special_offer, etc.
    image_url = Column(String(500))

    # Date & Time
    start_time = Column(DateTime(timezone=True), nullable=False)
    end_time = Column(DateTime(timezone=True), nullable=False)

    # Capacity & Attendance
    max_capacity = Column(Integer)
    current_rsvp_count = Column(Integer, default=0, nullable=False)

    # Pricing
    ticket_price = Column(DECIMAL(10, 2), default=0, nullable=False)
    is_free = Column(Boolean, default=True, nullable=False)

    # Points & Rewards
    attendance_points = Column(DECIMAL(10, 2), default=0, nullable=False)  # Points for attending
    bonus_points_multiplier = Column(DECIMAL(3, 2), default=1.0, nullable=False)  # Bonus for purchases during event

    # Status
    status = Column(String(20), default="upcoming", nullable=False)  # upcoming, ongoing, completed, cancelled
    is_featured = Column(Boolean, default=False, nullable=False)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    venue = relationship("Venue", back_populates="events")
    event_rsvps = relationship("EventRSVP", back_populates="event", cascade="all, delete-orphan")

    # Constraints
    __table_args__ = (
        CheckConstraint('end_time > start_time', name='check_event_time_valid'),
        CheckConstraint('max_capacity > 0', name='check_max_capacity_positive'),
        CheckConstraint('current_rsvp_count >= 0', name='check_rsvp_count_positive'),
        CheckConstraint('ticket_price >= 0', name='check_ticket_price_positive'),
        CheckConstraint('attendance_points >= 0', name='check_attendance_points_positive'),
        CheckConstraint('bonus_points_multiplier > 0', name='check_bonus_multiplier_positive'),
        Index('idx_event_venue', 'venue_id'),
        Index('idx_event_type', 'event_type'),
        Index('idx_event_start_time', 'start_time'),
        Index('idx_event_status', 'status'),
        Index('idx_event_featured', 'is_featured'),
        Index('idx_event_venue_date', 'venue_id', 'start_time'),
    )

    def __repr__(self):
        return f"<Event {self.title} at venue={self.venue_id}>"
