# TestFlight & App Store Submission Requirements

**Last Updated:** 2025-01-12
**Target:** TestFlight submission within 2-3 weeks
**Status:** ❌ NOT READY - Critical assets missing

---

## Current Status

### ✅ Ready
- [x] Info.plist privacy descriptions complete
- [x] Export compliance set (no encryption)
- [x] Bundle ID configured (com.ea-solutions.WiesbadenAfterDark)
- [x] iOS 17.0+ minimum version set
- [x] App functionality complete (pending backend integration)

### ❌ Missing (BLOCKERS)
- [ ] App icons (all sizes)
- [ ] Screenshots (3 device sizes)
- [ ] Privacy policy (public URL)
- [ ] Terms of service (public URL)
- [ ] App Store description (German + English)
- [ ] Keywords
- [ ] Promotional text
- [ ] Support URL

### 🚧 In Progress
- [ ] Backend integration (currently using mocks)
- [ ] Xcode capabilities (NFC, Wallet, Push)
- [ ] Signing & certificates

---

## Part 1: App Icons

### Requirements

**App Store Icon (Marketing):**
- 1024×1024 pixels
- PNG format (no transparency)
- RGB color space
- Square (no rounded corners, Apple adds them)

**App Bundle Icons (Xcode Asset Catalog):**
Required sizes for iOS:
- 20pt (1x, 2x, 3x) = 20px, 40px, 60px
- 29pt (1x, 2x, 3x) = 29px, 58px, 87px
- 40pt (1x, 2x, 3x) = 40px, 80px, 120px
- 60pt (2x, 3x) = 120px, 180px
- 76pt (1x, 2x) = 76px, 152px (iPad, if supporting)
- 83.5pt (2x) = 167px (iPad Pro, if supporting)

**Total:** ~9 sizes for iPhone-only app

### Design Guidelines

**Style:**
- Modern, clean, recognizable
- Works at small sizes (60px must be legible)
- No text (icon should work without words)
- Avoid gradients (keep simple)
- High contrast

**Wiesbaden After Dark Icon Ideas:**
1. **Nightlife Skyline**
   - Wiesbaden skyline silhouette
   - Dark background, gold/purple accents
   - Moon or stars

2. **WAD Monogram**
   - Stylized "WAD" letters
   - Bold, modern font
   - Dark background (black/navy)

3. **Location Pin + Night**
   - Location pin icon
   - Stars or night sky inside
   - Gradient dark blue → purple

4. **Cocktail Glass Minimal**
   - Simple cocktail glass outline
   - Dark background
   - One accent color (gold, purple)

**Recommended:** Option 1 (Nightlife Skyline) - most distinctive

### Design Tools

**DIY (Free):**
- Figma (free tier) - Professional, template-based
- Canva (free tier) - Easy, drag-and-drop
- Sketch (Mac only, paid)

**Hire Designer (Fast):**
- Fiverr: €15-30, 24-48 hours
  - Search: "iOS app icon design"
  - Provide brief: "Nightlife loyalty app, Wiesbaden, modern, dark theme"
- Upwork: €30-50, 2-3 days
- Dribbble: Higher end, €100+

**AI-Generated:**
- Midjourney: "iOS app icon, nightlife, Wiesbaden, minimal, dark purple and gold --ar 1:1"
- DALL-E 3: Similar prompt
- Note: May need manual cleanup

### Export Checklist

- [ ] Export 1024×1024 PNG (App Store)
- [ ] Export all required sizes (Xcode asset catalog)
- [ ] Test icon at small size (60px) - is it legible?
- [ ] Test icon on light AND dark backgrounds
- [ ] Drag into Xcode: Assets.xcassets/AppIcon.appiconset/
- [ ] Build app, check Home screen appearance

---

## Part 2: Screenshots

### Requirements

**Device Sizes (Required):**
1. **6.7" Display** (iPhone 15 Pro Max, 14 Pro Max)
   - Resolution: 1290 × 2796 pixels
   - Minimum: 3 screenshots

2. **6.5" Display** (iPhone 11 Pro Max, XS Max)
   - Resolution: 1242 × 2688 pixels
   - Minimum: 3 screenshots (if supporting older devices)

