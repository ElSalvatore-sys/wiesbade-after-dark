# Wiesbaden After Dark - Technical Architecture

**Last Updated:** 2025-01-12
**Platform Status:** Backend deployed, iOS app complete, integration pending

---

## System Overview

### Architecture Pattern
**Client-Server** with RESTful API

```
┌─────────────────┐
│   iOS App       │ ← SwiftUI + SwiftData (local cache)
│  (iPhone 17+)   │
└────────┬────────┘
         │ HTTPS
         │ JWT Auth
         ▼
┌─────────────────┐
│  FastAPI Backend│ ← Python 3.11, async/await
│   (Railway)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ PostgreSQL DB   │ ← Supabase, EU Central 1
│  (Supabase)     │
└─────────────────┘

External Integrations:
├─ Stripe (payments) - Planned
├─ Apple Wallet (passes) - Partial
├─ orderbird PRO (POS) - Planned
└─ Firebase (push notifications) - Configured
```

---

## Backend Architecture

### Deployment

**Platform:** Railway.app
- **URL:** https://wiesbade-after-dark-production.up.railway.app
- **Region:** US-West (Oregon) - Consider EU region for GDPR
- **Runtime:** Python 3.11 (forced via runtime.txt)
- **Server:** Uvicorn (ASGI)
- **Process:** Single dyno (Hobby plan)
- **Cost:** €5-10/month estimate (no railway.json found)

**Configuration Files:**
- `runtime.txt`: Specifies Python 3.11
- `.env`: Environment variables (DATABASE_URL, JWT_SECRET, etc.)
- `requirements.txt`: Python dependencies
- `Procfile` OR startup command: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Technology Stack

**Core Framework:**
- FastAPI 0.104.1 (async, type-safe, auto-docs)
- Uvicorn 0.24.0 (ASGI server)
- Pydantic 2.x (validation, serialization)

**Database:**
- asyncpg 0.29.0 (PostgreSQL async driver)
- SQLAlchemy 2.0.23 (ORM, async mode)
- Alembic 1.12.1 (migrations)

**Authentication:**
- python-jose 3.3.0 (JWT creation/validation)
- passlib 1.7.4 (password hashing, bcrypt)

**Payments:**
- Stripe 7.7.0 (payment processing)

**Other:**
- python-multipart (file uploads)
- python-dotenv (environment variables)

### API Structure

**Endpoint Organization:** `/api/v1/{domain}/{action}`

**Domains:**
1. **auth** - Authentication and authorization
2. **users** - User profile and account management
3. **venues** - Venue discovery and details
4. **transactions** - Financial transactions
5. **admin** - Admin operations

**Authentication Flow:**
1. Client sends phone number → Backend sends verification code (mock)
2. Client submits code → Backend validates → Returns access + refresh tokens
3. Client stores tokens in Keychain (iOS)
4. Client includes `Authorization: Bearer {access_token}` in requests
5. Access token expires (15 min) → Client uses refresh token → New access token

**Security Measures:**
- JWT with HS256 algorithm
- Access token: 15 minutes expiration
- Refresh token: 30 days expiration
- Password hashing: bcrypt with salt
- CORS: Currently `["*"]` (⚠️ NEEDS RESTRICTION)
- Rate limiting: ❌ NOT IMPLEMENTED (TODO)
- Input validation: ✅ Pydantic models

### Database Schema

**Connection:**
- Host: `aws-0-eu-central-1.pooler.supabase.com`
- Port: 6543 (connection pooler, not direct 5432)
- Database: postgres
- SSL: Required
- Pooling: pgBouncer (Supabase managed)

**8 Tables:**

