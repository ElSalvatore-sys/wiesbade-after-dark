#!/bin/bash

# Wiesbaden After Dark Backend - Deployment Script
# Used by Railway for production deployment

echo "🚀 Starting Wiesbaden After Dark Backend Deployment..."

# Run database migrations
echo "📦 Running database migrations..."
alembic upgrade head

# Check if migrations succeeded
if [ $? -eq 0 ]; then
    echo "✅ Database migrations completed successfully"
else
    echo "❌ Database migration failed!"
    exit 1
fi

# Start the application
echo "🌟 Starting production server..."
exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}
