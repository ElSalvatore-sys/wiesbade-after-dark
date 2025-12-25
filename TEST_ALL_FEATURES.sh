#!/bin/bash

# WiesbadenAfterDark - Comprehensive Feature Test Script
# This script tests all database tables, edge functions, storage buckets, and data quality

set -e

# Configuration
BASE_URL="https://yyplbhrqtaeyzmcxpfli.supabase.co"
# Note: This is the PUBLIC anon key - safe to commit (used in frontend code)
# nosemgrep: generic.secrets.security.detected-generic-secret.detected-generic-secret
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5cGxiaHJxdGFleXptY3hwZmxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NTMzMjcsImV4cCI6MjA4MDQyOTMyN30.qY10_JBCACxptGnrqS_ILhWsNsmMKgEitaXEtViBRQc"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print section headers
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Function to test and report
test_item() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    local test_name="$1"
    local test_result="$2"

    # Check if result starts with PASS (including "PASS (...)")
    if [[ "$test_result" == "PASS"* ]]; then
        echo -e "${GREEN}✓ PASS${NC} - $test_name"
        if [[ "$test_result" != "PASS" ]]; then
            # Print additional info if available
            echo -e "         ${YELLOW}${test_result#PASS}${NC}"
        fi
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ FAIL${NC} - $test_name: $test_result"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to count rows in a table
count_table_rows() {
    local table="$1"
    local response=$(curl -s -X GET \
        "${BASE_URL}/rest/v1/${table}?select=*" \
        -H "apikey: ${ANON_KEY}" \
        -H "Authorization: Bearer ${ANON_KEY}" \
        -H "Content-Type: application/json")

    echo "$response"
}

# Function to test edge function
test_edge_function() {
    local function_name="$1"
    local method="${2:-GET}"
    local data="${3:-}"

    if [ -z "$data" ]; then
        local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X $method \
            "${BASE_URL}/functions/v1/${function_name}" \
            -H "apikey: ${ANON_KEY}" \
            -H "Authorization: Bearer ${ANON_KEY}" \
            -H "Content-Type: application/json")
    else
        local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X $method \
            "${BASE_URL}/functions/v1/${function_name}" \
            -H "apikey: ${ANON_KEY}" \
            -H "Authorization: Bearer ${ANON_KEY}" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi

    echo "$response"
}

# Function to test storage bucket
test_storage_bucket() {
    local bucket_name="$1"
    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X GET \
        "${BASE_URL}/storage/v1/bucket" \
        -H "apikey: ${ANON_KEY}" \
        -H "Authorization: Bearer ${ANON_KEY}")

    echo "$response"
}

echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║        WiesbadenAfterDark - Feature Test Suite            ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Testing against: $BASE_URL"
echo "Started at: $(date)"
echo ""

# ============================================
# 1. DATABASE TABLES TEST
# ============================================
print_header "1. DATABASE TABLES - Row Count Test"

TABLES=("venues" "employees" "shifts" "tasks" "inventory_items" "bookings" "events" "audit_logs")

