# WiesbadenAfterDark Database Schema

Complete PostgreSQL database schema for the WiesbadenAfterDark loyalty platform.

## Overview

- **Database**: PostgreSQL (Supabase)
- **ORM**: SQLAlchemy
- **Migrations**: Alembic
- **Total Tables**: 14
- **Primary Key Strategy**: UUID (as_uuid=True)
- **Financial Precision**: DECIMAL(10, 2) for all points/money
- **Timezone**: All timestamps use timezone=True

## Entity-Relationship Diagram

```mermaid
erDiagram
    USERS ||--o{ VENUE_MEMBERSHIPS : "has"
    USERS ||--o{ CHECK_INS : "makes"
    USERS ||--o{ POINT_TRANSACTIONS : "has"
    USERS ||--o{ REFERRAL_CHAINS : "earns"
    USERS ||--o{ EVENT_RSVPS : "creates"
    USERS ||--o{ WALLET_PASSES : "owns"
    USERS ||--o{ USER_BADGES : "earns"
    USERS ||--o{ USERS : "refers"

    VENUES ||--o{ VENUE_MEMBERSHIPS : "has"
    VENUES ||--o{ PRODUCTS : "sells"
    VENUES ||--o{ CHECK_INS : "receives"
    VENUES ||--o{ EVENTS : "hosts"
    VENUES ||--o{ VENUE_TIER_CONFIGS : "configures"

    CHECK_INS ||--o{ REFERRAL_CHAINS : "triggers"
    CHECK_INS ||--o{ POINT_TRANSACTIONS : "creates"

    EVENTS ||--o{ EVENT_RSVPS : "has"

    BADGES ||--o{ USER_BADGES : "awarded"

    USERS {
        uuid id PK
        string phone_number UK
        string first_name
        string last_name
        string email UK
        date date_of_birth
        decimal total_points_earned
        decimal total_points_spent
        decimal total_points_available
        int total_referrals
        string referral_code UK
        uuid referred_by FK
        timestamp created_at
    }

    VENUES {
        uuid id PK
        string name
        string type
        text description
        decimal latitude
        decimal longitude
        decimal rating
        int member_count
        decimal food_margin_percent
        decimal beverage_margin_percent
        decimal points_multiplier
        timestamp created_at
    }

    VENUE_MEMBERSHIPS {
        uuid id PK
        uuid user_id FK
        uuid venue_id FK
        string current_tier
        int tier_level
        decimal points_balance
        decimal lifetime_points
        decimal points_to_next_tier
        int visit_count
        decimal tier_progress_percent
        timestamp joined_at
    }

    PRODUCTS {
        uuid id PK
        uuid venue_id FK
        string name
        string category
        decimal price
        decimal cost
        decimal margin_percent
        int stock_quantity
        boolean bonus_points_active
        decimal bonus_multiplier
        timestamp created_at
    }

    CHECK_INS {
        uuid id PK
        uuid user_id FK
        uuid venue_id FK
        decimal purchase_amount
        decimal margin_percent
        decimal base_points
        decimal tier_bonus
        decimal product_bonus
        decimal venue_multiplier_bonus
        decimal total_points_earned
        json items_purchased
        string verified
        timestamp checked_in_at
    }

    POINT_TRANSACTIONS {
        uuid id PK
        uuid user_id FK
        string transaction_type
        decimal points_amount
        decimal balance_before
        decimal balance_after
        string description
        uuid related_venue_id FK
        uuid related_check_in_id FK
        timestamp expires_at
        timestamp created_at
    }

    REFERRAL_CHAINS {
        uuid id PK
        uuid user_id FK
        uuid check_in_id FK
        int referral_level
        uuid referrer_user_id FK
        decimal purchase_amount
        decimal base_points_earned
        decimal reward_percentage
        decimal reward_points
        string status
        timestamp created_at
    }

    EVENTS {
        uuid id PK
        uuid venue_id FK
        string title
        string event_type
        timestamp start_time
        timestamp end_time
        int max_capacity
        int current_rsvp_count
        decimal ticket_price
        decimal attendance_points
        decimal bonus_points_multiplier
        string status
        boolean is_featured
    }

    EVENT_RSVPS {
        uuid id PK
        uuid user_id FK
        uuid event_id FK
        string status
        boolean attended
        timestamp check_in_time
        timestamp rsvp_at
    }

    WALLET_PASSES {
        uuid id PK
        uuid user_id FK
        string pass_type_identifier
        string serial_number UK
        string authentication_token
        json pass_data
        string status
        string version
        timestamp created_at
    }

    VENUE_TIER_CONFIGS {
        uuid id PK
        uuid venue_id FK
        string tier_name
        int tier_level
        decimal points_required
        int visits_required
        decimal points_multiplier
        decimal discount_percent
        json perks
        timestamp created_at
    }

    BADGES {
        uuid id PK
        string name UK
        text description
        string category
        string requirement_type
        int requirement_value
        boolean venue_specific
        string rarity
        boolean is_active
    }

    USER_BADGES {
        uuid id PK
        uuid user_id FK
        uuid badge_id FK
        timestamp earned_at
        int progress
        boolean notified
    }
```

