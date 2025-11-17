# Home Feature - Documentation

## 📱 Purpose

The Home screen is the main landing page after user login. It displays:
- **Points Balance** - User's total points across all venues
- **Referral Card** - User's referral code and earnings
- **Recent Activity** - Last few point transactions
- **Upcoming Events** - Events happening today or this week
- **Special Offers** - Inventory offers with bonus points
- **Nearby Venues** - Venues close to user's location
- **Quick Actions** - Buttons for Check-in, Wallet, History, Referrals

---

## 📁 File Structure

```
Features/Home/
├── README.md (this file)
├── ViewModels/
│   └── HomeViewModel.swift          # Data management and business logic
├── Views/
│   └── HomeView.swift                # Main home screen UI
└── Components/
    ├── EventHighlightCard.swift      # Event card in horizontal scroll
    ├── InventoryOfferCard.swift      # Product offer card
    ├── ReferralExplanationView.swift # How referrals work section
    └── (other component files)
```

---

## 🎯 Key Components

### 1. **HomeViewModel.swift**

**Location:** `Features/Home/ViewModels/HomeViewModel.swift`

**Purpose:** Manages all data loading and state for the Home screen.

#### Important Properties:

```swift
// Data
var venues: [Venue] = []              // All venues in the system
var todayEvents: [Event] = []         // Events happening today
var upcomingEvents: [Event] = []      // Events within next 7 days
var inventoryOffers: [Product] = []   // Products with bonus points
var memberships: [VenueMembership] = [] // User's venue memberships
var totalPoints: Int = 0              // Sum of all venue points

// UI State
var isLoading: Bool = false           // Shows loading indicator
var isRefreshing: Bool = false        // Pull-to-refresh state
var errorMessage: String?             // Error to display to user
```

#### Key Methods:

```swift
// Load all home data (called when view appears)
func loadHomeData(userId: UUID) async

// Refresh data (called on pull-to-refresh)
func refresh(userId: UUID) async

// Get venue for an event or product
func venue(for event: Event) -> Venue?
func venue(for product: Product) -> Venue?
```

#### How to Modify:

**Change what data loads on Home:**
- Edit `loadHomeData()` method in HomeViewModel.swift:712-96

**Change event filtering (e.g., show more/fewer events):**
- Edit `categorizeEvents()` method in HomeViewModel.swift:134-159
- Adjust `.prefix(3)` values in HomeView.swift

**Change points calculation:**
- Total points calculated in `loadMemberships()` in HomeViewModel.swift:244
- Formula: `totalPoints = memberships.reduce(0) { $0 + $1.pointsBalance }`

---

### 2. **HomeView.swift**

**Location:** `Features/Home/Views/HomeView.swift`

**Purpose:** Main UI layout for Home screen with all sections.

#### Structure:

The Home screen is a `ScrollView` containing a vertical stack of sections:

1. **Active Bonuses Banner** - Lines 43-46 (only shows if hasActiveBonuses)
2. **Points Balance Card** - Lines 49-52 (only shows if totalPoints > 0)
3. **Referral Card** - Lines 55-66
4. **Recent Transactions** - Lines 68-72 (only shows if has transactions)
5. **Event Highlights** - Lines 74 (`eventHighlightsSection`)
6. **Inventory Offers** - Lines 77 (`inventoryOffersSection`)
7. **Nearby Venues** - Lines 80 (`nearbyVenuesSection`)
8. **Quick Actions** - Lines 83-86 (`quickActionsSection`)

#### How to Modify:

**Change Points Display:**
- Location: `pointsBalanceCard` in HomeView.swift:195-284
- **Points number:** Line 204 - `Text("\(homeViewModel.totalPoints)")`
- **Euro conversion:** Line 220 - `Text("= €\(homeViewModel.totalPoints) value")`
  - ⚠️ **CRITICAL:** This is 1:1 ratio currently showing. Should be 10:1 (points ÷ 10 = euros)
  - **TO FIX:** Change to `"= €\(homeViewModel.totalPoints / 10) value"`
- **Card colors:** Lines 257-265 (gradient colors)
- **Card size/padding:** Line 255 (padding), Line 266 (corner radius)

**Add New Section:**
1. Create your section view (e.g., `private var mySectionView: some View { ... }`)
2. Add it to the VStack in body (lines 41-88)
3. Add `.padding(.horizontal)` for consistent margins
4. Example:
   ```swift
   // My New Section
   myNewSectionView
       .padding(.horizontal)
   ```

**Reorder Sections:**
- Simply move the section code up/down in the VStack (lines 41-88)
- Example: Move Quick Actions above Referral Card

**Change Number of Events Shown:**
- Location: `eventHighlightsSection` in HomeView.swift:288-370
- Line 319: `.prefix(3)` - change 3 to show more/fewer today events
- Line 336: `.prefix(3)` - change 3 to show more/fewer upcoming events

**Change Number of Offers Shown:**
- Location: `inventoryOffersSection` in HomeView.swift:373-441
- Line 408: `.prefix(5)` - change 5 to show more/fewer offers

