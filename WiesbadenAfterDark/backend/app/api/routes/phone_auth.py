"""
Phone Authentication API routes.
Handles phone number verification, SMS codes, and phone-based registration/login.
"""

import logging
from datetime import datetime, timedelta
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, and_
from pydantic import BaseModel, Field

from app.db.session import get_db
from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    generate_referral_code,
)
from app.core.sms import sms_service
from app.models.user import User
from app.models.verification_code import VerificationCode
from app.models.referral import Referral, ReferralChain
from app.schemas.user import UserResponse, TokenResponse

logger = logging.getLogger(__name__)

router = APIRouter()


# ============================================================================
# Request/Response Schemas
# ============================================================================

class SendCodeRequest(BaseModel):
    """Request to send verification code."""
    phone_number: str = Field(..., description="Phone number in E.164 format (e.g., +4917012345678)")


class SendCodeResponse(BaseModel):
    """Response after sending verification code."""
    message: str
    expires_in: int = Field(default=300, description="Code expiration in seconds")


class VerifyCodeRequest(BaseModel):
    """Request to verify SMS code."""
    phone_number: str = Field(..., description="Phone number in E.164 format")
    code: str = Field(..., min_length=6, max_length=6, description="6-digit verification code")


class RegisterRequest(BaseModel):
    """Request to register new user after phone verification."""
    phone_number: str = Field(..., description="Phone number in E.164 format")
    referral_code: Optional[str] = Field(None, description="Optional referral code")


class ValidateReferralResponse(BaseModel):
    """Response for referral code validation."""
    valid: bool
    referral_code: Optional[str] = None


# ============================================================================
# Helper Functions
# ============================================================================

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
        if not result.scalar_one_or_none():
            return code

    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Failed to generate unique referral code"
    )


# ============================================================================
# API Endpoints
# ============================================================================

@router.post(
    "/send-code",
    response_model=SendCodeResponse,
    summary="Send SMS verification code",
    description="Send a 6-digit verification code to the specified phone number via SMS"
)
async def send_verification_code(
    request: SendCodeRequest,
    db: AsyncSession = Depends(get_db)
) -> SendCodeResponse:
    """
    Send SMS verification code to phone number.

    Process:
    1. Invalidate any existing codes for this phone number
    2. Generate new 6-digit code
    3. Save to database with 5-minute expiration
    4. Send via Twilio SMS

    Args:
        request: Phone number to send code to
        db: Database session

    Returns:
        Success message and expiration time

    Raises:
        HTTPException: If SMS sending fails
    """
    logger.info(f"Sending verification code to {request.phone_number}")

    # Invalidate existing codes for this phone number
    result = await db.execute(
        select(VerificationCode).where(
            and_(
                VerificationCode.phone_number == request.phone_number,
                VerificationCode.is_used == False
            )
        )
    )
    existing_codes = result.scalars().all()
    for code in existing_codes:
        code.is_used = True

    # Generate new verification code
    code = sms_service.generate_verification_code()

    # Create verification code record
    verification = VerificationCode(
        phone_number=request.phone_number,
        code=code,
        expires_at=VerificationCode.create_expiration_time(),
    )
    db.add(verification)
    await db.commit()

    # Send SMS via Twilio
    success = await sms_service.send_verification_code(
        phone_number=request.phone_number,
        code=code
    )

    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to send verification code"
        )

    logger.info(f"Verification code sent successfully to {request.phone_number}")

    return SendCodeResponse(
        message="Verification code sent successfully",
        expires_in=300  # 5 minutes
    )


@router.post(
    "/verify-code",
    response_model=TokenResponse,
    summary="Verify SMS code and login/register",
    description="Verify the SMS code and either login existing user or register new user"
)
async def verify_code_and_authenticate(
    request: VerifyCodeRequest,
    db: AsyncSession = Depends(get_db)
) -> TokenResponse:
    """
    Verify SMS code and authenticate user.

    Process:
    1. Find valid verification code
    2. Check if user exists with this phone number
    3. If exists: Login and return tokens
    4. If not exists: This is just verification, registration comes next

    Args:
        request: Phone number and verification code
        db: Database session

    Returns:
        Access token, refresh token, and user data (if user exists)

    Raises:
        HTTPException: If code is invalid, expired, or already used
    """
    logger.info(f"Verifying code for {request.phone_number}")

    # Find verification code
    result = await db.execute(
        select(VerificationCode).where(
            and_(
                VerificationCode.phone_number == request.phone_number,
                VerificationCode.code == request.code,
                VerificationCode.is_used == False
            )
        )
    )
    verification = result.scalar_one_or_none()

    if not verification:
        logger.warning(f"Invalid verification code for {request.phone_number}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid verification code"
        )

    # Check if expired
    if verification.is_expired:
        logger.warning(f"Expired verification code for {request.phone_number}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Verification code has expired"
        )

    # Mark code as used
    verification.is_used = True
    verification.used_at = datetime.utcnow()

    # Check if user exists
    result = await db.execute(
        select(User).where(User.phone_number == request.phone_number)
    )
    user = result.scalar_one_or_none()

    if user:
        # Existing user - mark phone as verified and login
        user.phone_verified = True
        user.last_login_at = datetime.utcnow()
        await db.commit()

        # Generate tokens
        access_token = create_access_token({"sub": str(user.id)})
        refresh_token = create_refresh_token({"sub": str(user.id)})

        logger.info(f"User {user.id} logged in via phone")

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="Bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            user=UserResponse.model_validate(user)
        )
    else:
        # New user - just verify the code, registration comes in next step
        await db.commit()

        logger.info(f"Phone {request.phone_number} verified, awaiting registration")

        # Return tokens without user data (they need to register)
        # We'll create a temporary token that expires quickly
        temp_token = create_access_token(
            {"sub": request.phone_number, "temp": True},
            expires_delta=timedelta(minutes=10)
        )

        return TokenResponse(
            access_token=temp_token,
            refresh_token="",
            token_type="Bearer",
            expires_in=600,  # 10 minutes
            user=None
        )


