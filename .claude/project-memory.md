# WiesbadenAfterDark - Comprehensive Project Memory

**Last Updated:** November 15, 2025 (Auto-generated)  
**Project Status:** 85% Complete - MVP Ready, App Store Preparation Phase  
**Current Branch:** `cleanup/homeview-refactor`  
**Next Milestone:** TestFlight Beta (Target: December 1, 2025)

---

## 🎯 Project Overview

**Vision:** The ultimate nightlife companion for Wiesbaden - discover venues, check in with NFC, earn points, and unlock exclusive experiences.

**Type:** Native iOS App (SwiftUI) + Backend API (FastAPI)  
**Target Users:** Nightlife enthusiasts in Wiesbaden, Germany  
**Business Model:** Freemium (free check-ins, premium bookings & experiences)  
**First Partner:** Das Wohnzimmer (pitch deck ready)

---

## 📍 Current State (as of Nov 15, 2025)

### Project Metrics
- **iOS Codebase:** 151 Swift files, 8,992 total files, 108 MB
- **Backend Codebase:** 20+ Python files (FastAPI)
- **Database:** 14 PostgreSQL tables (Supabase-hosted)
- **Tests:** 38+ backend tests, 80% coverage enforced
- **Deployment:** Railway (backend live), iOS pending TestFlight
- **Git Status:** Clean working directory

### Recent Activity (Last 48 Hours)
- ✅ Nov 15 06:38 - **Major refactor:** HomeView reduced from 799 lines → 8 focused components
- ✅ Nov 15 05:41 - Simplified Profile to 4 sections
- ✅ Nov 15 04:51 - **Critical fix:** Resolved infinite loop memory crash
- ✅ Nov 14 - Railway deployment configured & live
- ✅ Nov 14 - Real Wiesbaden venues seed data added
- ✅ Nov 14 - Check-in celebration animations implemented

---

## 🏗️ Architecture

### iOS App Stack
**Framework:** SwiftUI + SwiftData (iOS 17.6+ required)  
**Pattern:** MVVM + Protocol-Oriented Design  
**Deployment Target:** iOS 17.6+  
**Bundle ID:** `com.wiesbadenafterDark.app` (placeholder)

**Key Apple Frameworks:**
- **PassKit** - Apple Wallet integration for loyalty passes
- **CoreNFC** - NFC tag reading for venue check-ins
- **LocalAuthentication** - Face ID/Touch ID for secure actions
- **CoreLocation** - Venue discovery & proximity detection
- **SwiftData** - Local persistence (bookings, check-ins, points)

**Feature Modules (13 total):**
1. **Home** - Dashboard with recommendations, recent check-ins
2. **Discover** - Venue browsing, search, filters, map view
3. **Events** - Upcoming events calendar & details
4. **Profile** - User stats, level, badges, settings
5. **CheckIn** - NFC check-in flow with animations
6. **Bookings** - Table reservations & event tickets
7. **Payments** - Stripe integration (prepared, not live)
8. **Points** - Points balance, history, rewards catalog
9. **Wallet** - Apple Wallet pass management
10. **Social** - Referrals, leaderboards (5-level deep tracking)
11. **Notifications** - Push & local notifications
12. **Onboarding** - Welcome flow & phone verification
13. **Settings** - Preferences, privacy, account management

### Backend Stack
**Framework:** FastAPI 0.104.1 (async)  
**Database:** PostgreSQL 14+ via Supabase  
**ORM:** SQLAlchemy 2.0+ (async)  
**Hosting:** Railway (4 Uvicorn workers)  
**Production URL:** `https://wiesbaden-after-dark-production.up.railway.app`

**API Endpoints (20+ RESTful routes):**
- Authentication: SMS verification via Twilio
- Venues: CRUD, search, details, hours
- Check-ins: NFC validation, points calculation
- Events: Listings, bookings, RSVPs
- Points: Balance, transactions, rewards
- Referrals: 5-level deep chain tracking
- Wallet: Pass generation, updates
- Admin: Venue management, analytics

**Database Schema (14 tables):**
```
users, venues, check_ins, point_transactions, referral_chains,
events, bookings, wallet_passes, special_offers, badges,
venue_hours, user_preferences, push_tokens, admin_logs
```

