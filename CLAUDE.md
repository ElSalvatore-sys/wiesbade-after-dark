# WiesbadenAfterDark - iOS Nightlife & Loyalty App

## Project Overview
Native iOS app (SwiftUI) + FastAPI backend for Wiesbaden nightlife venues.
Features: venue discovery, QR check-ins, points/loyalty system, event bookings, Apple Wallet passes.

## Tech Stack

### iOS App
- **Language**: Swift (SwiftUI)
- **Target**: iOS 17+
- **Architecture**: Feature-based modules in `/Features/`
- **No external dependencies** (pure SwiftUI)

### Backend
- **Framework**: FastAPI 0.104.1
- **Database**: Supabase PostgreSQL (14 tables)
- **ORM**: SQLAlchemy 2.0.23 + Alembic migrations
- **Auth**: python-jose (JWT) + passlib (bcrypt)
- **SMS**: Twilio (phone verification)

### Deployment
- **Backend**: Railway (https://wiesbade-after-dark-production.up.railway.app)
- **Database**: Supabase
- **iOS**: TestFlight → App Store

## Database Models (Key Tables)
- `users` - accounts, points, referral_code
- `venues` - bars/clubs with ratings, margins
- `venue_memberships` - user-venue tier/points
- `check_ins` - visit records, points earned
- `point_transactions` - points ledger with expiry
- `referral_chains` - multi-level referral tracking
- `events` / `event_rsvps` - event system
- `wallet_passes` - Apple Wallet integration

## Project Structure
```
WiesbadenAfterDark/
├── backend/
│   ├── app/api/          # Route handlers
│   ├── app/models/       # SQLAlchemy (22 models)
│   ├── app/schemas/      # Pydantic validation
│   ├── app/services/     # Business logic
│   └── alembic/          # DB migrations
├── WiesbadenAfterDark/   # iOS App
│   ├── Features/         # 12 feature modules
│   ├── Core/             # Networking, config
│   └── Shared/           # Reusable components
```

## iOS Feature Modules
1. **Onboarding** - Phone verification, registration
2. **Home** - Dashboard, nearby venues
3. **Discover** - Venue browsing
4. **VenueDetail** - Individual venue pages
5. **CheckIn** - QR/location-based check-ins
6. **Points** - Balance, transactions
7. **Events** - Listings, RSVPs
8. **Bookings** - Table reservations
9. **Payments** - Payment processing
10. **Profile** - User settings
11. **Community** - Social features
12. **VenueManagement** - Owner dashboard

## Development Workflows

### iOS Development
```bash
# Open in Xcode
open WiesbadenAfterDark.xcodeproj

# Build: Cmd+B
# Run: Cmd+R (iPhone 17 Simulator)
```

### Backend Development
```bash
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8000

# Run migrations
alembic upgrade head

# Create new migration
alembic revision --autogenerate -m "description"
```

### Testing
```bash
# Backend tests
cd backend && pytest

# iOS tests
# Cmd+U in Xcode
```

## API Documentation
- Local: http://localhost:8000/api/docs
- Production: https://wiesbade-after-dark-production.up.railway.app/api/docs

## Current Status
- Backend: 🟢 Live on Railway
- iOS: 🟡 Ready for TestFlight
- Build: ✅ 0 errors, 27 warnings

## Tool Priorities

### High Priority
- **Xcode**: iOS development, debugging
- **Prisma/SQLAlchemy**: Database operations
- **Playwright**: Test API endpoints

### When to Use Skills
- **web-asset-generator**: PWA icons, social sharing images for marketing
- **docx**: Booking confirmations, venue contracts, invoices

## Debugging Notes
<!-- Add solved issues here so Claude remembers -->

## Current Sprint
<!-- Update via Archon tasks -->
