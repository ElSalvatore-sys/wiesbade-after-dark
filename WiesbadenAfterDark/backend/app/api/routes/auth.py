"""
Authentication API routes.
Handles user registration, login, token management, and password reset.
"""

from datetime import datetime, timedelta
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_

from app.db.session import get_db
from app.core.config import settings
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token,
    generate_referral_code,
    generate_verification_code,
    generate_password_reset_token,
)
from app.models.user import User
from app.models.referral import Referral, ReferralChain
from app.schemas.user import (
    UserRegister,
    UserLogin,
    UserResponse,
    TokenResponse,
    TokenRefresh,
    EmailVerification,
    CodeVerification,
    ForgotPassword,
    ResetPassword,
)


router = APIRouter()


async def create_user_referral_chain(
    db: AsyncSession,
    new_user: User,
    referrer: User
) -> None:
    """
    Create referral chain for a new user based on their referrer's chain.

    Args:
        db: Database session
        new_user: The newly registered user
        referrer: The user who referred the new user
    """
    # Create individual referral record
    referral = Referral(
        referrer_id=referrer.id,
        referred_id=new_user.id,
        referral_code_used=referrer.referral_code,
    )
    db.add(referral)

    # Get referrer's chain (if exists)
    result = await db.execute(
        select(ReferralChain).where(ReferralChain.user_id == referrer.id)
    )
    referrer_chain = result.scalar_one_or_none()

    # Build new user's chain
    new_chain = ReferralChain(
        user_id=new_user.id,
        level_1_referrer_id=referrer.id,
    )

    # If referrer has a chain, shift it down
    if referrer_chain:
        new_chain.level_2_referrer_id = referrer_chain.level_1_referrer_id
        new_chain.level_3_referrer_id = referrer_chain.level_2_referrer_id
        new_chain.level_4_referrer_id = referrer_chain.level_3_referrer_id
        new_chain.level_5_referrer_id = referrer_chain.level_4_referrer_id

    db.add(new_chain)

    # Update referrer's referral count
    referrer.total_referrals += 1

    await db.flush()


async def generate_unique_referral_code(db: AsyncSession) -> str:
    """
    Generate a unique referral code that doesn't exist in the database.

    Args:
        db: Database session

    Returns:
        Unique 8-character referral code
    """
    max_attempts = 10
    for _ in range(max_attempts):
        code = generate_referral_code()

        # Check if code already exists
        result = await db.execute(
            select(User).where(User.referral_code == code)
        )
        existing_user = result.scalar_one_or_none()

        if not existing_user:
            return code

    # If we couldn't generate a unique code after max_attempts, raise error
    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Failed to generate unique referral code. Please try again.",
    )


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: UserRegister,
    db: AsyncSession = Depends(get_db)
):
    """
    Register a new user account.

    Creates a new user with the provided information, generates a unique referral code,
    and handles referral chain creation if a referral code was provided.

    Args:
        user_data: User registration data
        db: Database session

    Returns:
        TokenResponse with access token, refresh token, and user data

    Raises:
        HTTPException: 400 if email already registered or referral code invalid
    """
    # Check if email already exists
    result = await db.execute(
        select(User).where(User.email == user_data.email)
    )
    existing_user = result.scalar_one_or_none()

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email address already registered",
        )

    # Handle referral code if provided
    referrer = None
    if user_data.referred_by_code:
        result = await db.execute(
            select(User).where(User.referral_code == user_data.referred_by_code)
        )
        referrer = result.scalar_one_or_none()

        if not referrer:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid referral code: {user_data.referred_by_code}",
            )

    # Generate unique referral code for new user
    referral_code = await generate_unique_referral_code(db)

    # Create new user
    new_user = User(
        email=user_data.email,
        password_hash=hash_password(user_data.password),
        first_name=user_data.first_name,
        last_name=user_data.last_name,
        referral_code=referral_code,
        referred_by_code=user_data.referred_by_code,
        last_login_at=datetime.utcnow(),
    )

    db.add(new_user)
    await db.flush()  # Flush to get the user ID

    # Create referral chain if user was referred
    if referrer:
        await create_user_referral_chain(db, new_user, referrer)

    await db.commit()
    await db.refresh(new_user)

    # Generate tokens
    access_token = create_access_token(data={"sub": str(new_user.id)})
    refresh_token = create_refresh_token(data={"sub": str(new_user.id)})

    # Build response
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=UserResponse.model_validate(new_user),
    )


@router.post("/login", response_model=TokenResponse)
async def login(
    credentials: UserLogin,
    db: AsyncSession = Depends(get_db)
):
    """
    Authenticate user and return JWT tokens.

    Args:
        credentials: User login credentials (email and password)
        db: Database session

    Returns:
        TokenResponse with access token, refresh token, and user data

    Raises:
        HTTPException: 401 if credentials are invalid
    """
    # Find user by email
    result = await db.execute(
        select(User).where(User.email == credentials.email)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Verify password
    if not user.password_hash or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Check if account is active
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is inactive. Please contact support.",
        )

    # Update last login time
    user.last_login_at = datetime.utcnow()
    await db.commit()
    await db.refresh(user)

    # Generate tokens
    access_token = create_access_token(data={"sub": str(user.id)})
    refresh_token = create_refresh_token(data={"sub": str(user.id)})

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=UserResponse.model_validate(user),
    )