## Table Descriptions

### 1. users
**Purpose**: Core user accounts and profile information

**Key Fields**:
- `phone_number`: Unique identifier for authentication
- `referral_code`: Unique code for referral system (10 chars)
- `total_points_*`: Aggregate point tracking
- `referred_by`: Self-referential FK to track referrer

**Indexes**:
- `idx_user_phone` on `phone_number`
- `idx_user_email` on `email`
- `idx_user_referral_code` on `referral_code`
- `idx_user_referred_by` on `referred_by`

**Constraints**:
- All point totals must be >= 0
- Phone number and email are unique
- Referral code is unique

---

### 2. venues
**Purpose**: Venue/establishment information

**Key Fields**:
- `type`: Category (bar, club, restaurant, cafe)
- `latitude/longitude`: Location for geospatial queries
- `*_margin_percent`: Category-specific margins for points calculation
- `points_multiplier`: Venue-wide bonus multiplier

**Indexes**:
- `idx_venue_type` on `type`
- `idx_venue_location` on `(latitude, longitude)` - composite for geospatial
- `idx_venue_rating` on `rating`

**Constraints**:
- Rating: 0-5 range
- All margin percentages: 0-100 range
- Points multiplier > 0

---

### 3. venue_memberships
**Purpose**: User membership and tier progression at specific venues

**Key Fields**:
- `current_tier`: Tier name (Bronze, Silver, Gold, Platinum, Diamond)
- `tier_level`: Numeric level 1-5
- `points_balance`: Current available points at this venue
- `lifetime_points`: Total points ever earned at this venue
- `tier_progress_percent`: Visual progress to next tier (0-100)

**Indexes**:
- `idx_membership_user` on `user_id`
- `idx_membership_venue` on `venue_id`
- `idx_membership_tier` on `current_tier`
- `idx_membership_user_venue` on `(user_id, venue_id)` - composite for lookups

**Constraints**:
- Unique constraint on `(user_id, venue_id)` - one membership per user per venue
- Tier level: 1-5 range
- All point fields >= 0
- Tier progress: 0-100 range

---

### 4. products
**Purpose**: Products/items available at venues

**Key Fields**:
- `category`: Product category (beverages, food, merchandise)
- `price/cost`: Financial tracking (DECIMAL for precision)
- `margin_percent`: Calculated margin for points
- `bonus_points_active`: Special promotion flag
- `bonus_multiplier`: Extra points multiplier when active
- `bonus_start_date/bonus_end_date`: Promotion period

**Indexes**:
- `idx_product_venue` on `venue_id`
- `idx_product_category` on `category`
- `idx_product_bonus_active` on `bonus_points_active`
- `idx_product_available` on `is_available`
- `idx_product_venue_category` on `(venue_id, category)` - composite

