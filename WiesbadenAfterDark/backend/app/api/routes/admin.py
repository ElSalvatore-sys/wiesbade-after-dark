"""
Admin API routes for venue owners.
Handles dashboard, analytics, product management, and customer insights.
"""

from datetime import datetime, timedelta
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Query, Path
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_, desc, asc
from decimal import Decimal

from app.db.session import get_db
from app.api.dependencies import get_current_user, get_venue_owner
from app.models.user import User
from app.models.venue import Venue
from app.models.product import Product
from app.models.transaction import Transaction, TransactionType, TransactionStatus
from app.models.user_points import UserPoints
from app.schemas.admin import (
    DashboardResponse,
    DashboardOverview,
    DashboardStats,
    TopProduct,
    RecentTransaction,
    LowStockAlert,
    AnalyticsResponse,
    RevenueDataPoint,
    CustomerAcquisitionPoint,
    PointsAnalysis,
    ProductPerformance,
    ReferralImpact,
    VenueCustomer,
    CustomerListResponse,
    ProductWithStats,
)
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse, BonusActivation


router = APIRouter()


# Helper function for time-based stats
async def _get_stats_for_period(
    db: AsyncSession,
    venue_id: UUID,
    start_date: datetime,
    end_date: Optional[datetime] = None
) -> DashboardStats:
    """
    Calculate dashboard statistics for a specific time period.

    Args:
        db: Database session
        venue_id: Venue ID
        start_date: Start of period
        end_date: End of period (None = now)

    Returns:
        DashboardStats with aggregated metrics
    """
    if end_date is None:
        end_date = datetime.utcnow()

    # Query transactions in period
    result = await db.execute(
        select(
            func.count(Transaction.id).label('transaction_count'),
            func.coalesce(func.sum(Transaction.amount_total), 0).label('total_revenue'),
            func.count(func.distinct(Transaction.user_id)).label('unique_customers'),
            func.coalesce(func.sum(Transaction.points_earned), 0).label('points_issued'),
            func.coalesce(func.sum(Transaction.points_spent), 0).label('points_redeemed'),
        ).where(
            and_(
                Transaction.venue_id == venue_id,
                Transaction.status == TransactionStatus.COMPLETED,
                Transaction.created_at >= start_date,
                Transaction.created_at < end_date
            )
        )
    )
    stats = result.one()

    # Calculate average transaction value
    avg_value = Decimal("0.00")
    if stats.transaction_count > 0:
        avg_value = Decimal(str(stats.total_revenue)) / stats.transaction_count

    return DashboardStats(
        revenue=Decimal(str(stats.total_revenue)),
        transactions=stats.transaction_count,
        unique_customers=stats.unique_customers,
        points_issued=Decimal(str(stats.points_issued)),
        points_redeemed=Decimal(str(stats.points_redeemed)),
        avg_transaction_value=avg_value.quantize(Decimal("0.01"))
    )


