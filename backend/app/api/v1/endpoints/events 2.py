"""
Event endpoints for WiesbadenAfterDark
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
from datetime import datetime

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.event import (
    EventList,
    EventResponse,
    EventCreate,
    EventUpdate,
    EventRSVPResponse,
    MyEventsResponse,
    EventRSVPWithEvent,
)
from app.services.event_service import EventService

router = APIRouter()


@router.get("", response_model=EventList)
async def list_events(
    venue_id: Optional[str] = Query(None, description="Filter by venue ID"),
    event_type: Optional[str] = Query(None, description="Filter by event type"),
    status: Optional[str] = Query(None, description="Filter by status"),
    start_after: Optional[datetime] = Query(None, description="Events starting after this date"),
    start_before: Optional[datetime] = Query(None, description="Events starting before this date"),
    is_featured: Optional[bool] = Query(None, description="Filter by featured status"),
    limit: int = Query(default=20, le=100, description="Maximum number of results"),
    offset: int = Query(default=0, description="Offset for pagination"),
    db: AsyncSession = Depends(get_db),
):
    """
    List all events with optional filters.

    Public endpoint - no authentication required.
    Returns paginated list of events with venue info.
    """
    event_service = EventService(db)

    events = await event_service.list_events(
        venue_id=venue_id,
        event_type=event_type,
        status=status,
        start_after=start_after,
        start_before=start_before,
        is_featured=is_featured,
        limit=limit,
        offset=offset,
    )

    # Convert to response model with venue name
    event_responses = []
    for event in events:
        event_data = EventResponse.model_validate(event)
        if event.venue:
            event_data.venue_name = event.venue.name
        event_responses.append(event_data)

    return EventList(
        events=event_responses,
        total=len(event_responses),
        limit=limit,
        offset=offset,
    )


@router.get("/today", response_model=EventList)
async def get_today_events(
    limit: int = Query(default=10, le=50),
    db: AsyncSession = Depends(get_db),
):
    """
    Get events happening today.

    Public endpoint for homepage display.
    """
    event_service = EventService(db)
    events = await event_service.get_today_events(limit=limit)

    event_responses = []
    for event in events:
        event_data = EventResponse.model_validate(event)
        if event.venue:
            event_data.venue_name = event.venue.name
        event_responses.append(event_data)

    return EventList(
        events=event_responses,
        total=len(event_responses),
        limit=limit,
        offset=0,
    )


@router.get("/upcoming", response_model=EventList)
async def get_upcoming_events(
    days: int = Query(default=7, ge=1, le=30, description="Number of days to look ahead"),
    limit: int = Query(default=20, le=100),
    db: AsyncSession = Depends(get_db),
):
    """
    Get upcoming events within specified days.

    Public endpoint for discovery features.
    """
    event_service = EventService(db)
    events = await event_service.get_upcoming_events(days=days, limit=limit)

    event_responses = []
    for event in events:
        event_data = EventResponse.model_validate(event)
        if event.venue:
            event_data.venue_name = event.venue.name
        event_responses.append(event_data)

    return EventList(
        events=event_responses,
        total=len(event_responses),
        limit=limit,
        offset=0,
    )


@router.get("/featured", response_model=EventList)
async def get_featured_events(
    limit: int = Query(default=5, le=20),
    db: AsyncSession = Depends(get_db),
):
    """
    Get featured upcoming events.

    Public endpoint for homepage carousel.
    """
    event_service = EventService(db)
    events = await event_service.get_featured_events(limit=limit)

    event_responses = []
    for event in events:
        event_data = EventResponse.model_validate(event)
        if event.venue:
            event_data.venue_name = event.venue.name
        event_responses.append(event_data)

    return EventList(
        events=event_responses,
        total=len(event_responses),
        limit=limit,
        offset=0,
    )


@router.get("/my-events", response_model=MyEventsResponse)
async def get_my_events(
    include_past: bool = Query(default=False, description="Include past events"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get current user's RSVPed events.

    Requires authentication.
    Returns events user has RSVPed to with RSVP status.
    """
    event_service = EventService(db)
    rsvps = await event_service.get_user_rsvps(
        user_id=str(current_user.id),
        include_past=include_past,
    )

    rsvp_responses = []
    for rsvp in rsvps:
        rsvp_data = EventRSVPWithEvent.model_validate(rsvp)
        if rsvp.event:
            event_data = EventResponse.model_validate(rsvp.event)
            if rsvp.event.venue:
                event_data.venue_name = rsvp.event.venue.name
            rsvp_data.event = event_data
        rsvp_responses.append(rsvp_data)

    return MyEventsResponse(
        rsvps=rsvp_responses,
        total=len(rsvp_responses),
    )


