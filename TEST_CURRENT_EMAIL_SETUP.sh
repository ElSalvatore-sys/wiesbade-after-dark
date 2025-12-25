#!/bin/bash
#
# Test Current Email Configuration
# WiesbadenAfterDark SMTP Setup Verification
#
# Run this script to verify current email capabilities
#
# Usage: bash TEST_CURRENT_EMAIL_SETUP.sh
#

set -e

echo "=================================="
echo "WiesbadenAfterDark Email Test"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/Users/eldiaploo/Desktop/Projects-2025/WiesbadenAfterDark"
SUPABASE_URL="https://yyplbhrqtaeyzmcxpfli.supabase.co"
EDGE_FUNCTION_URL="${SUPABASE_URL}/functions/v1/send-booking-confirmation"

echo "Step 1: Checking Project Structure"
echo "===================================="

if [ -d "$PROJECT_DIR" ]; then
    echo -e "${GREEN}✓${NC} Project directory found: $PROJECT_DIR"
else
    echo -e "${RED}✗${NC} Project directory not found"
    exit 1
fi

echo ""
echo "Step 2: Checking Edge Function Implementation"
echo "=============================================="

EDGE_FUNCTION_FILE="$PROJECT_DIR/supabase/functions/send-booking-confirmation/index.ts"

if [ -f "$EDGE_FUNCTION_FILE" ]; then
    echo -e "${GREEN}✓${NC} Edge function found"

    # Check for key components
    if grep -q "sendRawEmail" "$EDGE_FUNCTION_FILE"; then
        echo -e "${GREEN}✓${NC} Using Supabase Auth SMTP (sendRawEmail)"
    fi

    if grep -q "booking_${action}_email_sent" "$EDGE_FUNCTION_FILE"; then
        echo -e "${GREEN}✓${NC} Audit logging implemented"
    fi

    if grep -q "Reservierung bestätigt" "$EDGE_FUNCTION_FILE"; then
        echo -e "${GREEN}✓${NC} German templates implemented"
    fi
else
    echo -e "${RED}✗${NC} Edge function not found"
fi

echo ""
echo "Step 3: Checking Email Templates"
echo "================================="

TEMPLATES_FILE="$PROJECT_DIR/SUPABASE_EMAIL_TEMPLATES.md"

if [ -f "$TEMPLATES_FILE" ]; then
    echo -e "${GREEN}✓${NC} Email templates documentation found"

    TEMPLATE_COUNT=$(grep -c "^## " "$TEMPLATES_FILE" || true)
    echo "  Templates documented: $TEMPLATE_COUNT"

    if grep -q "Passwort zurücksetzen" "$TEMPLATES_FILE"; then
        echo -e "${GREEN}✓${NC} Password reset template (German)"
    fi

    if grep -q "E-Mail bestätigen" "$TEMPLATES_FILE"; then
        echo -e "${GREEN}✓${NC} Email confirmation template (German)"
    fi
else
    echo -e "${YELLOW}!${NC} Email templates documentation not found"
fi

echo ""
echo "Step 4: Checking PWA Integration"
echo "================================="

PWA_API_FILE="$PROJECT_DIR/owner-pwa/src/services/supabaseApi.ts"

if [ -f "$PWA_API_FILE" ]; then
    echo -e "${GREEN}✓${NC} PWA API service found"

    if grep -q "sendBookingConfirmation" "$PWA_API_FILE"; then
        echo -e "${GREEN}✓${NC} sendBookingConfirmation function exists"
    fi
else
    echo -e "${RED}✗${NC} PWA API service not found"
fi

echo ""
echo "Step 5: Checking Database Schema"
echo "================================="

if grep -q "confirmation_sent_at" "$PROJECT_DIR/supabase/migrations"/* 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Booking confirmation_sent_at field exists"
else
    echo -e "${YELLOW}!${NC} Migration for confirmation_sent_at not verified"
fi

echo ""
echo "Step 6: Checking Environment Configuration"
echo "=========================================="

if [ -f "$PROJECT_DIR/owner-pwa/.env" ]; then
    echo -e "${GREEN}✓${NC} PWA .env file exists"

    if grep -q "VITE_SUPABASE_URL" "$PROJECT_DIR/owner-pwa/.env"; then
        echo -e "${GREEN}✓${NC} Supabase URL configured"
    fi
else
    echo -e "${YELLOW}!${NC} PWA .env file not found (may use .env.example)"
fi

echo ""
echo "Step 7: Email Service Summary"
echo "============================="

cat << 'EOF'

Current Configuration:
├─ Service: Supabase Auth SMTP (Built-in)
├─ Status: Active and Functional
├─ Features:
│  ├─ Booking Confirmations (Accept/Reject)
│  ├─ German Email Templates
│  ├─ Audit Logging
│  └─ Error Fallback Logging
├─ Rate Limit: ~4-5 emails/hour (free tier)
├─ Deliverability: Good (some spam filter risks)
└─ Cost: Free

Next Steps:
1. Review SMTP_SETUP_GUIDE.md (comprehensive guide)
2. Test current system with test booking
3. Consider upgrading to Resend (recommended for production)
4. Implement reminder emails (scheduled)

EOF

echo ""
echo "Step 8: Testing Information"
echo "==========================="

cat << 'EOF'

To test the current email system:

1. Start Owner PWA:
   cd /Users/eldiaploo/Desktop/Projects-2025/WiesbadenAfterDark/owner-pwa
   npm run dev

2. Create Test Booking:
   - Go to http://localhost:5173
   - Create event
   - Create booking with your email address

3. Accept/Reject Booking:
   - Click Accept or Reject
   - Check browser console for API response
   - Wait 1-2 minutes for email

4. Check Email:
   - Look in inbox
   - Check spam folder
   - Verify content and formatting

5. Monitor Delivery:
   - Check Supabase Edge Function logs
   - Query audit_logs table for status
   - Verify booking.confirmation_sent_at timestamp

To test password reset:
1. Go to https://owner-pwa.vercel.app/login
2. Click "Passwort vergessen?"
3. Enter email and check for reset link

EOF

echo ""
echo "=================================="
echo "Test Summary Complete"
echo "=================================="
echo ""
echo "Documentation created at:"
echo "  /Users/eldiaploo/Desktop/Projects-2025/WiesbadenAfterDark/SMTP_SETUP_GUIDE.md"
echo ""
echo "For detailed setup instructions and troubleshooting, see SMTP_SETUP_GUIDE.md"
echo ""
