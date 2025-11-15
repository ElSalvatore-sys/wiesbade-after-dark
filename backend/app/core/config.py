"""
Configuration settings for WiesbadenAfterDark API
"""
import os
from pydantic_settings import BaseSettings
from pydantic import Field
from typing import Optional


class Settings(BaseSettings):
    """Application settings"""

    # API Settings
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "WiesbadenAfterDark API"
    VERSION: str = "1.0.0"

    # Database Settings (Supabase PostgreSQL)
    DATABASE_URL: str

    # Supabase Settings (Optional - not critical for basic operation)
    SUPABASE_URL: Optional[str] = None
    SUPABASE_KEY: Optional[str] = None
    SUPABASE_JWT_SECRET: Optional[str] = None

    # JWT Settings
    SECRET_KEY: str = Field(
        default_factory=lambda: os.getenv("SECRET_KEY")
        or os.getenv("JWT_SECRET_KEY")
        or "dev-secret-key-change-in-production"
    )
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    # Points Expiration
    POINTS_EXPIRATION_DAYS: int = 180

    # CORS - Restricted to production backend and localhost for development
    BACKEND_CORS_ORIGINS: list[str] = [
        "https://wiesbade-after-dark-production.up.railway.app",
        "http://localhost:3000",
        "http://localhost:8000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
    ]

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
