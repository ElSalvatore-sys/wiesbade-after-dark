"""
Pydantic schemas for Transaction-related API requests and responses.
"""

from datetime import datetime
from typing import Optional, List
from uuid import UUID

from pydantic import BaseModel, Field


class OrderItem(BaseModel):
    """Schema for an item in an order."""
    product_id: Optional[UUID] = None
    name: str
    quantity: int = Field(..., gt=0)
    price: float = Field(..., ge=0)
    category: str


class TransactionCreate(BaseModel):
    """Schema for creating a transaction."""
    venue_id: UUID
    amount_total: float = Field(..., gt=0)
    amount_cash: float = Field(default=0, ge=0)
    amount_points: float = Field(default=0, ge=0)
    order_items: Optional[List[OrderItem]] = None
    category: Optional[str] = None
    payment_method: Optional[str] = "cash"  # cash, card, stripe
    notes: Optional[str] = None


class TransactionResponse(BaseModel):
    """Schema for transaction data in responses."""
    id: UUID
    user_id: UUID
    venue_id: UUID
    transaction_type: str
    status: str
    amount_total: float
    amount_cash: float
    amount_points: float
    points_earned: float
    points_spent: float
    points_multiplier: float
    payment_method: Optional[str]
    order_items: Optional[List[dict]]
    category: Optional[str]
    created_at: datetime
    completed_at: Optional[datetime]
    net_points_change: float  # Computed property

    class Config:
        from_attributes = True


class TransactionListResponse(BaseModel):
    """Schema for paginated transaction list."""
    transactions: List[TransactionResponse]
    total: int
    page: int
    page_size: int
    has_more: bool
