#!/bin/bash

echo "🔍 Verifying Bug Fixes - Code Changes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Events - Points Multiplier
echo "✅ TEST 1: Events - Points Multiplier Saved to Backend"
echo "  Checking Events.tsx for points_multiplier field..."

if grep -q "points_multiplier: eventData.pointsMultiplier" src/pages/Events.tsx; then
  echo "  ✓ Update event includes points_multiplier (line ~188)"
else
  echo "  ✗ FAILED: points_multiplier not found in update call"
fi

if grep -q "points_multiplier: eventData.pointsMultiplier || 1" src/pages/Events.tsx; then
  echo "  ✓ Create event includes points_multiplier (line ~208)"
else
  echo "  ✗ FAILED: points_multiplier not found in create call"
fi
echo ""

# Test 2: Bookings - Realtime Subscription
echo "✅ TEST 2: Bookings - Realtime Subscription Added"
echo "  Checking Bookings.tsx for useRealtimeSubscription..."

if grep -q "import.*useRealtimeSubscription" src/pages/Bookings.tsx; then
  echo "  ✓ Import statement added"
else
  echo "  ✗ FAILED: useRealtimeSubscription not imported"
fi

if grep -q "useRealtimeSubscription" src/pages/Bookings.tsx && grep -q "table: 'bookings'" src/pages/Bookings.tsx; then
  echo "  ✓ Hook integrated with 'bookings' table subscription"
else
  echo "  ✗ FAILED: Hook not properly integrated"
fi
echo ""

# Test 3: Dashboard - Real Bookings API
echo "✅ TEST 3: Dashboard - Real Bookings Data"
echo "  Checking Dashboard.tsx for getBookingsSummary()..."

if grep -q "supabaseApi.getBookingsSummary()" src/pages/Dashboard.tsx; then
  echo "  ✓ getBookingsSummary() API call added"
else
  echo "  ✗ FAILED: getBookingsSummary() not called"
fi

if grep -q "todaysBookings: bookingsSummary.total" src/pages/Dashboard.tsx; then
  echo "  ✓ Real booking count used (not hardcoded)"
else
  echo "  ✗ FAILED: Booking count still hardcoded"
fi
echo ""

# Test 4: Dashboard - Real Events API  
echo "✅ TEST 4: Dashboard - Real Events Data"
echo "  Checking Dashboard.tsx for getEvents()..."

if grep -q "api.getEvents" src/pages/Dashboard.tsx; then
  echo "  ✓ api.getEvents() API call added"
else
  echo "  ✗ FAILED: getEvents() not called"
fi

if grep -q "activeEvents: todayEvents.length" src/pages/Dashboard.tsx; then
  echo "  ✓ Real event count used (not hardcoded)"
else
  echo "  ✗ FAILED: Event count still hardcoded"
fi
echo ""

# Test 5: Dashboard - Real Activity Feed
echo "✅ TEST 5: Dashboard - Real Activity Feed"
echo "  Checking Dashboard.tsx for getAuditLogs()..."

if grep -q "supabaseApi.getAuditLogs()" src/pages/Dashboard.tsx; then
  echo "  ✓ getAuditLogs() API call added"
else
  echo "  ✗ FAILED: getAuditLogs() not called"
fi

if grep -q "recentActivity.map" src/pages/Dashboard.tsx; then
  echo "  ✓ Dynamic activity feed (not hardcoded array)"
else
  echo "  ✗ FAILED: Activity feed still hardcoded"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Code verification complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
