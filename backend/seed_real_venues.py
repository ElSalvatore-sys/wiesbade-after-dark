#!/usr/bin/env python3
"""
Seed script to add real Wiesbaden venues to the database.

Usage:
    python3 seed_real_venues.py

Requirements:
    - DATABASE_URL environment variable must be set
    - Or pass connection string as first argument

Example:
    export DATABASE_URL="postgresql+asyncpg://user:pass@host:port/db"
    python3 seed_real_venues.py
"""
import asyncio
import os
import sys
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import uuid

# Get database URL from environment or command line
DATABASE_URL = os.getenv("DATABASE_URL") or (sys.argv[1] if len(sys.argv) > 1 else None)

if not DATABASE_URL:
    print("❌ Error: DATABASE_URL environment variable not set")
    print("Usage: DATABASE_URL='postgresql+asyncpg://...' python3 seed_real_venues.py")
    sys.exit(1)

# Ensure URL uses asyncpg driver
if DATABASE_URL.startswith("postgresql://"):
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://", 1)

async def seed_venues():
    """Seed the database with real Wiesbaden venues."""
    print(f"🔌 Connecting to database...")

    try:
        engine = create_async_engine(DATABASE_URL, echo=False)
        async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    except Exception as e:
        print(f"❌ Failed to create database engine: {e}")
        sys.exit(1)

    print(f"✅ Database connection established\n")

    venues = [
        {
            'id': str(uuid.uuid4()),
            'name': 'Das Wohnzimmer',
            'type': 'bar_restaurant',
            'description': 'Cozy bar and restaurant in the heart of Wiesbaden. Perfect for after-work drinks and dinner with friends.',
            'address': 'Wilhelmstraße 24, 65183 Wiesbaden',
            'city': 'Wiesbaden',
            'postal_code': '65183',
            'country': 'Germany',
            'latitude': 50.0825,
            'longitude': 8.2403,
            'rating': 4.5,
            'total_reviews': 127,
            'price_level': 2,
            'phone_number': '+49 611 123456',
            'email': 'info@daswohnzimmer.de',
            'website': 'https://daswohnzimmer.de',
            'image_url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
            'hours_open': '17:00',
            'hours_close': '01:00',
            'food_margin_percent': 30.0,
            'beverage_margin_percent': 80.0,
            'default_margin_percent': 50.0,
            'points_multiplier': 1.0,
            'is_active': True,
            'member_count': 0
        },
        {
            'id': str(uuid.uuid4()),
            'name': 'Harput Restaurant',
            'type': 'restaurant',
            'description': 'Authentic Turkish cuisine with traditional flavors. Family-friendly atmosphere and generous portions.',
            'address': 'Luisenstraße 11, 65185 Wiesbaden',
            'city': 'Wiesbaden',
            'postal_code': '65185',
            'country': 'Germany',
            'latitude': 50.0815,
            'longitude': 8.2380,
            'rating': 4.6,
            'total_reviews': 89,
            'price_level': 2,
            'phone_number': '+49 611 345678',
            'email': 'info@harput.de',
            'image_url': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
            'hours_open': '11:30',
            'hours_close': '23:00',
            'food_margin_percent': 40.0,
            'beverage_margin_percent': 70.0,
            'default_margin_percent': 50.0,
            'is_active': True,
            'member_count': 0
        },
        {
            'id': str(uuid.uuid4()),
            'name': 'Kasino Gesellschaft',
            'type': 'fine_dining',
            'description': 'Elegant fine dining experience in historic building. Wine bar and seasonal menu.',
            'address': 'Friedrichstraße 22, 65185 Wiesbaden',
            'city': 'Wiesbaden',
            'postal_code': '65185',
            'country': 'Germany',
            'latitude': 50.0830,
            'longitude': 8.2405,
            'rating': 4.7,
            'total_reviews': 156,
            'price_level': 3,
            'phone_number': '+49 611 536200',
            'email': 'info@kasino-gesellschaft.de',
            'website': 'https://kasino-gesellschaft.de',
            'image_url': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
            'hours_open': '18:00',
            'hours_close': '23:00',
            'food_margin_percent': 35.0,
            'beverage_margin_percent': 75.0,
            'default_margin_percent': 50.0,
            'is_active': True,
            'member_count': 0
        }
    ]
    
    success_count = 0
    error_count = 0

    async with async_session() as session:
        for v in venues:
            try:
                query = text("""
                    INSERT INTO venues (
                        id, name, type, description, address, city, postal_code, country,
                        latitude, longitude, rating, total_reviews, price_level,
                        phone_number, email, website, image_url,
                        hours_open, hours_close,
                        food_margin_percent, beverage_margin_percent, default_margin_percent,
                        points_multiplier, is_active, member_count,
                        created_at, updated_at
                    ) VALUES (
                        :id, :name, :type, :description, :address, :city, :postal_code, :country,
                        :latitude, :longitude, :rating, :total_reviews, :price_level,
                        :phone_number, :email, :website, :image_url,
                        :hours_open, :hours_close,
                        :food_margin_percent, :beverage_margin_percent, :default_margin_percent,
                        :points_multiplier, :is_active, :member_count,
                        NOW(), NOW()
                    ) ON CONFLICT (name) DO UPDATE SET
                        image_url = EXCLUDED.image_url,
                        description = EXCLUDED.description,
                        rating = EXCLUDED.rating,
                        total_reviews = EXCLUDED.total_reviews,
                        updated_at = NOW()
                """)

                await session.execute(query, v)
                await session.commit()
                print(f"✅ Added/Updated: {v['name']} ({v['type']}) - {v['rating']}⭐")
                success_count += 1
            except Exception as e:
                print(f"❌ Error adding {v['name']}: {e}")
                await session.rollback()
                error_count += 1

    print(f"\n{'='*50}")
    print(f"📊 Summary:")
    print(f"  ✅ Successful: {success_count}")
    print(f"  ❌ Failed: {error_count}")
    print(f"  📍 Total: {len(venues)}")
    print(f"{'='*50}\n")

    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(seed_venues())
