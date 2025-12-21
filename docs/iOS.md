# iOS App Documentation

## Overview

Customer-facing iOS app for WiesbadenAfterDark venues.

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## Setup

1. Open `WiesbadenAfterDark.xcodeproj`
2. Configure Supabase URL in `Config.swift`
3. Run on simulator or device

## Features

### Events
- Browse upcoming events
- Event details with photos
- Ticket purchasing (future)

### Bookings
- Table reservations
- Party size selection
- Special requests

### Check-in
- QR code scanning
- Loyalty points earning
- Visit history

### Profile
- Loyalty level display
- Points balance
- Reward redemption

## Architecture

SwiftUI + MVVM pattern:

```
WiesbadenAfterDark/
├── Views/
│   ├── EventsView.swift
│   ├── BookingsView.swift
│   └── ProfileView.swift
├── ViewModels/
│   ├── EventsViewModel.swift
│   └── BookingsViewModel.swift
├── Models/
│   ├── Event.swift
│   └── Booking.swift
├── Services/
│   └── SupabaseService.swift
└── Config.swift
```

## Supabase Integration

The iOS app connects to the same Supabase backend:
- Events from Edge Functions
- Bookings saved to database
- Check-ins record loyalty points

## Future Features

- [ ] Push notifications (APNs)
- [ ] Apple Wallet passes
- [ ] Widgets for upcoming events
- [ ] App Clips for quick check-in
- [ ] Live Activities for event countdown