**Modify Quick Action Buttons:**
- Location: `quickActionsSection` in HomeView.swift:503-602
- Each button defined with: `quickActionButton(icon:title:color:action:)`
- To add new button:
   ```swift
   quickActionButton(
       icon: "star.fill",           // SF Symbol icon name
       title: "My Button",           // Button label
       color: .orange                // Button color
   ) {
       HapticManager.shared.light()  // Haptic feedback
       // Your action here
   }
   ```

**Change Points Card Appearance:**
- Background gradient: Lines 256-265
- Border gradient: Lines 268-278
- Shadow: Lines 279-283
- Font sizes: Lines 206 (points), 220 (euro), 198 (label)

---

## 🎨 Styling Guide

### Colors Used:
- **Points Card:**
  - Background: Orange gradient (`Color.orange.opacity(0.12)` → `Color.orange.opacity(0.05)`)
  - Border: Orange/Gold gradient
  - Text: Orange for points number, Gold for star icon

- **Referral Card:**
  - Background: Blue opacity (`Color.blue.opacity(0.1)`)
  - Border: Blue (`Color.blue.opacity(0.3)`)
  - Text: Blue for referral code

- **Quick Actions:**
  - Check-In: Purple
  - My Passes: Blue
  - History: Green
  - Refer Friend: Orange

### Spacing:
- Between sections: 24pt (line 41 `VStack(spacing: 24)`)
- Card padding: 16-24pt
- Horizontal margins: `.padding(.horizontal)` = 16pt default

### Corner Radius:
- Points Card: 20pt
- Other Cards: 16pt (Theme.CornerRadius.lg)
- Quick Action Buttons: 16pt

---

## 🔧 Common Modification Tasks

### Task 1: Fix Points → Euro Conversion (10:1 Ratio)

**Problem:** Currently showing 1:1 (450 points = €450)
**Should be:** 10:1 (450 points = €45)

**File:** `HomeView.swift`
**Line:** 220

**Change:**
```swift
// BEFORE:
Text("= €\(homeViewModel.totalPoints) value")

// AFTER:
Text("= €\(homeViewModel.totalPoints / 10) value")
```

---

### Task 2: Change How Many Events Show

**File:** `HomeView.swift`
**Lines:** 319, 336

**Change:**
```swift
// Show 5 events instead of 3
ForEach(homeViewModel.todayEvents.prefix(5), id: \.id) { event in
```

---

### Task 3: Hide Referral Card

**File:** `HomeView.swift`
**Lines:** 55-66

**Option A - Comment out:**
```swift
// Referral Card (Prominent)
/*
if let user = authViewModel.authState.user {
    VStack(spacing: 12) {
        ReferralCard(...)
        ReferralExplanationView()
    }
    .padding(.horizontal)
}
*/
```

**Option B - Add condition:**
```swift
// Only show if user has referrals
if let user = authViewModel.authState.user, user.totalReferrals > 0 {
    VStack(spacing: 12) {
        ReferralCard(...)
    }
    .padding(.horizontal)
}
```

---

### Task 4: Add New Quick Action Button

**File:** `HomeView.swift`
**Location:** Inside `quickActionsSection` LazyVGrid (line 541)

**Code to add:**
```swift
// My New Action
quickActionButton(
    icon: "star.fill",              // Choose SF Symbol icon
    title: "My Action",              // Button text
    color: .purple                   // Button color
) {
    HapticManager.shared.medium()    // Haptic feedback
    // Your action code here
    print("Button tapped!")
}
```

**Available SF Symbol icons:** https://developer.apple.com/sf-symbols/

---

### Task 5: Change Points Card Colors

**File:** `HomeView.swift`
**Location:** `pointsBalanceCard` computed property

**Background Gradient (lines 256-265):**
```swift
.background(
    LinearGradient(
        colors: [
            Color.purple.opacity(0.12),  // Change: orange → purple
            Color.purple.opacity(0.05)   // Change: orange → purple
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)
```

**Border Gradient (lines 268-278):**
```swift
.strokeBorder(
    LinearGradient(
        colors: [
            Color.purple.opacity(0.3),   // Change: orange → purple
            Color.pink.opacity(0.2)      // Change: gold → pink
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    ),
    lineWidth: 2
)
```

---

### Task 6: Make Points Number Bigger/Smaller

**File:** `HomeView.swift`
**Line:** 206

**Change font size:**
```swift
// Current (64pt):
.font(.system(size: 64, weight: .bold, design: .rounded))

// Bigger (80pt):
.font(.system(size: 80, weight: .bold, design: .rounded))

// Smaller (48pt):
.font(.system(size: 48, weight: .bold, design: .rounded))
```

---

### Task 7: Change Loading Message

**File:** `HomeView.swift`
**Line:** 114

**Change:**
```swift
// Current:
Text("Loading your points...")

// New message:
Text("Getting everything ready...")
```

---

### Task 8: Add Animation to Points Card

**File:** `HomeView.swift`
**Location:** After `pointsBalanceCard` definition (line 284)

