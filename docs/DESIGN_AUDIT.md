# WiesbadenAfterDark Design Audit
**Date**: November 27, 2025
**Goal**: Premium nightlife app refresh by Dec 1

---

## Current Issues Found

### 🔴 Critical (Fix First)
1. **111 hardcoded font sizes** - Not using Typography tokens
2. **Debug UI visible** - MyBookingsView shows user IDs
3. **45 hardcoded colors** - Especially in tier-related views

### 🟡 Medium Priority
4. **34 hardcoded padding values** - Should use Theme.Spacing
5. **12 hardcoded corner radii** - Should use Theme.CornerRadius
6. **Inconsistent design token adoption** - ~40% of views

---

## Files Needing Most Work

| File | Issues | Priority |
|------|--------|----------|
| TierBenefitsEditor.swift | 12 colors, 6 fonts | High |
| TierProgressView.swift | 6 colors, 8 fonts | High |
| InventoryOfferCard.swift | 7 fonts | High |
| TierMaintenanceSettings.swift | 9 fonts | High |
| VenueBookingTab.swift | 5 fonts | Medium |
| BonusIndicatorView.swift | 6 colors | Medium |
| BadgeConfigurationView.swift | 5 colors | Medium |
| MyBookingsView.swift | Debug UI | High |

---

## Design Refresh Plan

### Color Palette Update
```swift
// Updated Color+Theme.swift
extension Color {
    // Backgrounds - darker, more OLED-friendly
    static let appBackground = Color(hex: "09090B")      // Was #0F172A
    static let cardBackground = Color(hex: "18181B")     // Was #1E293B
    static let cardBorder = Color(hex: "27272A")         // NEW

    // Primary - deeper, more premium
    static let primary = Color(hex: "7C3AED")            // Was #8B5CF6

    // Gold - more realistic
    static let gold = Color(hex: "D4AF37")               // Was #FCD34D

    // Tier Colors (NEW - centralized)
    static let tierBronze = Color(hex: "CD7F32")
    static let tierSilver = Color(hex: "C0C0C0")
    static let tierGold = Color(hex: "FFD700")
    static let tierPlatinum = Color(hex: "E5E4E2")
    static let tierDiamond = Color(hex: "B9F2FF")
}
```

### Typography Update
```swift
// Updated Typography.swift - bolder headings
static let displayLarge: Font = .system(size: 48, weight: .bold)      // Was .semibold
static let displayMedium: Font = .system(size: 36, weight: .bold)     // Was .semibold
static let titleLarge: Font = .system(size: 28, weight: .bold)        // Was .semibold
```

### Spacing Update
```swift
// Updated Theme.swift - more breathing room
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // NEW - card-specific
    static let cardPadding: CGFloat = 20    // Was using 16
    static let cardGap: CGFloat = 12        // Between cards
    static let sectionGap: CGFloat = 32     // Between sections
}
```

---

## Day-by-Day Implementation

### Day 1 (Nov 27) - AUDIT ✅
- [x] List all views and issues
- [x] Identify hardcoded values
- [x] Create this document

### Day 2 (Nov 28) - DESIGN SYSTEM
- [x] Update Color+Theme.swift with new colors (appBackground, cardBackground, cardBorder, primary, gold)
- [x] Update Typography.swift with bolder weights (already had .bold)
- [x] Update Theme.swift with new spacing tokens (cardPadding, cardGap, sectionGap)
- [x] Add tier colors to design system (done Day 1)

### Day 3 (Nov 29) - HOME + DISCOVER
- [x] HomeView - 28 hardcoded values fixed
- [x] DiscoverView - 8 hardcoded values fixed
- [x] EventsView - already compliant (0 changes needed)

### Day 4 (Nov 30) - EVENTS + BOOKINGS
- [x] EventsView - already compliant (checked)
- [x] MyBookingsView - 7 hardcoded values fixed (debug UI removed Day 1)
- [x] BookingDetailView - 15 hardcoded values fixed

### Day 5 (Dec 1) - POLISH
- [ ] Fix remaining hardcoded values (use find/replace)
- [ ] Add micro-animations
- [ ] Performance audit
- [ ] Test on device

---

## Quick Wins (Do Today)

1. ✅ Remove debug UI from MyBookingsView (18 lines removed)
2. ✅ Add tier colors to Color+Theme.swift (tierBronze, tierSilver, tierGold, tierPlatinum, tierDiamond)
3. ⏳ Update card padding from 16 → 20 (Day 2)

---

## Reference: Current Design Tokens

### Typography (from Typography.swift)
- displayLarge: 48pt
- displayMedium: 36pt
- titleLarge: 28pt
- titleMedium: 24pt
- bodyLarge: 17pt
- bodyMedium: 15pt

### Spacing (from Theme.swift)
- xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48

### Colors (from Color+Theme.swift)
- Primary: #8B5CF6
- Background: #0F172A
- Card: #1E293B
- Text: white / #94A3B8 / #64748B

---
