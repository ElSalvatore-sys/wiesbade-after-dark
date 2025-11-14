"""
User endpoints (6-10)
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.user import (
    UserResponse,
    UserUpdate,
    PointsSummary,
    ExpiringPoints,
    ActivityUpdate,
    ActivityUpdateResponse,
)
from app.services.user_service import UserService

router = APIRouter()


@router.get("/{user_id}", response_model=UserResponse)
async def get_user_profile(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Endpoint #6: Get user profile

    Retrieves the profile information for a specific user.
    Users can only access their own profile.
    """
    # Authorization check - users can only access their own profile
    if str(current_user.id) != user_id:
        raise HTTPException(status_code=403, detail="Access denied")

    user_service = UserService(db)
    user = await user_service.get_user_by_id(user_id)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user


@router.put("/{user_id}", response_model=UserResponse)
async def update_user_profile(
    user_id: str,
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Endpoint #7: Update user profile

    Updates the profile information for a specific user.
    Users can only update their own profile.
    """
    # Authorization check
    if str(current_user.id) != user_id:
        raise HTTPException(status_code=403, detail="Access denied")

    user_service = UserService(db)
    updated_user = await user_service.update_user(user_id, user_update)

    return updated_user


@router.get("/{user_id}/points", response_model=PointsSummary)
async def get_user_points(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Endpoint #8: Get user points summary

    Retrieves a summary of the user's points across all venues,
    including a breakdown by venue with tier information.
    """
    # Authorization check
    if str(current_user.id) != user_id:
        raise HTTPException(status_code=403, detail="Access denied")

    user_service = UserService(db)
    points_summary = await user_service.get_points_summary(user_id)

    return points_summary


@router.get("/{user_id}/expiring-points", response_model=ExpiringPoints)
async def get_expiring_points(
    user_id: str,
    days_ahead: int = Query(default=30, ge=1, le=180, description="Number of days to look ahead"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Endpoint #9: Get points expiring soon

    Retrieves information about points that will expire within
    the specified number of days (default 30 days).
    """
    # Authorization check
    if str(current_user.id) != user_id:
        raise HTTPException(status_code=403, detail="Access denied")

    user_service = UserService(db)
    expiring = await user_service.get_expiring_points(user_id, days_ahead)

    return expiring


@router.put("/{user_id}/activity", response_model=ActivityUpdateResponse)
async def update_last_activity(
    user_id: str,
    activity_update: ActivityUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Endpoint #10: Update last activity

    Updates the user's last activity timestamp and venue visit information.
    Used to track user engagement and venue check-ins.
    """
    # Authorization check
    if str(current_user.id) != user_id:
        raise HTTPException(status_code=403, detail="Access denied")

    user_service = UserService(db)
    result = await user_service.update_activity(
        user_id,
        activity_update.venue_id,
        activity_update.activity_type,
    )

    return ActivityUpdateResponse(**result)