3. **5.5" Display** (iPhone 8 Plus, 7 Plus)
   - Resolution: 1242 × 2208 pixels
   - Minimum: 3 screenshots (if supporting older devices)

**Maximum:** 10 screenshots per device size

**Format:** PNG or JPEG (PNG recommended for quality)

### Screenshot Strategy

**Recommended 5 Screenshots:**
1. **Welcome/Onboarding**
   - Shows value proposition
   - "Earn rewards at Wiesbaden's best venues"
   - Overlay text: "Your nightlife loyalty app"

2. **Discover Venues**
   - Venue cards with photos
   - Shows Das Wohnzimmer, Park Café, etc.
   - Overlay: "8 venues, endless rewards"

3. **Venue Detail**
   - Das Wohnzimmer profile page
   - Shows hours, location, photos
   - Overlay: "Exclusive venue benefits"

4. **NFC Check-In**
   - Check-in animation or success screen
   - Shows points earned
   - Overlay: "One tap check-in"

5. **Points & Rewards**
   - Points balance, transaction history
   - Shows referral bonuses
   - Overlay: "Track every point"

**Optional Bonus Screenshots:**
6. Events page
7. Table booking
8. Payment flow
9. Profile / settings
10. Apple Wallet pass

### Capture Process

**Method 1: Xcode Simulator (Free, Fast)**
```bash
# Run app in Xcode
# Select simulator: iPhone 15 Pro Max
# Navigate to screen
# Cmd+S to save screenshot
# Repeat for each screen
```

**Method 2: Screenshot Framing Tool (Professional)**
- Use: app-mockup.com, screenshots.pro, or Figma template
- Adds device frame, background, text overlay
- More polished than raw screenshots

**Method 3: Hire Designer (Best Quality)**
- Fiverr: €20-40 for 5 screenshots with frames + text
- Provide: Raw screenshots from simulator
- They add: Device frames, backgrounds, overlay text, branding

### Screenshot Overlay Text (German Market)

**German (Primary):**
1. "Deine Nightlife-App für Wiesbaden"
2. "8 Venues. Endlose Belohnungen."
3. "Exklusive Vorteile in deinen Lieblingsvenues"
4. "Ein Tap. Punkte verdient."
5. "Jeden Punkt im Blick"

**English (Secondary, for App Store international):**
1. "Your nightlife loyalty app"
2. "8 venues, endless rewards"
3. "Exclusive venue benefits"
4. "One tap, points earned"
5. "Track every point"

### Checklist

