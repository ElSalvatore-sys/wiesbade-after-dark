# WiesbadenAfterDark - Production TODO List
## Making it REAL, not a demo

**Goal:** Replace all mock data with real functionality

---

## 🔴 CRITICAL (Must Have for Launch)

### 1. Database - Real Data
- [ ] Create all Supabase tables (venues, events, users, shifts, tasks, inventory, employees)
- [ ] Set up Row Level Security (RLS) policies
- [ ] Seed with Das Wohnzimmer real data
- [ ] Connect PWA to real Supabase tables (not mock)

### 2. Authentication - Real Users
- [ ] Real user registration (not demo accounts)
- [ ] Email verification
- [ ] Password reset flow
- [ ] Session management
- [ ] Secure token storage

### 3. Shifts - Real Functionality
- [ ] Save shifts to Supabase
- [ ] Real employee PINs stored securely
- [ ] Shift history persists
- [ ] Timesheet data is real
- [ ] Break times tracked

### 4. Tasks - Real Functionality
- [ ] Save tasks to Supabase
- [ ] Photo uploads to Supabase Storage
- [ ] Task assignments persist
- [ ] Notifications when assigned
- [ ] Approval workflow saves

### 5. Inventory - Real Functionality
- [ ] Products from Supabase
- [ ] Stock levels persist
- [ ] Transfers recorded
- [ ] Low stock alerts real
- [ ] Variance reports save

### 6. Analytics - Real Data
- [ ] Revenue from real transactions
- [ ] Customer count from check-ins
- [ ] Labor costs from shifts
- [ ] Top products from sales

---

## 🟡 IMPORTANT (Should Have)

### 7. Push Notifications
- [ ] Web push notifications (PWA)
- [ ] Task assigned → Employee notified
- [ ] Low stock → Manager notified
- [ ] Shift overtime → Owner notified
- [ ] Service worker handles background

### 8. iOS App - Real Connection
- [ ] Connect to Supabase (not mock)
- [ ] Real check-ins save points
- [ ] Real bookings
- [ ] Real events from database
- [ ] Push notifications

### 9. Multi-Venue Support
- [ ] Owner can have multiple venues
- [ ] Switch between venues
- [ ] Separate data per venue
- [ ] Venue-specific employees

### 10. Reports & Export
- [ ] Daily summary email
- [ ] Weekly report PDF
- [ ] Monthly analytics
- [ ] Tax report export
- [ ] Employee payroll export

---

## 🟢 NICE TO HAVE (Future)

### 11. Integrations
- [ ] Orderbird POS API (sales data)
- [ ] Stripe payments
- [ ] Twilio SMS verification
- [ ] Email service (SendGrid/Resend)

### 12. Apple Features (iOS)
- [ ] Widgets (upcoming events)
- [ ] App Clips (quick check-in)
- [ ] Live Activities (event countdown)
- [ ] Siri Shortcuts
- [ ] Apple Wallet passes

### 13. Advanced Features
- [ ] AI inventory predictions
- [ ] Staff scheduling optimization
- [ ] Customer loyalty tiers
- [ ] Referral system
- [ ] Marketing campaigns

### 14. Admin Panel
- [ ] Super admin dashboard
- [ ] All venues overview
- [ ] System health monitoring
- [ ] User management
- [ ] Feature flags

---

## 📋 CURRENT MOCK DATA TO REPLACE

| Component | Current State | Needs |
|-----------|---------------|-------|
| Shifts | Mock employees, mock history | Real Supabase data |
| Tasks | Mock tasks, no persistence | Real Supabase CRUD |
| Inventory | Mock products | Real products table |
| Analytics | Generated numbers | Real aggregations |
| Employees | Mock list | Real employees table |
| Events | Supabase Edge Function | ✅ Already connected |
| Venues | Supabase Edge Function | ✅ Already connected |

---

## 🗄️ SUPABASE TABLES NEEDED

```sql
-- Already exist (from Edge Functions)
venues ✅
events ✅
products ✅

-- Need to create
employees (
  id uuid PRIMARY KEY,
  venue_id uuid REFERENCES venues(id),
  name text NOT NULL,
  email text,
  phone text,
  role text NOT NULL, -- owner, manager, bartender, waiter, security, dj, cleaning
  pin_hash text,
  hourly_rate decimal,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
)

shifts (
  id uuid PRIMARY KEY,
  venue_id uuid REFERENCES venues(id),
  employee_id uuid REFERENCES employees(id),
  clock_in timestamptz NOT NULL,
  clock_out timestamptz,
  break_minutes integer DEFAULT 0,
  status text, -- active, completed, no-show
  notes text,
  created_at timestamptz DEFAULT now()
)

tasks (
  id uuid PRIMARY KEY,
  venue_id uuid REFERENCES venues(id),
  title text NOT NULL,
  description text,
  assigned_to uuid REFERENCES employees(id),
  status text DEFAULT 'pending', -- pending, in-progress, completed, approved
  priority text DEFAULT 'medium', -- low, medium, high, urgent
  due_date timestamptz,
  photo_url text,
  approved_by uuid REFERENCES employees(id),
  approved_at timestamptz,
  created_at timestamptz DEFAULT now()
)

inventory_items (
  id uuid PRIMARY KEY,
  venue_id uuid REFERENCES venues(id),
  product_id uuid REFERENCES products(id),
  storage_qty integer DEFAULT 0,
  bar_qty integer DEFAULT 0,
  min_stock integer DEFAULT 5,
  last_counted timestamptz,
  created_at timestamptz DEFAULT now()
)

inventory_transfers (
  id uuid PRIMARY KEY,
  venue_id uuid REFERENCES venues(id),
  product_id uuid REFERENCES products(id),
  from_location text, -- storage, bar
  to_location text,
  quantity integer NOT NULL,
  transferred_by uuid REFERENCES employees(id),
  created_at timestamptz DEFAULT now()
)
```

---

## ⏱️ ESTIMATED TIME

| Category | Tasks | Time |
|----------|-------|------|
| Database Setup | Tables, RLS, seed | 2-3 hours |
| Auth System | Real login, register | 2-3 hours |
| Shifts → Real | CRUD, persistence | 3-4 hours |
| Tasks → Real | CRUD, photos | 3-4 hours |
| Inventory → Real | CRUD, transfers | 2-3 hours |
| Analytics → Real | Aggregations | 2-3 hours |
| **Total** | | **~15-20 hours** |

---

## 🎯 PRIORITY ORDER

1. **Database tables** - Foundation for everything
2. **Auth system** - Real users with roles
3. **Shifts** - Core feature for Das Wohnzimmer
4. **Tasks** - Core feature with photo proof
5. **Inventory** - Important for bar operations
6. **Analytics** - Nice to have real data
7. **Push notifications** - Engagement
8. **iOS connection** - Customer app

---

**Start with:** Database tables + Auth system
**Then:** Shifts (most requested by Das Wohnzimmer)

