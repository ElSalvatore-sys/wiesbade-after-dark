# Quick Start: Test iOS App with Production Backend

**Time Required:** 5-10 minutes
**Status:** ✅ Everything is ready

---

## Step 1: Verify Backend (30 seconds)

```bash
curl https://wiesbade-after-dark-production.up.railway.app/health
```

**Expected Response:**
```json
{"status": "ok", "service": "WiesbadenAfterDark API"}
```

---

## Step 2: Open Xcode (already opening...)

Xcode should be opening now. If not:
```bash
open ~/Desktop/Projects-2025/WiesbadenAfterDark/WiesbadenAfterDark.xcodeproj
```

---

## Step 3: Select Device & Run

1. Click device selector in Xcode toolbar (top-left)
2. Choose: **iPhone 17** (or any simulator)
3. Press **⌘R** or click the Play ▶️ button
4. Wait for simulator to launch (~10 seconds)

---

## Step 4: Test Authentication Flow

### In the iOS Simulator:

1. **Enter Phone Number**
   - Use format: `+4915234567890`
   - Or any valid German phone number

2. **Click "Send Code"**
   - Should see loading indicator
   - Should receive success message

3. **Get Verification Code**
   - Open new terminal:
     ```bash
     railway logs -s wiesbade-after-dark-production --follow | grep "Verification code"
     ```
   - Look for: `"Verification code for +4915234567890: 123456"`
   - (Or check Twilio logs if SMS is configured)

4. **Enter Code**
   - Type the 6-digit code
   - Click "Verify"
   - Should navigate to main app screen

5. **Verify Success**
   - Check Xcode console (bottom panel)
   - Should see API calls to Railway URL
   - Should NOT see any "localhost" references

---

## Step 5: Test Core Features (2 minutes)

### Browse Venues
- [ ] Tap "Discover" tab
- [ ] Should see list/map of venues
- [ ] Tap a venue to see details

### Check In
- [ ] Navigate to a venue
- [ ] Tap "Check In" button
- [ ] Should see points earned notification
- [ ] Verify points balance updated

### View Profile
- [ ] Tap "Profile" tab
- [ ] Should see user info
- [ ] Should see referral code
- [ ] Should see points balance

### Transaction History
- [ ] In profile, view transactions
- [ ] Should see check-in transaction
- [ ] Points calculation should be correct

---

## What to Look For

### ✅ Good Signs
- API calls show `https://wiesbade-after-dark-production.up.railway.app`
- Authentication works smoothly
- Venues load without errors
- Check-in succeeds
- Points are calculated correctly
- No crash or freeze

### ❌ Red Flags
- See "localhost" in console
- Network errors (check Railway is running)
- 401/403 errors (auth issue)
- 500 errors (backend crash)
- App crashes or freezes

---

## Troubleshooting

### Problem: "Network Error"
**Solution:**
```bash
# Check backend is running
railway status -s wiesbade-after-dark-production

# Check health endpoint
curl https://wiesbade-after-dark-production.up.railway.app/health
```

### Problem: "401 Unauthorized"
**Cause:** JWT token expired or invalid
**Solution:** Delete app, reinstall, and re-authenticate

### Problem: "Cannot find verification code"
**Solution:** Check Railway logs:
```bash
railway logs -s wiesbade-after-dark-production --follow
```

### Problem: "Venues not loading"
**Solution:** Check database has venue data:
```bash
# Connect to Railway Postgres and run:
SELECT COUNT(*) FROM venues;
```

---

## Monitor Backend Logs

While testing, keep this running in a terminal:

```bash
railway logs -s wiesbade-after-dark-production --follow
```

You'll see:
- SMS verification codes
- API requests from iOS app
- Database queries
- Any errors

---

## Success Criteria

After 5 minutes of testing, you should have:

- [x] iOS app running on simulator
- [ ] Successfully registered/logged in
- [ ] Viewed at least one venue
- [ ] Performed at least one check-in
- [ ] Earned some points
- [ ] Seen transaction in history
- [ ] No critical errors in console
- [ ] All API calls use Railway URL

---

## Next Steps After Testing

### If Everything Works:
1. ✅ Mark iOS integration as complete
2. 📱 Create TestFlight build
3. 👥 Invite Das Wohnzimmer team
4. 📊 Prepare demo presentation
5. 🎯 Schedule pitch meeting

### If Issues Found:
1. 📝 Document the issue in detail
2. 🔍 Check console logs and backend logs
3. 🐛 Create bug report
4. 🔧 Fix and re-test
5. ♻️ Repeat until all critical issues resolved

---

## Quick Reference

**Production Backend:**
```
https://wiesbade-after-dark-production.up.railway.app
```

**Health Check:**
```bash
curl https://wiesbade-after-dark-production.up.railway.app/health
```

**Railway Logs:**
```bash
railway logs -s wiesbade-after-dark-production --follow
```

**Rebuild App:**
```bash
cd ~/Desktop/Projects-2025/WiesbadenAfterDark
xcodebuild clean build -project WiesbadenAfterDark.xcodeproj -scheme WiesbadenAfterDark
```

**Open Xcode:**
```bash
open WiesbadenAfterDark.xcodeproj
```

---

**START TESTING NOW!**

Xcode is opening... Select iPhone 17 simulator and press ⌘R to run!