- [ ] Capture screenshots from Xcode simulator (6.7" minimum)
- [ ] Add device frames (optional but recommended)
- [ ] Add overlay text (German + English versions)
- [ ] Test readability on small App Store preview
- [ ] Export as PNG (high quality)
- [ ] Name files: 01_welcome_6.7.png, 02_discover_6.7.png, etc.

---

## Part 3: Privacy Policy

### Requirements

- **Format:** Public webpage (HTTPS)
- **Language:** German (primary market) + English
- **Content:** Must cover all data collection and usage

### What to Cover

**Data Collected:**
1. Personal Information
   - Phone number (authentication)
   - First name, last name (optional)
   - Email address (optional)
   - Date of birth (optional, for age verification)

2. Usage Data
   - Venue check-ins (location, timestamp)
   - Transaction history (amount, points earned)
   - Referral codes used

3. Device Data
   - FCM token (push notifications)
   - Device model (for support)
   - iOS version

4. Biometric Data
   - Face ID / Touch ID (stored on-device only, never transmitted)

**How Data is Used:**
- Authenticate users
- Calculate and award points
- Track referrals
- Send notifications
- Improve app experience
- Comply with legal obligations

**Data Storage:**
- Stored on EU servers (Supabase, Frankfurt)
- GDPR compliant
- Encrypted in transit (HTTPS)
- Encrypted at rest (database encryption)

**Data Sharing:**
- Shared with venues (anonymized analytics)
- NOT sold to third parties
- NOT shared for marketing (unless user opts in)

**User Rights (GDPR):**
- Right to access data
- Right to delete account
- Right to export data
- Right to opt out of notifications

**Retention:**
- Account data: Until user deletes account
- Transaction data: 7 years (tax compliance)
- Anonymized analytics: Indefinitely

**Cookies:** None (mobile app)

### Generation Tools

**Option 1: Free Generators**
- iubenda.com (free tier, basic privacy policy)
- app-privacy-policy-generator.com
- privacypolicies.com/app-privacy-policy-generator/

**Steps:**
1. Select "Mobile App"
2. Enter app name: Wiesbaden After Dark
3. Select data types: Phone, Location, Transactions, Notifications
4. Select frameworks: None (custom backend)
5. Generate policy
6. Copy HTML
7. Host on GitHub Pages or Google Docs (public link)

**Option 2: Custom Written**
- Base on template (iubenda)
- Customize for Wiesbaden After Dark specifics
- Have lawyer review (€200-500, recommended before App Store)

**Option 3: Hire Writer**
- Fiverr: €50-100, GDPR-compliant privacy policy
- Upwork: €100-200, includes legal review

### Hosting

**Free Options:**
1. **GitHub Pages** (Recommended)
   ```bash
   # Create repo: wiesbaden-after-dark-legal
   # Add file: privacy-policy.html
   # Enable Pages in settings
   # URL: https://yourusername.github.io/wiesbaden-after-dark-legal/privacy-policy.html
   ```

2. **Google Sites**
   - Create public site
   - Paste privacy policy text
   - Publish
   - Copy public URL

3. **Notion (Public Page)**
   - Create page
   - Paste policy
   - Share → Publish to web
   - Copy public URL

**Paid Options:**
- Host on own domain: wiesbadenafterdark.com/privacy
- Requires domain (€10/year) + hosting (€5/month)

### Checklist

- [ ] Generate privacy policy (iubenda.com or custom)
- [ ] Translate to German (DeepL or human translator)
- [ ] Host publicly (GitHub Pages recommended)
- [ ] Test URL loads (https://...)
- [ ] Copy URL for App Store Connect
- [ ] Add link to app settings ("Privacy Policy" button)

---

## Part 4: Terms of Service

### Requirements

- **Format:** Public webpage (HTTPS)
- **Language:** German (primary) + English
- **Content:** Legal terms for using the app

### What to Cover

**Account Terms:**
- Must be 18+ to use app
- One account per person
- Responsible for account security
- Must provide accurate information

**Points & Rewards:**
- Points have no cash value
- Points are venue-specific (not transferable)
- Points may expire (180 days of inactivity)
- Venue reserves right to change point values
- Platform reserves right to adjust point calculations

**Prohibited Conduct:**
- Fraud (fake check-ins, fake referrals)
- Sharing accounts
- Reverse engineering the app
- Abuse of referral system
- Harassment of venue staff

**Refunds & Cancellations:**
- Points purchases non-refundable (unless required by law)
- Account deletion: Points forfeited
- Venue closure: Points at that venue become void

**Liability:**
- Platform provided "as is"
- No guarantee of uptime
- Not liable for lost points due to technical issues
- Venue responsible for honoring redemptions

**Termination:**
- Platform can terminate account for violations
- User can delete account anytime
- Data retained for 7 years (tax compliance)

**Governing Law:**
- German law
- Wiesbaden jurisdiction

**Changes to Terms:**
- Platform can update terms
- Users notified via app
- Continued use = acceptance

### Generation Tools

**Option 1: Free Templates**
- TermsFeed.com (free tier, basic TOS)
- termly.io/products/terms-and-conditions-generator/

**Steps:**
1. Select "Mobile App"
2. Enter details (app name, owner, jurisdiction)
3. Customize sections (points, rewards, liability)
4. Generate
5. Host publicly (same as privacy policy)

**Option 2: Hire Lawyer**
- German lawyer (wichtig für German law compliance)
- Cost: €500-1,000
- Recommended before App Store launch
- Covers liability protection

### Hosting

- Same as privacy policy
- GitHub Pages: privacy-policy.html + terms-of-service.html
- Same domain/folder

### Checklist

- [ ] Generate terms of service (TermsFeed or lawyer)
- [ ] Translate to German
- [ ] Host publicly (GitHub Pages)
- [ ] Test URL loads
- [ ] Copy URL for App Store Connect
- [ ] Add link to app settings ("Terms of Service" button)

---

## Part 5: App Store Metadata

### App Name
**English:** Wiesbaden After Dark
**German:** Wiesbaden After Dark (keep English, it's a brand name)
**Subtitle (30 chars):** "Nightlife Loyalty Platform"

### Description

**German (Primary Market):**
```
Entdecke Wiesbadens beste Nightlife-Venues und verdiene bei jedem Besuch Punkte.

Wiesbaden After Dark verbindet dich mit den angesagtesten Bars, Clubs und Restaurants der Stadt. Verdiene exklusive Belohnungen, lade Freunde ein und erlebe Wiesbaden wie nie zuvor.

FEATURES:

🎉 Entdecke 8 Top-Venues
Von Das Wohnzimmer bis Park Café - die besten Locations der Stadt in einer App.

⭐ Verdiene Punkte bei jedem Besuch
Einfach per NFC-Check-In einchecken und automatisch Punkte sammeln.

🎁 Exklusive Belohnungen
Löse deine Punkte gegen Drinks, Rabatte und VIP-Events ein.

👥 5-Level-Empfehlungssystem
Lade Freunde ein und verdiene, wenn sie einchecken - bis zu 5 Levels tief!

🔥 Streak-Boni
Besuche regelmäßig und erhalte Bonus-Punkte für deine Treue.

📊 Personalisiertes Erlebnis
Sieh deine Lieblingslocations, Statistiken und Transaktionshistorie.

🍹 Bonus-Aktionen
Verdiene doppelte oder dreifache Punkte bei speziellen Drinks und Events.

🎟️ Apple Wallet Integration
Speichere deine Venue-Mitgliedschaften in Apple Wallet.

WARUM WIESBADEN AFTER DARK?

• Modern & Schnell: Keine Stempelkarten, keine Apps mehrerer Venues. Alles in einer App.
• Sicher: Face ID / Touch ID Login, verschlüsselte Daten auf EU-Servern.
• Fair: Punkte bleiben bei deinen Lieblingslocations - einfach und transparent.

UNTERSTÜTZTE VENUES:
- Das Wohnzimmer
- Park Café
- Harput Restaurant
- Ente
- Hotel am Kochbrunnen
- Euro Palace
- Villa im Tal
- Kulturpalast

Lade jetzt herunter und erlebe Wiesbaden nach Einbruch der Dunkelheit!

Fragen oder Feedback? Schreib uns: support@wiesbadenafterdark.com
```

**English (International):**
```
Discover Wiesbaden's best nightlife venues and earn points on every visit.

Wiesbaden After Dark connects you with the city's hottest bars, clubs, and restaurants. Earn exclusive rewards, invite friends, and experience Wiesbaden like never before.

FEATURES:

🎉 Discover 8 Top Venues
From Das Wohnzimmer to Park Café - the city's best locations in one app.

⭐ Earn Points Every Visit
Simply check in via NFC and automatically collect points.

🎁 Exclusive Rewards
Redeem your points for drinks, discounts, and VIP events.

👥 5-Level Referral System
Invite friends and earn when they check in - up to 5 levels deep!

🔥 Streak Bonuses
Visit regularly and receive bonus points for your loyalty.

📊 Personalized Experience
See your favorite venues, stats, and transaction history.

🍹 Bonus Promotions
Earn double or triple points on special drinks and events.

🎟️ Apple Wallet Integration
Save your venue memberships in Apple Wallet.

WHY WIESBADEN AFTER DARK?

• Modern & Fast: No stamp cards, no multiple venue apps. Everything in one app.
• Secure: Face ID / Touch ID login, encrypted data on EU servers.
• Fair: Points stay with your favorite venues - simple and transparent.

SUPPORTED VENUES:
- Das Wohnzimmer
- Park Café
- Harput Restaurant
- Ente
- Hotel am Kochbrunnen
- Euro Palace
- Villa im Tal
- Kulturpalast

Download now and experience Wiesbaden after dark!

Questions or feedback? Email us: support@wiesbadenafterdark.com
```

### Keywords (100 characters max)

**German:**
```
wiesbaden,nightlife,bar,club,restaurant,punkte,loyalty,rewards,nfc,check-in
```

**English:**
```
wiesbaden,nightlife,bar,club,restaurant,loyalty,rewards,points,nfc,check-in
```

### Promotional Text (170 characters, can update without review)

**German:**
```
Neu: 8 Wiesbaden Venues, 5-Level-Empfehlungen, NFC-Check-Ins! Lade jetzt herunter und verdiene bei jedem Besuch Punkte. 🎉
```

**English:**
```
New: 8 Wiesbaden venues, 5-level referrals, NFC check-ins! Download now and earn points on every visit. 🎉
```

### Support URL
- wiesbadenafterdark.com/support (if you have domain)
- OR: GitHub Pages (same repo as privacy policy)
- OR: support@wiesbadenafterdark.com (email-only support)

### Marketing URL (Optional)
- wiesbadenafterdark.com
- OR: GitHub Pages landing page

### Category
**Primary:** Lifestyle
**Secondary:** Food & Drink

### Age Rating
**18+** (Nightlife, alcohol-related content)

---

## Part 6: Xcode Configuration

### Capabilities to Enable

**In Xcode → Target → Signing & Capabilities:**

1. **Near Field Communication Tag Reading**
   - Required for NFC check-ins
   - Info.plist: NFCReaderUsageDescription ✅ (already set)

2. **Wallet** (PassKit)
   - Required for Apple Wallet passes
   - Info.plist: com.apple.developer.pass-type-identifiers

3. **Push Notifications**
   - Required for points earned notifications
   - Backend: FCM token storage ready ✅

4. **App Groups** (Optional)
   - For sharing data between app and widget (future)

5. **Sign In with Apple** (Optional)
   - Alternative to phone auth (future)

### Signing Configuration

**Team:**
- [ ] Select Apple Developer account team
- [ ] Or: "Add an Account" → Sign in with Apple ID

**Bundle Identifier:**
- com.ea-solutions.WiesbadenAfterDark ✅ (already set)
- Must be unique (registered in Apple Developer portal)

**Provisioning Profile:**
- Xcode should auto-generate
- If issues: Apple Developer portal → Certificates, IDs & Profiles

### Build Settings

**Version:** 1.0.0
**Build:** 1

Increment build for each TestFlight upload (1, 2, 3, etc.)

### Info.plist Final Check

- [ ] Privacy descriptions present for all used permissions
- [ ] Export compliance: App Encryption = NO
- [ ] Supported orientations: Portrait only (recommended for iOS app)
- [ ] URL schemes (if using deep links): wiesbadenafterdark://

---

## Part 7: TestFlight Submission Process

### Pre-Submission Checklist

- [ ] All code complete and tested on device (not just simulator)
- [ ] No placeholder text ("Lorem ipsum", "Test", etc.)
- [ ] No debug logs or print statements (migrated to SecureLogger)
- [ ] Backend integration complete (no mock data)
- [ ] App icons in all sizes ✅
- [ ] Screenshots ready ✅
- [ ] Privacy policy + terms of service URLs ✅
- [ ] App Store description written ✅

### Archive & Upload

**Step 1: Archive**
```
1. Select device: "Any iOS Device (arm64)"
2. Product → Archive
3. Wait for archive to complete (5-10 minutes)
4. Organizer window opens automatically
```

**Step 2: Distribute**
```
1. Select archive → "Distribute App"
2. Select "TestFlight & App Store"
3. Select "Upload"
4. Choose signing: "Automatically manage signing" (recommended)
5. Review app.ipa contents
6. Upload (may take 10-30 minutes)
```

**Step 3: Processing**
```
1. Log in to App Store Connect: appstoreconnect.apple.com
2. My Apps → Wiesbaden After Dark → TestFlight
3. Wait for build to process (10-60 minutes)
4. Build status: "Processing" → "Ready to Submit" → "Waiting for Review"
```

### App Store Connect Configuration

**TestFlight Information:**
- [ ] Test Information: "Complete user flow from signup to points redemption. Test NFC check-in at Das Wohnzimmer or use QR fallback."
- [ ] Feedback Email: support@wiesbadenafterdark.com
- [ ] Marketing URL: (optional)
- [ ] Privacy Policy URL: https://...
- [ ] Sign-In Required: NO (users create accounts in-app)
- [ ] Export Compliance: NO (no encryption)

**Beta Testers:**
- [ ] Add internal testers (you, das Wohnzimmer staff)
- [ ] Add external testers (optional, requires Apple review)

### Apple Review (TestFlight)

**Timeline:** 24-48 hours (first submission)

**Common Rejection Reasons:**
1. Missing privacy policy
2. Crashes on launch
3. Features don't work as described
4. In-app purchases not configured (if using)
5. Content violates guidelines (unlikely for loyalty app)

**If Rejected:**
- Read rejection reason carefully
- Fix issues in Xcode
- Increment build number
- Upload new build
- Respond to App Review (Resolution Center)

### Post-Approval

**Once approved:**
- [ ] Invite beta testers via email
- [ ] They receive TestFlight invitation
- [ ] Download TestFlight app (if first time)
- [ ] Install Wiesbaden After Dark
- [ ] Provide feedback via TestFlight app

---

## Part 8: App Store Submission (After TestFlight Testing)

**Timeline:** 2-4 weeks after TestFlight launch

**Requirements:**
- [ ] TestFlight testing complete (minimum 1 week)
- [ ] Critical bugs fixed
- [ ] Positive feedback from testers
- [ ] All App Store Connect metadata complete

**Submission Process:**
1. App Store Connect → My Apps → Wiesbaden After Dark
2. App Store → Prepare for Submission
3. Fill in all metadata (descriptions, keywords, screenshots)
4. Select build (from TestFlight)
5. Pricing: Free (with in-app purchases for points, if applicable)
6. Availability: Germany initially (expand later)
7. Submit for Review

**Review Timeline:** 1-7 days (typically 24-48 hours)

**Launch:**
- Upon approval, app goes live on App Store
- Appears in search within 24 hours
- Promote via Das Wohnzimmer social media, in-venue signage

---

## Estimated Timeline

### Week 1: Asset Creation
- Days 1-3: Design app icons (or hire designer)
- Days 4-5: Capture and frame screenshots
- Days 6-7: Write privacy policy + terms of service

### Week 2: Configuration & Upload
- Days 1-2: Host legal documents publicly (GitHub Pages)
- Day 3: Configure Xcode capabilities and signing
- Day 4: Write App Store descriptions (German + English)
- Day 5: Final testing on physical device
- Days 6-7: Archive and upload to TestFlight

### Week 3: TestFlight Review & Launch
- Days 1-2: Apple reviews build (wait)
- Day 3: Approved! Invite beta testers
- Days 4-7: Beta testing, gather feedback, fix bugs

**Total: 3 weeks from start to TestFlight launch**

---

## Budget Estimate

**DIY (Minimal Cost):**
- App icons: Free (Figma) or €20 (Fiverr)
- Screenshots: Free (Xcode simulator)
- Privacy policy: Free (iubenda generator)
- Hosting: Free (GitHub Pages)
- Apple Developer: €99/year (required)
- **Total: €99-119**

**Professional (Recommended):**
- App icons: €30 (Fiverr designer)
- Screenshots: €40 (Fiverr, with device frames + text)
- Privacy policy: €100 (Fiverr, GDPR-compliant writer)
- Terms of service: €100 (Fiverr, legal template)
- Apple Developer: €99/year
- **Total: €369**

**Premium (Best Quality):**
- App icons: €100 (professional designer)
- Screenshots: €150 (professional screenshots + App Store preview video)
- Privacy policy + TOS: €500 (German lawyer review)
- Apple Developer: €99/year
- **Total: €849**

---

## Checklist Summary

### Critical (Must Have)
- [ ] App icons (1024×1024 + all sizes)
- [ ] Screenshots (minimum 3 for 6.7" display)
- [ ] Privacy policy (public URL)
- [ ] Terms of service (public URL)
- [ ] App Store description (German)
- [ ] Export compliance set
- [ ] Apple Developer account (€99/year)

### Important (Should Have)
- [ ] Keywords optimized
- [ ] Promotional text written
- [ ] Support URL configured
- [ ] Capabilities enabled (NFC, Wallet, Push)
- [ ] Backend integration complete

### Nice to Have
- [ ] Screenshots for 3 device sizes (not just one)
- [ ] App Store preview video (15-30 seconds)
- [ ] Lawyer review of legal documents
- [ ] Professional app icon design
- [ ] Localization (German + English)

---

**With focused effort, TestFlight submission is achievable within 3 weeks. Prioritize critical items, leverage free tools and affordable designers, and iterate based on beta tester feedback.**
