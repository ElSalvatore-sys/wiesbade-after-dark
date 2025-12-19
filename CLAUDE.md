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

---

## 🎯 KNOWLEDGE BASE REFERENCE

### CRITICAL: Search Before Implementing!

Before implementing ANY new feature, search the competitive research:

### Archon RAG Queries
```bash
archon:rag_search_knowledge_base("booking reservation flow")
archon:rag_search_knowledge_base("loyalty points rewards")
archon:rag_search_knowledge_base("German gastronomy payment")
archon:rag_search_knowledge_base("nightlife club booking")
archon:rag_search_knowledge_base("venue dashboard analytics")
```

### Research Files: ~/knowledge-base-research/companies/
- 01-booking-systems: OpenTable, Resy, SevenRooms, TheFork
- 02-nightlife: Resident Advisor, Discotech, Dice, Xceed, Fever
- 04-loyalty-programs: Punchh, Fivestars
- 06-german-specific: Quandoo, Gastrofix, Orderbird, Eventim, Lieferando
- 10-emerging: Partiful, Posh, Yelp, Foursquare

### Key Best Practices
| Feature | Best Practice | Source |
|---------|---------------|--------|
| No-show reduction | YUMS points | TheFork |
| Anti-scalping | Waitlist system | Dice |
| German compliance | GoBD, TSE | Gastrofix |
| Social virality | Invite-first | Partiful |
| Loyalty | 1000pts=€15 | Quandoo |

### Full Report: ~/knowledge-base-research/WiesbadenAfterDark_Competitive_Research_Summary.docx

---

## 🎯 KNOWLEDGE BASE - SEARCH BEFORE IMPLEMENTING!

### Archon Project
- **Project ID:** `c027b69c-949e-41fe-a3c2-efc659af668d`
- **View:** http://localhost:3737

### RAG Search Commands
```bash
# German market (payments, compliance, POS)
archon:rag_search_knowledge_base("german-market payment compliance")

# Booking flow UX patterns
archon:rag_search_knowledge_base("booking flow UX conversion")

# Loyalty & rewards systems
archon:rag_search_knowledge_base("loyalty points tier gamification")

# Nightlife/club features
archon:rag_search_knowledge_base("nightlife club table vip booking")

# Venue owner dashboard
archon:rag_search_knowledge_base("venue dashboard analytics reporting")

# No-show prevention
archon:rag_search_knowledge_base("no-show reduction YUMS points")

# Mobile app features
archon:rag_search_knowledge_base("mobile app push notifications checkin")
```

### Document IDs (Direct Access)
| Category | Doc ID |
|----------|--------|
| German Market | `cdf2b15c-0358-4de8-b382-34445b9626bc` |
| Nightlife | `c24c10a2-d4ab-42ae-8210-360aa2ea2179` |
| Booking Systems | `95b8dcf2-0019-4ae1-bf6e-7a216a8a75ef` |
| Loyalty Programs | `44f65a12-3776-4e99-b113-fbadda301d07` |
| Social/Emerging | `0e9d8956-8fe9-4f91-b8ad-6498d904e97a` |
| **MASTER** | `40edd5b3-fa71-4e44-b539-64763d375be1` |
| Booking Flow UX | `b136ff2b-668c-4a49-aaeb-6e3f34f721fc` |
| Venue Dashboard | `b990cfa8-a69a-4bd1-9268-4099f0bbc168` |
| German Compliance | `e3833cb3-7e2f-401b-b221-8dda1cc114b9` |
| Mobile App | `def418b2-8f4f-41d6-96fc-1ca4353eedac` |

### Quick Best Practices
| Feature | Best Practice | Source |
|---------|---------------|--------|
| No-shows | YUMS loyalty points | TheFork |
| Anti-scalping | EVENTIM Pass + phone verify | Eventim |
| Lowest fees | 3% commission | Xceed |
| VIP tables | Interactive map + deposits | Discotech |
| Viral growth | Invite-first model | Partiful |
| German compliance | GoBD, DATEV, TSE | Gastrofix |
| Loyalty cashback | 1000pts = €15 | Quandoo |

### Local Research Files
`~/knowledge-base-research/companies/` (20 files, 13,482 lines)
