# ✅ App Store Final Submission Checklist
## WiesbadenAfterDark iOS App

---

## Pre-Submission Requirements

### 1. Apple Developer Account
- [ ] Purchase Apple Developer Program membership (€99/year)
- [ ] Verify account activation (can take 24-48 hours)
- [ ] Complete legal agreements in App Store Connect
- [ ] Set up two-factor authentication for security

**Purchase:** https://developer.apple.com/programs/enroll/

---

### 2. App Store Connect Setup
- [ ] Create app record in App Store Connect
- [ ] Set app name: **WiesbadenAfterDark**
- [ ] Choose SKU: `wad-ios-2025`
- [ ] Set bundle identifier: `de.wiesbadenafterdark.app`
- [ ] Select primary language: **German**

**URL:** https://appstoreconnect.apple.com

---

### 3. App Information
- [ ] App name (30 characters max): `WiesbadenAfterDark`
- [ ] Subtitle (30 characters): `Wiesbaden Nachtleben`
- [ ] Category: **Lifestyle** (Primary), **Social Networking** (Secondary)
- [ ] Content rating: **12+** (Social features, nightlife)
- [ ] Copyright: `2025 ElSalvatore Sys`

---

### 4. Pricing and Availability
- [ ] Price: **Free**
- [ ] Availability: **Germany** only (initially)
- [ ] Release: **Manual Release** (after review approval)
- [ ] Pre-order: No

---

### 5. Privacy Policy
- [x] Privacy policy page created (docs/index.html)
- [ ] Enable GitHub Pages for repo
- [ ] Verify privacy URL is accessible
- [ ] Test on mobile device (German + English)

**Privacy URL:** `https://elsalvatore-sys.github.io/wiesbade-after-dark/`

**Steps to enable GitHub Pages:**
1. Go to repo Settings → Pages
2. Source: **Deploy from a branch**
3. Branch: **main** → Folder: **/docs**
4. Save and wait 2-3 minutes
5. Test URL

---

### 6. Support Information
- [x] Support page created (docs/support.html)
- [ ] Support URL added to App Store listing
- [ ] Support email active: `support@wiesbadenafterdark.de`

**Support URL:** `https://elsalvatore-sys.github.io/wiesbade-after-dark/support.html`

---

### 7. App Description

**German (Main):**
```
Entdecke das Nachtleben von Wiesbaden wie nie zuvor! WiesbadenAfterDark ist deine ultimative App für Bars, Clubs, Restaurants und Events in der hessischen Landeshauptstadt.

✨ FEATURES:
• Entdecke Venues: Finde die angesagtesten Locations
• Check-in per NFC: Sammle Punkte bei jedem Besuch
• Events: Verpasse kein Event mehr
• Belohnungen: Tausche Punkte gegen exklusive Vorteile
• Community: Teile deine Erlebnisse
• Bookings: Reserviere direkt in der App

🎯 WARUM WIESBADENAFTERDARK?
• Exklusive Deals & Rabatte
• Loyalty-Programm mit Bonuspunkten
• Echtzeit-Updates zu Events
• Direkte Kommunikation mit Venues

Perfekt für alle, die Wiesbadens Nachtleben aktiv erleben wollen!

Hinweis: NFC-Check-in erfordert iPhone XS oder neuer.
```

**English (Secondary):**
```
Discover Wiesbaden's nightlife like never before! WiesbadenAfterDark is your ultimate app for bars, clubs, restaurants, and events in Hesse's capital city.

✨ FEATURES:
• Discover Venues: Find the hottest locations
• NFC Check-in: Earn points with every visit
• Events: Never miss an event
• Rewards: Redeem points for exclusive benefits
• Community: Share your experiences
• Bookings: Reserve directly in the app

🎯 WHY WIESBADENAFTERDARK?
• Exclusive deals & discounts
• Loyalty program with bonus points
• Real-time event updates
• Direct communication with venues

Perfect for anyone who wants to actively experience Wiesbaden's nightlife!

Note: NFC check-in requires iPhone XS or newer.
```

**Keywords (100 characters max):**
```
wiesbaden,nightlife,bars,clubs,events,loyalty,rewards,nfc,checkin,bookings
```

---

### 8. Screenshots
- [ ] Capture 5 screenshots x 3 device sizes (15 total)
- [ ] Add text overlays (optional but recommended)
- [ ] Upload to App Store Connect
- [ ] Arrange in correct order

**See:** `APP_STORE_SCREENSHOTS.md` for detailed guide

---

### 9. App Icon
- [x] 1024x1024 px icon created
- [x] Added to Xcode Asset Catalog
- [x] No transparency, no rounded corners (iOS adds automatically)

**Verify in:** `WiesbadenAfterDark/Assets.xcassets/AppIcon.appiconset/`

---

### 10. Build Configuration
- [x] Version: 1.0.0
- [x] Build: 1
- [ ] Distribution certificate created
- [ ] Provisioning profile created (App Store Distribution)
- [ ] Capabilities configured (NFC, Push Notifications, etc.)

---

## Submission Steps

### Step 1: Final Build in Xcode
```bash
1. Open WiesbadenAfterDark.xcodeproj
2. Select "Any iOS Device (arm64)" target
3. Product → Archive
4. Wait for build to complete (2-5 minutes)
5. Organizer window opens automatically
```

---

### Step 2: Archive Validation
```bash
1. Select your archive in Organizer
2. Click "Validate App"
3. Choose distribution options:
   - App Store Connect
   - Upload symbols: YES
   - Manage version and build number: NO
4. Wait for validation (1-3 minutes)
5. Fix any errors if they appear
```

