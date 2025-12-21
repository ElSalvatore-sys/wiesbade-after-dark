"""
Event schemas for request/response validation
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from decimal import Decimal


class EventBase(BaseModel):
    """Base event schema"""
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    event_type: str = Field(..., description="Event type: concert, party, special_offer, etc.")
    image_url: Optional[str] = None
    start_time: datetime
    end_time: datetime
    max_capacity: Optional[int] = Field(None, gt=0)
    ticket_price: Decimal = Field(default=Decimal("0.00"), ge=0)
    is_free: bool = True
    attendance_points: Decimal = Field(default=Decimal("0.00"), ge=0)
    bonus_points_multiplier: Decimal = Field(default=Decimal("1.0"), gt=0)
    is_featured: bool = False


class EventCreate(EventBase):
    """Schema for creating an event"""
    pass


class EventUpdate(BaseModel):
    """Schema for updating an event"""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    event_type: Optional[str] = None
    image_url: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    max_capacity: Optional[int] = Field(None, gt=0)
    ticket_price: Optional[Decimal] = Field(None, ge=0)
    is_free: Optional[bool] = None
    attendance_points: Optional[Decimal] = Field(None, ge=0)
    bonus_points_multiplier: Optional[Decimal] = Field(None, gt=0)
    is_featured: Optional[bool] = None
    status: Optional[str] = Field(None, description="Status: upcoming, ongoing, completed, cancelled")


class EventResponse(BaseModel):
    """Event response schema"""
    id: str
    venue_id: str
    venue_name: Optional[str] = None
    title: str
    description: Optional[str] = None
    event_type: str
    image_url: Optional[str] = None
    start_time: datetime
    end_time: datetime
    max_capacity: Optional[int] = None
    current_rsvp_count: int = 0
    ticket_price: float = 0.0
    is_free: bool = True
    attendance_points: float = 0.0
    bonus_points_multiplier: float = 1.0
    status: str = "upcoming"
    is_featured: bool = False
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class EventList(BaseModel):
    """Event list response"""
    events: List[EventResponse]
    total: int
    limit: int
    offset: int


class EventRSVPBase(BaseModel):
    """Base RSVP schema"""
    status: str = Field(default="confirmed", description="Status: confirmed, cancelled, waitlist")


class EventRSVPCreate(EventRSVPBase):
    """Schema for creating an RSVP"""
    pass


class EventRSVPResponse(BaseModel):
    """RSVP response schema"""
    id: str
    user_id: str
    event_id: str
    status: str
    attended: bool = False
    check_in_time: Optional[datetime] = None
    rsvp_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class EventRSVPWithEvent(EventRSVPResponse):
    """RSVP response with event details"""
    event: Optional[EventResponse] = None


class MyEventsResponse(BaseModel):
    """Response for user's RSVPed events"""
    rsvps: List[EventRSVPWithEvent]
    total: int
