# Wiesbaden After Dark - 8-Week Launch Roadmap

**Last Updated:** 2025-01-12
**Timeline:** Weeks 1-8 (Launch to Das Wohnzimmer pilot)
**Success Metric:** Das Wohnzimmer generating €382.50/month recurring revenue by Week 8

---

## Current Status

**What's Done:** ✅
- Backend deployed and functional (Railway)
- Database schema complete (Supabase)
- iOS app UI complete (90 Swift files)
- Business model validated (723% ROI)
- 8 mock venues with real data

**What's Missing:** ❌
- No customers (0 revenue)
- iOS not connected to backend
- No pitch materials for Das Wohnzimmer
- No App Store submission
- No real venue data gathered

---

## Phase 1: Business Development (Week 1-2)

**Goal:** Secure Das Wohnzimmer pilot agreement

### Week 1: Pitch Materials Creation

**Monday-Tuesday: Pitch Deck**
- [ ] Create 10-slide deck on app.presentations.ai
  - Slide 1: Problem (venue retention challenges)
  - Slide 2: Solution (loyalty platform)
  - Slide 3: How it works (customer journey)
  - Slide 4: Business model (pricing tiers)
  - Slide 5: ROI for Das Wohnzimmer (€2,767/month net gain)
  - Slide 6: Technology (proven stack)
  - Slide 7: Differentiators (margin-based, inventory, referrals)
  - Slide 8: Roadmap (pilot → scale)
  - Slide 9: Team (your background)
  - Slide 10: Ask (3-month pilot)
- [ ] Export as PDF + PowerPoint
- [ ] Practice pitch (7-10 minutes)

**Wednesday: Demo Preparation**
- [ ] Record 3-minute demo video
  - Customer: Signup → discover → check-in → earn points
  - Venue admin: Dashboard → bonus activation → analytics
- [ ] Upload to YouTube (unlisted)
- [ ] Create one-pager PDF (ROI summary)

**Thursday-Friday: Research & Outreach Preparation**
- [ ] Visit Das Wohnzimmer in person
  - Observe customer flow, peak times
  - Take photos (interior, signage, crowd)
  - Note POS system if visible
- [ ] Find owner/manager name
  - Website about page
  - LinkedIn search
  - Instagram about section
  - Ask staff casually
- [ ] Draft outreach email (see template in das-wohnzimmer-partnership.md)
- [ ] Prepare follow-up sequence (3 days, 7 days, 14 days)

**Deliverables:**
- ✅ Pitch deck (10 slides, PDF + PPTX)
- ✅ Demo video (3 min, YouTube unlisted)
- ✅ One-pager (ROI summary PDF)
- ✅ Owner/manager identified
- ✅ Outreach email drafted

---

### Week 2: Contact & Meeting

**Monday: Initiate Contact**
- [ ] Send email to info@daswz-wiesbaden.com (personalized)
- [ ] Send Instagram DM to @daswohnzimmer_wiesbaden
- [ ] Set reminder for 3-day follow-up

**Tuesday-Wednesday: Follow-Up Research**
- [ ] Read all Google reviews (identify pain points)
- [ ] Analyze Instagram posts (what do they promote? Events? Specials?)
- [ ] Check competitors (Park Café, Euro Palace - what do they do?)
- [ ] Prepare custom talking points based on research

**Thursday: Follow-Up #1 (if no response)**
- [ ] Send follow-up email with demo video link
- [ ] Instagram DM with one-liner value prop

**Friday-Sunday: In-Person Visit (if no response)**
- [ ] Visit during slow hours (Tuesday or Wednesday evening)
- [ ] Introduce yourself to manager/bartender
- [ ] Leave one-pager + business card
- [ ] Ask for best time to chat with owner

**Deliverables:**
- ✅ Contact initiated (email + Instagram)
- ✅ Meeting scheduled OR in-person intro made
- ✅ Custom pitch prepared based on research

---

## Phase 2: Technical Completion (Week 3-4)

**Goal:** Connect iOS to backend, implement Stripe, prepare for TestFlight

### Week 3: iOS Backend Integration

**Monday-Tuesday: HTTP Client Setup**
- [ ] Create APIClient.swift (URLSession-based)
  ```swift
  class APIClient {
      let baseURL = "https://wiesbade-after-dark-production.up.railway.app"
      let session = URLSession.shared

      func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
          // JWT token from Keychain
          // Build URLRequest
          // Send request
          // Decode response
      }
  }
  ```