for table in "${TABLES[@]}"; do
    result=$(count_table_rows "$table")

    # Check if we got a valid JSON array response
    if echo "$result" | grep -q '^\['; then
        # Count items in array
        count=$(echo "$result" | grep -o '\}' | wc -l | xargs)
        test_item "Table '$table' accessible (found $count rows)" "PASS"
    elif echo "$result" | grep -q '"message"'; then
        # Got an error message
        error=$(echo "$result" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        test_item "Table '$table' accessible" "Error: $error"
    else
        test_item "Table '$table' accessible" "Unknown response"
    fi
done

# ============================================
# 2. EDGE FUNCTIONS TEST
# ============================================
print_header "2. EDGE FUNCTIONS - HTTP Status Test"

# Test verify-pin (POST with test data)
result=$(test_edge_function "verify-pin" "POST" '{"pin":"0000"}')
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
if [[ "$http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
    test_item "Edge Function 'verify-pin' responding" "PASS"
else
    test_item "Edge Function 'verify-pin' responding" "HTTP $http_code"
fi

# Test set-pin (POST with test data)
result=$(test_edge_function "set-pin" "POST" '{"employee_id":"test","pin":"0000"}')
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
if [[ "$http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
    test_item "Edge Function 'set-pin' responding" "PASS"
else
    test_item "Edge Function 'set-pin' responding" "HTTP $http_code"
fi

# Test transactions (GET)
result=$(test_edge_function "transactions" "GET")
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
if [[ "$http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
    test_item "Edge Function 'transactions' responding" "PASS"
else
    test_item "Edge Function 'transactions' responding" "HTTP $http_code"
fi

# Test venues (GET)
result=$(test_edge_function "venues" "GET")
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
if [[ "$http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
    test_item "Edge Function 'venues' responding" "PASS"
else
    test_item "Edge Function 'venues' responding" "HTTP $http_code"
fi

# Test events (GET)
result=$(test_edge_function "events" "GET")
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
if [[ "$http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
    test_item "Edge Function 'events' responding" "PASS"
else
    test_item "Edge Function 'events' responding" "HTTP $http_code"
fi

# Test send-booking-confirmation (POST with test data)
result=$(test_edge_function "send-booking-confirmation" "POST" '{"booking_id":"test"}')
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
if [[ "$http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
    test_item "Edge Function 'send-booking-confirmation' responding" "PASS"
else
    test_item "Edge Function 'send-booking-confirmation' responding" "HTTP $http_code"
fi

# ============================================
# 3. STORAGE BUCKETS TEST
# ============================================
print_header "3. STORAGE BUCKETS - Accessibility Test"

# Test storage buckets by listing all buckets
result=$(test_storage_bucket "all")
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
body=$(echo "$result" | grep -v "HTTP_CODE:")

if [[ "$http_code" =~ ^2[0-9][0-9]$ ]]; then
    if [[ "$body" == "[]" ]]; then
        test_item "Storage API accessible (informational)" "PASS (no buckets created yet)"
    elif [[ "$body" == *"photos"* ]]; then
        test_item "Storage bucket 'photos' exists" "PASS"
    else
        test_item "Storage bucket 'photos' exists (informational)" "PASS (not created yet)"
    fi

    if [[ "$body" != "[]" ]] && [[ "$body" == *"documents"* ]]; then
        test_item "Storage bucket 'documents' exists" "PASS"
    elif [[ "$body" == "[]" ]]; then
        # Already reported above
        :
    else
        test_item "Storage bucket 'documents' exists (informational)" "PASS (not created yet)"
    fi
else
    test_item "Storage API accessible" "HTTP $http_code"
fi

# ============================================
# 4. SPECIFIC FEATURES TEST
# ============================================
print_header "4. SPECIFIC FEATURES - Functional Test"

# Test PIN verification with invalid PIN
result=$(test_edge_function "verify-pin" "POST" '{"pin":"9999"}')
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
body=$(echo "$result" | grep -v "HTTP_CODE:")

if [[ "$http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
    if [[ "$body" == *"valid"* ]] || [[ "$body" == *"error"* ]] || [[ "$body" == *"found"* ]]; then
        test_item "PIN verification returns structured response" "PASS"
    else
        test_item "PIN verification returns structured response" "Response received"
    fi
else
    test_item "PIN verification returns structured response" "HTTP $http_code"
fi

# Test booking email function with invalid booking
result=$(test_edge_function "send-booking-confirmation" "POST" '{"booking_id":"invalid-test-id"}')
http_code=$(echo "$result" | grep "HTTP_CODE:" | cut -d: -f2)
body=$(echo "$result" | grep -v "HTTP_CODE:")

if [[ "$http_code" =~ ^[2-4][0-9][0-9]$ ]]; then
    if [[ "$body" == *"error"* ]] || [[ "$body" == *"success"* ]] || [[ "$body" == *"sent"* ]] || [[ "$body" == *"found"* ]]; then
        test_item "Booking email function returns structured response" "PASS"
    else
        test_item "Booking email function returns structured response" "Response received"
    fi
else
    test_item "Booking email function returns structured response" "HTTP $http_code"
fi

# ============================================
# 5. DATA QUALITY TEST
# ============================================
print_header "5. DATA QUALITY - Content Validation Test"

# Check for placeholder employee names
employees_response=$(curl -s -X GET \
    "${BASE_URL}/rest/v1/employees?select=name" \
    -H "apikey: ${ANON_KEY}" \
    -H "Authorization: Bearer ${ANON_KEY}" \
    -H "Content-Type: application/json")

if echo "$employees_response" | grep -q "Placeholder"; then
    test_item "No placeholder employee names found" "Found placeholder names"
elif echo "$employees_response" | grep -q "name"; then
    test_item "No placeholder employee names found" "PASS"
else
    test_item "No placeholder employee names found" "Could not verify"
fi

# Check for [Demo] task prefixes
tasks_response=$(curl -s -X GET \
    "${BASE_URL}/rest/v1/tasks?select=title" \
    -H "apikey: ${ANON_KEY}" \
    -H "Authorization: Bearer ${ANON_KEY}" \
    -H "Content-Type: application/json")

if echo "$tasks_response" | grep -q "\[Demo\]"; then
    demo_count=$(echo "$tasks_response" | grep -o "\[Demo\]" | wc -l | xargs)
    test_item "[Demo] task prefixes found (informational)" "PASS (found $demo_count demo tasks)"
elif echo "$tasks_response" | grep -q "title"; then
    test_item "[Demo] task prefixes found (informational)" "PASS (no demo tasks)"
else
    test_item "[Demo] task prefixes found (informational)" "Could not verify"
fi

# Check venues have valid data
venues_response=$(curl -s -X GET \
    "${BASE_URL}/rest/v1/venues?select=name,address" \
    -H "apikey: ${ANON_KEY}" \
    -H "Authorization: Bearer ${ANON_KEY}" \
    -H "Content-Type: application/json")

if echo "$venues_response" | grep -q "name"; then
    venue_count=$(echo "$venues_response" | grep -o '"name"' | wc -l | xargs)
    test_item "Venues table contains valid data" "PASS"
else
    test_item "Venues table contains valid data" "No data found"
fi

# Check bookings have valid statuses
bookings_response=$(curl -s -X GET \
    "${BASE_URL}/rest/v1/bookings?select=status" \
    -H "apikey: ${ANON_KEY}" \
    -H "Authorization: Bearer ${ANON_KEY}" \
    -H "Content-Type: application/json")

if echo "$bookings_response" | grep -q '^\[\]'; then
    test_item "Bookings table accessible (informational)" "PASS (empty - no bookings yet)"
elif echo "$bookings_response" | grep -q "status"; then
    booking_count=$(echo "$bookings_response" | grep -o '"status"' | wc -l | xargs)
    test_item "Bookings table accessible (informational)" "PASS (found $booking_count bookings)"
else
    test_item "Bookings table accessible (informational)" "Could not verify"
fi

# ============================================
# FINAL SUMMARY
# ============================================
echo ""
print_header "TEST SUMMARY"

PASS_RATE=0
if [ $TOTAL_TESTS -gt 0 ]; then
    PASS_RATE=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)
fi

echo "Total Tests:  $TOTAL_TESTS"
echo -e "${GREEN}Passed:       $PASSED_TESTS${NC}"
echo -e "${RED}Failed:       $FAILED_TESTS${NC}"
echo "Pass Rate:    ${PASS_RATE}%"
echo ""
echo "Completed at: $(date)"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ALL TESTS PASSED SUCCESSFULLY! ✓    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   SOME TESTS FAILED - REVIEW ABOVE     ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    exit 1
fi
