# WiesbadenAfterDark Backend

PostgreSQL database schema and backend infrastructure for the WiesbadenAfterDark loyalty platform.

## Overview

This backend provides a complete database schema for managing:
- User accounts and authentication
- Venue memberships with tier progression
- Points system with referral rewards
- Check-ins and purchases
- Events and RSVPs
- Apple Wallet integration
- Achievement badges

## Quick Start

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Database

Copy the example environment file and configure your database URL:

```bash
cp .env.example .env
```

Edit `.env` and set your database connection string:
```env
DATABASE_URL=postgresql://username:password@localhost:5432/wiesbaden_after_dark
```

For Supabase, use the connection pooler URL:
```env
DATABASE_URL=postgresql://postgres.[PROJECT_ID]:[PASSWORD]@aws-0-us-east-1.pooler.supabase.com:5432/postgres
```

### 3. Apply Migrations

```bash
# Apply all migrations
alembic upgrade head

# Verify current version
alembic current
```

### 4. Verify Schema

```bash
# Connect to your database
psql $DATABASE_URL

# List all tables
\dt

# Should show 14 tables:
# - users
# - venues
# - venue_memberships
# - products
# - check_ins
# - point_transactions
# - referral_chains
# - events
# - event_rsvps
# - wallet_passes
# - venue_tier_configs
# - badges
# - user_badges
```

## Schema Documentation

See [schema_diagram.md](schema_diagram.md) for complete documentation including:
- Entity-Relationship diagram
- Detailed table descriptions
- Index strategy
- Query optimization notes
- Constraint documentation

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   └── models/
│       ├── __init__.py          # Model exports
│       ├── base.py              # SQLAlchemy Base
│       ├── user.py              # User model
│       ├── venue.py             # Venue model
│       ├── venue_membership.py  # Membership & tiers
│       ├── product.py           # Products
│       ├── check_in.py          # Check-ins
│       ├── point_transaction.py # Point ledger
│       ├── referral_chain.py    # Referral tracking
│       ├── event.py             # Events
│       ├── event_rsvp.py        # Event RSVPs
│       ├── wallet_pass.py       # Apple Wallet
│       ├── venue_tier_config.py # Tier configuration
│       └── badge.py             # Achievement badges
├── alembic/
│   ├── versions/
│   │   └── 001_complete_schema.py  # Initial migration
│   └── env.py                      # Alembic environment
├── alembic.ini                     # Alembic configuration
├── requirements.txt                # Python dependencies
├── .env.example                    # Environment template
├── schema_diagram.md               # Complete schema docs
└── README.md                       # This file
```

## Database Schema

### Core Entities

**14 Tables**:
1. **users** - User accounts with referral system
2. **venues** - Venues/establishments
3. **venue_memberships** - User-venue relationships with tier progression
4. **products** - Products available at venues
5. **check_ins** - User purchases/check-ins
6. **point_transactions** - Immutable transaction ledger
7. **referral_chains** - 5-level referral reward tracking
8. **events** - Events hosted at venues
9. **event_rsvps** - Event attendance tracking
10. **wallet_passes** - Apple Wallet pass management
11. **venue_tier_configs** - Tier configuration per venue
12. **badges** - Achievement badge definitions
13. **user_badges** - User badge ownership

### Key Features

- **UUID Primary Keys**: All tables use UUID for scalability
- **DECIMAL Precision**: All financial/points data uses DECIMAL(10, 2)
- **Comprehensive Indexing**: 80+ indexes for query performance
- **Data Integrity**: 50+ constraints (CHECK, UNIQUE, FOREIGN KEY)
- **Soft Deletes**: Strategic use of CASCADE and SET NULL
- **Audit Trail**: Immutable transaction ledger
- **Timezone Support**: All timestamps include timezone

## Development

### Creating New Migrations

```bash
# Auto-generate migration from model changes
alembic revision --autogenerate -m "Description of changes"

# Apply new migration
alembic upgrade head
```

### Rolling Back

```bash
# Rollback one version
alembic downgrade -1

# Rollback to specific version
alembic downgrade <revision_id>

# Rollback all
alembic downgrade base
```

### Working with Models

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models import User, Venue, VenueMembership
import os

# Create engine
engine = create_engine(os.getenv('DATABASE_URL'))
Session = sessionmaker(bind=engine)
session = Session()

# Query users
users = session.query(User).filter(User.total_points_available > 100).all()

# Create new user
new_user = User(
    phone_number="+49123456789",
    first_name="John",
    last_name="Doe",
    referral_code="JOHN2024"
)
session.add(new_user)
session.commit()

# Query with joins
memberships = session.query(VenueMembership)\
    .join(User)\
    .join(Venue)\
    .filter(User.id == user_id)\
    .all()
```

## Production Deployment

### Supabase Setup

1. Create a new Supabase project
2. Get your connection string from Project Settings > Database
3. Use the **connection pooler** URL (port 5432) for production
4. Update `.env` with your Supabase URL
5. Run migrations: `alembic upgrade head`

### Environment Variables

Required environment variables for production:
```env
DATABASE_URL=postgresql://postgres.[PROJECT_ID]:[PASSWORD]@aws-0-us-east-1.pooler.supabase.com:5432/postgres
```

### Performance Considerations

- **Connection Pooling**: Use connection pooler in production
- **Read Replicas**: Consider read replicas for high traffic
- **Index Monitoring**: Monitor query performance and add indexes as needed
- **Backup Strategy**: Configure automated backups
- **Monitoring**: Set up database monitoring and alerting

## Next Steps

1. **Seed Data**: Create initial tier configurations and badges
2. **API Development**: Build REST or GraphQL endpoints
3. **Testing**: Write unit tests for models and integration tests
4. **Documentation**: Document API endpoints
5. **Monitoring**: Set up logging and monitoring

## Support

- Review model definitions in `app/models/`
- Check migration in `alembic/versions/001_complete_schema.py`
- See complete schema documentation in `schema_diagram.md`
- Consult [SQLAlchemy docs](https://docs.sqlalchemy.org/) for ORM usage
- Consult [Alembic docs](https://alembic.sqlalchemy.org/) for migration help
