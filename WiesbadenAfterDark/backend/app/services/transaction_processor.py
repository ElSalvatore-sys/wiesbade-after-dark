"""
Transaction processing service.
Orchestrates the complete transaction flow including points calculation,
referral rewards, streak tracking, and database updates.
"""

from decimal import Decimal
from datetime import datetime
from typing import Optional, List, Dict, Tuple
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.user import User
from app.models.venue import Venue
from app.models.transaction import Transaction, TransactionType, TransactionStatus
from app.models.user_points import UserPoints
from app.models.product import Product
from app.schemas.transaction import TransactionCreate
from app.services.points_calculator import PointsCalculator


class TransactionProcessor:
    """
    Service for processing transactions with complete business logic.

    Handles:
    - Payment validation (cash + points = total)
    - Points calculation with margins and bonuses
    - Referral reward distribution (5 levels × 25%)
    - Visit streak tracking and milestone bonuses
    - Atomic database updates
    """

    @staticmethod
    async def create_transaction(
        db: AsyncSession,
        user: User,
        transaction_data: TransactionCreate
    ) -> Transaction:
        """
        Process a complete transaction with all business logic.

        This is the main entry point for transaction processing. It orchestrates:
        1. Validation (amounts, points balance, venue access)
        2. Points calculation (with margins and bonuses)
        3. Transaction record creation
        4. UserPoints updates (earn and spend)
        5. Referral reward distribution
        6. Visit streak tracking and milestone bonuses
        7. Venue statistics updates

        All operations are performed atomically within a database transaction.

        Args:
            db: Database session (must be within a transaction context)
            user: Current authenticated user
            transaction_data: Transaction creation data

        Returns:
            Created Transaction object with all related data

        Raises:
            HTTPException: 400 if validation fails
            HTTPException: 404 if venue not found
            HTTPException: 500 if processing fails
        """
        # Step 1: Validate and fetch venue
        venue = await TransactionProcessor._get_venue(db, transaction_data.venue_id)

        # Step 2: Validate payment amounts
        TransactionProcessor._validate_amounts(transaction_data)

        # Step 3: Validate and update points if spending
        user_points = None
        if transaction_data.amount_points > 0:
            user_points = await TransactionProcessor._validate_and_spend_points(
                db,
                user.id,
                transaction_data.venue_id,
                transaction_data.amount_points
            )

        # Step 4: Calculate points earned (only on cash portion)
        points_earned = await TransactionProcessor._calculate_points_earned(
            db,
            transaction_data.amount_cash,
            venue,
            transaction_data.order_items
        )

        # Step 5: Create main transaction record
        transaction = Transaction(
            user_id=user.id,
            venue_id=venue.id,
            transaction_type=TransactionType.PURCHASE,
            status=TransactionStatus.COMPLETED,
            amount_total=transaction_data.amount_total,
            amount_cash=transaction_data.amount_cash,
            amount_points=transaction_data.amount_points,
            points_earned=points_earned,
            points_spent=transaction_data.amount_points,
            payment_method=transaction_data.payment_method,
            order_items=TransactionProcessor._serialize_order_items(transaction_data.order_items),
            description="Purchase transaction",
        )
        db.add(transaction)
        await db.flush()  # Get transaction ID

        # Step 6: Update or create UserPoints for earning
        if points_earned > 0:
            if not user_points:
                # Get or create UserPoints
                result = await db.execute(
                    select(UserPoints).where(
                        UserPoints.user_id == user.id,
                        UserPoints.venue_id == venue.id
                    )
                )
                user_points = result.scalar_one_or_none()

                if not user_points:
                    user_points = UserPoints(
                        user_id=user.id,
                        venue_id=venue.id,
                        points_earned=Decimal("0"),
                        points_spent=Decimal("0"),
                        points_available=Decimal("0"),
                    )
                    db.add(user_points)
                    await db.flush()

            # Add earned points
            user_points.add_points(points_earned)

        # Step 7: Update visit streak and check for milestone bonuses
        streak_bonus = await TransactionProcessor._update_streak_and_check_milestone(
            db,
            user.id,
            venue.id,
            user_points
        )

        # Step 8: Process referral rewards (5 levels × 25% each)
        await PointsCalculator.process_referral_rewards(
            db,
            user.id,
            venue.id,
            points_earned,
            transaction.id
        )

        # Step 9: Update venue statistics
        await TransactionProcessor._update_venue_stats(
            db,
            venue,
            transaction_data.amount_cash,
            points_earned
        )

        # Step 10: Commit and refresh
        await db.commit()
        await db.refresh(transaction)

        return transaction

    @staticmethod
    async def _get_venue(db: AsyncSession, venue_id: UUID) -> Venue:
        """Fetch and validate venue exists."""
        result = await db.execute(
            select(Venue).where(Venue.id == venue_id)
        )
        venue = result.scalar_one_or_none()

        if not venue:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Venue with ID {venue_id} not found"
            )

        if not venue.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This venue is not currently active"
            )

        return venue

    @staticmethod
    def _validate_amounts(transaction_data: TransactionCreate) -> None:
        """Validate that cash + points = total."""
        calculated_total = transaction_data.amount_cash + transaction_data.amount_points
        difference = abs(calculated_total - transaction_data.amount_total)

        # Allow small rounding difference (1 cent)
        if difference > Decimal("0.01"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Amount mismatch: cash ({transaction_data.amount_cash}) + points ({transaction_data.amount_points}) must equal total ({transaction_data.amount_total})"
            )

        if transaction_data.amount_total <= 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Transaction amount must be greater than 0"
            )

    @staticmethod
    async def _validate_and_spend_points(
        db: AsyncSession,
        user_id: UUID,
        venue_id: UUID,
        amount_points: Decimal
    ) -> UserPoints:
        """
        Validate user has sufficient points and deduct them.

        Critical business rule: Points can ONLY be spent at the venue where they were earned.
        """
        result = await db.execute(
            select(UserPoints).where(
                UserPoints.user_id == user_id,
                UserPoints.venue_id == venue_id
            )
        )
        user_points = result.scalar_one_or_none()

        if not user_points or user_points.points_available < amount_points:
            available = user_points.points_available if user_points else Decimal("0")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Insufficient points at this venue. Available: {available:.2f}, Required: {amount_points:.2f}"
            )

        # Spend the points
        success = user_points.spend_points(amount_points)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to deduct points"
            )

        return user_points

    @staticmethod
    async def _calculate_points_earned(
        db: AsyncSession,
        amount_cash: Decimal,
        venue: Venue,
        order_items: Optional[List] = None
    ) -> Decimal:
        """
        Calculate points earned from cash portion of payment.

        Critical business rule: Points are ONLY earned on the cash portion,
        NOT on the points spent portion.
        """
        if amount_cash <= 0:
            return Decimal("0.00")

        # Convert order items to dict format if needed
        items_dict = None
        if order_items:
            items_dict = [
                {
                    "product_id": item.product_id if hasattr(item, 'product_id') else None,
                    "price": item.price if hasattr(item, 'price') else 0,
                    "quantity": item.quantity if hasattr(item, 'quantity') else 1,
                    "category": item.category if hasattr(item, 'category') else None,
                }
                for item in order_items
            ]

        points_earned = PointsCalculator.calculate_order_points(
            amount_cash,
            venue,
            items_dict,
            db
        )

        return points_earned

    @staticmethod
    async def _update_streak_and_check_milestone(
        db: AsyncSession,
        user_id: UUID,
        venue_id: UUID,
        user_points: Optional[UserPoints]
    ) -> Decimal:
        """
        Update visit streak and create bonus transaction if milestone reached.

        Returns the bonus points awarded (if any).
        """
        if not user_points:
            # Get UserPoints
            result = await db.execute(
                select(UserPoints).where(
                    UserPoints.user_id == user_id,
                    UserPoints.venue_id == venue_id
                )
            )
            user_points = result.scalar_one_or_none()

        if not user_points:
            # No points record yet, will be created when points are earned
            return Decimal("0.00")

        # Update streak (returns bonus points if milestone reached)
        bonus_points = user_points.update_streak()

        # If milestone bonus was awarded, create transaction
        if bonus_points > 0:
            streak_transaction = Transaction(
                user_id=user_id,
                venue_id=venue_id,
                transaction_type=TransactionType.STREAK_BONUS,
                status=TransactionStatus.COMPLETED,
                amount_total=Decimal("0"),
                amount_cash=Decimal("0"),
                amount_points=Decimal("0"),
                points_earned=bonus_points,
                points_spent=Decimal("0"),
                description=f"Streak milestone bonus - {user_points.current_streak} day streak!",
            )
            db.add(streak_transaction)

        return bonus_points

    @staticmethod
    async def _update_venue_stats(
        db: AsyncSession,
        venue: Venue,
        amount_cash: Decimal,
        points_issued: Decimal
    ) -> None:
        """Update venue statistics."""
        venue.total_revenue = (venue.total_revenue or Decimal("0")) + amount_cash
        venue.total_points_issued = (venue.total_points_issued or Decimal("0")) + points_issued

    @staticmethod
    def _serialize_order_items(order_items: Optional[List]) -> Optional[List[Dict]]:
        """Convert order items to JSON-serializable format."""
        if not order_items:
            return None

        serialized = []
        for item in order_items:
            serialized.append({
                "product_id": str(item.product_id) if item.product_id else None,
                "name": item.name,
                "quantity": item.quantity,
                "price": float(item.price),
                "category": item.category,
            })

        return serialized

    @staticmethod
    async def get_user_transactions(
        db: AsyncSession,
        user_id: UUID,
        venue_id: Optional[UUID] = None,
        transaction_type: Optional[TransactionType] = None,
        limit: int = 20,
        offset: int = 0
    ) -> Tuple[List[Transaction], int]:
        """
        Get user's transaction history with optional filters.

        Args:
            db: Database session
            user_id: User ID
            venue_id: Optional filter by venue
            transaction_type: Optional filter by type
            limit: Number of results per page
            offset: Offset for pagination

        Returns:
            Tuple of (transactions list, total count)
        """
        # Build query
        query = select(Transaction).where(Transaction.user_id == user_id)

        if venue_id:
            query = query.where(Transaction.venue_id == venue_id)

        if transaction_type:
            query = query.where(Transaction.transaction_type == transaction_type)

        # Get total count
        from sqlalchemy import func
        count_query = select(func.count()).select_from(query.subquery())
        total_result = await db.execute(count_query)
        total = total_result.scalar()

        # Get paginated results
        query = query.order_by(Transaction.created_at.desc()).limit(limit).offset(offset)
        result = await db.execute(query)
        transactions = result.scalars().all()

        return list(transactions), total or 0