**1. users**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    first_name VARCHAR,
    last_name VARCHAR,
    phone VARCHAR,
    avatar_url VARCHAR,
    date_of_birth DATE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    total_points_earned DECIMAL DEFAULT 0,
    total_points_spent DECIMAL DEFAULT 0,
    total_points_available DECIMAL DEFAULT 0,
    referral_code VARCHAR UNIQUE NOT NULL,
    referred_by_code VARCHAR,
    total_referrals INTEGER DEFAULT 0,
    total_referral_earnings DECIMAL DEFAULT 0,
    fcm_token VARCHAR,
    preferred_language VARCHAR DEFAULT 'de',
    notification_preferences JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login_at TIMESTAMP,
    email_verified_at TIMESTAMP
);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_referred_by_code ON users(referred_by_code);
```

**2. venues**
```sql
CREATE TABLE venues (
    id UUID PRIMARY KEY,
    name VARCHAR NOT NULL,
    slug VARCHAR UNIQUE NOT NULL,
    venue_type VARCHAR,
    address VARCHAR,
    city VARCHAR,
    postal_code VARCHAR,
    latitude DECIMAL,
    longitude DECIMAL,
    phone VARCHAR,
    email VARCHAR,
    website VARCHAR,
    instagram VARCHAR,
    cover_image_url VARCHAR,
    logo_url VARCHAR,
    gallery_urls JSONB,
    food_margin_percent DECIMAL,
    beverage_margin_percent DECIMAL,
    default_margin_percent DECIMAL,
    points_multiplier DECIMAL DEFAULT 1.0,
    opening_hours JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_venues_slug ON venues(slug);
CREATE INDEX idx_venues_city ON venues(city);
```

**3. user_points (CRITICAL for BaFin compliance)**
```sql
CREATE TABLE user_points (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    venue_id UUID REFERENCES venues(id) ON DELETE CASCADE,
    points_earned DECIMAL DEFAULT 0,
    points_spent DECIMAL DEFAULT 0,
    points_available DECIMAL DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_visit_date DATE,
    total_visits INTEGER DEFAULT 0,
    total_spent DECIMAL DEFAULT 0,
    favorite_category VARCHAR,
    lifetime_value DECIMAL DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE (user_id, venue_id) -- ← KEY CONSTRAINT FOR TAX COMPLIANCE
);
CREATE INDEX idx_user_points_user_id ON user_points(user_id);
CREATE INDEX idx_user_points_venue_id ON user_points(venue_id);
```

**4. transactions**
```sql
CREATE TABLE transactions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    venue_id UUID REFERENCES venues(id),
    transaction_type VARCHAR NOT NULL, -- PURCHASE, POINTS_REDEMPTION, REFERRAL_BONUS, etc.
    status VARCHAR DEFAULT 'PENDING',
    amount_total DECIMAL,
    amount_cash DECIMAL,
    amount_points DECIMAL,
    points_earned DECIMAL DEFAULT 0,
    points_spent DECIMAL DEFAULT 0,
    points_multiplier DECIMAL DEFAULT 1.0,
    payment_method VARCHAR,
    payment_reference VARCHAR,
    stripe_payment_intent_id VARCHAR,
    order_items JSONB,
    category VARCHAR,
    notes TEXT,
    orderbird_receipt_id VARCHAR,
    orderbird_order_id VARCHAR,
    orderbird_synced_at TIMESTAMP,
    referral_level INTEGER, -- 1-5 for referral rewards
    original_transaction_id UUID REFERENCES transactions(id),
    extra_data JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    refunded_at TIMESTAMP
);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_venue_id ON transactions(venue_id);
CREATE INDEX idx_transactions_orderbird_receipt_id ON transactions(orderbird_receipt_id);
```

**5. referrals**
```sql
CREATE TABLE referrals (
    id UUID PRIMARY KEY,
    referrer_id UUID REFERENCES users(id),
    referred_id UUID REFERENCES users(id),
    referral_code_used VARCHAR NOT NULL,
    total_earnings DECIMAL DEFAULT 0,
    total_referred_purchases INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    first_purchase_at TIMESTAMP
);
CREATE INDEX idx_referrals_referrer_id ON referrals(referrer_id);
CREATE INDEX idx_referrals_referred_id ON referrals(referred_id);
```

**6. referral_chains (5-level tracking)**
```sql
CREATE TABLE referral_chains (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) UNIQUE,
    level_1_referrer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    level_2_referrer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    level_3_referrer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    level_4_referrer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    level_5_referrer_id UUID REFERENCES users(id) ON DELETE SET NULL,
    level_1_earnings DECIMAL DEFAULT 0,
    level_2_earnings DECIMAL DEFAULT 0,
    level_3_earnings DECIMAL DEFAULT 0,
    level_4_earnings DECIMAL DEFAULT 0,
    level_5_earnings DECIMAL DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_referral_chains_user_id ON referral_chains(user_id);