**Constraints**:
- Price, cost, margin all >= 0
- Margin: 0-100 range
- Bonus multiplier > 0
- Stock quantity >= 0

---

### 5. check_ins
**Purpose**: User purchases/check-ins at venues

**Key Fields**:
- `purchase_amount`: Total purchase (DECIMAL)
- `margin_percent`: Margin used for calculation
- `base_points`: purchase_amount * margin_percent / 100
- `tier_bonus`: Bonus from user's tier
- `product_bonus`: Bonus from special products
- `venue_multiplier_bonus`: Venue-wide multiplier bonus
- `total_points_earned`: Sum of all bonuses
- `items_purchased`: JSON array of purchased items
- `verified`: Verification status (pending, approved, rejected)

**Indexes**:
- `idx_checkin_user` on `user_id`
- `idx_checkin_venue` on `venue_id`
- `idx_checkin_user_venue` on `(user_id, venue_id)` - composite
- `idx_checkin_date` on `checked_in_at` - for time-series queries
- `idx_checkin_verified` on `verified` - for admin filtering

**Constraints**:
- All amounts and points >= 0
- Margin: 0-100 range

---

### 6. point_transactions
**Purpose**: Immutable ledger of all point movements

**Key Fields**:
- `transaction_type`: earn, spend, expire, adjust, referral_bonus
- `points_amount`: Positive for earn, negative for spend
- `balance_before/balance_after`: Audit trail
- `description`: Human-readable explanation
- `related_*_id`: Optional FKs to related entities
- `expires_at`: Expiration timestamp for earned points

**Indexes**:
- `idx_transaction_user` on `user_id`
- `idx_transaction_type` on `transaction_type`
- `idx_transaction_date` on `created_at` - for time-series
- `idx_transaction_venue` on `related_venue_id`
- `idx_transaction_expiry` on `expires_at` - for expiration jobs
- `idx_transaction_user_date` on `(user_id, created_at)` - composite for user history

**Constraints**:
- Both balances >= 0 (enforces non-negative points)

---

### 7. referral_chains
**Purpose**: 5-level referral reward tracking

**Key Fields**:
- `referral_level`: 1-5 (1 = direct, 2-5 = indirect)
- `referrer_user_id`: User receiving the reward
- `user_id`: User who made the purchase
- `purchase_amount`: Original purchase amount
- `base_points_earned`: Points earned by purchaser
- `reward_percentage`: % of base points rewarded
- `reward_points`: Actual reward amount
- `status`: pending, processed, expired

**Indexes**:
- `idx_referral_user` on `user_id`
- `idx_referral_referrer` on `referrer_user_id`
- `idx_referral_check_in` on `check_in_id`
- `idx_referral_level` on `referral_level`
- `idx_referral_status` on `status`
- `idx_referral_date` on `created_at`

**Constraints**:
- Referral level: 1-5 range
- All amounts >= 0
- Reward percentage: 0-100 range

---

### 8. events
**Purpose**: Events hosted at venues

**Key Fields**:
- `event_type`: concert, party, special_offer, etc.
- `start_time/end_time`: Event schedule
- `max_capacity`: Maximum attendees
- `current_rsvp_count`: Current RSVP count
- `ticket_price`: Entry cost (0 for free)
- `attendance_points`: Points for attending
- `bonus_points_multiplier`: Extra points during event
- `status`: upcoming, ongoing, completed, cancelled
- `is_featured`: Featured event flag

**Indexes**:
- `idx_event_venue` on `venue_id`
- `idx_event_type` on `event_type`
- `idx_event_start_time` on `start_time` - for chronological queries
- `idx_event_status` on `status`
- `idx_event_featured` on `is_featured`
- `idx_event_venue_date` on `(venue_id, start_time)` - composite