@router.get("/venues/{venue_id}/dashboard", response_model=DashboardResponse)
async def get_venue_dashboard(
    venue: Venue = Depends(get_venue_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Get comprehensive dashboard for venue owner.

    Returns metrics for:
    - Today (since midnight)
    - This week (last 7 days)
    - This month (last 30 days)
    - All time

    Plus:
    - Top 5 selling products this week
    - Last 10 transactions
    - Products with low stock

    Args:
        venue: Venue object (from dependency, validates ownership)
        db: Database session

    Returns:
        Complete dashboard with all sections
    """
    now = datetime.utcnow()
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    week_start = now - timedelta(days=7)
    month_start = now - timedelta(days=30)

    # Get stats for each period
    today_stats = await _get_stats_for_period(db, venue.id, today_start, now)
    week_stats = await _get_stats_for_period(db, venue.id, week_start, now)
    month_stats = await _get_stats_for_period(db, venue.id, month_start, now)
    all_time_stats = await _get_stats_for_period(
        db, venue.id, datetime(2020, 1, 1), now
    )

    overview = DashboardOverview(
        today=today_stats,
        week=week_stats,
        month=month_stats,
        all_time=all_time_stats
    )

    # Get top 5 products this week
    top_products_result = await db.execute(
        select(Product).where(
            Product.venue_id == venue.id
        ).order_by(
            desc(Product.total_sold)
        ).limit(5)
    )
    products = top_products_result.scalars().all()

    top_products = [
        TopProduct(
            product_id=p.id,
            name=p.name,
            category=p.category,
            quantity_sold=p.total_sold or 0,
            revenue=p.total_revenue or Decimal("0.00")
        )
        for p in products
    ]

    # Get recent transactions (last 10)
    recent_txns_result = await db.execute(
        select(Transaction, User).join(
            User, Transaction.user_id == User.id
        ).where(
            Transaction.venue_id == venue.id
        ).order_by(
            desc(Transaction.created_at)
        ).limit(10)
    )
    txns_with_users = recent_txns_result.all()

    recent_transactions = [
        RecentTransaction(
            id=txn.id,
            user_name=f"{user.first_name or ''} {user.last_name or ''}".strip() or user.email,
            amount_total=txn.amount_total,
            points_earned=txn.points_earned,
            points_spent=txn.points_spent,
            created_at=txn.created_at
        )
        for txn, user in txns_with_users
    ]

    # Get low stock alerts
    low_stock_result = await db.execute(
        select(Product).where(
            and_(
                Product.venue_id == venue.id,
                Product.is_available == True,
                Product.stock_quantity != None,
                Product.low_stock_threshold != None,
                Product.stock_quantity <= Product.low_stock_threshold
            )
        ).order_by(
            asc(Product.stock_quantity)
        )
    )
    low_stock_products = low_stock_result.scalars().all()

    low_stock_alerts = [
        LowStockAlert(
            product_id=p.id,
            name=p.name,
            category=p.category,
            stock_quantity=p.stock_quantity,
            low_stock_threshold=p.low_stock_threshold,
            deficit=p.low_stock_threshold - p.stock_quantity
        )
        for p in low_stock_products
    ]

    return DashboardResponse(
        overview=overview,
        top_products=top_products,
        recent_transactions=recent_transactions,
        low_stock_alerts=low_stock_alerts
    )


@router.get("/venues/{venue_id}/products", response_model=List[ProductWithStats])
async def list_venue_products(
    venue: Venue = Depends(get_venue_owner),
    category: Optional[str] = Query(None, description="Filter by category"),
    has_active_bonus: Optional[bool] = Query(None, description="Filter by active bonus"),
    in_stock_only: bool = Query(False, description="Only show items in stock"),
    db: AsyncSession = Depends(get_db)
):
    """
    List all products for venue management.

    Unlike the public endpoint, this includes inactive products for admin purposes.

    Args:
        venue: Venue object (validates ownership)
        category: Optional category filter
        has_active_bonus: Optional filter for products with active bonuses
        in_stock_only: Only show products in stock
        db: Database session

    Returns:
        List of products with full details and statistics
    """
    query = select(Product).where(Product.venue_id == venue.id)

    if category:
        query = query.where(Product.category == category)

    if has_active_bonus is not None:
        now = datetime.utcnow()
        if has_active_bonus:
            query = query.where(
                and_(
                    Product.bonus_points_active == True,
                    or_(
                        Product.bonus_start_date == None,
                        Product.bonus_start_date <= now
                    ),
                    or_(
                        Product.bonus_end_date == None,
                        Product.bonus_end_date >= now
                    )
                )
            )
        else:
            query = query.where(Product.bonus_points_active == False)

    if in_stock_only:
        query = query.where(Product.stock_quantity > 0)

    query = query.order_by(Product.category, Product.name)

    result = await db.execute(query)
    products = result.scalars().all()

    return [ProductWithStats.model_validate(p) for p in products]


@router.post("/venues/{venue_id}/products", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    product_data: ProductCreate,
    venue: Venue = Depends(get_venue_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Create a new product for the venue.

    Auto-calculates margin_percent if cost is provided.

    Args:
        product_data: Product creation data
        venue: Venue object (validates ownership)
        db: Database session

    Returns:
        Created product

    Raises:
        HTTPException: 400 if validation fails
    """
    # Calculate margin if cost provided
    margin_percent = None
    if product_data.cost and product_data.price > 0:
        margin_percent = ((product_data.price - product_data.cost) / product_data.price) * 100

    # Create product
    new_product = Product(
        venue_id=venue.id,
        name=product_data.name,
        description=product_data.description,
        category=product_data.category,
        price=product_data.price,
        cost=product_data.cost,
        margin_percent=margin_percent,
        sku=product_data.sku,
        stock_quantity=product_data.stock_quantity,
        low_stock_threshold=product_data.low_stock_threshold,
        orderbird_product_id=product_data.orderbird_product_id,
        image_url=product_data.image_url,
    )

    db.add(new_product)
    await db.commit()
    await db.refresh(new_product)

    return ProductResponse.model_validate(new_product)


@router.put("/venues/{venue_id}/products/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: UUID = Path(...),
    product_data: ProductUpdate = None,
    venue: Venue = Depends(get_venue_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Update an existing product.

    Only updates provided fields. Recalculates margin if cost or price updated.

    Args:
        product_id: Product UUID
        product_data: Update data
        venue: Venue object (validates ownership)
        db: Database session

    Returns:
        Updated product

    Raises:
        HTTPException: 404 if product not found
        HTTPException: 403 if product doesn't belong to venue
    """
    # Get product
    result = await db.execute(
        select(Product).where(Product.id == product_id)
    )
    product = result.scalar_one_or_none()

    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Product with ID {product_id} not found"
        )

    # Verify ownership
    if product.venue_id != venue.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This product does not belong to your venue"
        )

    # Update fields
    update_dict = product_data.model_dump(exclude_unset=True)

    for field, value in update_dict.items():
        setattr(product, field, value)

    # Recalculate margin if cost or price changed
    if ('cost' in update_dict or 'price' in update_dict) and product.cost and product.price > 0:
        product.margin_percent = ((product.price - product.cost) / product.price) * 100

    await db.commit()
    await db.refresh(product)

    return ProductResponse.model_validate(product)


@router.delete("/venues/{venue_id}/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    product_id: UUID = Path(...),
    venue: Venue = Depends(get_venue_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Soft delete a product (sets is_available = False).

    Doesn't actually remove from database to preserve transaction history.

    Args:
        product_id: Product UUID
        venue: Venue object (validates ownership)
        db: Database session

    Raises:
        HTTPException: 404 if product not found
        HTTPException: 403 if product doesn't belong to venue
    """
    # Get product
    result = await db.execute(
        select(Product).where(Product.id == product_id)
    )
    product = result.scalar_one_or_none()

    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Product with ID {product_id} not found"
        )

    # Verify ownership
    if product.venue_id != venue.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This product does not belong to your venue"
        )

    # Soft delete
    product.is_available = False
    await db.commit()


@router.post("/venues/{venue_id}/products/{product_id}/bonus", response_model=ProductResponse)
async def activate_product_bonus(
    product_id: UUID = Path(...),
    bonus_data: BonusActivation = None,
    venue: Venue = Depends(get_venue_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Activate bonus points promotion on a product.

    This is THE KEY FEATURE - allows venue owners to set bonus points on specific
    products to move excess inventory.

    Example: Set 2x points on apple juice to clear excess stock before expiration.

    Args:
        product_id: Product UUID
        bonus_data: Bonus activation data (multiplier, dates, reason)
        venue: Venue object (validates ownership)
        db: Database session

    Returns:
        Updated product with active bonus

    Raises:
        HTTPException: 404 if product not found
        HTTPException: 403 if product doesn't belong to venue
        HTTPException: 400 if dates invalid
    """
    # Get product
    result = await db.execute(
        select(Product).where(Product.id == product_id)
    )
    product = result.scalar_one_or_none()

    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Product with ID {product_id} not found"
        )

    # Verify ownership
    if product.venue_id != venue.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This product does not belong to your venue"
        )

    # Validate dates
    if bonus_data.start_date and bonus_data.end_date:
        if bonus_data.end_date <= bonus_data.start_date:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="End date must be after start date"
            )

    # Activate bonus using model method
    product.activate_bonus(
        multiplier=float(bonus_data.bonus_multiplier),
        start_date=bonus_data.start_date,
        end_date=bonus_data.end_date,
        reason=bonus_data.reason
    )

    await db.commit()
    await db.refresh(product)

    return ProductResponse.model_validate(product)


@router.delete("/venues/{venue_id}/products/{product_id}/bonus", response_model=ProductResponse)
async def deactivate_product_bonus(
    product_id: UUID = Path(...),
    venue: Venue = Depends(get_venue_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Deactivate bonus points promotion on a product.

    Args:
        product_id: Product UUID
        venue: Venue object (validates ownership)
        db: Database session

    Returns:
        Updated product without bonus

    Raises:
        HTTPException: 404 if product not found
        HTTPException: 403 if product doesn't belong to venue
    """
    # Get product
    result = await db.execute(
        select(Product).where(Product.id == product_id)
    )
    product = result.scalar_one_or_none()

    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Product with ID {product_id} not found"
        )

    # Verify ownership
    if product.venue_id != venue.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This product does not belong to your venue"
        )

    # Deactivate bonus using model method
    product.deactivate_bonus()

    await db.commit()
    await db.refresh(product)

    return ProductResponse.model_validate(product)


@router.get("/venues/{venue_id}/analytics", response_model=AnalyticsResponse)
async def get_venue_analytics(
    venue: Venue = Depends(get_venue_owner),
    start_date: Optional[datetime] = Query(None, description="Start date for analytics (default: 30 days ago)"),
    end_date: Optional[datetime] = Query(None, description="End date for analytics (default: now)"),
    db: AsyncSession = Depends(get_db)
):
    """
    Get detailed analytics with date range filtering.

    Provides business intelligence including:
    - Revenue trends (daily)
    - Customer acquisition (new vs returning)
    - Points analysis (issued vs redeemed)
    - Product performance by category
    - Referral program impact

    Args:
        venue: Venue object (validates ownership)
        start_date: Start of analysis period (default: 30 days ago)
        end_date: End of analysis period (default: now)
        db: Database session

    Returns:
        Complete analytics with trends and insights
    """
    now = datetime.utcnow()
    if not end_date:
        end_date = now
    if not start_date:
        start_date = end_date - timedelta(days=30)

    # Revenue trend (daily grouping)
    revenue_query = select(
        func.date(Transaction.created_at).label('date'),
        func.sum(Transaction.amount_total).label('revenue'),
        func.count(Transaction.id).label('transactions'),
        func.count(func.distinct(Transaction.user_id)).label('unique_customers')
    ).where(
        and_(
            Transaction.venue_id == venue.id,
            Transaction.status == TransactionStatus.COMPLETED,
            Transaction.created_at >= start_date,
            Transaction.created_at < end_date
        )
    ).group_by(
        func.date(Transaction.created_at)
    ).order_by(
        func.date(Transaction.created_at)
    )

    revenue_result = await db.execute(revenue_query)
    revenue_data = revenue_result.all()

    revenue_trend = [
        RevenueDataPoint(
            date=str(row.date),
            revenue=Decimal(str(row.revenue or 0)),
            transactions=row.transactions,
            unique_customers=row.unique_customers
        )
        for row in revenue_data
    ]

    # Customer acquisition (simplified - first visit vs repeat)
    # For demo purposes, using transaction counts
    customer_acquisition = [
        CustomerAcquisitionPoint(
            date=str(row.date),
            new_customers=0,  # Would need UserPoints.first_visit tracking
            returning_customers=row.unique_customers
        )
        for row in revenue_data
    ]

    # Points analysis
    points_query = select(
        func.sum(Transaction.points_earned).label('issued'),
        func.sum(Transaction.points_spent).label('redeemed')
    ).where(
        and_(
            Transaction.venue_id == venue.id,
            Transaction.status == TransactionStatus.COMPLETED,
            Transaction.created_at >= start_date,
            Transaction.created_at < end_date
        )
    )

    points_result = await db.execute(points_query)
    points_data = points_result.one()

    total_issued = Decimal(str(points_data.issued or 0))
    total_redeemed = Decimal(str(points_data.redeemed or 0))
    redemption_rate = 0.0
    if total_issued > 0:
        redemption_rate = float((total_redeemed / total_issued) * 100)

    points_analysis = PointsAnalysis(
        total_issued=total_issued,
        total_redeemed=total_redeemed,
        net_outstanding=total_issued - total_redeemed,
        redemption_rate=round(redemption_rate, 2)
    )

    # Product performance (top 10)
    product_result = await db.execute(
        select(Product).where(
            Product.venue_id == venue.id
        ).order_by(
            desc(Product.total_revenue)
        ).limit(10)
    )
    top_products = product_result.scalars().all()

    product_performance = [
        ProductPerformance(
            product_id=p.id,
            product_name=p.name,
            category=p.category,
            quantity_sold=p.total_sold or 0,
            revenue=p.total_revenue or Decimal("0.00"),
            points_issued=Decimal("0.00"),  # Would need to track per product
            avg_margin=p.margin_percent or Decimal("0.00")
        )
        for p in top_products
    ]

    # Referral impact
    referral_query = select(
        func.count(Transaction.id).label('count'),
        func.sum(Transaction.points_earned).label('points')
    ).where(
        and_(
            Transaction.venue_id == venue.id,
            Transaction.transaction_type == TransactionType.REFERRAL_BONUS,
            Transaction.created_at >= start_date,
            Transaction.created_at < end_date
        )
    )

    referral_result = await db.execute(referral_query)
    referral_data = referral_result.one()

    referral_impact = ReferralImpact(
        total_referrals=referral_data.count,
        customers_from_referrals=0,  # Would need to track
        revenue_from_referrals=Decimal("0.00"),  # Would need to track
        points_distributed=Decimal(str(referral_data.points or 0))
    )

    return AnalyticsResponse(
        date_range={"start_date": str(start_date.date()), "end_date": str(end_date.date())},
        revenue_trend=revenue_trend,
        customer_acquisition=customer_acquisition,
        points_analysis=points_analysis,
        product_performance=product_performance,
        referral_impact=referral_impact
    )


@router.get("/venues/{venue_id}/customers", response_model=CustomerListResponse)
async def list_venue_customers(
    venue: Venue = Depends(get_venue_owner),
    sort_by: str = Query("points", regex="^(points|spending|visits|last_visit)$", description="Sort field"),
    order: str = Query("desc", regex="^(asc|desc)$", description="Sort order"),
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(50, ge=1, le=100, description="Items per page"),
    db: AsyncSession = Depends(get_db)
):
    """
    List all customers who have visited this venue.

    Shows complete customer information including:
    - Points earned, spent, and available
    - Visit count and streaks
    - Last visit date
    - Lifetime spending

    Args:
        venue: Venue object (validates ownership)
        sort_by: Sort field (points, spending, visits, last_visit)
        order: Sort order (asc, desc)
        page: Page number (1-indexed)
        page_size: Items per page (max 100)
        db: Database session

    Returns:
        Paginated list of customers with statistics
    """
    # Calculate offset
    offset = (page - 1) * page_size

    # Base query: JOIN UserPoints with User
    query = select(UserPoints, User).join(
        User, UserPoints.user_id == User.id
    ).where(
        UserPoints.venue_id == venue.id
    )

    # Apply sorting
    if sort_by == "points":
        sort_column = UserPoints.points_available
    elif sort_by == "spending":
        sort_column = UserPoints.points_spent  # Proxy for spending
    elif sort_by == "visits":
        sort_column = UserPoints.total_visits
    elif sort_by == "last_visit":
        sort_column = UserPoints.last_visit_date
    else:
        sort_column = UserPoints.points_available

    if order == "desc":
        query = query.order_by(desc(sort_column))
    else:
        query = query.order_by(asc(sort_column))

    # Get total count
    count_query = select(func.count()).select_from(
        select(UserPoints).where(UserPoints.venue_id == venue.id).subquery()
    )
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # Get paginated results
    query = query.limit(page_size).offset(offset)
    result = await db.execute(query)
    customer_data = result.all()

    # Build customer list
    customers = []
    for user_points, user in customer_data:
        full_name = f"{user.first_name or ''} {user.last_name or ''}".strip()
        if not full_name:
            full_name = user.email.split('@')[0]  # Use email prefix if no name

        # Calculate lifetime spending (points spent represent value)
        lifetime_spending = user_points.points_spent

        customers.append(
            VenueCustomer(
                user_id=user.id,
                full_name=full_name,
                email=user.email,
                points_earned=user_points.points_earned,
                points_spent=user_points.points_spent,
                points_available=user_points.points_available,
                total_visits=user_points.total_visits,
                current_streak=user_points.current_streak,
                longest_streak=user_points.longest_streak,
                last_visit_date=user_points.last_visit_date,
                lifetime_spending=lifetime_spending
            )
        )

    # Calculate total pages
    total_pages = (total + page_size - 1) // page_size if total > 0 else 0

    return CustomerListResponse(
        customers=customers,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )
