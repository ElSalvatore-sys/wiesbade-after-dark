"""
API v1 Router - Combines all endpoint routers
"""
from fastapi import APIRouter

from app.api.v1.endpoints import users, venues, shifts, events

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(
    users.router,
    prefix="/users",
    tags=["users"],
)

api_router.include_router(
    venues.router,
    prefix="/venues",
    tags=["venues"],
)

api_router.include_router(
    shifts.router,
    prefix="/shifts",
    tags=["shifts"],
)

api_router.include_router(
    events.router,
    prefix="/events",
    tags=["events"],
)
