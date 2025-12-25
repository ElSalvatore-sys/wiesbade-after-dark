#!/bin/bash

# ============================================
# BOOKING CONFIRMATION EMAIL TEST SCRIPT
# ============================================

SUPABASE_URL="https://yyplbhrqtaeyzmcxpfli.supabase.co"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5cGxiaHJxdGFleXptY3hwZmxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NTMzMjcsImV4cCI6MjA4MDQyOTMyN30.qY10_JBCACxptGnrqS_ILhWsNsmMKgEitaXEtViBRQc"

echo "============================================"
echo "BOOKING CONFIRMATION EMAIL TEST"
echo "============================================"
echo ""

# Step 1: Get venue ID
echo "Step 1: Getting venue ID..."
VENUE_RESPONSE=$(curl -s "${SUPABASE_URL}/rest/v1/venues?select=id,name&limit=1" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}")

VENUE_ID=$(echo $VENUE_RESPONSE | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
VENUE_NAME=$(echo $VENUE_RESPONSE | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$VENUE_ID" ]; then
  echo "❌ No venue found! Creating test venue..."
  # Create a test venue if none exists
  curl -s "${SUPABASE_URL}/rest/v1/venues" \
    -X POST \
    -H "apikey: ${ANON_KEY}" \
    -H "Authorization: Bearer ${ANON_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Test Venue",
      "address": "Test Address",
      "city": "Wiesbaden",
      "email": "test@venue.com"
    }'

  VENUE_RESPONSE=$(curl -s "${SUPABASE_URL}/rest/v1/venues?select=id,name&limit=1" \
    -H "apikey: ${ANON_KEY}" \
    -H "Authorization: Bearer ${ANON_KEY}")

  VENUE_ID=$(echo $VENUE_RESPONSE | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
  VENUE_NAME=$(echo $VENUE_RESPONSE | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
fi

echo "✅ Venue ID: $VENUE_ID"
echo "   Venue Name: $VENUE_NAME"
echo ""

# Step 2: Create test booking
echo "Step 2: Creating test booking..."
BOOKING_DATE=$(date -v+3d +%Y-%m-%d 2>/dev/null || date -d "+3 days" +%Y-%m-%d)

BOOKING_RESPONSE=$(curl -s "${SUPABASE_URL}/rest/v1/bookings" \
  -X POST \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d "{
    \"venue_id\": \"${VENUE_ID}\",
    \"guest_name\": \"Ali Test\",
    \"guest_email\": \"ali@easolutions.com\",
    \"guest_phone\": \"+49123456789\",
    \"date\": \"${BOOKING_DATE}\",
    \"time\": \"19:00\",
    \"guest_count\": 4,
    \"status\": \"pending\",
    \"table_number\": 12,
    \"special_requests\": \"Fensterplatz, wenn möglich - TEST BOOKING\"
  }")

BOOKING_ID=$(echo $BOOKING_RESPONSE | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$BOOKING_ID" ]; then
  echo "❌ Failed to create booking"
  echo "Response: $BOOKING_RESPONSE"
  exit 1
fi

echo "✅ Booking created: $BOOKING_ID"
echo "   Guest: Ali Test <ali@easolutions.com>"
echo "   Date: $BOOKING_DATE at 19:00"
echo "   Guests: 4 people, Table 12"
echo ""

# Step 3: Test Edge Function - ACCEPTED email
echo "Step 3: Testing Edge Function (ACCEPTED email)..."
echo "Calling: ${SUPABASE_URL}/functions/v1/send-booking-confirmation"
echo ""

ACCEPTED_RESPONSE=$(curl -s "${SUPABASE_URL}/functions/v1/send-booking-confirmation" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -d "{\"booking_id\": \"${BOOKING_ID}\", \"action\": \"accepted\"}")

echo "Response:"
echo "$ACCEPTED_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$ACCEPTED_RESPONSE"
echo ""

# Check if successful
if echo "$ACCEPTED_RESPONSE" | grep -q '"success":true'; then
  echo "✅ Edge Function executed successfully"
elif echo "$ACCEPTED_RESPONSE" | grep -q 'email_pending'; then
  echo "⚠️  Email logged for manual sending (SMTP not configured)"
else
  echo "❌ Edge Function failed"
fi
echo ""

# Step 4: Wait a moment then check audit logs
echo "Step 4: Checking audit logs..."
sleep 2

AUDIT_RESPONSE=$(curl -s "${SUPABASE_URL}/rest/v1/audit_logs?select=*&order=created_at.desc&limit=5" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}")

echo "$AUDIT_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$AUDIT_RESPONSE"
echo ""

# Step 5: Check if confirmation_sent_at was updated
echo "Step 5: Checking booking confirmation timestamp..."
BOOKING_CHECK=$(curl -s "${SUPABASE_URL}/rest/v1/bookings?id=eq.${BOOKING_ID}&select=id,confirmation_sent_at" \
  -H "apikey: ${ANON_KEY}" \
  -H "Authorization: Bearer ${ANON_KEY}")

echo "$BOOKING_CHECK" | python3 -m json.tool 2>/dev/null || echo "$BOOKING_CHECK"
echo ""

# Step 6: Test REJECTED email
echo "Step 6: Testing REJECTED email..."
REJECTED_RESPONSE=$(curl -s "${SUPABASE_URL}/functions/v1/send-booking-confirmation" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -d "{\"booking_id\": \"${BOOKING_ID}\", \"action\": \"rejected\"}")

echo "Response:"
echo "$REJECTED_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$REJECTED_RESPONSE"
echo ""

# Step 7: Test REMINDER email
echo "Step 7: Testing REMINDER email..."
REMINDER_RESPONSE=$(curl -s "${SUPABASE_URL}/functions/v1/send-booking-confirmation" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ANON_KEY}" \
  -d "{\"booking_id\": \"${BOOKING_ID}\", \"action\": \"reminder\"}")

echo "Response:"
echo "$REMINDER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$REMINDER_RESPONSE"
echo ""

echo "============================================"
echo "TEST SUMMARY"
echo "============================================"
echo ""
echo "Booking ID: $BOOKING_ID"
echo "Venue: $VENUE_NAME ($VENUE_ID)"
echo "Guest Email: ali@easolutions.com"
echo ""
echo "Next Steps:"
echo "1. Check ali@easolutions.com inbox for emails"
echo "2. Review audit_logs table in Supabase"
echo "3. If no emails arrived, configure SMTP in Supabase Dashboard"
echo ""
echo "Supabase Dashboard:"
echo "https://supabase.com/dashboard/project/yyplbhrqtaeyzmcxpfli"
echo ""
echo "============================================"
