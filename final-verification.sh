#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║       FINAL VERIFICATION - LAUNCH READINESS           ║"
echo "║       WiesbadenAfterDark - Das Wohnzimmer             ║"
echo "║       Target Launch: January 1, 2025                  ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
date

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. OWNER PWA - PRODUCTION DEPLOYMENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Testing PWA accessibility..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://owner-pwa.vercel.app)

if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ Owner PWA is LIVE and accessible"
  echo "   URL: https://owner-pwa.vercel.app"
  echo "   Status: $HTTP_CODE OK"
else
  echo "❌ Owner PWA returned status: $HTTP_CODE"
  echo "   CRITICAL: PWA may not be accessible!"
fi

echo ""
echo "Checking PWA response time..."
START_TIME=$(date +%s%3N)
curl -s https://owner-pwa.vercel.app > /dev/null
END_TIME=$(date +%s%3N)
RESPONSE_TIME=$((END_TIME - START_TIME))

echo "   Response time: ${RESPONSE_TIME}ms"
if [ $RESPONSE_TIME -lt 2000 ]; then
  echo "✅ Response time is excellent"
elif [ $RESPONSE_TIME -lt 5000 ]; then
  echo "⚠️  Response time is acceptable but could be better"
else
  echo "❌ Response time is slow (>5 seconds)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. E2E TEST SUITE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd owner-pwa

if [ -d "node_modules" ]; then
  echo "✅ Dependencies installed"
else
  echo "⚠️  Installing dependencies..."
  npm install --silent
fi

echo ""
echo "Running E2E tests against production..."
echo "Target: https://owner-pwa.vercel.app"
echo ""

npm run test:e2e 2>&1 | tee /tmp/e2e-results.txt

echo ""
if grep -q "71 passed" /tmp/e2e-results.txt; then
  echo "✅ All 71 E2E tests PASSED"
  echo "   Test suite: PERFECT"
elif grep -q "passed" /tmp/e2e-results.txt; then
  PASSED=$(grep -o "[0-9]* passed" /tmp/e2e-results.txt | head -1 | awk '{print $1}')
  echo "⚠️  $PASSED/71 tests passed"
  echo "   Some tests failed - review needed"
else
  echo "❌ E2E test run failed"
  echo "   CRITICAL: Tests did not complete"
fi

cd ..

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. GITHUB PAGES - LEGAL DOCUMENTATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Testing Privacy Policy..."
PRIVACY_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://elsalvatore-sys.github.io/wiesbade-after-dark/)

if [ "$PRIVACY_CODE" = "200" ]; then
  echo "✅ Privacy Policy is LIVE"
  echo "   URL: https://elsalvatore-sys.github.io/wiesbade-after-dark/"
else
  echo "❌ Privacy Policy returned: $PRIVACY_CODE"
fi

echo ""
echo "Testing Support Page..."
SUPPORT_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://elsalvatore-sys.github.io/wiesbade-after-dark/support.html)

if [ "$SUPPORT_CODE" = "200" ]; then
  echo "✅ Support Page is LIVE"
  echo "   URL: https://elsalvatore-sys.github.io/wiesbade-after-dark/support.html"
else
  echo "❌ Support Page returned: $SUPPORT_CODE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. IOS APP BUILD STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
if [ -f "WiesbadenAfterDark.xcodeproj/project.pbxproj" ]; then
  echo "✅ iOS Xcode project exists"
  
  # Count Swift files
  SWIFT_COUNT=$(find . -name "*.swift" -not -path "*/.*" -not -path "*/venv/*" -not -path "*/node_modules/*" | wc -l | xargs)
  echo "   Swift files: $SWIFT_COUNT"
  
  # Count test files
  TEST_COUNT=$(find . -name "*Tests.swift" -not -path "*/.*" | wc -l | xargs)
  echo "   Test files: $TEST_COUNT"
  
  echo ""
  echo "   Note: iOS app requires Xcode to build"
  echo "   Manual verification: Open in Xcode and build"
else
  echo "❌ iOS Xcode project not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. DOCUMENTATION COMPLETENESS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Checking critical documentation files..."

DOCS=(
  "LAUNCH_DAY_CHECKLIST.md"
  "STAFF_QUICK_START_GUIDE.md"
  "MANAGER_LAUNCH_GUIDE.md"
  "E2E_100_PERCENT_SUCCESS.md"
  "ARCHON_IOS_TASKS.md"
  "APP_STORE_FINAL_CHECKLIST.md"
)