**Add scale effect on appear:**
```swift
private var pointsBalanceCard: some View {
    VStack(spacing: 12) {
        // ... existing card code ...
    }
    // ... existing modifiers ...
    .scaleEffect(animationScale)               // ADD THIS
    .onAppear {                                // ADD THIS
        withAnimation(.spring(response: 0.6)) {
            animationScale = 1.0
        }
    }
}

// At top of HomeView struct, add state:
@State private var animationScale: CGFloat = 0.8
```

---

## 📊 Data Flow

### How Home Data Loads:

1. **User opens app** → Auth succeeds → Navigate to HomeView
2. **HomeView appears** → `.task` modifier triggers (line 100)
3. **HomeViewModel.loadHomeData()** called with userId
4. **ViewModel loads:**
   - Venues from API
   - Events for all venues
   - Inventory offers from venues
   - User's memberships from all venues
   - Recent transactions for user
5. **Data propagates to UI** → Components re-render
6. **Loading completes** → `isLoading = false` → Loading indicator hides

### Pull-to-Refresh Flow:

1. **User pulls down** on Home screen
2. **`.refreshable`** modifier triggers (line 95)
3. **HomeViewModel.refresh()** called
4. **All data reloads** (calls `loadHomeData()` internally)
5. **UI updates** with fresh data

---

## 🐛 Troubleshooting

### Points not showing:
- Check `homeViewModel.totalPoints > 0` (line 49)
- Check `HomeViewModel.loadMemberships()` is calculating total correctly

### Events not showing:
- Check `homeViewModel.todayEvents` and `upcomingEvents` arrays
- Check `HomeViewModel.categorizeEvents()` logic
- Verify venues have events in mock data

### Loading indicator stuck:
- Check `isLoading` flag is set to `false` in HomeViewModel
- Check for errors in `loadHomeData()` - error should set `isLoading = false`

### Referral card missing:
- Check `authViewModel.authState.user` is not nil
- Check user has `referralCode` property set

### Quick actions not working:
- Add breakpoint or print in button action
- Check if sheet/navigation is triggered correctly

### Euro conversion wrong:
- See **Task 1** above to fix 10:1 ratio

---

## 🔗 Related Files

**Models:**
- `Core/Models/User.swift` - User data structure
- `Core/Models/Venue.swift` - Venue data structure
- `Core/Models/VenueMembership.swift` - Points balance per venue
- `Core/Models/Event.swift` - Event data structure
- `Core/Models/PointTransaction.swift` - Transaction history

**Components:**
- `Shared/Components/ReferralCard.swift` - Referral code display
- `Features/Home/Components/EventHighlightCard.swift` - Event card UI
- `Features/Home/Components/InventoryOfferCard.swift` - Offer card UI

**Services:**
- `Core/Services/VenueService.swift` - API calls for venue data
- `Core/Utilities/HapticManager.swift` - Haptic feedback utility

**View Models:**
- `Features/Onboarding/ViewModels/AuthenticationViewModel.swift` - User auth state

---

## 💡 Best Practices

1. **Always use HomeViewModel for data** - Don't directly manipulate data in views
2. **Keep computed properties in ViewModel** - Business logic belongs in ViewModel
3. **Use @State sparingly in HomeView** - Mostly for UI-only state (sheet showing, etc.)
4. **Test on multiple iPhone sizes** - SE, 15 Pro, 15 Pro Max
5. **Verify dark mode** - App enforces dark mode always
6. **Add haptic feedback** - Use `HapticManager.shared.light/medium/heavy()`
7. **Use existing color theme** - See `Theme.swift` for color palette
8. **Keep animations subtle** - Spring animations with 0.2-0.6 response time

---

## 📝 TODOs / Known Issues

- [ ] **CRITICAL:** Fix euro conversion from 1:1 to 10:1 ratio (see Task 1)
- [x] Add loading indicator (completed)
- [x] Add error handling with retry (completed)
- [x] Add haptic feedback to quick actions (completed)
- [x] Add animations to buttons (completed)
- [ ] Consider adding skeleton loaders for cards while loading
- [ ] Add refresh timestamp ("Updated 2 minutes ago")

---

## 🎓 Learning Resources

**SwiftUI Documentation:**
- [SwiftUI Views](https://developer.apple.com/documentation/swiftui/views)
- [Observable Macro](https://developer.apple.com/documentation/observation)
- [Async/Await](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

**SF Symbols:**
- [SF Symbols App](https://developer.apple.com/sf-symbols/) - Browse all icons

**Colors:**
- Use Xcode color picker to find hex codes
- Test accessibility with Color Contrast tool

---

## 📞 Support

If you need help modifying the Home feature:

1. **Check this README first** - Most common tasks documented above
2. **Check inline comments** in HomeView.swift and HomeViewModel.swift
3. **Test in Simulator** - Xcode → Product → Run (⌘R)
4. **Check console** - Xcode Console shows debug prints from ViewModel

---

**Last Updated:** 2025-11-17
**Version:** 1.0
**Maintained by:** EA Solutions