```

**7. products**
```sql
CREATE TABLE products (
    id UUID PRIMARY KEY,
    venue_id UUID REFERENCES venues(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    description TEXT,
    category VARCHAR,
    sku VARCHAR,
    price DECIMAL NOT NULL,
    cost DECIMAL,
    margin_percent DECIMAL,
    stock_quantity INTEGER,
    low_stock_threshold INTEGER,
    is_available BOOLEAN DEFAULT TRUE,
    bonus_points_active BOOLEAN DEFAULT FALSE,
    bonus_multiplier DECIMAL DEFAULT 1.0,
    bonus_start_date TIMESTAMP,
    bonus_end_date TIMESTAMP,
    bonus_reason VARCHAR,
    image_url VARCHAR,
    orderbird_product_id VARCHAR,
    orderbird_last_sync TIMESTAMP,
    total_sold INTEGER DEFAULT 0,
    total_revenue DECIMAL DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_products_venue_id ON products(venue_id);
CREATE INDEX idx_products_orderbird_product_id ON products(orderbird_product_id);
```

**8. alembic_versions**
```sql
CREATE TABLE alembic_versions (
    version_num VARCHAR PRIMARY KEY
);
```

### Business Logic

**Points Calculation (PointsCalculator class):**
```python
BASE_POINTS_RATE = 0.10  # 10% base

def calculate_points(amount, category_margin, venue_max_margin, product_bonus=1.0):
    # Margin ratio ensures high-margin items give more points
    margin_ratio = category_margin / venue_max_margin

    # Calculate base points
    base_points = amount * BASE_POINTS_RATE * margin_ratio

    # Apply product bonus (if active)
    final_points = base_points * product_bonus

    return round(final_points, 2)
```

**Referral Distribution (ReferralService):**
```python
REFERRAL_REWARD_PERCENTAGE = 0.25  # 25% per level

def distribute_referral_rewards(user_id, points_earned, venue_id):
    # Get referral chain for user
    chain = get_referral_chain(user_id)

    # Distribute to each level (1-5)
    for level in range(1, 6):
        referrer_id = chain[f"level_{level}_referrer_id"]
        if referrer_id:
            reward = points_earned * REFERRAL_REWARD_PERCENTAGE
            # Award points to referrer at this venue
            award_points(referrer_id, venue_id, reward, level)
```

**Streak Calculation:**
```python
def update_streak(user_id, venue_id):
    last_visit = get_last_visit_date(user_id, venue_id)
    today = datetime.now().date()

    if last_visit == today:
        return  # Already checked in today

    if last_visit == today - timedelta(days=1):
        # Consecutive day
        increment_streak(user_id, venue_id)
    else:
        # Streak broken
        reset_streak(user_id, venue_id)

    # Check for streak bonuses
    current_streak = get_streak(user_id, venue_id)
    if current_streak in [7, 14, 30]:
        award_streak_bonus(user_id, venue_id, current_streak)
```

---

## iOS App Architecture

### Project Structure

**90 Swift Files:**
```
WiesbadenAfterDark/
├── App/
│   └── WiesbadenAfterDarkApp.swift (entry point)
├── Models/ (13 SwiftData models)
│   ├── User.swift
│   ├── Venue.swift
│   ├── Event.swift
│   ├── Booking.swift
│   ├── CommunityPost.swift
│   ├── Reward.swift
│   ├── VenueMembership.swift (venue-specific points)
│   ├── CheckIn.swift
│   ├── WalletPass.swift
│   ├── PointTransaction.swift
│   ├── Payment.swift
│   ├── PointsPurchase.swift
│   └── Refund.swift
├── Views/ (41 views)
│   ├── Onboarding/ (5 views)
│   ├── Core/ (tabs, navigation)
│   ├── Discover/ (venue discovery, details)
│   ├── CheckIn/ (NFC, history, wallet)
│   ├── Payments/ (checkout, confirmation)
│   ├── Bookings/ (my bookings, details)
│   └── Components/ (19 reusable components)
├── Services/ (Protocols + Mocks)
│   ├── AuthServiceProtocol + MockAuthService
│   ├── VenueServiceProtocol + MockVenueService
│   ├── CheckInServiceProtocol + MockCheckInService
│   ├── WalletPassServiceProtocol + MockWalletPassService
│   ├── PaymentServiceProtocol + MockPaymentService
│   ├── BookingServiceProtocol + BookingService
│   ├── KeychainService (token storage)
│   ├── BiometricAuthManager (Face ID / Touch ID)
│   └── SecureLogger (PII sanitization)
└── ViewModels/
    ├── AuthenticationViewModel (27 print statements - PII risk)
    └── [Other view models]
```

### Technology Stack

**Core:**
- Swift 6.0 (concurrency-safe, strict)
- SwiftUI (declarative UI)
- SwiftData (local persistence, iCloud sync ready)
- Combine (reactive programming)

**Apple Frameworks:**
- Core NFC (NFC tag reading)
- PassKit (Apple Wallet passes)
- LocalAuthentication (Face ID / Touch ID)
- Security (Keychain Services)
- CoreLocation (venue discovery)
- UserNotifications (push notifications)

**Third-Party (Planned):**
- StripeKit (payments) - ❌ Not integrated
- Alamofire OR URLSession (HTTP client) - ❌ Not implemented

**Minimum Requirements:**
- iOS 17.0+ (SwiftData, new SwiftUI APIs)
- iPhone SE 2020+ (NFC support)
- Xcode 16+ (Swift 6 toolchain)

### Data Flow

**Current (Mock Data):**
```
SwiftUI View → ViewModel → Mock Service → Returns hardcoded data
                              ↓
                        SwiftData (local cache)
```

**Planned (Production):**
```
SwiftUI View → ViewModel → API Service → HTTP Request → Railway Backend
                              ↓                            ↓
                        SwiftData Cache                 PostgreSQL
                              ↓
                     Sync on app launch / pull-to-refresh
```

### Security Architecture

**Token Storage:**
- Access token: Keychain (not UserDefaults!)
- Refresh token: Keychain
- User ID: Keychain
- Keychain access group: com.ea-solutions.WiesbadenAfterDark

**Biometric Auth:**
- Face ID / Touch ID on app launch
- Fallback to passcode
- Configurable (user can disable)

**Logging:**
- SecureLogger sanitizes PII (email, phone, tokens)
- ⚠️ 302 print() statements remain (need migration)
- 27 in AuthenticationViewModel (contains PII)

**Network Security:**
- HTTPS only (App Transport Security)
- Certificate pinning: ❌ NOT IMPLEMENTED (TODO)
- JWT validation: Client-side expiration check

---

## Integration Points

### Stripe Payments

**Status:** UI complete, backend placeholder

**Flow (Planned):**
1. User selects points package (e.g., €10 for 100 points)
2. iOS calls `/api/v1/payments/create-intent`
3. Backend creates Stripe PaymentIntent → Returns client_secret
4. iOS presents Stripe payment sheet
5. User completes payment (card / Apple Pay)
6. Stripe webhook → Backend confirms → Awards points
7. iOS polls `/api/v1/transactions/{id}` → Updates UI

**Backend Endpoints:**
- POST `/api/v1/payments/create-intent` - ⚠️ Placeholder
- POST `/api/v1/payments/webhook` - ⚠️ Not implemented
- GET `/api/v1/payments/{id}` - ⚠️ Not implemented

**iOS Implementation:**
- PaymentSheet.swift - ✅ UI ready
- StripePaymentService - ❌ Empty class

**Missing:**
- Stripe publishable key (iOS)
- Stripe secret key (backend)
- Webhook endpoint configuration
- Test card handling

### Apple Wallet

**Status:** UI complete, pass generation missing

**Flow (Planned):**
1. User checks in at venue (NFC)
2. iOS calls `/api/v1/wallet/generate-pass`
3. Backend generates .pkpass file (signed)
4. iOS presents "Add to Wallet" sheet
5. User adds pass → Stored in Apple Wallet
6. Pass displays venue membership, points balance
7. Pass updates via push notifications (when points change)

**Backend Endpoints:**
- POST `/api/v1/wallet/generate-pass` - ❌ Not implemented
- POST `/api/v1/wallet/update-pass` - ❌ Not implemented
- POST `/api/v1/wallet/register-device` - ❌ Not implemented (for updates)

**iOS Implementation:**
- WalletPassDetailView.swift - ✅ UI ready
- MockWalletPassService - ✅ Returns mock passes

**Missing:**
- Pass Type ID: pass.com.ea-solutions.wiesbaden-after-dark (registered?)
- Team ID (Apple Developer account)
- Pass signing certificate
- Pass.json template
- Web service endpoints (for updates)

### orderbird PRO POS Integration

**Status:** Not started, fields prepared

**Planned Flow:**
1. Customer makes purchase at Das Wohnzimmer POS
2. orderbird creates receipt → Triggers webhook (or polling)
3. Backend receives transaction data
4. Backend awards points to customer (if phone number matches)
5. Customer receives push notification "You earned 15 points!"

**Backend Preparation:**
- `orderbird_receipt_id` field in transactions table
- `orderbird_product_id` field in products table
- `.env` config: `ORDERBIRD_API_KEY`, `ORDERBIRD_API_URL`

**Research Needed:**
- orderbird API documentation
- Authentication method (API key? OAuth?)
- Webhook vs. polling
- Data mapping (orderbird products → our products)
- Customer identification (phone number? Email? NFC tap before purchase?)

**Fallback:**
- Admin manual entry (already works)
- Customer submits receipt photo (OCR parsing)

### Firebase Cloud Messaging (Push Notifications)

**Status:** Backend configured, iOS integration pending

**Backend:**
- User.fcm_token field exists
- POST `/api/v1/users/me/fcm-token` endpoint exists

**iOS:**
- Info.plist: `remote-notification` background mode enabled
- Implementation: ❌ Not integrated

**Use Cases:**
- "You earned 25 points at Das Wohnzimmer!"
- "Your friend joined using your referral code!"
- "2x points on cocktails tonight at Das Wohnzimmer!"
- "Your streak is at 13 days - keep it going!"

---

## Deployment & DevOps

### Environments

**Production:**
- Backend: Railway (https://wiesbade-after-dark-production.up.railway.app)
- Database: Supabase (EU Central 1)
- iOS: TestFlight (pending) → App Store (pending)

**Staging:**
- ❌ Not configured
- Recommendation: Railway branch deployment

**Development:**
- Backend: Local (localhost:8000)
- Database: Supabase (shared) OR local PostgreSQL
- iOS: Xcode simulator + physical device

### CI/CD

**Current:**
- ❌ No automated testing
- ❌ No CI pipeline
- ❌ No deployment automation
- Git push to main → Railway auto-deploys (default behavior)

**Recommended:**
- GitHub Actions for backend tests
- Xcode Cloud for iOS builds
- Automated TestFlight uploads
- Database migration checks before deploy

### Monitoring

**Backend:**
- ❌ No error tracking (Sentry, Rollbar)
- ❌ No performance monitoring (New Relic, DataDog)
- ❌ No uptime monitoring (Pingdom, UptimeRobot)
- Railway provides basic logs

**iOS:**
- ❌ No crash reporting (Crashlytics, Bugsnag)
- ❌ No analytics (Mixpanel, Amplitude)
- ❌ No performance monitoring

**Recommendation:**
- Start with free tiers: Sentry (errors), Posthog (analytics), Better Stack (uptime)

---

## Performance & Scalability

### Current Bottlenecks

**Backend:**
1. Single Railway dyno (no horizontal scaling)
2. No caching (Redis not implemented)
3. No CDN for static assets
4. Synchronous operations (could be async)

**iOS:**
1. No pagination (loads all venues at once)
2. No image caching library (relies on native caching)
3. Large SwiftData models (could be optimized)

**Database:**
1. No connection pooling limits set
2. No query optimization (N+1 queries possible)
3. No read replicas

### Scalability Plan

**0-1,000 Users:**
- Current architecture sufficient
- Railway Hobby plan OK
- Supabase Free tier OK

**1,000-10,000 Users:**
- Railway Pro plan (€15-25/month, 2GB RAM)
- Supabase Pro (€25/month, connection pooling)
- Add Redis caching (Railway addon)
- Optimize database indexes

**10,000-100,000 Users:**
- Multiple Railway dynos (horizontal scaling)
- Read replicas for Supabase
- CDN for images (Cloudflare)
- Background job queue (Celery + Redis)
- Consider moving to AWS/GCP for cost optimization

**100,000+ Users:**
- Kubernetes cluster
- Managed Postgres (AWS RDS)
- Microservices architecture (split by domain)
- Full-time DevOps engineer

---

## Open Technical Debt

### Critical (Blocks Production)
1. ❌ iOS not connected to backend (uses mock data)
2. ❌ Stripe not implemented (payments won't work)
3. ❌ No automated tests (0 coverage)
4. ❌ 302 print() statements (PII exposure)
5. ❌ CORS wide open (security risk)

### High Priority
6. ❌ No error tracking (Sentry)
7. ❌ No rate limiting (DDoS risk)
8. ❌ No input sanitization beyond Pydantic
9. ❌ No database backups configured (Supabase has 7-day auto)
10. ❌ Apple Wallet pass generation missing

### Medium Priority
11. ❌ No caching (Redis)
12. ❌ No background jobs (Celery)
13. ❌ orderbird integration not researched
14. ❌ No API versioning strategy (currently /v1)
15. ❌ No database query optimization

### Low Priority
16. No CI/CD pipeline
17. No staging environment
18. No performance monitoring
19. No load testing
20. No documentation beyond README

---

## Next Technical Priorities

**Week 1-2: Backend Integration**
1. Create API client in iOS (URLSession-based)
2. Replace mock services with API calls
3. Implement error handling and retry logic
4. Test all endpoints from iOS
5. Handle token refresh flow

**Week 3-4: Payments & Wallet**
1. Configure Stripe in backend
2. Implement payment intent creation
3. Add Stripe webhook handler
4. Integrate StripeKit in iOS
5. Test payment flow end-to-end

**Week 5-6: Security & Quality**
1. Migrate print() to SecureLogger
2. Restrict CORS to iOS app
3. Add rate limiting (slowapi)
4. Add error tracking (Sentry)
5. Write critical path tests

**Week 7-8: Optimization**
1. Add Redis caching
2. Optimize database queries
3. Implement pagination
4. Add image CDN
5. Load testing

See `.claude/memory/next-critical-steps.md` for full roadmap.
