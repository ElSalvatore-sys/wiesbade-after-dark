# iOS Production Testing Checklist

## Status: READY FOR TESTING
**Backend URL:** https://wiesbade-after-dark-production.up.railway.app
**Configuration:** ✅ Already set to production
**Localhost References:** ✅ None found

---

## Pre-Test Setup
- [ ] Backend health check passes
  ```bash
  curl https://wiesbade-after-dark-production.up.railway.app/health
  ```
- [ ] iOS app built successfully
- [ ] Simulator/device connected

---

## Authentication Flow
- [ ] Open app on simulator/device
- [ ] Enter German phone number (format: +49...)
- [ ] Click "Send Code"
- [ ] Check backend logs for SMS send:
  ```bash
  railway logs -s wiesbade-after-dark-production
  ```
- [ ] Receive SMS code (check Twilio logs if needed)
- [ ] Enter verification code
- [ ] User registered successfully
- [ ] JWT token saved in Keychain
- [ ] App navigates to main screen

---

## Core Features to Test

### Profile Management
- [ ] View user profile (tap profile icon)
- [ ] See user's referral code
- [ ] View total points balance
- [ ] Check wallet pass section

### Venues
- [ ] Browse venues list (Map/List view)
- [ ] View venue details (tap a venue)
- [ ] See venue location on map
- [ ] Check venue hours/info
- [ ] View upcoming events at venue
- [ ] Join venue community

### Check-in System
- [ ] Navigate to a venue
- [ ] Tap "Check In" button
- [ ] Confirm location permission if needed
- [ ] Verify check-in successful
- [ ] See points earned notification
- [ ] View updated points balance
- [ ] Check transaction history shows check-in

### Events
- [ ] Browse upcoming events
- [ ] View event details
- [ ] RSVP to an event
- [ ] View "My Events" section
- [ ] Cancel RSVP

### Bookings (if implemented)
- [ ] Create a new booking
- [ ] View booking details
- [ ] See booking in "My Bookings"
- [ ] Generate wallet pass
- [ ] Cancel booking

### Points & Transactions
- [ ] View transaction history
- [ ] Verify points calculations:
  - Base check-in: 50 points
  - Margin-based bonus
  - Product bonuses
  - Streak bonuses
- [ ] Check referral rewards (if applicable)

---

## Error Handling Tests

### Invalid Inputs
- [ ] Invalid phone format rejected
- [ ] Empty phone number blocked
- [ ] Invalid verification code rejected
- [ ] Expired verification code handled

### Network Errors
- [ ] Offline mode shows error
- [ ] Timeout errors handled gracefully
- [ ] 404/500 errors show user-friendly message
- [ ] Retry mechanism works

### Edge Cases
- [ ] Check-in too soon (< 24h) blocked
- [ ] Check-in outside venue radius blocked
- [ ] Duplicate RSVPs prevented
- [ ] Invalid venue ID handled

---

## Production URL Verification

### During Testing, Verify:
- [ ] No "localhost" appears in Xcode console
- [ ] All API calls show Railway URL in logs
- [ ] SSL/HTTPS certificate valid (no warnings)
- [ ] Response times acceptable (< 2 seconds)

### Check Xcode Console for:
```
✅ Good: "GET https://wiesbade-after-dark-production.up.railway.app/api/v1/..."
❌ Bad: "GET http://localhost:8000/api/v1/..."
```

---

## Performance & UX

- [ ] App loads quickly (< 3 seconds)
- [ ] Smooth scrolling in venue list
- [ ] Images load properly
- [ ] Loading indicators appear during API calls
- [ ] No UI freezes or crashes
- [ ] Navigation flows naturally

---

## Security Checks

- [ ] JWT token stored securely in Keychain
- [ ] Token included in authenticated requests
- [ ] Logout clears token properly
- [ ] Unauthorized access shows login screen
- [ ] Phone number validation prevents injection

---

## Backend Integration Verification

### Database Operations
- [ ] New user created in Supabase
- [ ] Check-ins recorded correctly
- [ ] Transactions logged properly
- [ ] Points balances updated

### Check Backend Tables:
```sql
-- Users table
SELECT * FROM users ORDER BY created_at DESC LIMIT 5;

-- Check-ins table
SELECT * FROM check_ins ORDER BY checked_in_at DESC LIMIT 10;

-- Transactions table
SELECT * FROM transactions ORDER BY created_at DESC LIMIT 10;
```

---

## Known Issues & Limitations

Record any issues found during testing:

### Critical Issues
- [ ] None found (fill in if issues occur)

### Minor Issues
- [ ] None found (fill in if issues occur)

### Future Improvements
- [ ] (Add suggestions here)

---

## Test Results Summary

**Date Tested:** _______________
**Tested By:** _______________
**Device/Simulator:** _______________
**iOS Version:** _______________

**Authentication:** ✅ ❌ (circle one)
**Core Features:** ✅ ❌
**Error Handling:** ✅ ❌
**Production URLs:** ✅ ❌
**Performance:** ✅ ❌

**Overall Status:** PASS / FAIL

**Notes:**
```
(Add detailed notes here)
```

---

## Next Steps After Testing

### If All Tests Pass:
- [ ] Create TestFlight build
- [ ] Invite Das Wohnzimmer for demo
- [ ] Prepare pitch materials:
  - [ ] Feature overview deck
  - [ ] Demo script
  - [ ] ROI calculations
  - [ ] Integration timeline
- [ ] Schedule demo meeting

### If Issues Found:
- [ ] Document all issues in detail
- [ ] Prioritize (Critical/High/Medium/Low)
- [ ] Create fix tasks in Archon
- [ ] Re-test after fixes
- [ ] Repeat until all critical issues resolved

---

## Quick Test Script (30 minutes)

**Minimal viable test to verify production readiness:**

1. **5 min:** Backend health check + user registration
2. **5 min:** Login with phone verification
3. **5 min:** Browse venues + view details
4. **5 min:** Perform check-in + verify points
5. **5 min:** View transactions + profile
6. **5 min:** Test error cases (invalid inputs)

**If this passes → Ready for TestFlight**
**If this fails → Debug and fix before proceeding**

---

## Production Deployment Checklist

Before going live with Das Wohnzimmer:

- [ ] Backend deployed on Railway ✅ (already done)
- [ ] iOS app uses production URL ✅ (already done)
- [ ] Database migrations applied
- [ ] Twilio SMS working in production
- [ ] Error monitoring configured
- [ ] Backup strategy in place
- [ ] Support contact established
- [ ] Terms of service ready
- [ ] Privacy policy ready
- [ ] GDPR compliance verified

---

**CONFIGURATION STATUS:**
- **APIConfig.swift:** ✅ Production URL set
- **RealWalletPassService.swift:** ✅ Production URL set
- **No localhost references:** ✅ Verified clean
- **Ready for testing:** ✅ YES

**NEXT ACTION:** Build and run the iOS app, then work through this checklist!
