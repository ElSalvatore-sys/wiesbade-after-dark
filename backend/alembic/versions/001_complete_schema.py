"""Complete schema for WiesbadenAfterDark

Revision ID: 001
Revises:
Create Date: 2025-11-14

Creates all 14 tables for the WiesbadenAfterDark loyalty platform:
- users
- venues
- venue_memberships
- products
- check_ins
- point_transactions
- referral_chains
- events
- event_rsvps
- wallet_passes
- venue_tier_configs
- badges
- user_badges
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import uuid

revision = '001'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # 1. Create users table
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('phone_number', sa.String(20), unique=True, nullable=False),
        sa.Column('first_name', sa.String(100), nullable=False),
        sa.Column('last_name', sa.String(100), nullable=False),
        sa.Column('email', sa.String(255), unique=True),
        sa.Column('date_of_birth', sa.Date()),
        sa.Column('profile_image_url', sa.String(500)),
        sa.Column('total_points_earned', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('total_points_spent', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('total_points_available', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('total_referrals', sa.Integer(), default=0, nullable=False),
        sa.Column('referral_code', sa.String(10), unique=True, nullable=False),
        sa.Column('referred_by', postgresql.UUID(as_uuid=True)),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True)),
        sa.ForeignKeyConstraint(['referred_by'], ['users.id'], ondelete='SET NULL'),
        sa.CheckConstraint('total_points_earned >= 0', name='check_points_earned_positive'),
        sa.CheckConstraint('total_points_spent >= 0', name='check_points_spent_positive'),
        sa.CheckConstraint('total_points_available >= 0', name='check_points_available_positive'),
        sa.CheckConstraint('total_referrals >= 0', name='check_referrals_positive'),
    )
    op.create_index('idx_user_phone', 'users', ['phone_number'])
    op.create_index('idx_user_email', 'users', ['email'])
    op.create_index('idx_user_referral_code', 'users', ['referral_code'])
    op.create_index('idx_user_referred_by', 'users', ['referred_by'])

    # 2. Create venues table
    op.create_table(
        'venues',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(200), nullable=False),
        sa.Column('type', sa.String(50), nullable=False),
        sa.Column('description', sa.Text()),
        sa.Column('image_url', sa.String(500)),
        sa.Column('address', sa.String(500)),
        sa.Column('latitude', sa.DECIMAL(10, 8)),
        sa.Column('longitude', sa.DECIMAL(11, 8)),
        sa.Column('rating', sa.DECIMAL(3, 2), default=0, nullable=False),
        sa.Column('member_count', sa.Integer(), default=0, nullable=False),
        sa.Column('phone_number', sa.String(20)),
        sa.Column('email', sa.String(255)),
        sa.Column('website', sa.String(500)),
        sa.Column('food_margin_percent', sa.DECIMAL(5, 2), default=30, nullable=False),
        sa.Column('beverage_margin_percent', sa.DECIMAL(5, 2), default=80, nullable=False),
        sa.Column('default_margin_percent', sa.DECIMAL(5, 2), default=50, nullable=False),
        sa.Column('points_multiplier', sa.DECIMAL(3, 2), default=1.0, nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True)),
        sa.CheckConstraint('rating >= 0 AND rating <= 5', name='check_rating_range'),
        sa.CheckConstraint('member_count >= 0', name='check_member_count_positive'),
        sa.CheckConstraint('food_margin_percent >= 0 AND food_margin_percent <= 100', name='check_food_margin_range'),
        sa.CheckConstraint('beverage_margin_percent >= 0 AND beverage_margin_percent <= 100', name='check_beverage_margin_range'),
        sa.CheckConstraint('default_margin_percent >= 0 AND default_margin_percent <= 100', name='check_default_margin_range'),
        sa.CheckConstraint('points_multiplier > 0', name='check_points_multiplier_positive'),
    )
    op.create_index('idx_venue_type', 'venues', ['type'])
    op.create_index('idx_venue_location', 'venues', ['latitude', 'longitude'])
    op.create_index('idx_venue_rating', 'venues', ['rating'])

    # 3. Create venue_memberships table
    op.create_table(
        'venue_memberships',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('venue_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('current_tier', sa.String(50), default='Bronze', nullable=False),
        sa.Column('tier_level', sa.Integer(), default=1, nullable=False),
        sa.Column('points_balance', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('lifetime_points', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('points_to_next_tier', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('visit_count', sa.Integer(), default=0, nullable=False),
        sa.Column('last_visit_date', sa.DateTime(timezone=True)),
        sa.Column('tier_progress_percent', sa.DECIMAL(5, 2), default=0, nullable=False),
        sa.Column('joined_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True)),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['venue_id'], ['venues.id'], ondelete='CASCADE'),
        sa.UniqueConstraint('user_id', 'venue_id', name='unique_user_venue_membership'),
        sa.CheckConstraint('tier_level >= 1 AND tier_level <= 5', name='check_tier_level_range'),
        sa.CheckConstraint('points_balance >= 0', name='check_points_balance_positive'),
        sa.CheckConstraint('lifetime_points >= 0', name='check_lifetime_points_positive'),
        sa.CheckConstraint('points_to_next_tier >= 0', name='check_points_to_next_tier_positive'),
        sa.CheckConstraint('visit_count >= 0', name='check_visit_count_positive'),
        sa.CheckConstraint('tier_progress_percent >= 0 AND tier_progress_percent <= 100', name='check_tier_progress_range'),
    )
    op.create_index('idx_membership_user', 'venue_memberships', ['user_id'])
    op.create_index('idx_membership_venue', 'venue_memberships', ['venue_id'])
    op.create_index('idx_membership_tier', 'venue_memberships', ['current_tier'])
    op.create_index('idx_membership_user_venue', 'venue_memberships', ['user_id', 'venue_id'])

    # 4. Create products table
    op.create_table(
        'products',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('venue_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(200), nullable=False),
        sa.Column('category', sa.String(50), nullable=False),
        sa.Column('description', sa.String(500)),
        sa.Column('image_url', sa.String(500)),
        sa.Column('price', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('cost', sa.DECIMAL(10, 2)),
        sa.Column('margin_percent', sa.DECIMAL(5, 2)),
        sa.Column('stock_quantity', sa.Integer(), default=0, nullable=False),
        sa.Column('is_available', sa.Boolean(), default=True, nullable=False),
        sa.Column('bonus_points_active', sa.Boolean(), default=False, nullable=False),
        sa.Column('bonus_multiplier', sa.DECIMAL(3, 2), default=1.0, nullable=False),
        sa.Column('bonus_description', sa.String(200)),
        sa.Column('bonus_start_date', sa.DateTime(timezone=True)),
        sa.Column('bonus_end_date', sa.DateTime(timezone=True)),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True)),
        sa.ForeignKeyConstraint(['venue_id'], ['venues.id'], ondelete='CASCADE'),
        sa.CheckConstraint('price >= 0', name='check_price_positive'),
        sa.CheckConstraint('cost >= 0', name='check_cost_positive'),
        sa.CheckConstraint('margin_percent >= 0 AND margin_percent <= 100', name='check_margin_range'),
        sa.CheckConstraint('stock_quantity >= 0', name='check_stock_positive'),
        sa.CheckConstraint('bonus_multiplier > 0', name='check_bonus_multiplier_positive'),
    )
    op.create_index('idx_product_venue', 'products', ['venue_id'])
    op.create_index('idx_product_category', 'products', ['category'])
    op.create_index('idx_product_bonus_active', 'products', ['bonus_points_active'])
    op.create_index('idx_product_available', 'products', ['is_available'])
    op.create_index('idx_product_venue_category', 'products', ['venue_id', 'category'])

    # 5. Create check_ins table
    op.create_table(
        'check_ins',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('venue_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('purchase_amount', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('margin_percent', sa.DECIMAL(5, 2), nullable=False),
        sa.Column('base_points', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('tier_bonus', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('product_bonus', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('venue_multiplier_bonus', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('total_points_earned', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('items_purchased', postgresql.JSON()),
        sa.Column('receipt_number', sa.String(100)),
        sa.Column('verification_code', sa.String(50)),
        sa.Column('verified', sa.String(20), default='pending', nullable=False),
        sa.Column('check_in_latitude', sa.DECIMAL(10, 8)),
        sa.Column('check_in_longitude', sa.DECIMAL(11, 8)),
        sa.Column('checked_in_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['venue_id'], ['venues.id'], ondelete='CASCADE'),
        sa.CheckConstraint('purchase_amount >= 0', name='check_purchase_amount_positive'),
        sa.CheckConstraint('margin_percent >= 0 AND margin_percent <= 100', name='check_margin_percent_range'),
        sa.CheckConstraint('base_points >= 0', name='check_base_points_positive'),
        sa.CheckConstraint('tier_bonus >= 0', name='check_tier_bonus_positive'),
        sa.CheckConstraint('product_bonus >= 0', name='check_product_bonus_positive'),
        sa.CheckConstraint('venue_multiplier_bonus >= 0', name='check_venue_multiplier_bonus_positive'),
        sa.CheckConstraint('total_points_earned >= 0', name='check_total_points_positive'),
    )
    op.create_index('idx_checkin_user', 'check_ins', ['user_id'])
    op.create_index('idx_checkin_venue', 'check_ins', ['venue_id'])
    op.create_index('idx_checkin_user_venue', 'check_ins', ['user_id', 'venue_id'])
    op.create_index('idx_checkin_date', 'check_ins', ['checked_in_at'])
    op.create_index('idx_checkin_verified', 'check_ins', ['verified'])

    # 6. Create point_transactions table
    op.create_table(
        'point_transactions',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('transaction_type', sa.String(20), nullable=False),
        sa.Column('points_amount', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('balance_before', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('balance_after', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('description', sa.String(500), nullable=False),
        sa.Column('related_venue_id', postgresql.UUID(as_uuid=True)),
        sa.Column('related_check_in_id', postgresql.UUID(as_uuid=True)),
        sa.Column('related_user_id', postgresql.UUID(as_uuid=True)),
        sa.Column('expires_at', sa.DateTime(timezone=True)),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['related_venue_id'], ['venues.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['related_check_in_id'], ['check_ins.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['related_user_id'], ['users.id'], ondelete='SET NULL'),
        sa.CheckConstraint('balance_before >= 0', name='check_balance_before_positive'),
        sa.CheckConstraint('balance_after >= 0', name='check_balance_after_positive'),
    )
    op.create_index('idx_transaction_user', 'point_transactions', ['user_id'])
    op.create_index('idx_transaction_type', 'point_transactions', ['transaction_type'])
    op.create_index('idx_transaction_date', 'point_transactions', ['created_at'])
    op.create_index('idx_transaction_venue', 'point_transactions', ['related_venue_id'])
    op.create_index('idx_transaction_expiry', 'point_transactions', ['expires_at'])
    op.create_index('idx_transaction_user_date', 'point_transactions', ['user_id', 'created_at'])

    # 7. Create referral_chains table
    op.create_table(
        'referral_chains',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('check_in_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('referral_level', sa.Integer(), nullable=False),
        sa.Column('referrer_user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('purchase_amount', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('base_points_earned', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('reward_percentage', sa.DECIMAL(5, 2), nullable=False),
        sa.Column('reward_points', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('status', sa.String(20), default='pending', nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('processed_at', sa.DateTime(timezone=True)),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['check_in_id'], ['check_ins.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['referrer_user_id'], ['users.id'], ondelete='CASCADE'),
        sa.CheckConstraint('referral_level >= 1 AND referral_level <= 5', name='check_referral_level_range'),
        sa.CheckConstraint('purchase_amount >= 0', name='check_purchase_amount_positive'),
        sa.CheckConstraint('base_points_earned >= 0', name='check_base_points_positive'),
        sa.CheckConstraint('reward_percentage >= 0 AND reward_percentage <= 100', name='check_reward_percentage_range'),
        sa.CheckConstraint('reward_points >= 0', name='check_reward_points_positive'),
    )
    op.create_index('idx_referral_user', 'referral_chains', ['user_id'])
    op.create_index('idx_referral_referrer', 'referral_chains', ['referrer_user_id'])
    op.create_index('idx_referral_check_in', 'referral_chains', ['check_in_id'])
    op.create_index('idx_referral_level', 'referral_chains', ['referral_level'])
    op.create_index('idx_referral_status', 'referral_chains', ['status'])
    op.create_index('idx_referral_date', 'referral_chains', ['created_at'])

    # 8. Create events table
    op.create_table(
        'events',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('venue_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('title', sa.String(200), nullable=False),
        sa.Column('description', sa.Text()),
        sa.Column('event_type', sa.String(50), nullable=False),
        sa.Column('image_url', sa.String(500)),
        sa.Column('start_time', sa.DateTime(timezone=True), nullable=False),
        sa.Column('end_time', sa.DateTime(timezone=True), nullable=False),
        sa.Column('max_capacity', sa.Integer()),
        sa.Column('current_rsvp_count', sa.Integer(), default=0, nullable=False),
        sa.Column('ticket_price', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('is_free', sa.Boolean(), default=True, nullable=False),
        sa.Column('attendance_points', sa.DECIMAL(10, 2), default=0, nullable=False),
        sa.Column('bonus_points_multiplier', sa.DECIMAL(3, 2), default=1.0, nullable=False),
        sa.Column('status', sa.String(20), default='upcoming', nullable=False),
        sa.Column('is_featured', sa.Boolean(), default=False, nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True)),
        sa.ForeignKeyConstraint(['venue_id'], ['venues.id'], ondelete='CASCADE'),
        sa.CheckConstraint('end_time > start_time', name='check_event_time_valid'),
        sa.CheckConstraint('max_capacity > 0', name='check_max_capacity_positive'),
        sa.CheckConstraint('current_rsvp_count >= 0', name='check_rsvp_count_positive'),
        sa.CheckConstraint('ticket_price >= 0', name='check_ticket_price_positive'),
        sa.CheckConstraint('attendance_points >= 0', name='check_attendance_points_positive'),
        sa.CheckConstraint('bonus_points_multiplier > 0', name='check_bonus_multiplier_positive'),
    )
    op.create_index('idx_event_venue', 'events', ['venue_id'])
    op.create_index('idx_event_type', 'events', ['event_type'])
    op.create_index('idx_event_start_time', 'events', ['start_time'])
    op.create_index('idx_event_status', 'events', ['status'])
    op.create_index('idx_event_featured', 'events', ['is_featured'])
    op.create_index('idx_event_venue_date', 'events', ['venue_id', 'start_time'])

    # 9. Create event_rsvps table
    op.create_table(
        'event_rsvps',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('event_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('status', sa.String(20), default='confirmed', nullable=False),
        sa.Column('attended', sa.Boolean(), default=False, nullable=False),
        sa.Column('check_in_time', sa.DateTime(timezone=True)),
        sa.Column('reminder_sent', sa.Boolean(), default=False, nullable=False),
        sa.Column('last_reminder_at', sa.DateTime(timezone=True)),
        sa.Column('rsvp_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True)),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['event_id'], ['events.id'], ondelete='CASCADE'),
        sa.UniqueConstraint('user_id', 'event_id', name='unique_user_event_rsvp'),
    )
    op.create_index('idx_rsvp_user', 'event_rsvps', ['user_id'])
    op.create_index('idx_rsvp_event', 'event_rsvps', ['event_id'])
    op.create_index('idx_rsvp_status', 'event_rsvps', ['status'])
    op.create_index('idx_rsvp_attended', 'event_rsvps', ['attended'])
    op.create_index('idx_rsvp_user_event', 'event_rsvps', ['user_id', 'event_id'])

    # 10. Create wallet_passes table
    op.create_table(
        'wallet_passes',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('pass_type_identifier', sa.String(255), nullable=False),
        sa.Column('serial_number', sa.String(100), unique=True, nullable=False),
        sa.Column('authentication_token', sa.String(100), nullable=False),
        sa.Column('pass_data', postgresql.JSON(), nullable=False),
        sa.Column('status', sa.String(20), default='active', nullable=False),
        sa.Column('device_library_identifier', sa.String(100)),
        sa.Column('push_token', sa.String(100)),
        sa.Column('version', sa.String(20), default='1.0', nullable=False),
        sa.Column('last_updated', sa.DateTime(timezone=True), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('expires_at', sa.DateTime(timezone=True)),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    )
    op.create_index('idx_wallet_user', 'wallet_passes', ['user_id'])
    op.create_index('idx_wallet_serial', 'wallet_passes', ['serial_number'])
    op.create_index('idx_wallet_device', 'wallet_passes', ['device_library_identifier'])
    op.create_index('idx_wallet_status', 'wallet_passes', ['status'])
    op.create_index('idx_wallet_token', 'wallet_passes', ['authentication_token'])

    # 11. Create venue_tier_configs table
    op.create_table(
        'venue_tier_configs',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('venue_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('tier_name', sa.String(50), nullable=False),
        sa.Column('tier_level', sa.Integer(), nullable=False),
        sa.Column('points_required', sa.DECIMAL(10, 2), nullable=False),
        sa.Column('visits_required', sa.Integer(), default=0, nullable=False),
        sa.Column('points_multiplier', sa.DECIMAL(3, 2), default=1.0, nullable=False),
        sa.Column('discount_percent', sa.DECIMAL(5, 2), default=0, nullable=False),
        sa.Column('perks', postgresql.JSON()),
        sa.Column('tier_color', sa.String(50)),
        sa.Column('tier_icon', sa.String(100)),
        sa.Column('description', sa.Text()),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True)),
        sa.ForeignKeyConstraint(['venue_id'], ['venues.id'], ondelete='CASCADE'),
        sa.UniqueConstraint('venue_id', 'tier_level', name='unique_venue_tier_level'),
        sa.UniqueConstraint('venue_id', 'tier_name', name='unique_venue_tier_name'),
        sa.CheckConstraint('tier_level >= 1 AND tier_level <= 5', name='check_tier_level_range'),
        sa.CheckConstraint('points_required >= 0', name='check_points_required_positive'),
        sa.CheckConstraint('visits_required >= 0', name='check_visits_required_positive'),
        sa.CheckConstraint('points_multiplier >= 1.0', name='check_points_multiplier_min'),
        sa.CheckConstraint('discount_percent >= 0 AND discount_percent <= 100', name='check_discount_range'),
    )
    op.create_index('idx_tier_config_venue', 'venue_tier_configs', ['venue_id'])
    op.create_index('idx_tier_config_level', 'venue_tier_configs', ['tier_level'])
    op.create_index('idx_tier_config_venue_level', 'venue_tier_configs', ['venue_id', 'tier_level'])

    # 12. Create badges table
    op.create_table(
        'badges',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(100), unique=True, nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('category', sa.String(50), nullable=False),
        sa.Column('requirement_type', sa.String(50)),
        sa.Column('requirement_value', sa.Integer()),
        sa.Column('venue_specific', sa.Boolean(), default=False, nullable=False),
        sa.Column('icon_url', sa.String(500)),
        sa.Column('color', sa.String(50)),
        sa.Column('rarity', sa.String(20), default='common', nullable=False),
        sa.Column('is_active', sa.Boolean(), default=True, nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True)),
        sa.CheckConstraint('requirement_value >= 0', name='check_requirement_value_positive'),
    )
    op.create_index('idx_badge_category', 'badges', ['category'])
    op.create_index('idx_badge_rarity', 'badges', ['rarity'])
    op.create_index('idx_badge_active', 'badges', ['is_active'])
    op.create_index('idx_badge_venue_specific', 'badges', ['venue_specific'])

    # 13. Create user_badges table
    op.create_table(
        'user_badges',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('badge_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('earned_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('progress', sa.Integer(), default=100, nullable=False),
        sa.Column('notified', sa.Boolean(), default=False, nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['badge_id'], ['badges.id'], ondelete='CASCADE'),
        sa.UniqueConstraint('user_id', 'badge_id', name='unique_user_badge'),
        sa.CheckConstraint('progress >= 0 AND progress <= 100', name='check_progress_range'),
    )
    op.create_index('idx_user_badge_user', 'user_badges', ['user_id'])
    op.create_index('idx_user_badge_badge', 'user_badges', ['badge_id'])
    op.create_index('idx_user_badge_earned', 'user_badges', ['earned_at'])
    op.create_index('idx_user_badge_user_badge', 'user_badges', ['user_id', 'badge_id'])


def downgrade():
    # Drop tables in reverse order to respect foreign key constraints
    op.drop_table('user_badges')
    op.drop_table('badges')
    op.drop_table('venue_tier_configs')
    op.drop_table('wallet_passes')
    op.drop_table('event_rsvps')
    op.drop_table('events')
    op.drop_table('referral_chains')
    op.drop_table('point_transactions')
    op.drop_table('check_ins')
    op.drop_table('products')
    op.drop_table('venue_memberships')
    op.drop_table('venues')
    op.drop_table('users')
