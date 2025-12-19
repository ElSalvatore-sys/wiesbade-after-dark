"""
EventRSVP model for WiesbadenAfterDark
Tracks user RSVPs and attendance at events
"""
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, Index, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.core.database import Base


class EventRSVP(Base):
    __tablename__ = "event_rsvps"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    event_id = Column(UUID(as_uuid=True), ForeignKey("events.id", ondelete="CASCADE"), nullable=False)

    # RSVP Status
    status = Column(String(20), default="confirmed", nullable=False)  # confirmed, cancelled, waitlist

    # Attendance Tracking
    attended = Column(Boolean, default=False, nullable=False)
    check_in_time = Column(DateTime(timezone=True))

    # Notifications
    reminder_sent = Column(Boolean, default=False, nullable=False)
    last_reminder_at = Column(DateTime(timezone=True))

    # Timestamps
    rsvp_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="event_rsvps")
    event = relationship("Event", back_populates="event_rsvps")

    # Constraints
    __table_args__ = (
        UniqueConstraint('user_id', 'event_id', name='unique_user_event_rsvp'),
        Index('idx_rsvp_user', 'user_id'),
        Index('idx_rsvp_event', 'event_id'),
        Index('idx_rsvp_status', 'status'),
        Index('idx_rsvp_attended', 'attended'),
        Index('idx_rsvp_user_event', 'user_id', 'event_id'),
    )

    def __repr__(self):
        return f"<EventRSVP user={self.user_id} event={self.event_id} status={self.status}>"
