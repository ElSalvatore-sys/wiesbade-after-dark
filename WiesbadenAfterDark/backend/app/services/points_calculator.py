"""
Points calculation service.
Handles all points calculations based on venue margins, product bonuses, and multipliers.
"""

from decimal import Decimal, ROUND_HALF_UP
from typing import Optional, List, Dict
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.venue import Venue
from app.models.product import Product
from app.models.user_points import UserPoints
from app.models.referral import ReferralChain
from app.models.transaction import Transaction, TransactionType
from app.models.user import User


class PointsCalculator:
    """
    Service for calculating points earned based on venue margins and product bonuses.

    Implements the business rule:
        Points = amount × 10% × (category_margin / highest_venue_margin) × product_bonus × venue_multiplier
    """

    BASE_POINTS_RATE = Decimal("0.10")  # 10% base rate
    REFERRAL_REWARD_PERCENTAGE = Decimal("0.25")  # 25% per referral level

    @staticmethod
    def calculate_base_points(
        amount: Decimal,
        venue: Venue,
        category: Optional[str] = None
    ) -> Decimal:
        """
        Calculate base points earned from a purchase amount.

        Formula: amount × 10% × (category_margin / highest_venue_margin)

        The category margin is scaled relative to the venue's highest margin category.
        This ensures high-margin items (like drinks) earn more points than low-margin items (like food).

        Args:
            amount: Purchase amount in EUR
            venue: Venue object with margin configuration
            category: Product category ('food', 'beverages', or other)

        Returns:
            Base points earned (Decimal with 2 decimal places)

        Examples:
            >>> # €100 on beverages (80% margin) at venue with 80% max margin
            >>> calculate_base_points(Decimal('100'), venue, 'beverages')
            Decimal('10.00')  # 100 × 10% × (80/80)

            >>> # €100 on food (30% margin) at venue with 80% max margin
            >>> calculate_base_points(Decimal('100'), venue, 'food')
            Decimal('3.75')  # 100 × 10% × (30/80)
        """
        if amount <= 0:
            return Decimal("0.00")

        # Get margin for the specified category
        category_margin = venue.get_margin_for_category(category or "other")

        # Find the highest margin at this venue
        highest_margin = max(
            venue.food_margin_percent or Decimal("0"),
            venue.beverage_margin_percent or Decimal("0"),
            venue.default_margin_percent or Decimal("50.0")
        )

        # Ensure we don't divide by zero
        if highest_margin == 0:
            highest_margin = Decimal("100.0")

        # Calculate: amount × 10% × (category_margin / highest_margin)
        margin_ratio = Decimal(category_margin) / Decimal(highest_margin)
        base_points = amount * PointsCalculator.BASE_POINTS_RATE * margin_ratio

        return base_points.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    @staticmethod
    def calculate_product_points(
        amount: Decimal,
        product: Product,
        venue: Venue
    ) -> Decimal:
        """
        Calculate points for a specific product purchase, including bonus multipliers.

        Args:
            amount: Purchase amount for this product
            product: Product object (may have active bonus)
            venue: Venue object

        Returns:
            Points earned with bonuses applied
        """
        # Get base points for the product's category
        base_points = PointsCalculator.calculate_base_points(
            amount,
            venue,
            product.category
        )

        # Apply product bonus multiplier if active
        if product.is_bonus_active:
            bonus_multiplier = product.effective_points_multiplier
            total_points = base_points * Decimal(bonus_multiplier)
            return total_points.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

        return base_points

    @staticmethod
    def calculate_order_points(
        amount_cash: Decimal,
        venue: Venue,
        order_items: Optional[List[Dict]] = None,
        db: Optional[AsyncSession] = None
    ) -> Decimal:
        """
        Calculate total points earned for an entire order.

        If order_items are provided with product IDs, calculates points per product
        with individual bonus multipliers. Otherwise, uses the cash amount and
        default margin.

        Args:
            amount_cash: Cash portion of payment (points only earned on cash)
            venue: Venue object
            order_items: Optional list of order items with product_id, quantity, price
            db: Optional database session (required if order_items have product_ids)

        Returns:
            Total points earned for the order
        """
        if not order_items or amount_cash <= 0:
            # Simple calculation without product details
            return PointsCalculator.calculate_base_points(amount_cash, venue)

        total_points = Decimal("0.00")

        # Calculate points for each item
        for item in order_items:
            item_total = Decimal(str(item.get("price", 0))) * Decimal(str(item.get("quantity", 1)))

            # If product ID provided, get product-specific bonus
            if item.get("product_id") and db:
                # Note: This would require async, so for now use category-based calculation
                # In real implementation, products should be fetched beforehand
                category = item.get("category", "other")
                item_points = PointsCalculator.calculate_base_points(item_total, venue, category)
            else:
                # Use category from item
                category = item.get("category", "other")
                item_points = PointsCalculator.calculate_base_points(item_total, venue, category)

            total_points += item_points

        # Apply venue-wide multiplier
        venue_multiplier = venue.points_multiplier or Decimal("1.0")
        total_points = total_points * Decimal(venue_multiplier)

        return total_points.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    @staticmethod
    async def process_referral_rewards(
        db: AsyncSession,
        user_id: UUID,
        venue_id: UUID,
        points_earned: Decimal,
        transaction_id: Optional[UUID] = None
    ) -> List[Transaction]:
        """
        Process referral rewards for the user's referral chain (5 levels × 25% each).

        Creates REFERRAL_BONUS transactions for each referrer in the chain and
        updates their UserPoints balances.

        Args:
            db: Database session
            user_id: User who made the purchase
            venue_id: Venue where purchase was made
            points_earned: Base points earned from the purchase
            transaction_id: Optional original transaction ID for reference

        Returns:
            List of REFERRAL_BONUS Transaction objects created
        """
        # Get user's referral chain
        result = await db.execute(
            select(ReferralChain).where(ReferralChain.user_id == user_id)
        )
        chain = result.scalar_one_or_none()

        if not chain:
            # User has no referral chain (wasn't referred by anyone)
            return []

        referral_transactions = []
        reward_amount = points_earned * PointsCalculator.REFERRAL_REWARD_PERCENTAGE

        # Process each level in the chain (1-5)
        for level in range(1, 6):
            referrer_id = getattr(chain, f"level_{level}_referrer_id")

            if not referrer_id:
                # No referrer at this level
                break

            # Get or create UserPoints for referrer at this venue
            result = await db.execute(
                select(UserPoints).where(
                    UserPoints.user_id == referrer_id,
                    UserPoints.venue_id == venue_id
                )
            )
            user_points = result.scalar_one_or_none()

            if not user_points:
                # Create new UserPoints record for this referrer at this venue
                user_points = UserPoints(
                    user_id=referrer_id,
                    venue_id=venue_id,
                    points_earned=Decimal("0"),
                    points_spent=Decimal("0"),
                    points_available=Decimal("0"),
                )
                db.add(user_points)
                await db.flush()  # Get the ID

            # Add points to referrer
            user_points.add_points(reward_amount)

            # Update referral chain earnings tracking
            chain.add_earnings(level, reward_amount)

            # Create referral bonus transaction
            referral_transaction = Transaction(
                user_id=referrer_id,
                venue_id=venue_id,
                transaction_type=TransactionType.REFERRAL_BONUS,
                status="completed",
                amount_total=Decimal("0"),
                amount_cash=Decimal("0"),
                amount_points=Decimal("0"),
                points_earned=reward_amount,
                points_spent=Decimal("0"),
                referral_level=level,
                original_transaction_id=transaction_id,
                description=f"Referral bonus (Level {level}) - {reward_amount:.2f} points",
            )
            db.add(referral_transaction)
            referral_transactions.append(referral_transaction)

        await db.flush()
        return referral_transactions

    @staticmethod
    def calculate_referral_reward(points_earned: Decimal) -> Decimal:
        """
        Calculate the reward amount for a single referral level.

        Args:
            points_earned: Points earned by the referred user

        Returns:
            Reward amount (25% of points earned)
        """
        reward = points_earned * PointsCalculator.REFERRAL_REWARD_PERCENTAGE
        return reward.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
