"""
Pydantic schemas for Product-related API requests and responses.
"""

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class ProductResponse(BaseModel):
    """Schema for product data in responses."""
    id: UUID
    venue_id: UUID
    name: str
    description: Optional[str]
    category: str
    price: float
    margin_percent: Optional[float]
    stock_quantity: int
    is_available: bool
    bonus_points_active: bool
    bonus_multiplier: float
    bonus_start_date: Optional[datetime]
    bonus_end_date: Optional[datetime]
    bonus_reason: Optional[str]
    image_url: Optional[str]
    total_sold: int
    is_featured: bool
    effective_points_multiplier: float  # Computed property
    is_bonus_active: bool  # Computed property
    is_low_stock: bool  # Computed property

    class Config:
        from_attributes = True


class ProductCreate(BaseModel):
    """Schema for creating a product."""
    name: str = Field(..., min_length=1)
    description: Optional[str] = None
    category: str
    price: float = Field(..., gt=0)
    cost: Optional[float] = None
    margin_percent: Optional[float] = None
    stock_quantity: int = Field(default=0, ge=0)
    low_stock_threshold: int = Field(default=10, ge=0)
    is_available: bool = True
    image_url: Optional[str] = None
    sku: Optional[str] = None


class ProductUpdate(BaseModel):
    """Schema for updating a product."""
    name: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    price: Optional[float] = Field(None, gt=0)
    cost: Optional[float] = None
    margin_percent: Optional[float] = None
    stock_quantity: Optional[int] = Field(None, ge=0)
    is_available: Optional[bool] = None
    image_url: Optional[str] = None


class BonusActivation(BaseModel):
    """Schema for activating bonus points on a product."""
    bonus_multiplier: float = Field(..., gt=1.0, le=10.0)  # e.g., 2.0 for double points
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    reason: Optional[str] = None
