# WiesbadenAfterDark - Testing Phase
## Das Wohnzimmer Pre-Launch Testing

**Testing Period:** This Week (Dec 2-6, 2025)
**Location:** Das Wohnzimmer, Wiesbaden
**Goal:** Test everything before public launch

---

## Phase 1: Setup & Configuration

### 1.1 Venue Setup in Backend
- [ ] Create Das Wohnzimmer venue in Supabase
- [ ] Add venue details (name, address, phone, hours, photos)
- [ ] Set up owner account (Max's credentials)
- [ ] Configure venue ID in Owner PWA

### 1.2 Staff Accounts
- [ ] Create owner account for Das Wohnzimmer
- [ ] Create manager account(s)
- [ ] Create bartender accounts
- [ ] Create inventory manager account
- [ ] Test all role logins work

### 1.3 Menu/Products Setup
- [ ] Add all drinks to inventory system
- [ ] Set prices for each item
- [ ] Set minimum stock levels
- [ ] Scan barcodes for all products
- [ ] Verify product list is complete

---

## Phase 2: Kassensystem (POS) Integration

### 2.1 Identify POS System
- [ ] What POS does Das Wohnzimmer use? (Lightspeed, Square, Orderbird, etc.)
- [ ] Get API documentation for their POS
- [ ] Determine integration possibilities
- [ ] Get API credentials if available

### 2.2 Integration Options
- [ ] Option A: Direct API integration (if POS supports)
- [ ] Option B: Manual sync (export/import)
- [ ] Option C: Barcode scanning bridge
- [ ] Document chosen approach

### 2.3 Data Sync
- [ ] Sales data → Points calculation
- [ ] Inventory sync from POS
- [ ] Transaction history sync

---

## Phase 3: Points System Testing

### 3.1 Check-in Flow
- [ ] Customer opens iOS app
- [ ] Customer checks in at venue (NFC/QR/GPS)
- [ ] Points awarded correctly
- [ ] Check-in appears in Owner dashboard
- [ ] Notification sent to customer

### 3.2 Points Calculation
- [ ] Base points per check-in: ___
- [ ] Points per € spent: ___
- [ ] Event multiplier working (1.5x, 2x)
- [ ] Referral bonus points working
- [ ] Points appear in customer profile

### 3.3 Rewards Redemption
- [ ] Customer can view available rewards
- [ ] Redemption process works
- [ ] Owner sees redemption in dashboard
- [ ] Points deducted correctly

---

## Phase 4: Booking System Testing

### 4.1 Customer App
- [ ] Browse venue and see availability
- [ ] Make a table reservation
- [ ] Receive confirmation notification
- [ ] View booking in "My Bookings"
- [ ] Cancel booking works

### 4.2 Owner PWA
- [ ] New bookings appear in Bookings page
- [ ] Calendar view shows correct dates
- [ ] Confirm booking works
- [ ] Cancel booking works
- [ ] Send message to guest works

---

## Phase 5: Inventory System Testing

### 5.1 Initial Stock Count
- [ ] Inventory manager scans all products
- [ ] Storage counts are accurate
- [ ] Bar counts are accurate
- [ ] Low stock alerts trigger correctly

### 5.2 Daily Operations
- [ ] Transfer from storage to bar
- [ ] Track bottles opened/sold
- [ ] End-of-night count
- [ ] Variance report accurate

### 5.3 Barcode Scanning
- [ ] Phone camera scanning works
- [ ] Correct product identified
- [ ] Quick stock update works
- [ ] Unknown barcode prompts to add

---

## Phase 6: Task Management Testing

### 6.1 Task Creation
- [ ] Owner creates task
- [ ] Assign to specific employee
- [ ] Set due time
- [ ] Employee receives notification

### 6.2 Task Completion
- [ ] Employee marks task in progress
- [ ] Employee marks task complete
- [ ] Photo proof uploads (if required)
- [ ] Owner can approve/reject

### 6.3 End-of-Shift
- [ ] All tasks visible
- [ ] Incomplete tasks flagged
- [ ] Owner notified of incomplete tasks

---

## Phase 7: Dashboard & Analytics

### 7.1 Real-time Data
- [ ] Today's bookings count accurate
- [ ] Active events showing
- [ ] Low stock count accurate
- [ ] Revenue numbers correct

### 7.2 Reports
- [ ] Daily summary works
- [ ] Weekly analytics accurate
- [ ] Customer insights showing

---

## Phase 8: Notifications

### 8.1 Customer App (iOS)
- [ ] Push notifications enabled
- [ ] Check-in confirmation received
- [ ] Booking confirmation received
- [ ] Points earned notification
- [ ] Event reminder works

### 8.2 Owner PWA
- [ ] Browser notifications enabled
- [ ] New booking alert works
- [ ] Low stock alert works
- [ ] Task completion alert works

---

## Phase 9: Edge Cases & Errors

### 9.1 Network Issues
- [ ] App works with slow connection
- [ ] Offline mode graceful degradation
- [ ] Data syncs when back online

### 9.2 Error Handling
- [ ] Invalid login shows error
- [ ] Failed booking shows message
- [ ] Scanner errors handled

---

## Issues Found

| # | Issue | Severity | Status | Notes |
|---|-------|----------|--------|-------|
| 1 |       |          |        |       |
| 2 |       |          |        |       |
| 3 |       |          |        |       |

---

## Sign-Off

- [ ] Owner (Das Wohnzimmer) approves system
- [ ] All critical issues resolved
- [ ] Staff trained on system
- [ ] Ready for public launch

**Tested by:** _______________
**Date:** _______________
**Launch approved:** Yes / No
