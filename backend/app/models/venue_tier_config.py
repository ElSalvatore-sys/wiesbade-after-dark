"""
VenueTierConfig model for WiesbadenAfterDark
Configures tier thresholds and benefits for each venue
"""
from sqlalchemy import Column, String, Integer, Text, DECIMAL, DateTime, ForeignKey, Index, UniqueConstraint, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSON
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime

from app.models.base import Base


class VenueTierConfig(Base):
    __tablename__ = "venue_tier_configs"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    venue_id = Column(UUID(as_uuid=True), ForeignKey("venues.id", ondelete="CASCADE"), nullable=False)

    # Tier Information
    tier_name = Column(String(50), nullable=False)  # Bronze, Silver, Gold, Platinum, Diamond
    tier_level = Column(Integer, nullable=False)  # 1-5

    # Tier Requirements (DECIMAL for precision)
    points_required = Column(DECIMAL(10, 2), nullable=False)  # Lifetime points needed
    visits_required = Column(Integer, default=0, nullable=False)  # Minimum visits needed

    # Benefits
    points_multiplier = Column(DECIMAL(3, 2), default=1.0, nullable=False)  # Extra points (1.0 = no bonus, 1.5 = +50%)
    discount_percent = Column(DECIMAL(5, 2), default=0, nullable=False)  # Percentage discount on purchases

    # Perks (JSON for flexibility)
    perks = Column(JSON)  # Array of perks: ["Free drink on birthday", "Priority seating", etc.]

    # Visual
    tier_color = Column(String(50))  # Hex color or color name
    tier_icon = Column(String(100))  # Icon name or URL
    description = Column(Text)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    venue = relationship("Venue", back_populates="venue_tier_configs")

    # Constraints
    __table_args__ = (
        UniqueConstraint('venue_id', 'tier_level', name='unique_venue_tier_level'),
        UniqueConstraint('venue_id', 'tier_name', name='unique_venue_tier_name'),
        CheckConstraint('tier_level >= 1 AND tier_level <= 5', name='check_tier_level_range'),
        CheckConstraint('points_required >= 0', name='check_points_required_positive'),
        CheckConstraint('visits_required >= 0', name='check_visits_required_positive'),
        CheckConstraint('points_multiplier >= 1.0', name='check_points_multiplier_min'),
        CheckConstraint('discount_percent >= 0 AND discount_percent <= 100', name='check_discount_range'),
        Index('idx_tier_config_venue', 'venue_id'),
        Index('idx_tier_config_level', 'tier_level'),
        Index('idx_tier_config_venue_level', 'venue_id', 'tier_level'),
    )

    def __repr__(self):
        return f"<VenueTierConfig venue={self.venue_id} tier={self.tier_name} level={self.tier_level}>"
