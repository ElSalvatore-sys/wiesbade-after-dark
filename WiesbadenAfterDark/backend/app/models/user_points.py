"""
UserPoints model - CRITICAL for German tax compliance.
Tracks venue-specific point balances. Points cannot be transferred between venues.
"""

import uuid
from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy import Column, ForeignKey, DateTime, Numeric, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.session import Base


class UserPoints(Base):
    """
    Venue-specific point balance for a user.
    CRITICAL: Points earned at one venue can ONLY be spent at that venue.
    This ensures German tax compliance.
    """

    __tablename__ = "user_points"

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign Keys
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    venue_id = Column(UUID(as_uuid=True), ForeignKey("venues.id", ondelete="CASCADE"), nullable=False)

    # Point Balances
    points_earned = Column(Numeric(10, 2), default=0, nullable=False)
    points_spent = Column(Numeric(10, 2), default=0, nullable=False)
    points_available = Column(Numeric(10, 2), default=0, nullable=False)

    # Visit Streak Tracking
    current_streak = Column(Integer, default=0)  # Consecutive days visited
    longest_streak = Column(Integer, default=0)  # Historical best streak
    last_visit_date = Column(DateTime)
    total_visits = Column(Integer, default=0)

    # Statistics
    total_spent = Column(Numeric(12, 2), default=0)  # Total money spent at this venue
    favorite_category = Column(String(50))  # Most purchased category
    lifetime_value = Column(Numeric(12, 2), default=0)  # Total value as customer

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="user_points")
    venue = relationship("Venue", back_populates="user_points")

    # Ensure one record per user-venue combination
    __table_args__ = (
        UniqueConstraint('user_id', 'venue_id', name='unique_user_venue_points'),
    )

    def __repr__(self) -> str:
        return f"<UserPoints user={self.user_id} venue={self.venue_id} available={self.points_available}>"

    def add_points(self, amount: float) -> None:
        """
        Add points to user's balance for this venue.

        Args:
            amount: Points to add
        """
        self.points_earned += amount
        self.points_available += amount
        self.updated_at = datetime.utcnow()

    def spend_points(self, amount: float) -> bool:
        """
        Spend points from user's balance for this venue.

        Args:
            amount: Points to spend

        Returns:
            True if successful, False if insufficient points
        """
        if self.points_available < amount:
            return False

        self.points_spent += amount
        self.points_available -= amount
        self.updated_at = datetime.utcnow()
        return True

    def update_streak(self) -> int:
        """
        Update visit streak based on last visit date.
        Returns bonus points if milestone reached.

        Returns:
            Bonus points earned (0 if no milestone)
        """
        now = datetime.utcnow()
        bonus_points = 0

        if self.last_visit_date is None:
            # First visit
            self.current_streak = 1
            self.last_visit_date = now
            self.total_visits = 1
        else:
            # Check if visit is on a different day
            last_visit_day = self.last_visit_date.date()
            today = now.date()

            if last_visit_day == today:
                # Same day visit, don't update streak
                pass
            elif last_visit_day == today - timedelta(days=1):
                # Consecutive day visit
                self.current_streak += 1
                self.last_visit_date = now
                self.total_visits += 1

                # Check for streak milestones and award bonus points
                if self.current_streak == 7:
                    bonus_points = 50  # 7-day streak bonus
                elif self.current_streak == 14:
                    bonus_points = 100  # 14-day streak bonus
                elif self.current_streak == 30:
                    bonus_points = 250  # 30-day streak bonus

                # Update longest streak
                if self.current_streak > self.longest_streak:
                    self.longest_streak = self.current_streak
            else:
                # Streak broken
                self.current_streak = 1
                self.last_visit_date = now
                self.total_visits += 1

        self.updated_at = datetime.utcnow()

        # Add bonus points to balance if earned
        if bonus_points > 0:
            self.add_points(bonus_points)

        return bonus_points