@router.get("/{event_id}", response_model=EventResponse)
async def get_event(
    event_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Get a single event by ID.

    Public endpoint for event detail page.
    """
    event_service = EventService(db)
    event = await event_service.get_event_by_id(event_id)

    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    event_data = EventResponse.model_validate(event)
    if event.venue:
        event_data.venue_name = event.venue.name

    return event_data


@router.get("/venue/{venue_id}", response_model=EventList)
async def get_venue_events(
    venue_id: str,
    include_past: bool = Query(default=False, description="Include past events"),
    limit: int = Query(default=20, le=100),
    offset: int = Query(default=0),
    db: AsyncSession = Depends(get_db),
):
    """
    Get events for a specific venue.

    Public endpoint for venue detail page.
    """
    event_service = EventService(db)
    events = await event_service.get_venue_events(
        venue_id=venue_id,
        include_past=include_past,
        limit=limit,
        offset=offset,
    )

    event_responses = [EventResponse.model_validate(e) for e in events]

    return EventList(
        events=event_responses,
        total=len(event_responses),
        limit=limit,
        offset=offset,
    )


@router.post("/venue/{venue_id}", response_model=EventResponse, status_code=201)
async def create_event(
    venue_id: str,
    event_data: EventCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new event for a venue.

    Requires authentication and venue ownership.
    """
    event_service = EventService(db)

    # Verify venue ownership
    is_owner = await event_service.is_venue_owner(str(current_user.id), venue_id)
    if not is_owner:
        raise HTTPException(
            status_code=403,
            detail="Only venue owners can create events",
        )

    event = await event_service.create_event(venue_id, event_data)
    return EventResponse.model_validate(event)


@router.put("/{event_id}", response_model=EventResponse)
async def update_event(
    event_id: str,
    event_data: EventUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update an existing event.

    Requires authentication and venue ownership.
    """
    event_service = EventService(db)

    # Get event to check ownership
    event = await event_service.get_event_by_id(event_id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    # Verify venue ownership
    is_owner = await event_service.is_venue_owner(str(current_user.id), str(event.venue_id))
    if not is_owner:
        raise HTTPException(
            status_code=403,
            detail="Only venue owners can update events",
        )

    updated_event = await event_service.update_event(event_id, event_data)
    return EventResponse.model_validate(updated_event)


@router.delete("/{event_id}", status_code=204)
async def delete_event(
    event_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete an event.

    Requires authentication and venue ownership.
    """
    event_service = EventService(db)

    # Get event to check ownership
    event = await event_service.get_event_by_id(event_id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    # Verify venue ownership
    is_owner = await event_service.is_venue_owner(str(current_user.id), str(event.venue_id))
    if not is_owner:
        raise HTTPException(
            status_code=403,
            detail="Only venue owners can delete events",
        )

    await event_service.delete_event(event_id)
    return None


@router.post("/{event_id}/rsvp", response_model=EventRSVPResponse, status_code=201)
async def rsvp_to_event(
    event_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    RSVP to an event.

    Requires authentication.
    Creates confirmed RSVP or waitlist entry if at capacity.
    """
    event_service = EventService(db)

    # Check event exists
    event = await event_service.get_event_by_id(event_id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    if event.status == "cancelled":
        raise HTTPException(status_code=400, detail="Cannot RSVP to cancelled event")

    if event.status == "completed":
        raise HTTPException(status_code=400, detail="Cannot RSVP to past event")

    rsvp = await event_service.create_rsvp(str(current_user.id), event_id)
    return EventRSVPResponse.model_validate(rsvp)


@router.delete("/{event_id}/rsvp", status_code=204)
async def cancel_rsvp(
    event_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Cancel RSVP to an event.

    Requires authentication.
    """
    event_service = EventService(db)

    success = await event_service.cancel_rsvp(str(current_user.id), event_id)
    if not success:
        raise HTTPException(status_code=404, detail="RSVP not found")

    return None


@router.post("/{event_id}/check-in", response_model=EventRSVPResponse)
async def check_in_to_event(
    event_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Check in to an event.

    Requires authentication and confirmed RSVP.
    Awards attendance points upon check-in.
    """
    event_service = EventService(db)

    rsvp = await event_service.check_in_user(str(current_user.id), event_id)
    if not rsvp:
        raise HTTPException(
            status_code=400,
            detail="No confirmed RSVP found for this event",
        )

    return EventRSVPResponse.model_validate(rsvp)
