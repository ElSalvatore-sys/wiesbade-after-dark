"""
Application configuration using Pydantic Settings.
Loads environment variables from .env file.
"""

from typing import List
from pydantic_settings import BaseSettings
from pydantic import Field, validator


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Database
    DATABASE_URL: str = Field(..., description="PostgreSQL connection string")

    # Security
    SECRET_KEY: str = Field(..., description="Secret key for JWT encoding")
    ALGORITHM: str = Field(default="HS256", description="JWT algorithm")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=15, description="Access token expiration in minutes")
    REFRESH_TOKEN_EXPIRE_DAYS: int = Field(default=30, description="Refresh token expiration in days")

    # CORS
    ALLOWED_ORIGINS: list[str] = Field(default=["*"], description="Allowed origins")

    # Stripe
    STRIPE_SECRET_KEY: str = Field(default="", description="Stripe secret key")
    STRIPE_PUBLISHABLE_KEY: str = Field(default="", description="Stripe publishable key")
    STRIPE_WEBHOOK_SECRET: str = Field(default="", description="Stripe webhook secret")

    # orderbird
    ORDERBIRD_API_KEY: str = Field(default="", description="orderbird API key")
    ORDERBIRD_API_URL: str = Field(default="https://api.orderbird.com/v1", description="orderbird API URL")

    # Twilio SMS
    TWILIO_ACCOUNT_SID: str = Field(default="", description="Twilio Account SID")
    TWILIO_AUTH_TOKEN: str = Field(default="", description="Twilio Auth Token")
    TWILIO_PHONE_NUMBER: str = Field(default="", description="Twilio Phone Number")

    # Email (Optional)
    SMTP_HOST: str = Field(default="", description="SMTP server host")
    SMTP_PORT: int = Field(default=587, description="SMTP server port")
    SMTP_USER: str = Field(default="", description="SMTP username")
    SMTP_PASSWORD: str = Field(default="", description="SMTP password")
    FROM_EMAIL: str = Field(default="noreply@wiesbadenafterdark.com", description="From email address")

    # App
    APP_NAME: str = Field(default="Wiesbaden After Dark", description="Application name")
    APP_VERSION: str = Field(default="1.0.0", description="Application version")
    DEBUG: bool = Field(default=False, description="Debug mode")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


# Global settings instance
settings = Settings()
