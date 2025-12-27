# 🧪 iOS App Test Suite
## WiesbadenAfterDark - Phase 4 Testing

---

## Test Files Created

### Unit Tests (WiesbadenAfterDarkTests/)

| File | Tests | Coverage |
|------|-------|----------|
| WiesbadenAfterDarkTests.swift | 1 | App launch |
| NFCReaderServiceTests.swift | 7 | NFC service, parsing |
| PaymentServiceTests.swift | 7 | Stripe payments |
| APIServiceTests.swift | 6 | API calls |
| CheckInViewModelTests.swift | 9 | Check-in flow |
| ModelTests.swift | 7 | Data models |
| **Total** | **37** | Core functionality |

### UI Tests (WiesbadenAfterDarkUITests/)

| File | Tests | Coverage |
|------|-------|----------|
| WiesbadenAfterDarkUITests.swift | 8 | Navigation, launch |

---

## Test Categories

### 1. NFC Service Tests
- ✅ Service initialization
- ✅ Initial state (idle)
- ✅ NFC availability check
- ✅ Venue ID parsing (wad:// URL)
- ✅ Venue ID parsing (HTTPS URL)
- ✅ Venue ID parsing (plain UUID)
- ✅ Invalid input handling

### 2. Payment Service Tests
- ✅ Service initialization
- ✅ Initial state
- ✅ Invalid amount validation
- ✅ Zero amount validation
- ✅ Points payment (sufficient)
- ✅ Points payment (insufficient)
- ✅ State reset

### 3. API Service Tests
- ✅ Service initialization
- ✅ Fetch venues
- ✅ URL construction
- ✅ Invalid venue ID handling
- ✅ ISO8601 date formatting
- ✅ Booking validation

### 4. Check-In ViewModel Tests
- ✅ ViewModel initialization
- ✅ Initial state
- ✅ State reset
- ✅ Error dismissal
- ✅ Cancel check-in
- ✅ Error messages (German)

### 5. Model Tests
- ✅ Venue decoding
- ✅ Booking decoding
- ✅ Post decoding
- ✅ Check-in decoding
- ✅ Loyalty tier ordering
- ✅ Points balance decoding

### 6. UI Tests
- ✅ App launch
- ✅ Tab bar existence
- ✅ Home navigation
- ✅ Discover navigation
- ✅ Events navigation
- ✅ Wallet navigation
- ✅ Profile navigation
- ✅ Launch performance

---

## Running Tests

### In Xcode:
```
Cmd + U (Run all tests)
```

### Command Line:
```bash
cd WiesbadenAfterDark
xcodebuild test \
  -project WiesbadenAfterDark.xcodeproj \
  -scheme WiesbadenAfterDark \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

---

## Test Coverage Goals

| Category | Target | Current |
|----------|--------|---------|
| Services | 80% | ~70% |
| ViewModels | 70% | ~60% |
| Models | 90% | ~80% |
| UI | 50% | ~40% |

---

## Manual Testing Checklist

### Authentication
- [ ] Phone number login
- [ ] OTP verification
- [ ] Logout flow
- [ ] Session persistence

### Venues
- [ ] List loads
- [ ] Detail view
- [ ] Featured venues
- [ ] Search/filter

### Events
- [ ] Events list
- [ ] Event detail
- [ ] Date filtering
- [ ] Venue events

### Check-In
- [ ] NFC scan (real device only)
- [ ] QR code scan
- [ ] Points credited
- [ ] Wrong venue error

### Payments
- [ ] Points payment
- [ ] Card payment (test mode)
- [ ] Apple Pay (device only)
- [ ] Refund flow

### Community
- [ ] View posts
- [ ] Create post
- [ ] Add image
- [ ] Like/comment

### Bookings
- [ ] Create booking
- [ ] View bookings
- [ ] Cancel booking

### Profile
- [ ] View profile
- [ ] Edit name
- [ ] Change avatar
- [ ] Settings

---

## Device Testing Required

The following require real device testing:

| Feature | Reason |
|---------|--------|
| NFC Check-In | CoreNFC not available in simulator |
| Apple Pay | Requires Wallet setup |
| Camera | QR scanning |
| Push Notifications | Requires device token |
| Haptic Feedback | Physical feedback |

---

*Created: December 26, 2025*