- [ ] Define Endpoint enum (all API routes)
- [ ] Create DTOs (Data Transfer Objects) matching backend models
- [ ] Implement token refresh logic

**Wednesday: Authentication Service**
- [ ] Replace MockAuthService with APIAuthService
- [ ] Test phone verification flow
- [ ] Test login flow
- [ ] Test token refresh
- [ ] Test logout
- [ ] Handle network errors gracefully

**Thursday: Venue Service**
- [ ] Replace MockVenueService with APIVenueService
- [ ] Fetch venues from `/api/v1/venues`
- [ ] Fetch venue details from `/api/v1/venues/{id}`
- [ ] Cache in SwiftData (offline support)
- [ ] Test pagination (if implemented backend)

**Friday: Points & Transactions**
- [ ] Implement points fetching (`/api/v1/users/me/points`)
- [ ] Implement transaction history
- [ ] Implement referral data fetching
- [ ] Test all flows end-to-end

**Deliverables:**
- ✅ iOS connected to Railway backend
- ✅ Authentication working end-to-end
- ✅ Venues loading from API
- ✅ Points and transactions syncing

---

### Week 4: Payments & App Store Prep

**Monday-Tuesday: Stripe Integration**
- [ ] Backend: Add Stripe secret key to .env
- [ ] Backend: Implement `/api/v1/payments/create-intent`
  ```python
  @router.post("/create-intent")
  async def create_payment_intent(amount: int):
      intent = stripe.PaymentIntent.create(
          amount=amount,  # in cents
          currency="eur",
          payment_method_types=["card"]
      )
      return {"client_secret": intent.client_secret}
  ```
- [ ] Backend: Implement `/api/v1/payments/webhook`
- [ ] iOS: Add Stripe publishable key
- [ ] iOS: Implement StripePaymentService (replace placeholder)
- [ ] iOS: Test payment flow with test card

**Wednesday: App Store Assets**
- [ ] Design app icon (1024×1024)
  - Tool: Figma, Canva, or hire on Fiverr (€20)
  - Export all sizes (Xcode asset catalog)