@router.post(
    "/register",
    response_model=TokenResponse,
    summary="Register new user after phone verification",
    description="Create new user account after phone number has been verified"
)
async def register_user(
    request: RegisterRequest,
    db: AsyncSession = Depends(get_db)
) -> TokenResponse:
    """
    Register new user after phone verification.

    Process:
    1. Verify phone number was verified recently
    2. Check phone number not already registered
    3. Validate referral code if provided
    4. Create new user account
    5. Set up referral chain if referred
    6. Return authentication tokens

    Args:
        request: Phone number and optional referral code
        db: Database session

    Returns:
        Access token, refresh token, and user data

    Raises:
        HTTPException: If phone not verified, already registered, or invalid referral
    """
    logger.info(f"Registering new user with phone {request.phone_number}")

    # Check if phone was verified recently (within last 10 minutes)
    result = await db.execute(
        select(VerificationCode).where(
            and_(
                VerificationCode.phone_number == request.phone_number,
                VerificationCode.is_used == True,
                VerificationCode.used_at >= datetime.utcnow() - timedelta(minutes=10)
            )
        ).order_by(VerificationCode.used_at.desc())
    )
    verification = result.scalar_one_or_none()

    if not verification:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number not verified. Please verify your phone first."
        )

    # Check if user already exists
    result = await db.execute(
        select(User).where(User.phone_number == request.phone_number)
    )
    existing_user = result.scalar_one_or_none()

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User with this phone number already exists"
        )

    # Validate referral code if provided
    referrer = None
    if request.referral_code:
        result = await db.execute(
            select(User).where(User.referral_code == request.referral_code)
        )
        referrer = result.scalar_one_or_none()

        if not referrer:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid referral code"
            )

    # Extract country code from phone number (assumes E.164 format)
    phone_country_code = "+49"  # Default to Germany
    if request.phone_number.startswith("+"):
        # Extract country code (1-3 digits after +)
        for i in range(1, min(5, len(request.phone_number))):
            if not request.phone_number[i].isdigit():
                break
            phone_country_code = request.phone_number[:i+1]

    # Generate unique referral code
    new_referral_code = await generate_unique_referral_code(db)

    # Create new user
    new_user = User(
        phone_number=request.phone_number,
        phone_country_code=phone_country_code,
        phone_verified=True,
        referral_code=new_referral_code,
        referred_by_code=request.referral_code,
        is_verified=True,  # Phone verified
        is_active=True,
        last_login_at=datetime.utcnow(),
    )

    db.add(new_user)
    await db.flush()  # Get user ID

    # Create referral chain if referred
    if referrer:
        await create_user_referral_chain(db, new_user, referrer)
        logger.info(f"User {new_user.id} referred by {referrer.id}")

    await db.commit()
    await db.refresh(new_user)

    # Send welcome SMS
    await sms_service.send_welcome_message(request.phone_number, new_user.referral_code)

    # Generate tokens
    access_token = create_access_token({"sub": str(new_user.id)})
    refresh_token = create_refresh_token({"sub": str(new_user.id)})

    logger.info(f"User {new_user.id} registered successfully via phone")

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="Bearer",
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=UserResponse.model_validate(new_user)
    )


@router.get(
    "/validate-referral",
    response_model=ValidateReferralResponse,
    summary="Validate referral code",
    description="Check if a referral code exists and is valid"
)
async def validate_referral_code(
    code: str,
    db: AsyncSession = Depends(get_db)
) -> ValidateReferralResponse:
    """
    Validate if referral code exists.

    Args:
        code: Referral code to validate
        db: Database session

    Returns:
        Validation result with code details if valid
    """
    logger.info(f"Validating referral code: {code}")

    result = await db.execute(
        select(User).where(User.referral_code == code)
    )
    user = result.scalar_one_or_none()

    if user:
        logger.info(f"Referral code {code} is valid (user {user.id})")
        return ValidateReferralResponse(valid=True, referral_code=code)
    else:
        logger.info(f"Referral code {code} not found")
        return ValidateReferralResponse(valid=False)
