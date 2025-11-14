"""
Admin API response schemas.
Used for dashboard, analytics, and customer management endpoints.
"""

from datetime import datetime
from typing import Optional, List
from uuid import UUID
from decimal import Decimal

from pydantic import BaseModel, Field


# Dashboard Schemas

class DashboardStats(BaseModel):
    """Statistics for a specific time period."""

    revenue: Decimal = Field(default=Decimal("0.00"))
    transactions: int = Field(default=0)
    unique_customers: int = Field(default=0)
    points_issued: Decimal = Field(default=Decimal("0.00"))
    points_redeemed: Decimal = Field(default=Decimal("0.00"))
    avg_transaction_value: Decimal = Field(default=Decimal("0.00"))


class DashboardOverview(BaseModel):
    """Dashboard overview with stats for different time periods."""

    today: DashboardStats
    week: DashboardStats
    month: DashboardStats
    all_time: DashboardStats


class TopProduct(BaseModel):
    """Top selling product information."""

    product_id: UUID
    name: str
    category: str
    quantity_sold: int
    revenue: Decimal


class RecentTransaction(BaseModel):
    """Recent transaction summary for dashboard."""

    id: UUID
    user_name: str
    amount_total: Decimal
    points_earned: Decimal
    points_spent: Decimal
    created_at: datetime


class LowStockAlert(BaseModel):
    """Low stock product alert."""

    product_id: UUID
    name: str
    category: str
    stock_quantity: int
    low_stock_threshold: int
    deficit: int  # How many below threshold


class DashboardResponse(BaseModel):
    """Complete dashboard response with all sections."""

    overview: DashboardOverview
    top_products: List[TopProduct]
    recent_transactions: List[RecentTransaction]
    low_stock_alerts: List[LowStockAlert]


# Analytics Schemas

class RevenueDataPoint(BaseModel):
    """Single data point for revenue trend chart."""

    date: str  # YYYY-MM-DD format
    revenue: Decimal
    transactions: int
    unique_customers: int


class CustomerAcquisitionPoint(BaseModel):
    """Customer acquisition data point."""

    date: str  # YYYY-MM-DD format
    new_customers: int
    returning_customers: int


class PointsAnalysis(BaseModel):
    """Points issued vs redeemed analysis."""

    total_issued: Decimal
    total_redeemed: Decimal
    net_outstanding: Decimal
    redemption_rate: float  # Percentage


class ProductPerformance(BaseModel):
    """Product performance metrics."""

    product_id: UUID
    product_name: str
    category: str
    quantity_sold: int
    revenue: Decimal
    points_issued: Decimal
    avg_margin: Decimal


class ReferralImpact(BaseModel):
    """Referral program impact metrics."""

    total_referrals: int
    customers_from_referrals: int
    revenue_from_referrals: Decimal
    points_distributed: Decimal


class AnalyticsResponse(BaseModel):
    """Complete analytics response with trends and insights."""

    date_range: dict  # {start_date, end_date}
    revenue_trend: List[RevenueDataPoint]
    customer_acquisition: List[CustomerAcquisitionPoint]
    points_analysis: PointsAnalysis
    product_performance: List[ProductPerformance]
    referral_impact: ReferralImpact


# Customer Management Schemas

class VenueCustomer(BaseModel):
    """Customer information at a specific venue."""

    user_id: UUID
    full_name: str
    email: str
    points_earned: Decimal
    points_spent: Decimal
    points_available: Decimal
    total_visits: int
    current_streak: int
    longest_streak: int
    last_visit_date: Optional[datetime]
    lifetime_spending: Decimal  # Total EUR spent at this venue


class CustomerListResponse(BaseModel):
    """Paginated customer list response."""

    customers: List[VenueCustomer]
    total: int
    page: int
    page_size: int
    total_pages: int


# Product Management Schemas (some reused from product.py, some new)

class ProductWithStats(BaseModel):
    """Product with sales statistics for admin view."""

    id: UUID
    name: str
    description: Optional[str]
    category: str
    price: Decimal
    cost: Optional[Decimal]
    margin_percent: Optional[Decimal]
    stock_quantity: Optional[int]
    low_stock_threshold: Optional[int]
    is_low_stock: bool
    is_available: bool

    # Bonus information
    bonus_points_active: bool
    bonus_multiplier: Optional[Decimal]
    bonus_start_date: Optional[datetime]
    bonus_end_date: Optional[datetime]
    bonus_reason: Optional[str]
    is_bonus_active: bool

    # Sales statistics (calculated)
    total_sold: Optional[int] = Field(default=0)
    total_revenue: Optional[Decimal] = Field(default=Decimal("0.00"))

    # Timestamps
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True,
    }
