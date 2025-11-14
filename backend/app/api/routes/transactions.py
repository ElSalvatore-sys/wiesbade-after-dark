"""
Transactions API routes.
Handles transaction creation, listing, and details.
"""

from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.api.dependencies import get_current_user
from app.models.user import User
from app.models.transaction import Transaction, TransactionType
from app.schemas.transaction import (
    TransactionCreate,
    TransactionResponse,
    TransactionListResponse,
)
from app.services.transaction_processor import TransactionProcessor


router = APIRouter()


@router.post("", response_model=TransactionResponse, status_code=status.HTTP_201_CREATED)
async def create_transaction(
    transaction_data: TransactionCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Create a new transaction (purchase with mixed payment: cash + points).

    This is the core endpoint for processing purchases. It handles:
    - Payment validation (cash + points = total)
    - Points calculation based on venue margins and product bonuses
    - Points spending (only at venue where earned)
    - Referral reward distribution (5 levels × 25% each)
    - Visit streak tracking with milestone bonuses
    - All updates are atomic (rollback on any error)

    Business Rules:
    - Points are ONLY earned on the cash portion (not on points spent)
    - Points can ONLY be spent at the venue where they were earned
    - Each referrer in the chain gets 25% of points earned
    - Visit streaks award bonuses at 7, 14, and 30 days

    Args:
        transaction_data: Transaction creation data
        current_user: Authenticated user
        db: Database session

    Returns:
        Created transaction with complete details

    Raises:
        HTTPException: 400 if validation fails (invalid amounts, insufficient points)
        HTTPException: 404 if venue not found
        HTTPException: 500 if processing fails

    Example Request:
        {
            "venue_id": "uuid",
            "amount_total": 100.00,
            "amount_cash": 95.00,
            "amount_points": 5.00,
            "order_items": [
                {
                    "product_id": "uuid",
                    "name": "Beer",
                    "quantity": 2,
                    "price": 50.00,
                    "category": "beverages"
                }
            ],
            "payment_method": "card"
        }
    """
    try:
        # Process transaction with all business logic
        transaction = await TransactionProcessor.create_transaction(
            db,
            current_user,
            transaction_data
        )

        return TransactionResponse.model_validate(transaction)

    except HTTPException:
        # Re-raise HTTP exceptions (validation errors, etc.)
        raise

    except Exception as e:
        # Log error and return generic message
        print(f"Transaction processing error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to process transaction. Please try again."
        )


@router.get("", response_model=TransactionListResponse)
async def list_transactions(
    venue_id: Optional[UUID] = Query(None, description="Filter by venue ID"),
    transaction_type: Optional[TransactionType] = Query(None, description="Filter by transaction type"),
    page: int = Query(1, ge=1, description="Page number (1-indexed)"),
    per_page: int = Query(20, ge=1, le=100, description="Items per page (max 100)"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get current user's transaction history with optional filters and pagination.

    Supports filtering by:
    - venue_id: Show only transactions at a specific venue
    - transaction_type: Filter by type (purchase, referral_bonus, streak_bonus, etc.)

    Transactions are returned in reverse chronological order (newest first).

    Args:
        venue_id: Optional venue filter
        transaction_type: Optional transaction type filter
        page: Page number (1-indexed)
        per_page: Number of items per page (max 100)
        current_user: Authenticated user
        db: Database session

    Returns:
        Paginated list of transactions with metadata

    Example Response:
        {
            "transactions": [...],
            "total": 150,
            "page": 1,
            "per_page": 20,
            "total_pages": 8
        }
    """
    # Calculate offset
    offset = (page - 1) * per_page

    # Get transactions with filters
    transactions, total = await TransactionProcessor.get_user_transactions(
        db,
        current_user.id,
        venue_id=venue_id,
        transaction_type=transaction_type,
        limit=per_page,
        offset=offset
    )

    # Calculate total pages
    total_pages = (total + per_page - 1) // per_page if total > 0 else 0

    return TransactionListResponse(
        transactions=[TransactionResponse.model_validate(t) for t in transactions],
        total=total,
        page=page,
        per_page=per_page,
        total_pages=total_pages,
    )


@router.get("/{transaction_id}", response_model=TransactionResponse)
async def get_transaction(
    transaction_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get detailed information about a specific transaction.

    Only returns transactions that belong to the current user.

    Args:
        transaction_id: Transaction UUID
        current_user: Authenticated user
        db: Database session

    Returns:
        Transaction details

    Raises:
        HTTPException: 404 if transaction not found or doesn't belong to user
    """
    # Get transaction
    result = await db.execute(
        select(Transaction).where(Transaction.id == transaction_id)
    )
    transaction = result.scalar_one_or_none()

    if not transaction:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transaction with ID {transaction_id} not found"
        )

    # Verify transaction belongs to current user
    if transaction.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to view this transaction"
        )

    return TransactionResponse.model_validate(transaction)
