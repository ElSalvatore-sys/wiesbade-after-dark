"""
Event service for WiesbadenAfterDark
Handles event CRUD operations and RSVPs
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func
from sqlalchemy.orm import selectinload
from typing import Optional, List
from datetime import datetime, timedelta
from uuid import UUID

from app.models.event import Event
from app.models.event_rsvp import EventRSVP
from app.models.venue import Venue
from app.schemas.event import EventCreate, EventUpdate


class EventService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def list_events(
        self,
        venue_id: Optional[str] = None,
        event_type: Optional[str] = None,
        status: Optional[str] = None,
        start_after: Optional[datetime] = None,
        start_before: Optional[datetime] = None,
        is_featured: Optional[bool] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> List[Event]:
        """List events with optional filters"""
        query = select(Event).options(selectinload(Event.venue))

        # Apply filters
        conditions = []
        if venue_id:
            conditions.append(Event.venue_id == UUID(venue_id))
        if event_type:
            conditions.append(Event.event_type == event_type)
        if status:
            conditions.append(Event.status == status)
        if start_after:
            conditions.append(Event.start_time >= start_after)
        if start_before:
            conditions.append(Event.start_time <= start_before)
        if is_featured is not None:
            conditions.append(Event.is_featured == is_featured)

        if conditions:
            query = query.where(and_(*conditions))

        # Order by start time, then by featured status
        query = query.order_by(Event.is_featured.desc(), Event.start_time.asc())
        query = query.limit(limit).offset(offset)

        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def get_event_by_id(self, event_id: str) -> Optional[Event]:
        """Get a single event by ID"""
        query = select(Event).options(selectinload(Event.venue)).where(
            Event.id == UUID(event_id)
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_venue_events(
        self,
        venue_id: str,
        include_past: bool = False,
        limit: int = 20,
        offset: int = 0,
    ) -> List[Event]:
        """Get events for a specific venue"""
        query = select(Event).where(Event.venue_id == UUID(venue_id))

        if not include_past:
            query = query.where(Event.end_time >= datetime.utcnow())

        query = query.order_by(Event.start_time.asc())
        query = query.limit(limit).offset(offset)

        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def create_event(self, venue_id: str, event_data: EventCreate) -> Event:
        """Create a new event for a venue"""
        event = Event(
            venue_id=UUID(venue_id),
            title=event_data.title,
            description=event_data.description,
            event_type=event_data.event_type,
            image_url=event_data.image_url,
            start_time=event_data.start_time,
            end_time=event_data.end_time,
            max_capacity=event_data.max_capacity,
            ticket_price=event_data.ticket_price,
            is_free=event_data.is_free,
            attendance_points=event_data.attendance_points,
            bonus_points_multiplier=event_data.bonus_points_multiplier,
            is_featured=event_data.is_featured,
            status="upcoming",
        )
        self.db.add(event)
        await self.db.commit()
        await self.db.refresh(event)
        return event

    async def update_event(self, event_id: str, event_data: EventUpdate) -> Optional[Event]:
        """Update an existing event"""
        event = await self.get_event_by_id(event_id)
        if not event:
            return None

        # Update only provided fields
        update_data = event_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(event, field, value)

        event.updated_at = datetime.utcnow()
        await self.db.commit()
        await self.db.refresh(event)
        return event

    async def delete_event(self, event_id: str) -> bool:
        """Delete an event"""
        event = await self.get_event_by_id(event_id)
        if not event:
            return False

        await self.db.delete(event)
        await self.db.commit()
        return True

    async def get_today_events(self, limit: int = 10) -> List[Event]:
        """Get events happening today"""
        now = datetime.utcnow()
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        today_end = today_start + timedelta(days=1)

        query = (
            select(Event)
            .options(selectinload(Event.venue))
            .where(
                and_(
                    Event.start_time >= today_start,
                    Event.start_time < today_end,
                    Event.status != "cancelled",
                )
            )
            .order_by(Event.start_time.asc())
            .limit(limit)
        )

        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def get_upcoming_events(self, days: int = 7, limit: int = 20) -> List[Event]:
        """Get upcoming events within specified days"""
        now = datetime.utcnow()
        future_date = now + timedelta(days=days)

        query = (
            select(Event)
            .options(selectinload(Event.venue))
            .where(
                and_(
                    Event.start_time >= now,
                    Event.start_time <= future_date,
                    Event.status == "upcoming",
                )
            )
            .order_by(Event.is_featured.desc(), Event.start_time.asc())
            .limit(limit)
        )

        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def get_featured_events(self, limit: int = 5) -> List[Event]:
        """Get featured upcoming events"""
        now = datetime.utcnow()

        query = (
            select(Event)
            .options(selectinload(Event.venue))
            .where(
                and_(
                    Event.is_featured == True,
                    Event.start_time >= now,
                    Event.status == "upcoming",
                )
            )
            .order_by(Event.start_time.asc())
            .limit(limit)
        )

        result = await self.db.execute(query)
        return list(result.scalars().all())

    # RSVP Methods

    async def create_rsvp(self, user_id: str, event_id: str) -> Optional[EventRSVP]:
        """Create RSVP for an event"""
        event = await self.get_event_by_id(event_id)
        if not event:
            return None

        # Check if already RSVPed
        existing = await self.get_user_rsvp(user_id, event_id)
        if existing:
            return existing

        # Check capacity
        if event.max_capacity and event.current_rsvp_count >= event.max_capacity:
            # Create waitlist entry
            rsvp = EventRSVP(
                user_id=UUID(user_id),
                event_id=UUID(event_id),
                status="waitlist",
            )
        else:
            rsvp = EventRSVP(
                user_id=UUID(user_id),
                event_id=UUID(event_id),
                status="confirmed",
            )
            # Increment RSVP count
            event.current_rsvp_count += 1

        self.db.add(rsvp)
        await self.db.commit()
        await self.db.refresh(rsvp)
        return rsvp

    async def cancel_rsvp(self, user_id: str, event_id: str) -> bool:
        """Cancel RSVP for an event"""
        rsvp = await self.get_user_rsvp(user_id, event_id)
        if not rsvp:
            return False

        was_confirmed = rsvp.status == "confirmed"
        rsvp.status = "cancelled"
        rsvp.updated_at = datetime.utcnow()

        # Decrement RSVP count if was confirmed
        if was_confirmed:
            event = await self.get_event_by_id(event_id)
            if event and event.current_rsvp_count > 0:
                event.current_rsvp_count -= 1

        await self.db.commit()
        return True

    async def get_user_rsvp(self, user_id: str, event_id: str) -> Optional[EventRSVP]:
        """Get user's RSVP for a specific event"""
        query = select(EventRSVP).where(
            and_(
                EventRSVP.user_id == UUID(user_id),
                EventRSVP.event_id == UUID(event_id),
            )
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_user_rsvps(
        self,
        user_id: str,
        include_past: bool = False,
        status: Optional[str] = None,
    ) -> List[EventRSVP]:
        """Get all RSVPs for a user"""
        query = (
            select(EventRSVP)
            .options(selectinload(EventRSVP.event).selectinload(Event.venue))
            .where(EventRSVP.user_id == UUID(user_id))
        )

        if status:
            query = query.where(EventRSVP.status == status)
        else:
            query = query.where(EventRSVP.status != "cancelled")

        if not include_past:
            query = query.join(Event).where(Event.end_time >= datetime.utcnow())

        query = query.order_by(EventRSVP.created_at.desc())

        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def check_in_user(self, user_id: str, event_id: str) -> Optional[EventRSVP]:
        """Mark user as checked in to an event"""
        rsvp = await self.get_user_rsvp(user_id, event_id)
        if not rsvp or rsvp.status != "confirmed":
            return None

        rsvp.attended = True
        rsvp.check_in_time = datetime.utcnow()
        rsvp.updated_at = datetime.utcnow()

        await self.db.commit()
        await self.db.refresh(rsvp)
        return rsvp

    async def is_venue_owner(self, user_id: str, venue_id: str) -> bool:
        """Check if user is owner of a venue"""
        query = select(Venue).where(
            and_(
                Venue.id == UUID(venue_id),
                Venue.owner_id == UUID(user_id),
            )
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none() is not None
