#!/bin/bash

echo "=== RUNNING ALL E2E TESTS ==="
echo ""
echo "Target: https://owner-pwa.vercel.app"
echo ""

# Run all tests
npx playwright test --reporter=list

echo ""
echo "=== TEST RESULTS ==="
echo ""
echo "To view HTML report: npx playwright show-report"
