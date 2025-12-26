# Owner PWA - Mobile Testing Plan
**Date:** December 26, 2025
**Target:** Das Wohnzimmer Launch (January 1, 2025)
**Time Estimate:** 30 minutes

---

## Test Environment
- **URL:** https://owner-6xdb541ae-l3lim3d-2348s-projects.vercel.app
- **Login:** owner@example.com / password
- **Devices:** iPhone Safari, Chrome Mobile
- **Connection:** WiFi + 4G

---

## 10 Critical Mobile Tests

### ✅ Test 1: PWA Installation (3 min)
**Steps:**
1. Open URL in Safari on iPhone
2. Tap Share → Add to Home Screen
3. Tap the PWA icon on home screen
4. Verify it opens in standalone mode (no browser UI)

**Expected:**
- PWA installs successfully
- App icon visible on home screen
- Opens without Safari UI
- No browser address bar

**Result:** ___________

---

### ✅ Test 2: Login Flow (2 min)
**Steps:**
1. Enter owner@example.com
2. Enter password
3. Tap Login button
4. Verify redirect to dashboard

**Expected:**
- Login button is touch-friendly (44x44px)
- No layout shifts on keyboard open
- Smooth transition to dashboard
- Session persists after close/reopen

**Result:** ___________

---

### ✅ Test 3: Dashboard Touch Targets (3 min)
**Steps:**
1. Tap each stat card (Revenue, Bookings, Inventory, Tasks)
2. Verify cards are clickable
3. Check hover effects work on touch
4. Tap notification bell

**Expected:**
- All cards respond to tap
- Visual feedback on touch
- Navigation works correctly
- Notifications panel opens smoothly

**Result:** ___________

---

### ✅ Test 4: Barcode Scanner (4 min)
**Steps:**
1. Navigate to Inventory
2. Tap "Scan Barcode" button
3. Grant camera permission
4. Point at a barcode (or use test image)
5. Verify detection works

**Expected:**
- Camera opens instantly
- Permission prompt appears once
- Scanner overlay is visible
- Barcode detection works
- Falls back gracefully if no camera

**Result:** ___________

---

### ✅ Test 5: Events Management (4 min)
**Steps:**
1. Navigate to Events
2. Tap "+ Create Event" button
3. Fill form on mobile (check keyboard handling)
4. Upload image (tap camera icon)
5. Tap Save

**Expected:**
- Form fields are large enough to tap
- Keyboard doesn't hide input fields
- Image upload works (camera + gallery)
- Success message appears
- Event appears in list

**Result:** ___________

---

### ✅ Test 6: Bookings Calendar (3 min)
**Steps:**
1. Navigate to Bookings
2. Swipe between calendar dates
3. Tap on a booking to view details
4. Accept/reject a booking
5. Check email confirmation (if SMTP configured)

**Expected:**
- Calendar is swipeable on mobile
- Touch targets are large enough
- Booking modal opens smoothly
- Accept/reject buttons work
- Modal closes correctly

**Result:** ___________

---

### ✅ Test 7: Responsive Layout (3 min)
**Steps:**
1. Test in portrait mode
2. Rotate to landscape mode
3. Check navigation menu
4. Verify all content is readable
5. Test on different screen sizes

**Expected:**
- No horizontal scrolling
- Content reflows properly
- Navigation adapts to screen size
- Text is readable (16px minimum)
- Images scale correctly

**Result:** ___________

---

### ✅ Test 8: Notifications (3 min)
**Steps:**
1. Tap notification bell icon
2. Verify notifications slide in smoothly
3. Tap a notification item
4. Check notification badge count updates
5. Clear a notification

**Expected:**
- Slide-in animation is smooth
- High contrast text (readable)
- Tap targets are 44x44px minimum
- Badge updates in real-time
- Notifications can be dismissed

**Result:** ___________

---

### ✅ Test 9: Profile & Settings (2 min)
**Steps:**
1. Tap profile icon (top right)
2. Verify dropdown opens
3. Tap Settings
4. Check Settings page loads
5. Tap Logout and verify redirect

**Expected:**
- Dropdown opens smoothly
- All menu items are tappable
- Settings page is mobile-friendly
- Logout works correctly
- Redirect to login page

**Result:** ___________

---

### ✅ Test 10: Offline Behavior (3 min)
**Steps:**
1. Turn off WiFi/4G
2. Try to navigate between pages
3. Check if service worker caches pages
4. Turn connection back on
5. Verify data syncs

**Expected:**
- App shows offline indicator
- Cached pages load instantly
- Form submissions queue
- Data syncs when back online
- No data loss

**Result:** ___________

---

## Performance Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| First Contentful Paint | < 2s | _____ |
| Time to Interactive | < 3s | _____ |
| Page Load (Dashboard) | < 1.5s | _____ |
| Page Load (Events) | < 2s | _____ |
| Barcode Scanner Open | < 0.5s | _____ |

---

## Critical Issues Found

### High Priority
- [ ] Issue 1: _______________________________
- [ ] Issue 2: _______________________________
- [ ] Issue 3: _______________________________

### Medium Priority
- [ ] Issue 4: _______________________________
- [ ] Issue 5: _______________________________

### Low Priority (Nice-to-have)
- [ ] Issue 6: _______________________________

---

## Browser Compatibility

| Browser | Version | Status | Notes |
|---------|---------|--------|-------|
| Safari iOS | 17+ | _____ | Primary target |
| Chrome iOS | Latest | _____ | Secondary |
| Safari iOS | 15-16 | _____ | Fallback support |
| Chrome Android | Latest | _____ | Optional |

---

## Sign-Off

**Tested By:** _______________________
**Date:** _______________________
**Status:** ☐ Pass ☐ Fail ☐ Pass with Issues

**Notes:**
_______________________________________
_______________________________________
_______________________________________

---

## Next Steps After Testing

1. **If Pass:**
   - Mark Owner PWA as production-ready ✅
   - Schedule Das Wohnzimmer onboarding
   - Prepare launch announcement

2. **If Pass with Issues:**
   - Create bug tickets for critical issues
   - Fix before January 1 launch
   - Retest affected areas

3. **If Fail:**
   - Document all blocking issues
   - Prioritize critical fixes
   - Delay launch if necessary

---

**Test Completion Time:** _____ minutes
**Overall Status:** ☐ READY FOR LAUNCH ☐ NEEDS FIXES ☐ NOT READY
