"""Add phone authentication columns to users table

Revision ID: 001_phone_auth
Revises:
Create Date: 2025-11-12 20:17:51.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '001_phone_auth'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """
    Add phone authentication columns and make email nullable.

    Changes:
    - Add phone_number (unique, indexed)
    - Add phone_country_code
    - Add phone_verified
    - Make email nullable
    - Make password_hash nullable
    """
    # Add phone authentication columns
    op.add_column('users', sa.Column('phone_number', sa.String(length=20), nullable=True))
    op.add_column('users', sa.Column('phone_country_code', sa.String(length=5), nullable=True))
    op.add_column('users', sa.Column('phone_verified', sa.Boolean(), nullable=False, server_default='false'))

    # Create unique constraint and index on phone_number
    op.create_unique_constraint('uq_users_phone_number', 'users', ['phone_number'])
    op.create_index('ix_users_phone_number', 'users', ['phone_number'])

    # Make email nullable (was required, now optional for phone-only auth)
    op.alter_column('users', 'email',
                    existing_type=sa.String(length=255),
                    nullable=True)

    # Make password_hash nullable (not needed for phone-only auth)
    op.alter_column('users', 'password_hash',
                    existing_type=sa.String(length=255),
                    nullable=True)

    # Create verification_codes table
    op.create_table(
        'verification_codes',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('phone_number', sa.String(length=20), nullable=False),
        sa.Column('code', sa.String(length=6), nullable=False),
        sa.Column('is_used', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('expires_at', sa.DateTime(), nullable=False),
        sa.Column('attempts', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('now()')),
        sa.Column('used_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_verification_codes_phone_number', 'verification_codes', ['phone_number'])


def downgrade() -> None:
    """
    Remove phone authentication columns and restore email as required.

    Reverts all changes made in upgrade().
    """
    # Drop verification_codes table
    op.drop_index('ix_verification_codes_phone_number', table_name='verification_codes')
    op.drop_table('verification_codes')

    # Remove phone authentication columns
    op.drop_index('ix_users_phone_number', table_name='users')
    op.drop_constraint('uq_users_phone_number', 'users', type_='unique')
    op.drop_column('users', 'phone_verified')
    op.drop_column('users', 'phone_country_code')
    op.drop_column('users', 'phone_number')

    # Restore email as required
    op.alter_column('users', 'email',
                    existing_type=sa.String(length=255),
                    nullable=False)

    # Restore password_hash as required
    op.alter_column('users', 'password_hash',
                    existing_type=sa.String(length=255),
                    nullable=False)
