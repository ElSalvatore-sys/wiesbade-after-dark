# 📱 Mobile Testing Guide - WiesbadenAfterDark Owner PWA
## Complete Device Testing Checklist

---

## 🔗 Production URL
https://owner-pwa.vercel.app

**Login Credentials:**
- Email: `owner@example.com`
- Password: `password`

---

## 📱 Device Requirements

### Recommended Test Devices:
- iPhone (iOS 15+) - Safari
- Android Phone (Android 10+) - Chrome
- iPad/Tablet - Safari or Chrome

### Browser Requirements:
- Safari 15+ (iOS)
- Chrome 90+ (Android)
- Camera permission enabled
- Location permission (optional)

---

## 🧪 TEST 1: PWA Installation (5 min)

### iOS (Safari):
1. Open `https://owner-pwa.vercel.app` in Safari
2. Tap the **Share** button (square with arrow)
3. Scroll down and tap **"Add to Home Screen"**
4. Tap **"Add"** in top right
5. Find the app icon on your home screen
6. Tap to open - should launch like native app

**Expected:**
- ✅ App icon appears on home screen
- ✅ Opens without browser UI (fullscreen)
- ✅ Splash screen shows briefly

### Android (Chrome):
1. Open `https://owner-pwa.vercel.app` in Chrome
2. Tap the **three dots** menu (top right)
3. Tap **"Add to Home screen"** or **"Install app"**
4. Tap **"Add"**
5. Find the app icon on your home screen

**Expected:**
- ✅ App icon appears
- ✅ Opens in standalone mode
- ✅ Shows in app switcher

---

## 🧪 TEST 2: Login Flow (3 min)

### Steps:
1. Open PWA
2. Enter email: `owner@example.com`
3. Enter password: `password`
4. Tap **"Anmelden"** (Login)

**Expected:**
- ✅ Form validates inputs
- ✅ Loading spinner shows
- ✅ Redirects to Dashboard
- ✅ No error messages

### Test Invalid Login:
1. Enter wrong password
2. Tap Login

**Expected:**
- ✅ Error message appears in German
- ✅ Form doesn't clear

---

## 🧪 TEST 3: Dashboard (3 min)

### Steps:
1. After login, observe Dashboard
2. Check all stat cards load
3. Scroll down to see all content

**Expected:**
- ✅ 4 stat cards visible (Bookings, Events, Revenue, Stock)
- ✅ Real data displayed (not "Loading...")
- ✅ Quick action buttons visible
- ✅ Recent activity feed shows entries
- ✅ Smooth scrolling

### Click Tests:
1. Tap **"Low Stock Items"** card → Should navigate to Inventory
2. Tap **"Today's Bookings"** card → Should navigate to Bookings
3. Tap **"Active Events"** card → Should navigate to Events

---

## 🧪 TEST 4: Bottom Navigation (2 min)

### Steps:
1. Tap each icon in bottom navigation bar
2. Observe page transitions

**Navigation Items:**
| Icon | Page | Expected |
|------|------|----------|
| 🏠 Home | Dashboard | Stats and activity |
| 📅 Calendar | Shifts | Employee shifts |
| ✅ Checkmark | Tasks | Task list |
| 📦 Box | Inventory | Stock items |
| 👤 Person | Settings | Profile settings |

**Expected:**
- ✅ Each tap navigates correctly
- ✅ Active icon highlighted
- ✅ Smooth transitions
- ✅ No flickering

---

## 🧪 TEST 5: Barcode Scanner (5 min) ⭐ CRITICAL

### Steps:
1. Navigate to **Inventory** page
2. Tap **"Barcode scannen"** or **"Quick Scan"** button
3. Grant camera permission when prompted
4. Point camera at any barcode

**Test Barcodes:**
- Any product barcode (EAN-13, UPC-A)
- QR code
- If no barcode available, use manual input

**Expected:**
- ✅ Camera opens fullscreen
- ✅ Scanning frame with animated line visible
- ✅ Purple corner markers visible
- ✅ "Halten Sie den Barcode in den Rahmen" text shows

### On Successful Scan:
- ✅ Vibration feedback (if supported)
- ✅ Green checkmark animation
- ✅ Barcode number displayed
- ✅ Returns to inventory (opens item if found)

### Manual Input Test:
1. In scanner, tap **"Manuell eingeben"**
2. Enter barcode: `7501064191022` (Corona Extra)
3. Tap **"Bestätigen"**

**Expected:**
- ✅ Modal closes
- ✅ Item found → Stock update modal
- ✅ OR new item → Add item modal

### Error Handling Test:
1. Deny camera permission
2. Try to scan

**Expected:**
- ✅ Error message in German
- ✅ "Erneut versuchen" and "Manuell eingeben" buttons

---

## 🧪 TEST 6: Photo Upload (5 min)

### Steps:
1. Navigate to **Mitarbeiter** (Employees)
2. Tap **"+ Neuer Mitarbeiter"**
3. Tap the photo circle/avatar area

