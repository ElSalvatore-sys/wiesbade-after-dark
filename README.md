# WiesbadenAfterDark 🌙

A modern nightlife loyalty platform connecting venues and guests in Wiesbaden, Germany. Earn points through venue check-ins, build streaks, unlock exclusive perks, and discover the vibrant after-dark scene.

[![Deploy to Railway](https://github.com/ElSalvatore-sys/wiesbade-after-dark/actions/workflows/deploy.yml/badge.svg)](https://github.com/ElSalvatore-sys/wiesbade-after-dark/actions/workflows/deploy.yml)
[![CodeQL](https://github.com/ElSalvatore-sys/wiesbade-after-dark/actions/workflows/codeql.yml/badge.svg)](https://github.com/ElSalvatore-sys/wiesbade-after-dark/actions/workflows/codeql.yml)
[![codecov](https://codecov.io/gh/ElSalvatore-sys/wiesbade-after-dark/branch/main/graph/badge.svg)](https://codecov.io/gh/ElSalvatore-sys/wiesbade-after-dark)

## 🚀 Features

### For Guests
- **Smart Check-Ins**: NFC, QR code, or geolocation-based venue check-ins
- **Points & Rewards**: Earn points with every visit, redeemable for exclusive perks
- **Streak Bonuses**: Build daily/weekly streaks for multiplier rewards
- **Tier System**: Progress from Bronze → Silver → Gold → Platinum → Diamond
- **Referral Network**: 5-level referral system with rewards for you and your friends
- **Event Discovery**: Find and book exclusive nightlife events
- **Apple Wallet Integration**: Store loyalty cards and event tickets

### For Venues
- **Customer Insights**: Real-time analytics on visitor patterns and engagement
- **Custom Rewards**: Create targeted promotions and special offers
- **Event Management**: List events, manage bookings, track attendance
- **Product Bonuses**: Boost specific products with point multipliers
- **Community Building**: Engage with your most loyal customers

## 🏗️ Architecture

### Backend (FastAPI)
- **Python 3.11** with async/await support
- **FastAPI** REST API with automatic OpenAPI documentation
- **PostgreSQL** (Supabase) for production data
- **Alembic** database migrations
- **JWT** authentication with refresh tokens
- **Railway** deployment with auto-scaling

### iOS App (SwiftUI)
- **iOS 17.0+** minimum deployment target
- **SwiftUI** modern declarative UI
- **SwiftData** local persistence
- **Combine** reactive programming
- **Core NFC** for venue check-ins
- **PassKit** Apple Wallet integration

## 📦 Project Structure

```
WiesbadenAfterDark/
├── backend/                      # FastAPI backend
│   ├── app/
│   │   ├── api/                  # API routes & endpoints
│   │   ├── core/                 # Config, database, security
│   │   ├── models/               # SQLAlchemy models
│   │   └── schemas/              # Pydantic schemas
│   ├── tests/                    # Pytest test suite
│   ├── alembic/                  # Database migrations
│   └── requirements.txt          # Python dependencies
├── WiesbadenAfterDark/           # iOS app source
│   ├── App/                      # App entry point
│   ├── Core/                     # Models, services, utilities
│   ├── Features/                 # Feature modules (Home, Profile, etc.)
│   └── Shared/                   # Reusable UI components
├── WiesbadenAfterDarkTests/      # iOS unit tests
└── docs/                         # Documentation
```

## 🛠️ Getting Started

### Backend Setup

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Setup environment variables
cp .env.example .env
# Edit .env with your configuration

# Run database migrations
alembic upgrade head

# Start development server
uvicorn app.main:app --reload
```

Backend will be available at: `http://localhost:8000`
API documentation: `http://localhost:8000/docs`

### iOS Setup

```bash
# Open Xcode project
open WiesbadenAfterDark.xcodeproj

# Update APIConfig.swift with your backend URL
# Build and run on simulator or device
```

**Requirements:**
- Xcode 15.0+
- iOS 17.0+ device or simulator
- Apple Developer account (for device deployment)

## 🧪 Testing

### Backend Tests

```bash
cd backend

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_auth.py -v
```

**Test Coverage:** 80%+ (enforced in CI/CD)

### iOS Tests

```bash
# Run tests in Xcode
cmd + U

# Or via command line
xcodebuild test \
  -project WiesbadenAfterDark.xcodeproj \
  -scheme WiesbadenAfterDark \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## 🚢 Deployment

### Backend (Railway)

Automatic deployment on push to `main`:

```bash
git push origin main
# GitHub Actions automatically:
# 1. Runs tests
# 2. Checks code quality
# 3. Deploys to Railway
```

Production URL: `https://wiesbade-after-dark-production.up.railway.app`

### iOS (TestFlight)

```bash
# Archive for distribution
xcodebuild archive \
  -project WiesbadenAfterDark.xcodeproj \
  -scheme WiesbadenAfterDark \
  -archivePath build/WiesbadenAfterDark.xcarchive

# Or use Fastlane (coming soon)
fastlane beta
```

## 📊 API Endpoints

**Authentication:**
- `POST /api/v1/auth/send-code` - Send SMS verification code
- `POST /api/v1/auth/verify-code` - Verify SMS code
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh access token

**Users:**
- `GET /api/v1/users/me` - Get current user profile
- `PUT /api/v1/users/me` - Update user profile
- `GET /api/v1/users/validate-referral` - Validate referral code

**Venues:**
- `GET /api/v1/venues` - List all venues
- `GET /api/v1/venues/{id}` - Get venue details
- `POST /api/v1/venues/{id}/join` - Join venue community

**Check-Ins & Points:**
- `POST /api/v1/checkins` - Create check-in
- `GET /api/v1/transactions/history` - Points transaction history
- `GET /api/v1/transactions/balance` - Current points balance

Full API documentation: `/docs` endpoint

## 🔐 Security

- **JWT Authentication** with secure refresh token rotation
- **HTTPS Only** - All API communication encrypted
- **CORS Protection** - Restricted origins
- **Rate Limiting** - API endpoint protection
- **Secrets Management** - Environment variables for sensitive data
- **CodeQL Scanning** - Weekly automated security analysis
- **Dependency Updates** - Automated via Dependabot

## 📈 Monitoring & Analytics

- **Railway Metrics**: Server performance, response times
- **Test Coverage**: Codecov integration
- **Error Tracking**: Production error logs
- **User Analytics**: Anonymized usage patterns

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎯 Roadmap

- [x] Backend MVP with 25 endpoints
- [x] iOS app with core features
- [x] NFC check-in support
- [x] Points calculation engine
- [x] Referral system (5 levels)
- [x] Tier progression
- [ ] Apple Wallet PassKit integration
- [ ] Stripe payment integration
- [ ] orderbird POS system integration
- [ ] Push notifications
- [ ] Social features (friends, leaderboards)
- [ ] Venue admin dashboard

## 📞 Support

- **Documentation**: [/docs](/docs)
- **Issues**: [GitHub Issues](https://github.com/ElSalvatore-sys/wiesbade-after-dark/issues)
- **Email**: support@wiesbadenafterdark.com

## 🙏 Acknowledgments

- Built with [FastAPI](https://fastapi.tiangolo.com/)
- Database powered by [Supabase](https://supabase.com/)
- Deployed on [Railway](https://railway.app/)
- iOS development with [SwiftUI](https://developer.apple.com/xcode/swiftui/)

---

**Made with ❤️ in Wiesbaden, Germany**
