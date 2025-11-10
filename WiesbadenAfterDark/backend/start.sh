#!/bin/bash

# Wiesbaden After Dark Backend - Quick Start Script

echo "🚀 Starting Wiesbaden After Dark Backend..."

# Navigate to backend directory
cd "$(dirname "$0")"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install/upgrade dependencies
echo "📥 Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Check for .env file
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo "Please edit .env with your configuration before proceeding."
    echo ""
    read -p "Press Enter to continue or Ctrl+C to exit..."
fi

# Start the server
echo "🌟 Starting FastAPI server..."
echo "📖 API Documentation: http://localhost:8000/api/docs"
echo "🔍 Alternative Docs: http://localhost:8000/api/redoc"
echo ""

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
