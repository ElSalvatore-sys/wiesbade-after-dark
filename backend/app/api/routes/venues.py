"""
Venues API routes.
Handles venue discovery, details, products, and promotions.
"""

from typing import List, Optional
from uuid import UUID
from datetime import datetime
import math

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_

from app.db.session import get_db
from app.api.dependencies import get_current_user, get_optional_current_user
from app.models.user import User
from app.models.venue import Venue
from app.models.user_points import UserPoints
from app.models.product import Product
from app.schemas.venue import VenueListItem, VenueResponse, VenueWithUserPoints
from app.schemas.product import ProductResponse


router = APIRouter()


def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate distance between two coordinates using Haversine formula.

    Args:
        lat1: Latitude of first point
        lon1: Longitude of first point
        lat2: Latitude of second point
        lon2: Longitude of second point

    Returns:
        Distance in kilometers
    """
    R = 6371  # Earth's radius in kilometers

    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)

    a = (
        math.sin(delta_lat / 2) ** 2
        + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    return R * c


@router.get("", response_model=List[VenueListItem])
async def list_venues(
    venue_type: Optional[str] = Query(None, description="Filter by venue type"),
    is_featured: Optional[bool] = Query(None, description="Filter by featured status"),
    latitude: Optional[float] = Query(None, description="User's latitude for distance calculation"),
    longitude: Optional[float] = Query(None, description="User's longitude for distance calculation"),
    max_distance_km: Optional[float] = Query(None, description="Maximum distance in kilometers"),
    db: AsyncSession = Depends(get_db)
):
    """
    List all venues with optional filtering.

    Supports filtering by:
    - venue_type: Type of venue (club, bar, lounge, restaurant)
    - is_featured: Featured venues only
    - Location-based filtering (requires latitude, longitude, and max_distance_km)

    Args:
        venue_type: Optional venue type filter
        is_featured: Optional featured status filter
        latitude: User's current latitude
        longitude: User's current longitude
        max_distance_km: Maximum distance from user's location
        db: Database session

    Returns:
        List of VenueListItem matching filters

    Note:
        Distance calculation uses Haversine formula for accuracy.
        Venues are returned sorted by distance if location provided, otherwise by name.
    """
    # Build query with filters
    query = select(Venue).where(Venue.is_active == True)

    if venue_type:
        query = query.where(Venue.venue_type == venue_type)

    if is_featured is not None:
        query = query.where(Venue.is_featured == is_featured)

    # Execute query
    result = await db.execute(query)
    venues = result.scalars().all()

    # Build response with distance calculation
    venue_items = []
    for venue in venues:
        # Calculate distance if location provided
        distance_km = None
        if latitude is not None and longitude is not None and venue.latitude and venue.longitude:
            distance_km = calculate_distance(
                latitude, longitude, float(venue.latitude), float(venue.longitude)
            )

            # Skip if beyond max distance
            if max_distance_km is not None and distance_km > max_distance_km:
                continue

        venue_items.append(
            VenueListItem(
                id=venue.id,
                name=venue.name,
                slug=venue.slug,
                venue_type=venue.venue_type,
                description=venue.description,
                address=venue.address,
                city=venue.city,
                postal_code=venue.postal_code,
                latitude=venue.latitude,
                longitude=venue.longitude,
                phone=venue.phone,
                website=venue.website,
                instagram_handle=venue.instagram_handle,
                is_featured=venue.is_featured,
                logo_url=venue.logo_url,
                cover_image_url=venue.cover_image_url,
                distance_km=distance_km,
            )
        )

    # Sort by distance if location provided, otherwise by name
    if latitude is not None and longitude is not None:
        venue_items.sort(key=lambda v: v.distance_km if v.distance_km is not None else float('inf'))
    else:
        venue_items.sort(key=lambda v: v.name)

    return venue_items


@router.get("/{venue_id}", response_model=VenueWithUserPoints)
async def get_venue_details(
    venue_id: UUID,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get detailed information about a specific venue.

    If user is authenticated, also returns their points balance at this venue.

    Args:
        venue_id: UUID of the venue
        current_user: Optional authenticated user
        db: Database session

    Returns:
        VenueWithUserPoints including venue details and user's points (if authenticated)

    Raises:
        HTTPException: 404 if venue not found
    """
    # Get venue
    result = await db.execute(
        select(Venue).where(Venue.id == venue_id)
    )
    venue = result.scalar_one_or_none()

    if not venue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Venue with ID {venue_id} not found",
        )

    # Get user's points at this venue if authenticated
    user_points_data = None
    if current_user:
        result = await db.execute(
            select(UserPoints).where(
                and_(
                    UserPoints.user_id == current_user.id,
                    UserPoints.venue_id == venue_id
                )
            )
        )
        user_points = result.scalar_one_or_none()

        if user_points:
            user_points_data = {
                "points_earned": user_points.points_earned,
                "points_spent": user_points.points_spent,
                "points_available": user_points.points_available,
                "current_streak": user_points.current_streak,
                "longest_streak": user_points.longest_streak,
                "total_visits": user_points.total_visits,
                "last_visit_date": user_points.last_visit_date,
            }

    # Build response
    venue_dict = VenueResponse.model_validate(venue).model_dump()
    venue_dict["user_points"] = user_points_data

    return VenueWithUserPoints(**venue_dict)


