"""
API dependencies for authentication and authorization.
Provides reusable dependencies for protected routes.
"""

from uuid import UUID
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.core.security import decode_token
from app.models.user import User
from app.models.venue import Venue


# HTTP Bearer security scheme for JWT tokens
security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> User:
    """
    Get current authenticated user from JWT token.

    This dependency extracts the JWT token from the Authorization header,
    decodes it, and retrieves the corresponding user from the database.

    Args:
        credentials: HTTP Bearer credentials containing the JWT token
        db: Database session

    Returns:
        User object if authentication successful

    Raises:
        HTTPException: 401 if token invalid or user not found
        HTTPException: 403 if user account is inactive
    """
    token = credentials.credentials

    # Decode JWT token
    payload = decode_token(token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Validate token type
    token_type = payload.get("type")
    if token_type != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token type. Expected access token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Get user ID from token
    user_id_str = payload.get("sub")
    if not user_id_str:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload: missing user ID",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Convert string UUID to UUID object
    try:
        user_id = UUID(user_id_str)
    except (ValueError, AttributeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload: malformed user ID",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Get user from database
    result = await db.execute(
        select(User).where(User.id == user_id)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Check if user account is active
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive or suspended",
        )

    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user)
) -> User:
    """
    Get current user and ensure they are verified.

    Args:
        current_user: Current authenticated user

    Returns:
        User object if verified

    Raises:
        HTTPException: 403 if user email is not verified
    """
    if not current_user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Email verification required. Please verify your email address.",
        )

    return current_user


async def get_venue_owner(
    venue_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> Venue:
    """
    Get venue and verify current user is the owner.
    Used for admin/owner-only endpoints.

    Args:
        venue_id: UUID of the venue
        current_user: Current authenticated user
        db: Database session

    Returns:
        Venue object if user is the owner

    Raises:
        HTTPException: 404 if venue not found
        HTTPException: 403 if user is not the owner
    """
    # Get venue from database
    result = await db.execute(
        select(Venue).where(Venue.id == venue_id)
    )
    venue = result.scalar_one_or_none()

    if not venue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Venue with ID {venue_id} not found",
        )

    # Verify user is the owner
    if venue.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to manage this venue",
        )

    return venue


async def get_optional_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> Optional[User]:
    """
    Get current user if authenticated, otherwise return None.
    Useful for endpoints that work with or without authentication.

    Args:
        credentials: Optional HTTP Bearer credentials
        db: Database session

    Returns:
        User object if authenticated, None otherwise
    """
    if not credentials:
        return None

    try:
        return await get_current_user(credentials, db)
    except HTTPException:
        return None
