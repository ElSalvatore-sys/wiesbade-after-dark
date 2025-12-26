# 🔧 NFC Implementation Guide
## WiesbadenAfterDark - Real NFC Check-In

**Status:** RealNFCReaderService created ✅
**Next:** Integrate into CheckInViewModel

---

## ✅ What's Done

### 1. Real NFC Service Created
**File:** `Core/Services/RealNFCReaderService.swift`

**Features:**
- ✅ Real CoreNFC implementation
- ✅ NDEF tag reading
- ✅ Venue ID extraction from multiple formats
- ✅ German error messages
- ✅ Proper async/await with continuations
- ✅ Non-isolated delegate methods

**Supported Formats:**
```
wad://checkin/{venueId}
https://wiesbadenafterdark.de/checkin/{venueId}
wiesbaden-after-dark://venue/{venueId}
Plain UUID text on tag
```

### 2. Entitlements Configured
**File:** `WiesbadenAfterDark.entitlements`

```xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>TAG</string>
</array>
```

---

## 🔨 What Needs To Be Done

### Step 1: Add NFC Usage Description to Info.plist

**File:** `WiesbadenAfterDark/Info.plist`

**Add this entry:**
```xml
<key>NFCReaderUsageDescription</key>
<string>WiesbadenAfterDark benötigt NFC, um bei Venues einzuchecken und Punkte zu sammeln.</string>
```

**Or in English:**
```xml
<key>NFCReaderUsageDescription</key>
<string>WiesbadenAfterDark uses NFC to check in at venues and earn loyalty points.</string>
```

### Step 2: Update CheckInViewModel

**File:** `Features/CheckIn/ViewModels/CheckInViewModel.swift`

**Current code (line 103-140):**
```swift
func performNFCCheckIn(
    userId: UUID,
    venue: Venue,
    membership: VenueMembership,
    event: Event? = nil
) async {
    checkInState = .scanning
    isLoading = true
    errorMessage = nil

    do {
        // 1. Simulate NFC scan ❌ FAKE
        let payload = try await checkInService.simulateNFCScan(for: venue)

        checkInState = .validating

        // 2. Validate payload
        let isValid = try await checkInService.validateNFCPayload(payload)

        guard isValid else {
            throw CheckInError.invalidNFCPayload
        }

        // 3. Perform check-in
        await performCheckIn(
            userId: userId,
            venue: venue,
            membership: membership,
            method: .nfc,
            event: event
        )

    } catch {
        errorMessage = error.localizedDescription
        checkInState = .error(error.localizedDescription)
        isLoading = false
    }
}
```

**NEW code (replace with):**
```swift
/// NFC Reader Service
private let nfcReader = RealNFCReaderService()

func performNFCCheckIn(
    userId: UUID,
    venue: Venue,
    membership: VenueMembership,
    event: Event? = nil
) async {
    checkInState = .scanning
    isLoading = true
    errorMessage = nil

    do {
        // 1. Real NFC scan ✅ REAL
        let scannedVenueId = try await nfcReader.startScanning()

        checkInState = .validating

        // 2. Validate scanned venue matches expected venue
        guard scannedVenueId == venue.id.uuidString else {
            throw CheckInError.wrongVenue
        }

        // 3. Perform check-in
        await performCheckIn(
            userId: userId,
            venue: venue,
            membership: membership,
            method: .nfc,
            event: event
        )

    } catch let error as RealNFCReaderService.NFCError {
        errorMessage = error.localizedDescription
        checkInState = .error(error.localizedDescription)
        isLoading = false
    } catch {
        errorMessage = error.localizedDescription
        checkInState = .error(error.localizedDescription)
        isLoading = false
    }
}
```

### Step 3: Add CheckInError.wrongVenue

**File:** `Core/Models/CheckInError.swift` (or wherever CheckInError is defined)

**Add this case:**
```swift
enum CheckInError: Error, LocalizedError {
    // ... existing cases ...
    case wrongVenue

    var errorDescription: String? {
        switch self {
        // ... existing cases ...
        case .wrongVenue:
            return "Du hast den falschen NFC-Tag gescannt. Bitte scanne den Tag der Venue."
        }
    }
}
```

### Step 4: Add Import Statement

**File:** `Features/CheckIn/ViewModels/CheckInViewModel.swift`

