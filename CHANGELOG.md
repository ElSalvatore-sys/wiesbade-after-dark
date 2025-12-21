# Changelog

All notable changes to WiesbadenAfterDark.

## [1.0.0] - 2024-12-22

### Added
- **Database** - Complete Supabase schema with RLS policies
- **Authentication** - Real user login with role-based access
- **Shifts** - Clock in/out with PIN, break tracking, overtime alerts
- **Tasks** - CRUD with photo uploads, assignment, approval workflow
- **Inventory** - Stock levels, transfers, low stock alerts
- **Analytics** - Revenue, labor costs, top products from real data
- **Push Notifications** - Supabase Realtime integration
  - Task assigned/completed/approved notifications
  - Shift clock in/out alerts for managers
  - Low stock warnings
  - Booking notifications (future)
- **Service Worker** - Offline support, push handling, background sync
- **German Localization** - All notifications in German

### Technical
- React 18 + TypeScript + Vite
- Tailwind CSS dark theme
- Supabase PostgreSQL + Auth + Realtime + Storage
- Web Push API with VAPID keys
- Vercel deployment

### Database Tables
- venues, employees, shifts, tasks
- inventory_items, inventory_transfers
- products, events, push_subscriptions

## [0.9.0] - 2024-12-20

### Added
- Initial PWA structure
- Mock data implementation
- Basic UI components
- Dashboard layout

## [0.8.0] - 2024-12-15

### Added
- iOS app foundation
- SwiftUI views
- Supabase Edge Functions for events/venues
