# 🌙 WiesbadenAfterDark

A complete venue management platform for nightlife & hospitality in Germany.

## Overview

WiesbadenAfterDark consists of two applications:
- **Owner PWA** - Staff & management dashboard for venue operations
- **Customer iOS App** - Guest-facing mobile app for bookings & loyalty

## Tech Stack

| Component | Technology |
|-----------|------------|
| Frontend PWA | React 18 + TypeScript + Vite |
| iOS App | Swift + SwiftUI |
| Backend | Supabase (PostgreSQL + Auth + Realtime + Storage) |
| Styling | Tailwind CSS with custom dark theme |
| Deployment | Vercel (PWA) + App Store (iOS) |

## Features

### Owner PWA
- **Dashboard** - Real-time analytics & venue overview
- **Shifts** - Employee clock in/out with PIN authentication
- **Tasks** - Assignment & approval workflow with photo proof
- **Inventory** - Stock tracking & transfer management
- **Analytics** - Revenue, labor costs, top products
- **Push Notifications** - Real-time alerts via Supabase Realtime

### Customer iOS App
- **Events** - Browse upcoming events with tickets
- **Bookings** - Reserve tables with party size
- **Check-in** - QR code for loyalty points
- **Loyalty** - Points, levels, rewards

## Quick Start

### Owner PWA
```bash
cd owner-pwa
npm install
cp .env.example .env.local  # Add Supabase credentials
npm run dev
```

### iOS App
```bash
cd WiesbadenAfterDark-iOS
open WiesbadenAfterDark.xcodeproj
# Configure Supabase URL in Config.swift
# Run on simulator or device
```

## Environment Variables

### PWA (.env.local)
```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_anon_key
VITE_VAPID_PUBLIC_KEY=your_vapid_key  # For push notifications
```

## Database Schema

See [docs/API.md](docs/API.md) for complete schema.

### Core Tables
- `venues` - Venue information
- `employees` - Staff with roles & PINs
- `shifts` - Clock in/out records
- `tasks` - Task assignments
- `inventory_items` - Stock levels
- `events` - Upcoming events
- `products` - Menu items

## Deployment

### PWA to Vercel
```bash
cd owner-pwa
vercel --prod
```

### iOS to TestFlight
1. Archive in Xcode
2. Upload to App Store Connect
3. Submit for TestFlight review

## Project Structure

```
WiesbadenAfterDark/
├── owner-pwa/              # React PWA
│   ├── src/
│   │   ├── components/     # Reusable UI
│   │   ├── pages/          # Main views
│   │   ├── services/       # API & notifications
│   │   ├── contexts/       # React contexts
│   │   └── lib/            # Supabase client
│   └── public/             # Static assets & SW
├── WiesbadenAfterDark-iOS/ # Swift iOS app
├── supabase/               # Migrations & functions
└── docs/                   # Documentation
```

## License

Private - EA Solutions

## Author

Ali - EA Solutions