**Common errors:**
- Missing provisioning profile → Create in developer.apple.com
- Invalid icon → Check size and format
- Missing entitlements → Configure in Xcode

---

### Step 3: Upload to App Store Connect
```bash
1. Click "Distribute App" in Organizer
2. Choose "App Store Connect"
3. Upload options:
   - Upload symbols: YES
   - Upload bitcode: NO (deprecated)
4. Wait for upload (5-15 minutes depending on connection)
5. Receive confirmation email from Apple
```

---

### Step 4: Processing
- [ ] Wait for build to process (15-60 minutes)
- [ ] Check App Store Connect for "Ready to Submit" status
- [ ] Receive email: "Your build is ready"

---

### Step 5: Complete App Store Listing
```bash
1. Go to App Store Connect → My Apps → WiesbadenAfterDark
2. Select your build in "Build" section
3. Fill in all required fields:
   - Description (German + English)
   - Keywords
   - Screenshots (all sizes)
   - Support URL
   - Privacy Policy URL
   - App Review Information (see below)
4. Save changes
```

---

### Step 6: App Review Information
```
Contact Information:
- First Name: ElSalvatore
- Last Name: Sys
- Phone: [Your phone number]
- Email: support@wiesbadenafterdark.de

Demo Account (for testing):
- Username: reviewer@wiesbadenafterdark.de
- Password: ReviewTest2025!
- Notes: Use this account to test all features. NFC check-in requires physical device.

Review Notes:
"
WiesbadenAfterDark ist eine Nightlife-Discovery-App für Wiesbaden, Deutschland.

Wichtig für Review:
1. NFC Check-in: Erfordert iPhone XS+ mit physischem NFC-Tag. Im Simulator nicht testbar.
2. Demo-Account: reviewer@wiesbadenafterdark.de / ReviewTest2025!
3. Test-Venues: In der App sichtbar (z.B. 'Das Wohnzimmer')
4. Stripe Payments: Test-Modus aktiv, keine echten Transaktionen

Die App ist derzeit für den deutschen Markt (Wiesbaden) optimiert.

Bei Fragen: support@wiesbadenafterdark.de
"
```

---

### Step 7: Submit for Review
- [ ] Review all information one last time
- [ ] Check that privacy policy URL is accessible
- [ ] Verify screenshots are in correct order
- [ ] Click "Submit for Review"
- [ ] Confirm submission

---

## After Submission

### Review Timeline
- **Waiting for Review:** 1-3 days
- **In Review:** 12-48 hours
- **Total Time:** Usually 2-5 days

### Possible Outcomes

#### ✅ Approved
- [ ] Receive email: "Your app status is Ready for Sale"
- [ ] Manually release app (if selected Manual Release)
- [ ] App goes live on App Store (1-2 hours after release)
- [ ] Verify app listing on App Store
- [ ] Download and test from App Store

#### ⚠️ Metadata Rejected
- [ ] Fix description/screenshots/metadata only
- [ ] No new build required
- [ ] Resubmit for review (fast track)

#### ❌ Binary Rejected
- [ ] Review rejection reasons carefully
- [ ] Fix code issues
- [ ] Increment build number
- [ ] Create new archive
- [ ] Upload new build
- [ ] Resubmit for review

---

## Post-Launch Checklist

### Immediate Actions (Day 1)
- [ ] Monitor crash reports in App Store Connect
- [ ] Check reviews and ratings
- [ ] Verify all features work in production
- [ ] Test with real users at Das Wohnzimmer
- [ ] Monitor backend logs for errors

### Week 1 Actions
- [ ] Collect user feedback
- [ ] Identify top issues or bugs
- [ ] Plan v1.0.1 bug fix release if needed
- [ ] Monitor analytics (downloads, DAU, retention)

### Marketing
- [ ] Share App Store link on social media
- [ ] Create launch announcement
- [ ] Contact Das Wohnzimmer for promotion
- [ ] Set up app website landing page

---

## Important URLs

| Resource | URL |
|----------|-----|
| Apple Developer | https://developer.apple.com |
| App Store Connect | https://appstoreconnect.apple.com |
| Privacy Policy | https://elsalvatore-sys.github.io/wiesbade-after-dark/ |
| Support | https://elsalvatore-sys.github.io/wiesbade-after-dark/support.html |
| Supabase Dashboard | https://app.supabase.com |

---

## Contact Information

**Developer:** ElSalvatore Sys
**Email:** support@wiesbadenafterdark.de
**Support:** See docs/support.html

---

## Version History

| Version | Build | Status | Date |
|---------|-------|--------|------|
| 1.0.0 | 1 | Ready for Submission | Dec 26, 2025 |

---

## Next Steps After €99 Purchase

1. **Immediately:** Complete Apple Developer enrollment
2. **Day 1:** Create app record in App Store Connect
3. **Day 1:** Enable GitHub Pages
4. **Day 2:** Take screenshots (1-2 hours)
5. **Day 2:** Create archive and upload (30 min)
6. **Day 2:** Submit for review
7. **Day 4-7:** App review completes
8. **Day 7:** Launch! 🚀

---

**CURRENT STATUS:** iOS app is 100% code complete with 37 unit tests and 8 UI tests. Ready for archive and submission once Apple Developer account is active.

---

*Created: December 26, 2025*
*Last Updated: December 26, 2025*
