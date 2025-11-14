# WiesbadenAfterDark Backend API

FastAPI backend for the WiesbadenAfterDark nightlife loyalty platform.

## Features

- **User Management** (Endpoints 6-10)
  - User profile management
  - Points tracking across venues
  - Expiring points notifications
  - Activity tracking

- **Venue Management** (Endpoints 11-14)
  - Venue listing with geospatial filtering
  - Venue details and products
  - Tier configuration management
  - Distance calculation from user location

## Technology Stack

- **Framework**: FastAPI 0.109.0
- **Database**: PostgreSQL (via Supabase)
- **ORM**: SQLAlchemy 2.0 (async)
- **Authentication**: JWT (python-jose)
- **Geospatial**: geopy
- **ASGI Server**: Uvicorn

## Project Structure

```
backend/
├── app/
│   ├── api/
│   │   └── v1/
│   │       ├── api.py              # API router
│   │       └── endpoints/
│   │           ├── users.py        # User endpoints (6-10)
│   │           └── venues.py       # Venue endpoints (11-14)
│   ├── core/
│   │   ├── config.py               # Configuration settings
│   │   ├── database.py             # Database connection
│   │   └── deps.py                 # Dependencies (auth, db)
│   ├── models/                     # SQLAlchemy models
│   │   ├── user.py
│   │   ├── venue.py
│   │   ├── product.py
│   │   ├── venue_membership.py
│   │   ├── transaction.py
│   │   └── special_offer.py
│   ├── schemas/                    # Pydantic schemas
│   │   ├── user.py
│   │   └── venue.py
│   ├── services/                   # Business logic
│   │   ├── user_service.py
│   │   └── venue_service.py
│   └── main.py                     # Application entry point
├── requirements.txt
├── .env.example
└── README.md
```

## Installation

### Prerequisites

- Python 3.11+
- PostgreSQL (Supabase account)
- pip

### Setup

1. **Clone the repository**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your actual values
   ```

5. **Set up database**
   - Create a Supabase project
   - Get your database URL and credentials
   - Update .env with your Supabase settings

## Environment Variables

```env
DATABASE_URL=postgresql+asyncpg://user:password@host:5432/database
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-supabase-anon-key
SUPABASE_JWT_SECRET=your-jwt-secret
SECRET_KEY=your-super-secret-key
```

## Running the API

### Development Mode

```bash
# From backend directory
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Or using Python:

```bash
python -m app.main
```

The API will be available at:
- API: http://localhost:8000
- Docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API Endpoints

### User Endpoints (6-10)

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/api/v1/users/{user_id}` | GET | Get user profile | Yes |
| `/api/v1/users/{user_id}` | PUT | Update user profile | Yes |
| `/api/v1/users/{user_id}/points` | GET | Get points summary | Yes |
| `/api/v1/users/{user_id}/expiring-points` | GET | Get expiring points | Yes |
| `/api/v1/users/{user_id}/activity` | PUT | Update last activity | Yes |

### Venue Endpoints (11-14)

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/api/v1/venues` | GET | List venues with filters | No |
| `/api/v1/venues/{venue_id}` | GET | Get venue details | No |
| `/api/v1/venues/{venue_id}/products` | GET | Get venue products | No |
| `/api/v1/venues/{venue_id}/tier-config` | GET | Get tier configuration | Yes (Owner) |

## Testing Endpoints

### Get User Profile
```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/v1/users/{user_id}
```

### Get Points Summary
```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/v1/users/{user_id}/points
```

### List Venues
```bash
curl "http://localhost:8000/api/v1/venues?lat=50.0826&lng=8.2400&limit=10"
```

### Get Venue Products with Bonus Filter
```bash
curl "http://localhost:8000/api/v1/venues/{venue_id}/products?has_bonus=true"
```

### Get Expiring Points
```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/users/{user_id}/expiring-points?days_ahead=30"
```

## Database Models

### Key Models

- **User**: User accounts and profiles
- **Venue**: Bars, clubs, and establishments
- **VenueMembership**: User membership and points at each venue
- **Transaction**: Points earning and redemption history
- **Product**: Items/services available at venues
- **SpecialOffer**: Promotions and special offers

### Relationships

- User has many VenueMemberships (one per venue)
- VenueMembership has many Transactions
- Venue has many Products
- Venue has many SpecialOffers

## Business Logic

### Points System

- Points earned on purchases (configurable by venue)
- Points expire after 180 days (configurable)
- Tier-based multipliers (Bronze: 1x, Silver: 1.25x, Gold: 1.5x, Platinum: 2x)

### Tier Progression

- **Bronze**: 0-999 points
- **Silver**: 1,000-4,999 points (5% discount)
- **Gold**: 5,000-14,999 points (10% discount)
- **Platinum**: 15,000+ points (15% discount)

## Development

### Code Style

- Follow PEP 8 guidelines
- Use type hints
- Document functions with docstrings

### Adding New Endpoints

1. Create endpoint function in appropriate router
2. Add business logic to service layer
3. Create/update Pydantic schemas
4. Update API router if needed

## Production Deployment

### Prerequisites

- PostgreSQL database
- ASGI server (Uvicorn/Gunicorn)
- Reverse proxy (Nginx/Caddy)

### Deployment Steps

1. Set production environment variables
2. Run database migrations
3. Start server with Gunicorn:
   ```bash
   gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker
   ```

## API Documentation

Once running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Success Criteria

✅ All 9 endpoints (6-14) implemented
✅ User service with points aggregation
✅ Venue service with distance calculation
✅ Proper authentication & authorization
✅ Error handling for all edge cases
✅ FastAPI auto-docs updated

## License

Proprietary - WiesbadenAfterDark

## Support

For issues or questions, please contact the development team.