**Expected:**
- ✅ Camera/Gallery picker appears
- ✅ Can take photo OR select from gallery

### Upload Test:
1. Select/take a photo
2. Wait for upload

**Expected:**
- ✅ Loading indicator shows
- ✅ Photo preview appears
- ✅ Can remove/replace photo

### Event Photo Test:
1. Navigate to **Events**
2. Create new event or edit existing
3. Tap photo area
4. Upload image

**Expected:**
- ✅ Same flow as employee photo
- ✅ Image displays in event card

---

## 🧪 TEST 7: Clock In/Out (5 min) ⭐ CRITICAL

### Steps:
1. Navigate to **Schichten** (Shifts)
2. Tap **"Mitarbeiter einchecken"**
3. Select an employee from dropdown
4. Enter 4-digit PIN: `1234` (default)

**Expected:**
- ✅ PIN input auto-focuses
- ✅ Auto-advance to next digit
- ✅ Paste works (copy "1234" and paste)

### On Success:
- ✅ Employee appears in "Active Shifts"
- ✅ Timer starts counting (X h Y m)
- ✅ Status shows "Active" (green)

### Break Test:
1. Find active shift
2. Tap **"Pause starten"**

**Expected:**
- ✅ Status changes to "On Break" (yellow)
- ✅ Button changes to "Pause beenden"

### Clock Out:
1. Tap **"Auschecken"**

**Expected:**
- ✅ Shift moves to history
- ✅ Hours calculated correctly

---

## 🧪 TEST 8: Bookings Calendar (3 min)

### Steps:
1. Navigate to **Reservierungen** (Bookings)
2. Switch between **List** and **Calendar** views
3. In calendar, tap different dates

**Expected:**
- ✅ Calendar displays current month
- ✅ Days with bookings show indicators
- ✅ Tapping date shows bookings for that day
- ✅ Can navigate months (prev/next)

### Quick Actions:
1. Find pending booking
2. Tap green checkmark (Confirm)

**Expected:**
- ✅ Status changes to "Bestätigt"
- ✅ Badge color changes to green
- ✅ (Email sent if SMTP configured)

---

## 🧪 TEST 9: Offline Mode (3 min)

### Steps:
1. Enable **Airplane Mode** on device
2. Navigate through the app
3. Try to load data

**Expected:**
- ✅ Banner appears: "Sie sind offline"
- ✅ Cached pages still display
- ✅ Navigation still works
- ✅ No crash

### Reconnect Test:
1. Disable Airplane Mode
2. Pull down to refresh (or tap refresh)

**Expected:**
- ✅ Banner disappears
- ✅ Data refreshes
- ✅ Actions work again

---

## 🧪 TEST 10: Performance (2 min)

### Steps:
1. Navigate between pages rapidly
2. Scroll long lists (inventory, tasks)
3. Open/close modals

**Expected:**
- ✅ Smooth 60fps animations
- ✅ No lag or stuttering
- ✅ No "jank" on scroll
- ✅ Modals animate smoothly

---

## 🧪 TEST 11: Dark Theme (1 min)

### Steps:
1. Observe all pages

**Expected:**
- ✅ Dark background (#09090B)
- ✅ White/light text readable
- ✅ Purple accent colors (#7C3AED)
- ✅ No white flashes between pages
- ✅ Form inputs have dark backgrounds

---

## 📝 Test Results Template

Copy and fill in during testing:
MOBILE TESTING RESULTS
Date: _______________
Device: ______________
OS Version: __________
Browser: _____________
TEST 1: PWA Installation
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 2: Login Flow
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 3: Dashboard
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 4: Bottom Navigation
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 5: Barcode Scanner ⭐
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 6: Photo Upload
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 7: Clock In/Out ⭐
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 8: Bookings Calendar
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 9: Offline Mode
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 10: Performance
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
TEST 11: Dark Theme
[ ] PASS  [ ] FAIL  [ ] PARTIAL
Notes: ________________
OVERALL: ___/11 PASSED
CRITICAL ISSUES: ________________

---

## 🐛 Common Issues & Fixes

### Camera Not Working:
1. Check camera permission in Settings
2. Close and reopen app
3. Use different browser

### PWA Not Installing:
1. iOS: Must use Safari (not Chrome)
2. Android: Use Chrome (not Firefox)
3. Clear browser cache and retry

### Slow Loading:
1. Check internet connection
2. Close other apps
3. Restart PWA

### Touch Not Responsive:
1. Ensure touch targets are 44x44px+
2. Report specific area if issue persists

---

## ✅ Success Criteria

**Minimum for Pilot:**
- All 11 tests PASS or PARTIAL
- No CRITICAL tests failing (Barcode, Clock In/Out)
- Performance acceptable on target devices

**Recommended:**
- 100% PASS rate
- Test on both iOS and Android
- Test on slow network (3G simulation)

---

*Testing Time: ~30-40 minutes*
*Last Updated: December 26, 2025*