### External Services
- ✅ **Supabase** - PostgreSQL hosting, real-time subscriptions
- ✅ **Twilio** - SMS verification (active, configured)
- ✅ **Railway** - Backend hosting (deployed, healthy)
- ⏸️ **Stripe** - Payment processing (code ready, keys not configured)
- 📋 **Apple Developer** - Provisioning needed for TestFlight
- 📋 **App Store Connect** - Account setup pending

### Required Environment Variables
```bash
# Database
DATABASE_URL                 # Supabase PostgreSQL connection string
SUPABASE_URL                 # Supabase project URL
SUPABASE_KEY                 # Supabase anon/public key
SUPABASE_JWT_SECRET          # JWT verification secret

# Authentication
JWT_SECRET_KEY               # App JWT signing key
TWILIO_ACCOUNT_SID           # Twilio account identifier
TWILIO_AUTH_TOKEN            # Twilio auth token
TWILIO_VERIFY_SERVICE_SID    # Twilio Verify service ID

# API Configuration
ALLOWED_ORIGINS              # CORS allowed origins (fixed: no longer wildcard)

# Payments (not yet configured)
STRIPE_SECRET_KEY            # Stripe secret key
STRIPE_PUBLISHABLE_KEY       # Stripe publishable key
STRIPE_WEBHOOK_SECRET        # Stripe webhook signature secret
```

---

## ✅ What's Working (Production-Ready Features)

### Backend (Deployed & Live)
- ✅ FastAPI server running on Railway (4 workers)
- ✅ SMS authentication flow via Twilio
- ✅ Venue discovery with search & filters
- ✅ Check-in system with NFC tag validation
- ✅ Points calculation (margin-based, 5-level referrals)
- ✅ Database migrations & seed data
- ✅ Comprehensive test suite (38+ tests, 80% coverage)
- ✅ CI/CD pipeline (GitHub Actions: test → deploy)
- ✅ CORS security fixed (no longer wildcard)
- ✅ CodeQL security scanning active
- ✅ Dependabot enabled (weekly updates)

### iOS App (Ready for TestFlight)
- ✅ Complete UI/UX for all 13 feature modules
- ✅ HomeView refactored into 8 reusable components
- ✅ NFC check-in flow with celebration animations
- ✅ SwiftData models (18 total) for offline-first architecture
- ✅ Apple Wallet pass generation & updates
- ✅ Face ID authentication for sensitive actions
- ✅ Real Wiesbaden venue data (seed data loaded)
- ✅ Service layer abstraction (network, storage, location)
- ✅ Error handling & user feedback
- ✅ Dark mode support

---

## ⚠️ What Needs Completion (Before Launch)

### Priority 1: App Store Blockers
1. **Stripe Integration** - Code exists (100+ TODOs), keys not configured
   - Complete payment flow testing
   - Add webhook handlers
   - Implement refund logic