**Constraints**:
- end_time > start_time
- max_capacity > 0
- All counts and prices >= 0
- Bonus multiplier > 0

---

### 9. event_rsvps
**Purpose**: User RSVPs and attendance tracking

**Key Fields**:
- `status`: confirmed, cancelled, waitlist
- `attended`: Actual attendance flag
- `check_in_time`: When user arrived
- `reminder_sent`: Notification tracking

**Indexes**:
- `idx_rsvp_user` on `user_id`
- `idx_rsvp_event` on `event_id`
- `idx_rsvp_status` on `status`
- `idx_rsvp_attended` on `attended`
- `idx_rsvp_user_event` on `(user_id, event_id)` - composite

**Constraints**:
- Unique constraint on `(user_id, event_id)` - one RSVP per user per event

---

### 10. wallet_passes
**Purpose**: Apple Wallet pass management

**Key Fields**:
- `pass_type_identifier`: Apple Wallet type ID
- `serial_number`: Unique pass serial
- `authentication_token`: Secure update token
- `pass_data`: Complete pass.json structure (JSON)
- `device_library_identifier`: Registered device
- `push_token`: For push notifications
- `version`: Pass version tracking

**Indexes**:
- `idx_wallet_user` on `user_id`
- `idx_wallet_serial` on `serial_number` - for Apple Wallet API
- `idx_wallet_device` on `device_library_identifier`
- `idx_wallet_status` on `status`
- `idx_wallet_token` on `authentication_token` - for secure lookups

**Constraints**:
- Serial number is unique

---

### 11. venue_tier_configs
**Purpose**: Venue-specific tier configuration

**Key Fields**:
- `tier_name`: Tier display name
- `tier_level`: Numeric level 1-5
- `points_required`: Lifetime points needed
- `visits_required`: Minimum visits needed
- `points_multiplier`: Extra points multiplier (>= 1.0)
- `discount_percent`: Percentage discount
- `perks`: JSON array of perks

**Indexes**:
- `idx_tier_config_venue` on `venue_id`
- `idx_tier_config_level` on `tier_level`
- `idx_tier_config_venue_level` on `(venue_id, tier_level)` - composite

**Constraints**:
- Unique constraint on `(venue_id, tier_level)`
- Unique constraint on `(venue_id, tier_name)`
- Tier level: 1-5 range
- Points multiplier >= 1.0
- Discount: 0-100 range

---

### 12. badges
**Purpose**: Achievement badge definitions

**Key Fields**:
- `name`: Unique badge name
- `category`: achievement, milestone, social, venue_specific
- `requirement_type`: check_ins, points_earned, referrals, etc.
- `requirement_value`: Number needed
- `venue_specific`: Venue-only badge flag
- `rarity`: common, rare, epic, legendary
- `is_active`: Active badge flag

**Indexes**:
- `idx_badge_category` on `category`
- `idx_badge_rarity` on `rarity`
- `idx_badge_active` on `is_active`
- `idx_badge_venue_specific` on `venue_specific`

**Constraints**:
- Name is unique
- Requirement value >= 0

---

### 13. user_badges
**Purpose**: User badge ownership/progress

**Key Fields**:
- `earned_at`: When badge was earned
- `progress`: Progress percentage (0-100)
- `notified`: Notification sent flag

**Indexes**:
- `idx_user_badge_user` on `user_id`
- `idx_user_badge_badge` on `badge_id`
- `idx_user_badge_earned` on `earned_at`
- `idx_user_badge_user_badge` on `(user_id, badge_id)` - composite

**Constraints**:
- Unique constraint on `(user_id, badge_id)` - one badge per user
- Progress: 0-100 range

---

## Index Strategy

### Performance Optimization

1. **Foreign Keys**: All foreign keys have indexes for JOIN performance
2. **Composite Indexes**: Created for common query patterns
   - `(user_id, venue_id)` - User's memberships/check-ins at specific venues
   - `(venue_id, category)` - Product filtering
   - `(user_id, created_at)` - User transaction history
   - `(latitude, longitude)` - Geospatial queries
   - `(venue_id, start_time)` - Event listings