@router.get("/{venue_id}/products", response_model=List[ProductResponse])
async def get_venue_products(
    venue_id: UUID,
    category: Optional[str] = Query(None, description="Filter by product category"),
    in_stock_only: bool = Query(False, description="Show only products in stock"),
    db: AsyncSession = Depends(get_db)
):
    """
    Get all products for a specific venue.

    Supports filtering by:
    - category: Product category (e.g., 'Drinks', 'Food')
    - in_stock_only: Only show products with stock_quantity > 0

    Args:
        venue_id: UUID of the venue
        category: Optional category filter
        in_stock_only: Filter for in-stock items only
        db: Database session

    Returns:
        List of ProductResponse for the venue

    Raises:
        HTTPException: 404 if venue not found
    """
    # Verify venue exists
    result = await db.execute(
        select(Venue).where(Venue.id == venue_id)
    )
    venue = result.scalar_one_or_none()

    if not venue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Venue with ID {venue_id} not found",
        )

    # Build query for products
    query = select(Product).where(
        and_(
            Product.venue_id == venue_id,
            Product.is_active == True
        )
    )

    if category:
        query = query.where(Product.category == category)

    if in_stock_only:
        query = query.where(Product.stock_quantity > 0)

    # Order by category, then name
    query = query.order_by(Product.category, Product.name)

    result = await db.execute(query)
    products = result.scalars().all()

    return [ProductResponse.model_validate(product) for product in products]


@router.get("/{venue_id}/promotions", response_model=List[ProductResponse])
async def get_venue_promotions(
    venue_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    Get all products with active bonus point promotions for a venue.

    Returns products where:
    - bonus_points_active = True
    - Current time is between bonus_start_date and bonus_end_date (if set)
    - Product is active and in stock

    This is useful for highlighting special promotions to help venues move inventory.

    Args:
        venue_id: UUID of the venue
        db: Database session

    Returns:
        List of ProductResponse with active bonus promotions

    Raises:
        HTTPException: 404 if venue not found
    """
    # Verify venue exists
    result = await db.execute(
        select(Venue).where(Venue.id == venue_id)
    )
    venue = result.scalar_one_or_none()

    if not venue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Venue with ID {venue_id} not found",
        )

    # Get products with active bonuses
    now = datetime.utcnow()

    query = select(Product).where(
        and_(
            Product.venue_id == venue_id,
            Product.is_active == True,
            Product.bonus_points_active == True,
            Product.stock_quantity > 0,
            or_(
                Product.bonus_start_date == None,
                Product.bonus_start_date <= now
            ),
            or_(
                Product.bonus_end_date == None,
                Product.bonus_end_date >= now
            )
        )
    ).order_by(Product.bonus_multiplier.desc(), Product.name)

    result = await db.execute(query)
    products = result.scalars().all()

    return [ProductResponse.model_validate(product) for product in products]