**Add at top:**
```swift
import CoreNFC
```

### Step 5: Remove Mock Service Default

**File:** `Features/CheckIn/ViewModels/CheckInViewModel.swift`

**Current line 77:**
```swift
self.checkInService = checkInService ?? MockCheckInService.shared
```

**Change to:**
```swift
self.checkInService = checkInService ?? RealCheckInService.shared
```

---

## 🧪 Testing

### Simulator Testing
**Status:** ❌ NFC does NOT work in simulator

You'll see this error:
```
NFC wird auf diesem Gerät nicht unterstützt
```

This is NORMAL and expected.

### Real Device Testing

**Requirements:**
- iPhone 7 or newer
- iOS 13.0+
- Physical NFC tag

**Steps:**
1. Build and run on real device
2. Navigate to check-in screen
3. Tap "Check-In with NFC"
4. Hold iPhone near NFC tag
5. Should scan and check in

**Test NFC Tags:**
You can buy blank NTAG213/215/216 tags from Amazon for ~€10/20 tags.

**Writing Tags:**
Use these apps to write venue IDs to tags:
- NFC Tools (iOS)
- TagWriter by NXP (iOS)

**Format to write:**
```
URL/URI Record:
wad://checkin/{venue-uuid}

OR

Text Record:
{venue-uuid}
```

---

## 📱 Physical Device Setup

### Option 1: Free Development (7 days)

1. Connect iPhone via USB
2. Xcode → Select your iPhone
3. Signing & Capabilities → Team: Your Apple ID
4. Build and run
5. iPhone Settings → Trust developer
6. **Limitation:** App expires after 7 days

### Option 2: Paid Developer (€99/year)

1. Purchase Apple Developer Program
2. Add team in Xcode
3. Create provisioning profile with NFC capability
4. Build and run
5. **Benefit:** No expiration, can submit to App Store

---

## 🚨 Common Issues

### "NFC not supported on this device"

**Cause:** Running in Simulator
**Fix:** Test on real iPhone 7+ only

### "NFC capability missing"

**Cause:** Entitlements not synced
**Fix:**
1. Clean build folder (Cmd+Shift+K)
2. Delete DerivedData
3. Rebuild project

### "Invalid team"

**Cause:** No Apple Developer account
**Fix:** Either:
- Use free account (7-day limit)
- Purchase €99 developer program

### "Tag not detected"

**Causes:**
1. iPhone case too thick
2. Tag not formatted correctly
3. Tag too far from phone

**Fix:**
- Remove case
- Hold tag directly against back of iPhone
- Use NFC Tools app to verify tag works

---

## 📊 Implementation Progress

| Task | Status |
|------|--------|
| Create RealNFCReaderService | ✅ Done |
| Add NFC entitlements | ✅ Done |
| Add Info.plist usage description | ⏳ TODO |
| Update CheckInViewModel | ⏳ TODO |
| Add CheckInError.wrongVenue | ⏳ TODO |
| Test on real device | ⏳ TODO |

**Estimated Time:** 30-45 minutes to complete remaining tasks

---

## 🎯 Next Steps

1. **Add NFC usage description to Info.plist** (2 min)
2. **Update CheckInViewModel** (10 min)
3. **Add wrongVenue error** (3 min)
4. **Build on real device** (15 min)
5. **Write test NFC tag** (10 min)
6. **Test check-in flow** (5 min)

**Total:** ~45 minutes

---

## 💡 Tips

### Creating Test Tags

Buy these from Amazon:
- NTAG213 (144 bytes) - €0.50/tag
- NTAG215 (504 bytes) - €0.60/tag
- NTAG216 (888 bytes) - €0.80/tag

All work perfectly for venue IDs.

### Tag Format Recommendation

Use URL format for best compatibility:
```
wad://checkin/{venue-uuid}
```

This works with both the app AND fallback web handling.

### Multi-Venue Setup

For Das Wohnzimmer:
1. Create 3-5 NFC stickers
2. Place at: entrance, bar, tables
3. All contain same venue UUID
4. Users can check in from anywhere

### Security

The app validates:
1. Scanned venue ID matches selected venue
2. User is actually at the venue (backend can check distance)
3. Check-in cooldown (can't check in twice within 1 hour)

---

*NFC Implementation Guide - December 26, 2025*
