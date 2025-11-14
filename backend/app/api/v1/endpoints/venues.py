"""
Venue endpoints (11-14)
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
from geopy.distance import geodesic

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.venue import (
    VenueList,
    VenueDetail,
    VenueResponse,
    ProductList,
    TierConfig,
)
from app.services.venue_service import VenueService

router = APIRouter()


@router.get("", response_model=VenueList)
async def list_venues(
    type: Optional[str] = Query(None, description="Filter by venue type (bar, club, restaurant)"),
    has_events: Optional[bool] = Query(None, description="Filter venues with events"),
    lat: Optional[float] = Query(None, description="User latitude for distance calculation"),
    lng: Optional[float] = Query(None, description="User longitude for distance calculation"),
    limit: int = Query(default=20, le=100, description="Maximum number of results"),
    offset: int = Query(default=0, description="Offset for pagination"),
    db: AsyncSession = Depends(get_db),
):
    """
    Endpoint #11: List venues with filters

    Retrieves a list of active venues with optional filtering by type and events.
    If latitude and longitude are provided, calculates distance from user location.

    Query Parameters:
    - type: Filter by venue type (e.g., "bar", "club", "restaurant")
    - has_events: Filter venues that have events (true/false)
    - lat, lng: User location for distance calculation
    - limit: Maximum number of results (default 20, max 100)
    - offset: Pagination offset (default 0)
    """
    venue_service = VenueService(db)

    venues = await venue_service.list_venues(
        venue_type=type,
        has_events=has_events,
        user_location=(lat, lng) if lat and lng else None,
        limit=limit,
        offset=offset,
    )

    # Convert to VenueResponse and calculate distance if location provided
    venue_responses = []
    for venue in venues:
        venue_data = VenueResponse.model_validate(venue)

        # Calculate distance if user location provided
        if lat is not None and lng is not None:
            venue_location = (venue.latitude, venue.longitude)
            user_location = (lat, lng)
            distance_km = geodesic(user_location, venue_location).km
            venue_data.distance = round(distance_km, 2)

        venue_responses.append(venue_data)

    return VenueList(
        venues=venue_responses,
        total=len(venue_responses),
        limit=limit,
        offset=offset,
    )


@router.get("/{venue_id}", response_model=VenueDetail)
async def get_venue_details(
    venue_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Endpoint #12: Get venue details

    Retrieves detailed information about a specific venue.
    This endpoint is public and doesn't require authentication.
    """
    venue_service = VenueService(db)
    venue = await venue_service.get_venue_by_id(venue_id)

    if not venue:
        raise HTTPException(status_code=404, detail="Venue not found")

    return venue


@router.get("/{venue_id}/products", response_model=ProductList)
async def get_venue_products(
    venue_id: str,
    has_bonus: Optional[bool] = Query(None, description="Filter products with bonuses"),
    category: Optional[str] = Query(None, description="Filter by product category"),
    db: AsyncSession = Depends(get_db),
):
    """
    Endpoint #13: Get venue products

    Retrieves all available products for a specific venue,
    with optional filtering by bonus availability and category.

    Query Parameters:
    - has_bonus: Filter products that have bonus points (true/false)
    - category: Filter by product category (e.g., "drink", "food")
    """
    venue_service = VenueService(db)

    # First check if venue exists
    venue = await venue_service.get_venue_by_id(venue_id)
    if not venue:
        raise HTTPException(status_code=404, detail="Venue not found")

    products = await venue_service.get_products(
        venue_id,
        has_bonus=has_bonus,
        category=category,
    )

    return ProductList(
        products=products,
        total=len(products),
    )


@router.get("/{venue_id}/tier-config", response_model=TierConfig)
async def get_tier_config(
    venue_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Endpoint #14: Get tier configuration (owner only)

    Retrieves the tier/loyalty program configuration for a venue.
    This endpoint is restricted to venue owners only.

    Returns tier levels with:
    - Point thresholds
    - Benefits and perks
    - Discount percentages
    - Bonus multipliers
    """
    venue_service = VenueService(db)

    # Check if user is venue owner
    is_owner = await venue_service.is_owner(current_user.id, venue_id)
    if not is_owner:
        raise HTTPException(
            status_code=403,
            detail="Access denied. Only venue owners can view tier configuration.",
        )

    tier_config = await venue_service.get_tier_config(venue_id)

    return tier_config
