"""
SQLAlchemy models for WiesbadenAfterDark

Import all models here to ensure they are registered with SQLAlchemy
"""
from app.models.base import Base
from app.models.user import User
from app.models.venue import Venue
from app.models.venue_membership import VenueMembership
from app.models.product import Product
from app.models.check_in import CheckIn
from app.models.point_transaction import PointTransaction
from app.models.referral_chain import ReferralChain
from app.models.event import Event
from app.models.event_rsvp import EventRSVP
from app.models.wallet_pass import WalletPass
from app.models.venue_tier_config import VenueTierConfig
from app.models.badge import Badge, UserBadge

__all__ = [
    "Base",
    "User",
    "Venue",
    "VenueMembership",
    "Product",
    "CheckIn",
    "PointTransaction",
    "ReferralChain",
    "Event",
    "EventRSVP",
    "WalletPass",
    "VenueTierConfig",
    "Badge",
    "UserBadge",
]
