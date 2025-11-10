# Wiesbaden After Dark - Backend API

FastAPI backend for the Wiesbaden After Dark loyalty platform. Powers a nightlife loyalty system for venues in Wiesbaden, Germany with venue-specific points, 5-level referrals, and inventory management.

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- PostgreSQL database (Supabase recommended)
- pip and virtualenv

### Installation

1. **Clone and navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Run the start script:**
   ```bash
   ./start.sh
   ```

   This will:
   - Create a virtual environment
   - Install all dependencies
   - Copy `.env.example` to `.env` (if needed)
   - Start the development server

3. **Configure environment variables:**
   Edit `.env` file with your configuration:
   ```env
   DATABASE_URL=postgresql+asyncpg://user:pass@host:5432/db
   SECRET_KEY=your-secret-key
   ```

4. **Access the API:**
   - API Docs: http://localhost:8000/api/docs
   - Alternative Docs: http://localhost:8000/api/redoc
   - Health Check: http://localhost:8000/health

## 📋 Architecture

### Tech Stack
- **FastAPI** - Modern async Python web framework
- **SQLAlchemy 2.0** - Async ORM with PostgreSQL
- **Pydantic** - Data validation and settings
- **JWT** - Secure authentication
- **Stripe** - Payment processing
- **orderbird** - POS integration

### Key Features

#### 1. **Venue-Specific Points (German Tax Compliant)**
Points earned at one venue can ONLY be spent at that venue. This is critical for German tax compliance.

```python
# Example: User earns 10 points at "Das Wohnzimmer"
# These points can ONLY be redeemed at "Das Wohnzimmer"
user_points = UserPoints(
    user_id=user_id,
    venue_id=venue_id,
    points_available=10.0
)
```

#### 2. **5-Level Referral System**
Each level in the referral chain earns 25% of points earned:

```
User A refers User B
User B refers User C
User C spends €100 → earns 10 points

Rewards:
- User C: 10 points (earned from purchase)
- User B: 2.5 points (25% of 10)
- User A: 2.5 points (25% of 10)
- ... up to 5 levels
```

#### 3. **Margin-Based Points Calculation**
Points earned based on profit margin:

```python
# High margin items (e.g., drinks) = More points
# Low margin items (e.g., food) = Fewer points
points = amount × 10% × venue_margin_percentage
```

#### 4. **Inventory Bonus System**
Venues can activate temporary point bonuses to move excess inventory:

```python
# Set 2x points on apple juice to move excess stock
product.activate_bonus(
    multiplier=2.0,
    reason="Excess inventory"
)
```

## 📁 Project Structure

```
backend/
├── app/
│   ├── api/
│   │   ├── routes/          # API endpoints
│   │   │   ├── auth.py      # Authentication
│   │   │   ├── users.py     # User management
│   │   │   ├── venues.py    # Venue operations
│   │   │   ├── transactions.py  # Transactions & points
│   │   │   └── admin.py     # Admin/inventory management
│   │   └── dependencies.py  # Shared dependencies
│   ├── core/
│   │   ├── config.py        # Settings & configuration
│   │   └── security.py      # Auth utilities
│   ├── db/
│   │   └── session.py       # Database session management
│   ├── models/              # SQLAlchemy models
│   │   ├── user.py          # User model
│   │   ├── venue.py         # Venue model
│   │   ├── transaction.py   # Transaction model
│   │   ├── user_points.py   # Venue-specific points
│   │   ├── referral.py      # Referral system
│   │   └── product.py       # Product/inventory
│   ├── schemas/             # Pydantic schemas
│   │   ├── user.py
│   │   ├── venue.py
│   │   ├── product.py
│   │   └── transaction.py
│   ├── services/            # Business logic
│   │   ├── points_calculator.py
│   │   └── streak_calculator.py
│   └── main.py             # FastAPI application
├── requirements.txt        # Python dependencies
├── .env.example           # Environment template
├── start.sh               # Quick start script
└── README.md              # This file
```

## 🔐 Authentication

JWT-based authentication with access and refresh tokens:

- **Access Token**: 15 minutes expiration
- **Refresh Token**: 30 days expiration

Example login flow:
```python
POST /api/v1/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer",
  "expires_in": 900,
  "user": { ... }
}
```

## 📊 Database Models

### Core Models

1. **User** - User accounts and authentication
2. **Venue** - Nightlife establishments
3. **UserPoints** - Venue-specific point balances (CRITICAL!)
4. **Transaction** - All monetary and point transactions
5. **Referral** - Referral relationships
6. **ReferralChain** - 5-level referral chains
7. **Product** - Venue inventory with bonus system

### Relationships

```
User
├── UserPoints (many) - Points at each venue
├── Transactions (many) - Transaction history
├── Referrals Made (many) - Users they referred
└── Referrals Received (one) - Who referred them

Venue
├── UserPoints (many) - Customer balances
├── Transactions (many) - Sales history
└── Products (many) - Inventory
```

## 🎯 Key Business Rules

### 1. Points Earning
```
Points = Amount × 10% × Venue Margin × Bonus Multiplier
```

Example:
- Customer spends €100 on drinks (60% margin)
- Base points: €100 × 10% = €10
- With margin: €10 × 60% = €6
- With 2x bonus: €6 × 2 = €12 points

### 2. Points Redemption
Points can ONLY be spent at the venue where earned:
```python
# ✅ Correct: Use Das Wohnzimmer points at Das Wohnzimmer
# ❌ Wrong: Use Das Wohnzimmer points at Park Café
```

### 3. Referral Rewards
5 levels, 25% per level:
```
Level 1 (Direct referral): 25% of points earned
Level 2 (Referral of referral): 25% of points earned
... up to Level 5
```

## 🛠️ Development

### Running Tests
```bash
pytest
```

### Database Migrations
```bash
alembic revision --autogenerate -m "description"
alembic upgrade head
```

### Code Quality
```bash
# Format code
black app/

# Lint
flake8 app/

# Type checking
mypy app/
```

## 🚢 Deployment

### Supabase + Railway

1. **Database (Supabase)**:
   - Create project at supabase.com
   - Get DATABASE_URL from settings
   - Add to Railway environment variables

2. **Backend (Railway)**:
   ```bash
   railway login
   railway init
   railway up
   ```

### Environment Variables
Required for production:
```env
DATABASE_URL=postgresql+asyncpg://...
SECRET_KEY=<generate-with-secrets>
ALLOWED_ORIGINS=https://yourdomain.com
STRIPE_SECRET_KEY=sk_live_...
```

## 📖 API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8000/api/docs
- **ReDoc**: http://localhost:8000/api/redoc

### Example Endpoints

```
POST   /api/v1/auth/register       - Register new user
POST   /api/v1/auth/login          - Login
GET    /api/v1/users/me            - Get current user
GET    /api/v1/users/me/points     - Get points summary
GET    /api/v1/venues              - List venues
POST   /api/v1/transactions        - Create transaction
GET    /api/v1/admin/venues/{id}/products - List products
POST   /api/v1/admin/products/{id}/bonus - Activate bonus
```

## 🤝 Contributing

1. Create a feature branch
2. Make changes
3. Run tests
4. Submit pull request

## 📄 License

Proprietary - Wiesbaden After Dark Platform

## 🆘 Support

For issues or questions:
- Email: support@wiesbadenafterdark.com
- Docs: /api/docs
