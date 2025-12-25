# WiesbadenAfterDark - Testing Guide

## Quick Start

```bash
# Run all feature tests
./TEST_ALL_FEATURES.sh
```

## What Gets Tested

### 1. Database Tables
- **venues** - Nightlife venue information
- **employees** - Staff member records
- **shifts** - Employee shift schedules
- **tasks** - Task management system
- **inventory_items** - Inventory tracking
- **bookings** - Customer reservations
- **events** - Venue events
- **audit_logs** - System audit trail

### 2. Edge Functions
- **verify-pin** - Employee PIN authentication
- **set-pin** - PIN creation/update
- **transactions** - Financial transactions API
- **venues** - Venue data API
- **events** - Events data API
- **send-booking-confirmation** - Email notifications

### 3. Storage
- **Storage API** - File storage system
- **Buckets** - photos, documents

### 4. Data Quality
- No placeholder data validation
- Demo data detection
- Data structure verification

## Test Results

Current Status: **100% PASS** (21/21 tests)

See `TEST_RESULTS_SUMMARY.md` for detailed results.

## Test Configuration

The test script uses:
- **Base URL:** https://yyplbhrqtaeyzmcxpfli.supabase.co
- **API Key:** Auto-updated (managed via Supabase MCP)
- **Timeout:** 60 seconds per test suite

## Updating Tests

### Adding New Table Tests

Edit `TEST_ALL_FEATURES.sh`:

```bash
TABLES=("venues" "employees" "shifts" "tasks" "inventory_items" "bookings" "events" "audit_logs" "your_new_table")
```

### Adding New Edge Function Tests

```bash
# Add after line 186 in section 2
result=$(test_edge_function "your-function-name" "GET")
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
if [[ "$http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
    test_item "Edge Function 'your-function-name' responding" "PASS"
else
    test_item "Edge Function 'your-function-name' responding" "HTTP $http_code"
fi
```

### Adding Data Quality Checks

```bash
# Add after line 316 in section 5
your_check_response=$(curl -s -X GET \
    "${BASE_URL}/rest/v1/your_table?select=field" \
    -H "apikey: ${API_KEY}" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json")

if echo "$your_check_response" | grep -q "expected_pattern"; then
    test_item "Your custom check" "PASS"
else
    test_item "Your custom check" "Did not find expected pattern"
fi
```

## Troubleshooting

### API Key Expired

If you see "Invalid API key" errors:

1. Get new key from Supabase MCP:
```bash
# In Claude Code
supabase:get_publishable_keys()
```

2. Update line 10 in TEST_ALL_FEATURES.sh:
```bash
API_KEY="your-new-api-key-here"
```

### Edge Function 500 Errors

Check function logs:
```bash
# In Claude Code
supabase:get_logs(service="edge-function")
```

### Storage Bucket Failures

Create buckets if they don't exist:
```sql
-- In Supabase SQL Editor
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('photos', 'photos', true),
  ('documents', 'documents', false);
```

## CI/CD Integration

Add to GitHub Actions workflow:

```yaml
- name: Run Feature Tests
  run: |
    chmod +x TEST_ALL_FEATURES.sh
    ./TEST_ALL_FEATURES.sh
```

## Local Development

For local Supabase instance:

```bash
# Update BASE_URL in script
BASE_URL="http://localhost:54321"
API_KEY="your-local-anon-key"
```

## Test Frequency

- **Before Deployment:** Always run full test suite
- **After Schema Changes:** Run database table tests
- **After Function Updates:** Run edge function tests
- **Daily/Weekly:** Automated CI/CD runs

## Related Files

- `TEST_ALL_FEATURES.sh` - Main test script
- `TEST_RESULTS_SUMMARY.md` - Latest test results
- `supabase/migrations/` - Database schema
- `supabase/functions/` - Edge function code

---

**Last Updated:** December 25, 2025