@router.post("/refresh")
async def refresh_token(
    token_data: TokenRefresh,
    db: AsyncSession = Depends(get_db)
):
    """
    Refresh access token using a valid refresh token.

    Args:
        token_data: Refresh token data
        db: Database session

    Returns:
        New access token

    Raises:
        HTTPException: 401 if refresh token is invalid
    """
    # Decode refresh token
    payload = decode_token(token_data.refresh_token)

    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Verify token type
    if payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token type. Expected refresh token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Get user ID
    user_id_str = payload.get("sub")
    if not user_id_str:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        user_id = UUID(user_id_str)
    except (ValueError, AttributeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Verify user exists and is active
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Generate new access token
    new_access_token = create_access_token(data={"sub": str(user.id)})

    return {
        "access_token": new_access_token,
        "token_type": "bearer",
        "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    }


@router.post("/verify-email")
async def send_verification_code(
    data: EmailVerification,
    db: AsyncSession = Depends(get_db)
):
    """
    Send email verification code to user.

    In production, this would send an email with the code.
    For development, it returns the code in the response.

    Args:
        data: Email verification request
        db: Database session

    Returns:
        Success message with verification code (dev only)

    Raises:
        HTTPException: 404 if user not found
    """
    # Find user by email
    result = await db.execute(
        select(User).where(User.email == data.email)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User with this email not found",
        )

    # Generate verification code
    verification_code = generate_verification_code()

    # TODO: In production, send email with verification code
    # For now, we return the code in the response for testing

    return {
        "message": "Verification code sent successfully",
        "code": verification_code,  # Remove in production
        "email": data.email,
    }


@router.post("/verify-code")
async def verify_email_code(
    data: CodeVerification,
    db: AsyncSession = Depends(get_db)
):
    """
    Verify email with verification code.

    In production, this would check against stored code.
    For development, accepts any 6-digit code.

    Args:
        data: Code verification request
        db: Database session

    Returns:
        Success message

    Raises:
        HTTPException: 404 if user not found
        HTTPException: 400 if code is invalid
    """
    # Find user by email
    result = await db.execute(
        select(User).where(User.email == data.email)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User with this email not found",
        )

    # Validate code format (6 digits)
    if not data.code.isdigit() or len(data.code) != 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid verification code format. Expected 6 digits.",
        )

    # TODO: In production, verify against stored code and expiration
    # For now, we accept any 6-digit code

    # Mark user as verified
    if not user.is_verified:
        user.is_verified = True
        user.email_verified_at = datetime.utcnow()
        await db.commit()

    return {
        "message": "Email verified successfully",
        "is_verified": True,
    }


@router.post("/forgot-password")
async def forgot_password(
    data: ForgotPassword,
    db: AsyncSession = Depends(get_db)
):
    """
    Request password reset token.

    In production, this would send an email with a reset link.
    For development, it returns the token in the response.

    Args:
        data: Forgot password request
        db: Database session

    Returns:
        Success message with reset token (dev only)

    Note:
        Always returns success even if email not found (security best practice)
    """
    # Find user by email
    result = await db.execute(
        select(User).where(User.email == data.email)
    )
    user = result.scalar_one_or_none()

    if user:
        # Generate password reset token (1 hour expiration)
        reset_token = create_access_token(
            data={"email": user.email, "type": "password_reset"},
            expires_delta=timedelta(hours=1)
        )

        # TODO: In production, send email with reset link containing token
        # For now, return token in response

        return {
            "message": "Password reset instructions sent to your email",
            "reset_token": reset_token,  # Remove in production
        }

    # Return same message even if user not found (security best practice)
    return {
        "message": "Password reset instructions sent to your email",
    }


@router.post("/reset-password")
async def reset_password(
    data: ResetPassword,
    db: AsyncSession = Depends(get_db)
):
    """
    Reset user password with reset token.

    Args:
        data: Password reset request with token and new password
        db: Database session

    Returns:
        Success message

    Raises:
        HTTPException: 400 if token is invalid or expired
        HTTPException: 404 if user not found
    """
    # Decode reset token
    payload = decode_token(data.token)

    if not payload:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired reset token",
        )

    # Verify token type
    if payload.get("type") != "password_reset":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid token type",
        )

    # Get email from token
    email = payload.get("email")
    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid token payload",
        )

    # Find user by email
    result = await db.execute(
        select(User).where(User.email == email)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Hash and update password
    user.password_hash = hash_password(data.new_password)
    await db.commit()

    return {
        "message": "Password reset successfully",
    }