3. **Time-Series**: All `created_at` and date fields indexed for:
   - Historical queries
   - Analytics
   - Expiration jobs

4. **Status Fields**: Boolean and enum-like fields indexed for filtering:
   - `verified` on check_ins
   - `status` on various tables
   - `is_available`, `bonus_points_active` on products
   - `is_featured` on events

### Query Optimization Notes

**Common Query Patterns**:
```sql
-- User's memberships (uses idx_membership_user)
SELECT * FROM venue_memberships WHERE user_id = ?;

-- Venue's products by category (uses idx_product_venue_category)
SELECT * FROM products WHERE venue_id = ? AND category = ?;

-- User's transaction history (uses idx_transaction_user_date)
SELECT * FROM point_transactions WHERE user_id = ? ORDER BY created_at DESC;

-- Nearby venues (uses idx_venue_location)
SELECT * FROM venues WHERE
  latitude BETWEEN ? AND ? AND
  longitude BETWEEN ? AND ?;

-- Upcoming events at venue (uses idx_event_venue_date)
SELECT * FROM events WHERE venue_id = ? AND start_time > NOW();

-- Expired points (uses idx_transaction_expiry)
SELECT * FROM point_transactions WHERE expires_at < NOW();
```

---

## Data Precision & Financial Integrity

### DECIMAL Usage
All financial and points data uses `DECIMAL(10, 2)`:
- **10 digits total**: Up to 99,999,999.99
- **2 decimal places**: Precise to cents/hundredths
- **No floating-point errors**: Critical for financial accuracy

**Fields using DECIMAL**:
- All `*_points*` fields
- All `*_amount*` fields
- All `*_percent*` fields (with appropriate scale)
- `price`, `cost`, `margin_percent`
- Geographic coordinates (DECIMAL(10,8) and DECIMAL(11,8))

### Constraint Enforcement

**Check Constraints** ensure data validity:
- Non-negative amounts (points, prices, counts)
- Percentage ranges (0-100)
- Rating ranges (0-5)
- Tier level ranges (1-5)
- Referral level ranges (1-5)
- Time validity (end_time > start_time)

**Unique Constraints** prevent duplicates:
- One membership per user per venue
- One RSVP per user per event
- One badge per user
- Unique phone numbers, emails, referral codes
- Unique wallet pass serial numbers

**Foreign Key Constraints** ensure referential integrity:
- CASCADE DELETE: Child records deleted when parent deleted
- SET NULL: Soft references preserved when parent deleted

---

## Migration Application

### Prerequisites
```bash
cd backend
pip install -r requirements.txt
```

### Environment Setup
Create `.env` file:
```env
DATABASE_URL=postgresql://user:password@localhost:5432/wiesbaden_after_dark
```

### Apply Migration
```bash
# Initialize Alembic (if not already done)
alembic init alembic

# Apply migration
alembic upgrade head

# Verify
alembic current
```

### Rollback
```bash
alembic downgrade -1
```

---

## Schema Version

- **Version**: 001
- **Created**: 2025-11-14
- **Tables**: 14
- **Indexes**: 80+
- **Constraints**: 50+
- **Status**: Production-Ready ✅

---

## Next Steps

1. **Seed Data**: Create initial tier configurations, badges
2. **API Development**: Build REST/GraphQL endpoints
3. **Testing**: Unit tests for models, integration tests for queries
4. **Monitoring**: Add query performance monitoring
5. **Backup Strategy**: Configure automated backups
6. **Scaling**: Add read replicas as needed

---

## Support

For schema updates or questions:
- Review model definitions in `backend/app/models/`
- Check migration file in `backend/alembic/versions/001_complete_schema.py`
- Consult SQLAlchemy documentation for ORM usage
