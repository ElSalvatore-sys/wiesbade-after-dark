"""
Security utilities for authentication and authorization.
Includes password hashing, JWT token creation/validation, and referral code generation.
"""

import secrets
import string
from datetime import datetime, timedelta
from typing import Optional, Dict, Any

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings


# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """
    Hash a plain password using bcrypt.

    Args:
        password: Plain text password

    Returns:
        Hashed password string
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a plain password against a hashed password.

    Args:
        plain_password: Plain text password to verify
        hashed_password: Hashed password to compare against

    Returns:
        True if password matches, False otherwise
    """
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    """
    Create a JWT access token.

    Args:
        data: Dictionary of data to encode in the token
        expires_delta: Optional custom expiration time

    Returns:
        Encoded JWT token string
    """
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update({"exp": expire, "type": "access"})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

    return encoded_jwt


def create_refresh_token(data: Dict[str, Any]) -> str:
    """
    Create a JWT refresh token with longer expiration.

    Args:
        data: Dictionary of data to encode in the token

    Returns:
        Encoded JWT refresh token string
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})

    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def decode_token(token: str) -> Optional[Dict[str, Any]]:
    """
    Decode and validate a JWT token.

    Args:
        token: JWT token string to decode

    Returns:
        Decoded token payload if valid, None otherwise
    """
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None


def generate_referral_code(length: int = 8) -> str:
    """
    Generate a unique referral code.
    Excludes ambiguous characters (0, O, I, 1, l) for better readability.

    Args:
        length: Length of the referral code (default: 8)

    Returns:
        Random referral code string
    """
    # Characters excluding ambiguous ones: 0, O, I, 1, l
    safe_chars = ''.join(c for c in string.ascii_uppercase + string.digits
                        if c not in '0O1Il')

    return ''.join(secrets.choice(safe_chars) for _ in range(length))


def generate_verification_code(length: int = 6) -> str:
    """
    Generate a numeric verification code for email/phone verification.

    Args:
        length: Length of the code (default: 6)

    Returns:
        Random numeric code string
    """
    return ''.join(secrets.choice(string.digits) for _ in range(length))


def generate_password_reset_token() -> str:
    """
    Generate a secure token for password reset.

    Returns:
        URL-safe random token string
    """
    return secrets.token_urlsafe(32)
