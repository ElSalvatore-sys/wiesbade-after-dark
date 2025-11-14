# Seeding Real Wiesbaden Venues

This guide explains how to add real Wiesbaden venue data to your database.

## Overview

The `seed_real_venues.py` script adds three real Wiesbaden venues:
1. **Das Wohnzimmer** - Cozy bar & restaurant
2. **Harput Restaurant** - Authentic Turkish cuisine
3. **Kasino Gesellschaft** - Elegant fine dining

## Running Locally

### Prerequisites
```bash
pip install sqlalchemy asyncpg
```

### Method 1: Using Environment Variable
```bash
export DATABASE_URL="postgresql+asyncpg://user:pass@host:port/database"
python3 seed_real_venues.py
```

### Method 2: Direct Argument
```bash
python3 seed_real_venues.py "postgresql+asyncpg://user:pass@host:port/database"
```

## Running on Railway

### Option 1: Using Railway CLI

1. Install Railway CLI:
```bash
npm install -g @railway/cli
```

2. Login and link project:
```bash
railway login
railway link
```

3. Run seed script:
```bash
railway run python3 backend/seed_real_venues.py
```

### Option 2: Using Railway Dashboard

1. Go to your Railway project dashboard
2. Open the "Deployments" tab
3. Click on "Run Command"
4. Enter: `python3 backend/seed_real_venues.py`
5. Click "Run"

### Option 3: SSH into Railway Container

1. Connect to your Railway deployment:
```bash
railway shell
```

2. Run the seed script:
```bash
cd backend
python3 seed_real_venues.py
```

## Verifying Venues Were Added

### Using Python
```bash
railway run python3 << 'EOF'
import asyncio
import os
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

async def check_venues():
    engine = create_async_engine(os.getenv("DATABASE_URL"))
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        result = await session.execute(text("SELECT name, type, rating FROM venues ORDER BY name"))
        venues = result.all()

        print(f"\n📍 Total venues: {len(venues)}\n")
        for v in venues:
            print(f"  ✅ {v[0]} ({v[1]}) - {v[2]}⭐")

asyncio.run(check_venues())
EOF
```

### Using API
```bash
curl "https://wiesbade-after-dark-production.up.railway.app/api/v1/venues" | jq
```

## Troubleshooting

### Connection Issues
- Verify your DATABASE_URL is correct
- Ensure you're using `postgresql+asyncpg://` (not just `postgresql://`)
- Check that your IP is whitelisted in Supabase

### Permission Issues
- Make sure the database user has INSERT permissions
- Verify the `venues` table exists

### Duplicate Entries
The script uses `ON CONFLICT (name) DO UPDATE` so it's safe to run multiple times. It will:
- Insert new venues
- Update existing venues with the same name

## Success Criteria

After running the script, you should see:
- ✅ 3 venues successfully added/updated
- ✅ Das Wohnzimmer listed first (alphabetically)
- ✅ All venues have realistic data (photos, hours, margins)
- ✅ API returns all venues when queried
- ✅ iOS app can fetch and display them

## Venues Data

| Name | Type | Rating | Address |
|------|------|--------|---------|
| Das Wohnzimmer | Bar & Restaurant | 4.5⭐ | Wilhelmstraße 24, 65183 Wiesbaden |
| Harput Restaurant | Restaurant | 4.6⭐ | Luisenstraße 11, 65185 Wiesbaden |
| Kasino Gesellschaft | Fine Dining | 4.7⭐ | Friedrichstraße 22, 65185 Wiesbaden |

All venues include:
- Real addresses in Wiesbaden
- Professional photos from Unsplash
- Accurate opening hours
- Realistic pricing and margins
- Proper GPS coordinates