2. **App Icon** - No 1024x1024 icon designed yet
3. **App Store Assets**
   - No screenshots (need 6.5", 6.7", 12.9" sizes)
   - No app preview videos
   - No marketing copy written
4. **Privacy Policy & Terms of Service** - Required for App Store submission
5. **Provisioning Profiles** - Apple Developer account needed

### Priority 2: Security & Production Hardening
1. **Rate Limiting** - Not implemented (security gap)
2. **Certificate Pinning** - iOS → Backend communication not pinned
3. **Email Notifications** - Only SMS currently active (SendGrid/AWS SES needed)
4. **Crash Reporting** - No Sentry/Firebase integration yet
5. **Analytics** - No user behavior tracking (consider Mixpanel)

### Priority 3: Feature Completion
1. **Booking Persistence** - UI ready, SwiftData integration incomplete
2. **Payment History** - UI exists, service integration needed
3. **Venue Photos** - Currently relies on URLs, need CDN (Cloudflare R2?)
4. **Push Notifications** - Backend ready, iOS certificates needed
5. **Social Features** - Referral system backend complete, iOS UI partial

### Priority 4: Testing & Quality
1. **iOS Unit Tests** - Currently 0 tests
2. **iOS UI Tests** - Currently 0 tests
3. **Backend Load Testing** - Not performed yet
4. **Accessibility Audit** - VoiceOver, Dynamic Type not tested

---

## 🗓️ Roadmap & Timeline

### Phase 1: TestFlight Beta (Target: Dec 1, 2025) - 2 weeks
**Goals:** Internal testing with 10-20 users

**Tasks:**
- [ ] Generate app icon (1024x1024) using `web-asset-generator` skill ✨
- [ ] Configure Apple Developer account ($99/year)
- [ ] Create provisioning profiles (development, distribution)
- [ ] Write Privacy Policy & Terms of Service
- [ ] Configure Stripe keys (test mode first)
- [ ] Create 6 App Store screenshots per device size
- [ ] Set up TestFlight in App Store Connect
- [ ] Upload first build via Xcode Cloud or Fastlane
- [ ] Add 10 internal testers
- [ ] Create feedback collection form (Google Forms/Typeform)

**Estimated Effort:** 40 hours (1 week full-time or 2 weeks part-time)

### Phase 2: Private Beta (Target: Dec 15, 2025) - 2 weeks
**Goals:** External testing with 50 users, Das Wohnzimmer partnership

**Tasks:**
- [ ] Implement rate limiting (20 requests/minute per user)
- [ ] Add Sentry for crash reporting
- [ ] Complete Stripe integration & test payments
- [ ] Enable push notifications
- [ ] Seed 20+ real Wiesbaden venues
- [ ] Add CDN for venue images (Cloudflare R2)
- [ ] Pitch Das Wohnzimmer (deck ready, schedule meeting)
- [ ] Recruit 50 beta testers (Instagram/Facebook ads?)
- [ ] Weekly feedback review & bug fixes
- [ ] Implement top 5 feature requests

**Estimated Effort:** 60 hours

### Phase 3: App Store Submission (Target: Jan 1, 2026) - 2 weeks
**Goals:** Public launch on iOS App Store

**Tasks:**
- [ ] Accessibility audit & fixes (VoiceOver, Dynamic Type)
- [ ] Performance optimization (reduce app size, loading times)
- [ ] App Store metadata (description, keywords, screenshots)
- [ ] Create app preview video (30 seconds)
- [ ] Final security audit (penetration testing?)
- [ ] App Store review submission
- [ ] Marketing materials (website landing page, social media)
- [ ] Press kit for local Wiesbaden media
- [ ] Monitor review status daily

**Estimated Effort:** 50 hours

### Phase 4: Post-Launch (Jan 2026 onwards)
**Goals:** User acquisition, retention, expansion

**Milestones:**
- [ ] **Month 1:** 100 active users, 5 partner venues
- [ ] **Month 3:** 500 active users, 15 partner venues
- [ ] **Month 6:** 2,000 active users, 30 partner venues
- [ ] **Month 12:** 10,000 active users, break-even revenue

**Features to Add:**
- Social check-ins (share to Instagram Stories)
- Group bookings & event tickets
- Gamification (badges, achievements, levels)
- Venue loyalty programs integration
- User-generated content (reviews, photos)
- Admin dashboard for venue partners

---

## 🔑 Critical Technical Details

### Points Calculation Logic
```python
# Margin-based points: Higher margin items = more points
points = (price * margin_percentage) / 10

# Referral chain: 5 levels deep
Level 1 (direct): 10% of referral's points
Level 2: 5% of referral's points
Level 3: 3% of referral's points
Level 4: 2% of referral's points
Level 5: 1% of referral's points
```

### Check-In Flow
1. User taps NFC tag at venue entrance
2. iOS app reads NFC tag (venue ID embedded)
3. POST to `/api/check-in` with venue_id + user_id + timestamp
4. Backend validates: venue exists, tag is authentic, not duplicate (1 per day)
5. Points awarded (base: 10 points + margin-based bonus if purchase made)
6. Referral chain points distributed (5 levels up)
7. Celebration animation shown in iOS app

### Database Indexes (Performance)
```sql
CREATE INDEX idx_checkins_user_venue_date ON check_ins(user_id, venue_id, created_at);
CREATE INDEX idx_points_user_date ON point_transactions(user_id, created_at);
CREATE INDEX idx_referrals_chain ON referral_chains(referrer_id, referee_id);
```

---

## 📚 Knowledge Base References

### Documentation (Links to Central KB)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [FastAPI Docs](https://fastapi.tiangolo.com)
- [Supabase Docs](https://supabase.com/docs)
- [Railway Deployment](https://docs.railway.app)
- [Stripe iOS SDK](https://stripe.com/docs/mobile/ios)
- [Twilio Verify](https://www.twilio.com/docs/verify)
- [PassKit Guide](https://developer.apple.com/documentation/passkit)
- [Core NFC](https://developer.apple.com/documentation/corenfc)

### Applicable Skills (from Skills Inventory)
1. ⭐ **web-asset-generator** - Generate app icon, social sharing images, PWA icons
2. **docx** - Create booking confirmations, receipts
3. **pdf** - Generate event tickets, terms of service
4. **xlsx** - Export analytics, venue reports
5. **scientific-visualization** (adapted) - User analytics dashboards

### Active MCPs
1. **Filesystem** - File operations, project navigation
2. **GitHub** - Issue tracking, PR automation
3. **Figma** - Design-to-code (if designs exist)
4. **Archon** - Task management, knowledge base (not yet connected to this project)

---

## 🐛 Known Issues & Technical Debt

### Critical (Fix Before Launch)
1. **100+ TODO comments** in codebase
   - Priority TODOs: Booking system (12 TODOs), Stripe integration (45 TODOs)
2. **Rate limiting not implemented** - API endpoints vulnerable to abuse
3. **Certificate pinning not implemented** - Man-in-the-middle attack vector
4. **Mock payment service still in use** - Replace with real Stripe integration

### Medium Priority
1. **French file schema violations** (from LingXM analysis, wrong project but noted)
2. **No app icon** - Currently using default placeholder
3. **Incomplete booking SwiftData persistence** - UI works, storage incomplete
4. **No venue photos** - Relies on external URLs, no local caching

### Low Priority (Post-Launch)
1. **GraphQL consideration** - REST is working, but GraphQL might improve complex queries
2. **Image optimization** - No progressive loading or compression
3. **Monitoring/APM** - No New Relic/Datadog for backend performance
4. **Email service** - Only SMS currently, no email verification

---

## 🎯 Success Metrics (How We'll Measure Progress)

### Technical Metrics
- **Test Coverage:** Currently 80% (backend), 0% (iOS) → Target: 80% both
- **API Response Time:** Currently <200ms average → Target: <150ms
- **App Crash Rate:** Not tracked → Target: <0.1%
- **Build Success Rate:** Currently manual → Target: 100% automated

### Business Metrics
- **Monthly Active Users (MAU):** 0 → Target: 100 (Month 1), 2,000 (Month 6)
- **Check-ins per User:** N/A → Target: 8/month average
- **Booking Conversion:** N/A → Target: 15% of check-ins → bookings
- **Revenue per User:** $0 → Target: $5/month average (by Month 6)

### User Satisfaction
- **App Store Rating:** N/A → Target: 4.5+ stars
- **Net Promoter Score (NPS):** N/A → Target: 50+ (good)
- **Beta Feedback Score:** N/A → Target: 4.2+ out of 5

---

## 🚀 Quick Commands & Workflows

### Development
```bash
# Navigate to project
proj wies  # Auto-activates Python venv if needed

# Backend
cd backend
uvicorn app.main:app --reload  # Run local backend

# iOS
open WiesbadenAfterDark.xcodeproj  # Open in Xcode
# ⌘+R to build & run in simulator

# Run tests
pytest tests/ -v --cov=app --cov-report=html  # Backend tests
# iOS tests: ⌘+U in Xcode
```

### Deployment
```bash
# Backend (automatic via GitHub Actions on push to main)
git push origin main  # Triggers Railway deployment

# iOS (manual for now, Fastlane coming in Phase 2)
# Xcode → Product → Archive → Distribute → TestFlight
```

### Memory Update (Automated)
```bash
# Automatic: Runs on every push via GitHub Actions
# Manual trigger:
.github/workflows/update-memory.yml  # Will create in next step
```

---

## 🔄 Auto-Update Rules (For GitHub Actions)

**Triggers:**
- Every commit to `main` or `develop` branches
- Every PR merge
- Weekly cron (Sundays at midnight UTC)

**What Gets Updated:**
1. **Last Updated** timestamp
2. **Recent Activity** - Last 10 commits
3. **Current State** - File counts, test coverage, deployment status
4. **Known Issues** - TODO count, failed tests
5. **Roadmap Progress** - Completed tasks marked

**Memory Update Script:** `.github/workflows/update-memory.yml` (creating next)

---

## 📞 Key Contacts & Resources

### Team
- **Project Lead:** You (ElSalvatore)
- **Backend Developer:** You
- **iOS Developer:** You
- **Design:** (Figma files pending)

### External Services
- **Supabase Project:** [Project URL from env]
- **Railway Project:** `wiesbaden-after-dark-production`
- **GitHub Repo:** `ElSalvatore-sys/wiesbade-after-dark`
- **Twilio Account:** [Account SID from env]

### Support Resources
- **FastAPI Discord:** [https://discord.gg/fastapi](https://discord.gg/fastapi)
- **SwiftUI Forums:** [https://developer.apple.com/forums/tags/swiftui](https://developer.apple.com/forums/tags/swiftui)
- **Railway Discord:** [https://discord.gg/railway](https://discord.gg/railway)

---

## 💡 Ideas & Future Enhancements

### Brainstorm (Post-Launch)
- [ ] Integration with Google Maps for venue discovery
- [ ] Apple Watch app for quick check-ins
- [ ] Widgets for iOS home screen (upcoming events, points balance)
- [ ] Dark mode theme customization
- [ ] Multi-city expansion (Frankfurt, Mainz, Darmstadt)
- [ ] Partner venue admin portal (web app)
- [ ] User-generated content moderation system
- [ ] Machine learning for personalized recommendations
- [ ] Integration with local event ticketing platforms

---

## 🎓 Lessons Learned

### What Went Well
- ✅ SwiftUI + SwiftData architecture scales well
- ✅ FastAPI async performance is excellent
- ✅ Railway deployment was seamless
- ✅ Supabase PostgreSQL is reliable and fast
- ✅ Test-driven development caught many bugs early

### What Could Be Improved
- ⚠️ Should have created app icon sooner (blocking TestFlight)
- ⚠️ Rate limiting should have been day 1, not post-MVP
- ⚠️ iOS testing was neglected (0% coverage)
- ⚠️ Documentation written reactively, not proactively
- ⚠️ Should have configured Stripe earlier (now blocking payments)

### Next Time
- 📝 Create app assets (icon, screenshots) in parallel with development
- 📝 Write tests first (TDD for both backend and iOS)
- 📝 Set up monitoring/crash reporting from day 1
- 📝 Document as you build, not after
- 📝 Involve partner venues earlier for feedback

---

## 🔐 Security Considerations

### Current Security Measures
- ✅ JWT authentication with expiration
- ✅ Phone number verification via Twilio
- ✅ HTTPS only (enforced)
- ✅ CORS restricted to specific origins (no longer wildcard)
- ✅ SQL injection protection (SQLAlchemy parameterized queries)
- ✅ CodeQL security scanning (GitHub Actions)
- ✅ Dependabot for dependency updates
- ✅ Secrets in environment variables (not hardcoded)

### Pending Security Enhancements
- [ ] Rate limiting (20 requests/minute per user)
- [ ] Certificate pinning for iOS → Backend
- [ ] Two-factor authentication option
- [ ] Biometric re-authentication for sensitive actions
- [ ] Encryption at rest for PII (phone numbers, emails)
- [ ] Regular security audits (quarterly)
- [ ] Penetration testing before public launch

---

## 📊 Project Statistics

### Code Metrics
- **Total Files:** 8,992
- **Swift Files:** 151
- **Python Files:** 20+
- **Total Size:** 108 MB
- **Lines of Code (Swift):** ~15,000 (estimated)
- **Lines of Code (Python):** ~3,500 (backend)
- **Test Coverage (Backend):** 80%
- **Test Coverage (iOS):** 0% (⚠️ needs improvement)

### Repository Health
- **Branches:** 8 active
- **Last Commit:** Nov 15, 2025
- **Commit Frequency:** 15+ commits/week
- **Contributors:** 1 (you)
- **Open Issues:** TBD (check GitHub)
- **Open PRs:** TBD (check GitHub)

---

## 🧠 Memory Maintenance

**Auto-Update Frequency:** On every push + weekly summary  
**Manual Review:** Monthly (first Sunday of each month)  
**Archive Old Versions:** Quarterly (keep last 4 versions)

**Last Manual Review:** Not yet established  
**Next Manual Review:** December 1, 2025

---

*This project memory is automatically updated by GitHub Actions on every commit. Last auto-update: Nov 15, 2025. For manual updates or questions, contact project lead.*
