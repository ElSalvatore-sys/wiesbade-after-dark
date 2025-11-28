# WiesbadenAfterDark - Project Documentation

## Project Status: Ready for App Store Submission

**Last Updated:** November 28, 2025
**Target Launch:** December 6, 2025 (Das Wohnzimmer)

---

## Apps Overview

### 1. iOS User App (WiesbadenAfterDark)
**Location:** `~/Desktop/Projects-2025/WiesbadenAfterDark/WiesbadenAfterDark.xcodeproj`
**Status:** Complete - Ready for testing

**Tech Stack:**
- SwiftUI + Swift 6
- SwiftData for persistence
- Supabase backend
- Railway deployment

**Features:**
- Phone authentication with name input
- Venue discovery with dark theme cards
- Events with filter chips (All, This Week, This Weekend)
- Bookings management
- Community feed (photos, reactions, comments, share)
- Points/rewards system
- Profile with Recent Activity
- Check-in with NFC

**Design System:**
- Background: #09090B (OLED black)
- Cards: #18181B with #27272A border
- Primary: #7C3AED (deep purple)
- Gradient: #8B5CF6 to #EC4899
- Gold: #D4AF37

---

### 2. Owner PWA
**Location:** `~/Desktop/Projects-2025/WiesbadenAfterDark/owner-pwa/`
**Live URL:** https://owner-6xdb541ae-l3lim3d-2348s-projects.vercel.app
**Status:** Deployed

**Tech Stack:**
- Vite + React 19 + TypeScript
- Tailwind CSS v3
- html5-qrcode for barcode scanning

**Features:**
- Dashboard with stats
- Events management (CRUD, image upload, AI placeholder)
- Bookings with split calendar view
- Inventory with barcode scanner
- Push notifications
- PWA installable

**Login:** owner@example.com / password

---

## Recent Changes (Nov 28, 2025)

### iOS App Improvements:
1. Dark theme cards (venues, deals)
2. Name input in onboarding
3. Recent Activity moved to Profile
4. Events filter chips
5. Loading speed 12s to 1.1s
6. Community: photos, reactions, comments, share
7. Tab bar consistent iOS 17/18
8. App icon added (1024x1024)

### Owner PWA:
- Full dashboard
- Events + Bookings + Inventory
- Barcode scanner
- Push notifications
- Deployed to Vercel

---

## TODOs for Later

| Item | Priority | Notes |
|------|----------|-------|
| AI Image API Keys | Medium | DALL-E/Midjourney for event images |
| Auto-Ordering System | High | Automatic stock reordering for owners |
| Splash Screen | Low | Loading animation with logo |
| App Store Screenshots | High | Device mockups for submission |
| Social Sharing Images | Low | Open Graph for marketing |
| Real Supabase Data | High | Replace mock data with production |
| Stripe Integration | High | Payment processing |

---

## Commands

### iOS App
```bash
open ~/Desktop/Projects-2025/WiesbadenAfterDark/WiesbadenAfterDark.xcodeproj
# Select iPhone, Cmd+R to build & run
```

### Owner PWA
```bash
cd ~/Desktop/Projects-2025/WiesbadenAfterDark/owner-pwa
npm run dev    # Development
npm run build  # Production
vercel --prod  # Deploy
```

---

## Git Info

**Branch:** `claude/production-polish-demo-prep-016GJZ4x9y5pcyRkGe7bojqE`
**Repo:** https://github.com/ElSalvatore-sys/wiesbade-after-dark

---

## Backend

**Railway:** https://wiesbaden-after-dark-production.up.railway.app
**Supabase:** Check .env for credentials

---

## First Client

**Das Wohnzimmer** - Wiesbaden
- Bar/Restaurant/Club
- Internal testing: Dec 6-10
- Public launch: Dec 13-15