- [ ] Capture screenshots
  - iPhone 15 Pro Max (6.7")
  - iPhone 15 (6.1")
  - iPhone SE (5.5")
  - Minimum 3 per size: Onboarding, Venue detail, Check-in
  - Tool: Xcode simulator + built-in screenshot tool

**Thursday: Legal Documents**
- [ ] Write privacy policy
  - Tool: iubenda.com (free tier) OR app-privacy-policy-generator.com
  - Cover: Data collected, Keychain usage, location, NFC, camera
  - Host on GitHub Pages or Google Docs (public link)
- [ ] Write terms of service
  - Template: TermsFeed.com
  - Cover: Point redemption rules, account termination, liability
  - Host publicly

**Friday: Xcode Configuration**
- [ ] Enable capabilities:
  - Near Field Communication Tag Reading
  - Wallet (passes)
  - Push Notifications
- [ ] Set signing & capabilities (Team ID, certificates)
- [ ] Set version: 1.0.0, build: 1
- [ ] Update Info.plist with privacy policy + terms URLs

**Deliverables:**
- ✅ Stripe payments working end-to-end
- ✅ App icons in all sizes
- ✅ Screenshots (3+ per size)
- ✅ Privacy policy + terms of service (public URLs)
- ✅ Xcode configured for TestFlight

---

## Phase 3: Launch Preparation (Week 5-6)

**Goal:** TestFlight live, security hardened, Das Wohnzimmer pilot agreement signed

### Week 5: TestFlight Submission

**Monday: Final Code Cleanup**
- [ ] Migrate all print() statements to SecureLogger
  - Priority: AuthenticationViewModel (27 statements)
  - Find: `Grep pattern="print\(" output_mode="files_with_matches"`
  - Replace with: `SecureLogger.log()`
- [ ] Remove debug flags
- [ ] Set environment to production

**Tuesday: Backend Security**
- [ ] Restrict CORS to specific origin:
  ```python
  origins = [
      "https://apps.apple.com",  # App Store
      "capacitor://localhost",    # If using Capacitor (not applicable)
  ]
  ```
- [ ] Add rate limiting:
  ```python
  from slowapi import Limiter
  limiter = Limiter(key_func=get_remote_address)

  @app.post("/api/v1/auth/login")
  @limiter.limit("5/minute")
  async def login(...):
      ...
  ```
- [ ] Add error tracking (Sentry):
  ```python
  import sentry_sdk
  sentry_sdk.init(dsn=os.getenv("SENTRY_DSN"))
  ```

**Wednesday: TestFlight Build**
- [ ] Archive app in Xcode (Product → Archive)
- [ ] Upload to App Store Connect
- [ ] Fill in TestFlight information:
  - What to test: "Complete user flow from signup to points redemption"
  - Export compliance: Select "No" (no encryption)
- [ ] Add beta testers (your email + Das Wohnzimmer staff if available)
- [ ] Wait for Apple review (24-48 hours)

**Thursday-Friday: Testing**
- [ ] Test on physical iPhone (not simulator)
  - Signup flow
  - Venue discovery
  - NFC check-in (with test NFC tag)
  - Points earning
  - Referral code
  - Payment flow
  - Apple Wallet (if implemented)
- [ ] Fix critical bugs
- [ ] Submit new build if needed

**Deliverables:**
- ✅ App in TestFlight (approved by Apple)
- ✅ Security hardened (CORS, rate limiting, logging)
- ✅ Critical bugs fixed
- ✅ Testing complete

---

### Week 6: Das Wohnzimmer Pilot Agreement

**Monday: Meeting (Scheduled in Week 2)**
- [ ] Present pitch deck (10 slides, 7-10 minutes)
- [ ] Live demo on TestFlight (iPhone)
- [ ] Show customized ROI (€2,767/month net gain)
- [ ] Address objections (see das-wohnzimmer-partnership.md)
- [ ] Propose 3-month free pilot

**Tuesday: Gather Venue Data**
- [ ] Request menu with prices
- [ ] Request COGS or margin data (if willing to share)
- [ ] Understand POS system (orderbird PRO? other?)
- [ ] Document weekly customer volume estimate
- [ ] Ask about current loyalty approach
- [ ] Identify slow days/hours to boost

**Wednesday: Pilot Agreement**
- [ ] Draft simple agreement (1-2 pages):
  - 3-month pilot (free, no obligations)
  - Data sharing (anonymized analytics)
  - Success metrics (adoption %, revenue lift)
  - Post-pilot options (continue, negotiate, discontinue)
  - Either party can terminate with 7 days notice
- [ ] Send for review
- [ ] Sign agreement (DocuSign or in-person)

**Thursday-Friday: Platform Customization**
- [ ] Create Das Wohnzimmer venue in production database
- [ ] Import menu data (products table)
- [ ] Set margin percentages (food, beverage, default)
- [ ] Configure bonus multipliers (if needed)
- [ ] Create admin account for Das Wohnzimmer manager

**Deliverables:**
- ✅ Das Wohnzimmer pilot agreement signed
- ✅ Real venue data gathered
- ✅ Menu imported into platform
- ✅ Admin dashboard configured

---

## Phase 4: Pilot Launch (Week 7-8)

**Goal:** Soft launch with Das Wohnzimmer staff + friends, gather feedback, iterate

### Week 7: Staff Training & Soft Launch

**Monday: NFC Tag Deployment**
- [ ] Order NFC tags (NTAG215, 10 tags, ~€15)
  - Amazon: "NTAG215 NFC tags"
  - Aliexpress (cheaper, slower shipping)
- [ ] Encode tags with venue ID:
  - URL format: `wiesbadenafterdar://venue/das-wohnzimmer` (deep link)
  - Or: Simple ID that app reads
- [ ] Deploy tags at Das Wohnzimmer:
  - Bar entrance (2 tags)
  - Each high-traffic table (6 tags)
  - Restroom entrance (2 tags)
- [ ] Create signage:
  - "Tap here to earn points!"
  - QR code fallback (if NFC fails)

**Tuesday: Staff Training (2 hours)**
- [ ] Present to all staff (bartenders, servers, manager)
- [ ] Explain value proposition (for venue and customers)
- [ ] Demo customer flow:
  1. Staff says: "Do you have the Das Wohnzimmer app?"
  2. If no: "Download it and use code DASWZ for 5 bonus points!"
  3. If yes: "Tap your phone to the NFC tag to check in"
  4. After purchase: "You just earned 12 points!"
- [ ] Demo admin dashboard:
  - View customer list
  - Activate bonus multipliers
  - See analytics
- [ ] Q&A and troubleshooting
- [ ] Distribute staff referral codes (staff earn 5x referral points)

**Wednesday: Marketing Materials**
- [ ] Design and print:
  - Table tents (10cm x 15cm, 50 units, €30)
    - "Earn points on every purchase! Download the app"
    - QR code to App Store
  - Posters (A3, 5 units, €20)
    - "Join 500+ members earning rewards"
    - App screenshots, benefits
  - Business cards (100 units, €15)
    - Referral code printed
    - Hand to regular customers
- [ ] Deliver to Das Wohnzimmer

**Thursday: Soft Launch (Staff + Friends)**
- [ ] Invite Das Wohnzimmer staff to download app
- [ ] Create staff accounts (10-15 people)
- [ ] Create test transactions (manual entry via admin)
- [ ] Staff invites friends (20-30 people target)
- [ ] Monitor first check-ins and transactions
- [ ] Fix critical bugs immediately

**Friday: Feedback Collection**
- [ ] Survey staff:
  - How easy was customer onboarding?
  - Any confusion or friction points?
  - Suggested improvements?
- [ ] Survey customers:
  - App usability (1-5 scale)
  - Value of points system (1-5 scale)
  - Would you recommend to a friend? (NPS)
  - Open feedback
- [ ] Analyze first week data:
  - Adoption rate (% of customers who signed up)
  - Check-in success rate (NFC taps)
  - Average points earned per customer
  - Referral rate (% who used referral code)

**Deliverables:**
- ✅ NFC tags deployed and functional
- ✅ Staff trained and confident
- ✅ Marketing materials in venue
- ✅ 30-50 active users (staff + friends)
- ✅ Feedback collected and documented

---

### Week 8: Public Launch & Iteration

**Monday-Tuesday: Iterate Based on Feedback**
- [ ] Fix bugs identified in soft launch
- [ ] Improve onboarding flow (if needed)
- [ ] Adjust NFC tag placement (if success rate low)
- [ ] Update marketing materials (if messaging unclear)
- [ ] Release update to TestFlight (if needed)

**Wednesday: Public Launch**
- [ ] Das Wohnzimmer announces on Instagram:
  - "Introducing our new rewards app!"
  - Screenshots, benefits, download link
  - Staff testimonials
- [ ] Post on Das Wohnzimmer social media:
  - Instagram story (daily for 7 days)
  - Instagram post (photo of customers using app)
  - Facebook post (if applicable)
- [ ] Email to Das Wohnzimmer mailing list (if they have one):
  - "Earn points on every visit!"
  - Download instructions
  - Exclusive launch bonus (2x points for 7 days)

**Thursday: Monitor Launch**
- [ ] Track hourly signups (target: 50+ in first 24 hours)
- [ ] Monitor NFC check-ins (success rate target: 80%+)
- [ ] Respond to customer support (Instagram DMs, email)
- [ ] Fix critical issues immediately

**Friday: First Week Review**
- [ ] Meeting with Das Wohnzimmer manager
- [ ] Present metrics:
  - Total signups: [target: 100+]
  - Active users: [target: 50+]
  - Check-ins: [target: 150+]
  - Points earned: [total]
  - Referrals: [count]
- [ ] Discuss initial impressions
- [ ] Plan next 2 weeks (continue promotion, iterate, measure revenue lift)

**Deliverables:**
- ✅ Public launch complete
- ✅ 100+ app signups
- ✅ Social media promotion live
- ✅ First week metrics documented
- ✅ Next iteration plan agreed

---

## Success Metrics (End of Week 8)

### Must-Have (Critical)
- ✅ Das Wohnzimmer pilot agreement signed
- ✅ App in TestFlight (approved)
- ✅ 100+ active users (30% of weekly customers)
- ✅ 200+ check-ins (1st week)
- ✅ 1,000+ points earned (total)
- ✅ Positive feedback from venue owner
- ✅ No critical bugs

### Nice-to-Have (Stretch Goals)
- 200+ active users (50% adoption)
- 20+ referrals generated
- Social media posts from customers (UGC)
- Local press coverage (e.g., Wiesbadener Kurier)
- 10%+ increase in visit frequency (measured via POS)

### Revenue Goal (Week 8)
- Setup fee: €500 (if applicable, or waived for pilot)
- Recurring: €0 (free pilot for 3 months)
- **Post-pilot (Month 4):** €382.50/month (€99 + 3% fees)

---

## Risk Management

### High-Probability Risks

**1. Das Wohnzimmer declines pilot**
- Mitigation: Approach Park Café or Harput immediately
- Pivot: Offer even more aggressive terms (6-month free trial)
- Learning: Document objections, refine pitch

**2. Low customer adoption (<20%)**
- Mitigation: Launch bonus (2x points for sign-ups)
- Staff incentives: €1 per customer signup
- Simplify onboarding: QR code signup (skip phone verification)

**3. NFC check-in failures (>30% failure rate)**
- Mitigation: QR code fallback (always available)
- Better tag placement (eye-level, away from metal)
- Android support (if customer base has Android users)

**4. Technical bugs in production**
- Mitigation: Thorough testing in Week 5
- Emergency hotfix process (TestFlight update within 24 hours)
- Rollback plan (revert to previous build)

**5. Payment issues (Stripe failures)**
- Mitigation: Test extensively in Week 4
- Manual point purchases (admin adds points manually)
- Clear error messages for users

### Low-Probability, High-Impact Risks

**1. BaFin regulatory challenge**
- Mitigation: Venue-specific points (already implemented)
- Legal consultation (€500 for lawyer review)
- Pivot: Pure marketing platform (no points redemption)

**2. Apple rejects app**
- Mitigation: Follow guidelines strictly
- Prepare for App Review appeals
- Alternative: Web app (PWA) if necessary

**3. Data breach / security incident**
- Mitigation: Security hardening in Week 5
- Incident response plan (notify users within 24 hours)
- Insurance (cyber liability, if scaling)

**4. Das Wohnzimmer closes / changes ownership**
- Mitigation: Diversify early (sign 2nd venue by Month 3)
- Contractual protection (30-day notice)

---

## Next Steps After Week 8

### Month 3-4: Pilot Measurement Phase
- Measure visit frequency increase (compare to baseline)
- Calculate actual revenue lift for Das Wohnzimmer
- Gather customer testimonials (video + written)
- Document case study (metrics, quotes, photos)

### Month 5: Pitch to Additional Venues
- Use Das Wohnzimmer data as proof
- Target: Park Café, Harput Restaurant, Ente
- Goal: Sign 2 additional venues
- Offer: 1-month free trial (less generous than Das Wohnzimmer)

### Month 6-12: Scale to 5 Venues
- Refine platform based on feedback
- Automate operations (less manual work)
- Hire part-time support (customer service)
- Revenue target: €1,895/month

### Year 2: Regional Expansion
- 20 venues in Wiesbaden
- Expand to Frankfurt or Mainz
- Consider seed funding (if scaling faster)

---

## Weekly Check-In Template

Every Monday, review:
- ✅ **What shipped last week?** (deliverables)
- ⚠️ **What's blocked?** (issues, dependencies)
- 🎯 **What's the goal this week?** (top 3 priorities)
- 📊 **Key metrics** (signups, check-ins, revenue)
- 💡 **Learnings** (what worked, what didn't)

**Example (Week 7):**
```
✅ Shipped: NFC tags deployed, staff trained, soft launch complete
⚠️ Blocked: None
🎯 This week: Public launch, 100+ signups, social media campaign
📊 Metrics: 35 soft launch users, 87 check-ins, 450 points earned
💡 Learnings: NFC works great, QR fallback never used (good)
```

---

## Critical Path

**The ONE thing that determines success:**
→ Das Wohnzimmer pilot agreement signed by end of Week 6.

Without this, everything else is academic. ALL effort should prioritize securing this anchor customer.

**If Das Wohnzimmer fails:**
- Document all learnings
- Refine pitch based on objections
- Approach next venue within 7 days
- Do NOT give up after one rejection

**If Das Wohnzimmer succeeds:**
- Extract every possible testimonial, metric, and case study element
- Use this proof to sign 4 more venues within 6 months
- Achieve €1,895/month recurring revenue
- Validate platform for potential investment/scaling

---

**The roadmap is aggressive but achievable. Stay focused on the critical path: Das Wohnzimmer pilot by Week 6. Everything else supports this goal.**
