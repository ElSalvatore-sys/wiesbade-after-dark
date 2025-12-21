# Owner PWA

Staff & management dashboard for WiesbadenAfterDark venues.

## Setup

```bash
npm install
cp .env.example .env.local
npm run dev
```

## Environment Variables

```
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
VITE_VAPID_PUBLIC_KEY=BK...  # Optional, for push notifications
```

## Features

### Dashboard
Real-time overview of venue operations:
- Active shifts count
- Pending tasks
- Low stock alerts
- Today's revenue

### Shifts
Employee time tracking:
- PIN-based clock in/out
- Break time recording
- Overtime warnings
- Shift history

### Tasks
Task management workflow:
- Create & assign tasks
- Priority levels (low, medium, high, urgent)
- Photo proof uploads
- Manager approval

### Inventory
Stock management:
- Storage & bar quantities
- Transfer between locations
- Low stock alerts
- Category filtering

### Analytics
Business insights:
- Revenue trends
- Labor costs
- Top selling products
- Customer analytics

### Push Notifications
Real-time alerts via Supabase Realtime:
- Task assignments
- Task completions (for managers)
- Shift clock in/out
- Low stock warnings

## Project Structure

```
src/
├── components/
│   ├── layout/         # DashboardLayout, Navigation
│   ├── shifts/         # ShiftCard, PinPad
│   ├── tasks/          # TaskCard, TaskForm
│   └── NotificationSettings.tsx
├── pages/
│   ├── Dashboard.tsx
│   ├── Shifts.tsx
│   ├── Tasks.tsx
│   ├── Inventory.tsx
│   └── ...
├── services/
│   ├── pushNotifications.ts  # Push + Realtime
│   ├── notifications.ts      # Service worker
│   └── supabaseApi.ts        # API helpers
├── contexts/
│   └── AuthContext.tsx       # Auth state
└── lib/
    └── supabase.ts           # Supabase client
```

## Build & Deploy

```bash
npm run build
npm run preview  # Test locally

# Deploy to Vercel
vercel --prod
```

## PWA Features

- Installable on mobile/desktop
- Offline support via service worker
- Push notifications
- Background sync for offline actions

## Tech Stack

- Vite + React 18 + TypeScript
- Tailwind CSS with custom dark theme
- Supabase (PostgreSQL + Auth + Realtime + Storage)
- Web Push API with VAPID keys