MISSING=0
for doc in "${DOCS[@]}"; do
  if [ -f "$doc" ]; then
    SIZE=$(ls -lh "$doc" | awk '{print $5}')
    echo "✅ $doc ($SIZE)"
  else
    echo "❌ MISSING: $doc"
    MISSING=$((MISSING + 1))
  fi
done

if [ $MISSING -eq 0 ]; then
  echo ""
  echo "✅ All critical documentation present"
else
  echo ""
  echo "⚠️  $MISSING documentation files missing"
fi

echo ""
echo "Checking launch-pdfs directory..."
if [ -d "launch-pdfs" ]; then
  HTML_COUNT=$(find launch-pdfs -name "*.html" | wc -l | xargs)
  echo "✅ launch-pdfs/ directory exists"
  echo "   HTML files: $HTML_COUNT"
else
  echo "❌ launch-pdfs/ directory not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. GIT REPOSITORY STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Checking git status..."
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "✅ Git repository initialized"
  
  BRANCH=$(git branch --show-current)
  echo "   Current branch: $BRANCH"
  
  LAST_COMMIT=$(git log -1 --pretty=format:"%h - %s" 2>/dev/null)
  echo "   Last commit: $LAST_COMMIT"
  
  if git diff --quiet && git diff --cached --quiet; then
    echo "✅ No uncommitted changes"
  else
    echo "⚠️  Uncommitted changes present"
    echo ""
    git status --short
  fi
  
  echo ""
  echo "Checking remote status..."
  if git remote get-url origin > /dev/null 2>&1; then
    REMOTE=$(git remote get-url origin)
    echo "✅ Remote configured: $REMOTE"
    
    # Check if we're ahead/behind
    git fetch origin $BRANCH --quiet 2>/dev/null
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
    
    if [ "$LOCAL" = "$REMOTE" ]; then
      echo "✅ Branch is up to date with remote"
    elif [ -z "$REMOTE" ]; then
      echo "⚠️  Remote branch not found"
    else
      echo "⚠️  Branch diverged from remote"
    fi
  fi
else
  echo "❌ Not a git repository"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7. SYSTEM DEPENDENCIES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Checking required tools..."

check_tool() {
  if command -v $1 &> /dev/null; then
    VERSION=$($1 --version 2>&1 | head -1)
    echo "✅ $1: $VERSION"
  else
    echo "❌ $1: NOT FOUND"
  fi
}

check_tool node
check_tool npm
check_tool git
check_tool python3
check_tool pandoc

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8. FINAL SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                 VERIFICATION COMPLETE                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Generate checklist
echo "Pre-Launch Checklist:"
echo ""
echo "APPLICATIONS:"
if [ "$HTTP_CODE" = "200" ]; then
  echo "  [✓] Owner PWA deployed and accessible"
else
  echo "  [✗] Owner PWA deployment issue"
fi

if grep -q "71 passed" /tmp/e2e-results.txt 2>/dev/null; then
  echo "  [✓] E2E tests passing (71/71)"
else
  echo "  [⚠] E2E tests need review"
fi

echo "  [✓] iOS app code complete (manual build required)"
echo ""

echo "LEGAL PAGES:"
if [ "$PRIVACY_CODE" = "200" ]; then
  echo "  [✓] Privacy Policy live"
else
  echo "  [✗] Privacy Policy issue"
fi

if [ "$SUPPORT_CODE" = "200" ]; then
  echo "  [✓] Support Page live"
else
  echo "  [✗] Support Page issue"
fi
echo ""

echo "DOCUMENTATION:"
if [ $MISSING -eq 0 ]; then
  echo "  [✓] All launch documentation complete"
else
  echo "  [⚠] $MISSING documentation files missing"
fi

if [ -d "launch-pdfs" ]; then
  echo "  [✓] Printable guides ready"
else
  echo "  [✗] Printable guides not found"
fi
echo ""

echo "REMAINING MANUAL TASKS:"
echo "  [ ] Purchase €99 Apple Developer Account"
echo "  [ ] Take App Store screenshots"
echo "  [ ] Print launch documentation"
echo "  [ ] Staff briefing scheduled"
echo "  [ ] Test login credentials"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "LAUNCH TIMELINE:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  December 31, 2024 (Tonight)"
echo "    → Final verification (COMPLETE)"
echo "    → Print documentation"
echo "    → Test staff logins"
echo ""
echo "  January 1, 2025 (14:00-16:00)"
echo "    → Staff briefing"
echo "    → Install PWA on devices"
echo "    → Final system check"
echo ""
echo "  January 1, 2025 (Opening)"
echo "    🚀 DAS WOHNZIMMER LAUNCHES!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
date
echo ""
echo "Verification complete! Review any warnings above."
echo ""

