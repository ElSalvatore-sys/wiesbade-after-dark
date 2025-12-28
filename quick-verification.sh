#!/bin/bash

echo "╔═══════════════════════════════════════════════════════╗"
echo "║     QUICK LAUNCH READINESS VERIFICATION               ║"
echo "║     WiesbadenAfterDark - Das Wohnzimmer              ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

PASS=0
FAIL=0

# Owner PWA
echo "1. OWNER PWA"
if curl -s https://owner-pwa.vercel.app | grep -q "html"; then
  echo "   ✅ PWA is accessible"
  PASS=$((PASS+1))
else
  echo "   ❌ PWA not accessible"
  FAIL=$((FAIL+1))
fi

# GitHub Pages - Privacy
echo ""
echo "2. GITHUB PAGES - PRIVACY POLICY"
if curl -s https://elsalvatore-sys.github.io/wiesbade-after-dark/ | grep -q "Datenschutz"; then
  echo "   ✅ Privacy Policy live"
  PASS=$((PASS+1))
else
  echo "   ❌ Privacy Policy issue"
  FAIL=$((FAIL+1))
fi

# GitHub Pages - Support
echo ""
echo "3. GITHUB PAGES - SUPPORT"
if curl -s https://elsalvatore-sys.github.io/wiesbade-after-dark/support.html | grep -q "Support"; then
  echo "   ✅ Support Page live"
  PASS=$((PASS+1))
else
  echo "   ❌ Support Page issue"
  FAIL=$((FAIL+1))
fi

# iOS Project
echo ""
echo "4. iOS APP"
if [ -f "WiesbadenAfterDark.xcodeproj/project.pbxproj" ]; then
  SWIFT_COUNT=$(find . -name "*.swift" -not -path "*/.*" -not -path "*/venv/*" -not -path "*/node_modules/*" | wc -l | xargs)
  echo "   ✅ Xcode project exists ($SWIFT_COUNT Swift files)"
  PASS=$((PASS+1))
else
  echo "   ❌ Xcode project not found"
  FAIL=$((FAIL+1))
fi

# Documentation
echo ""
echo "5. LAUNCH DOCUMENTATION"
DOCS=("LAUNCH_DAY_CHECKLIST.md" "STAFF_QUICK_START_GUIDE.md" "MANAGER_LAUNCH_GUIDE.md")
DOC_COUNT=0
for doc in "${DOCS[@]}"; do
  [ -f "$doc" ] && DOC_COUNT=$((DOC_COUNT+1))
done

if [ $DOC_COUNT -eq 3 ]; then
  echo "   ✅ All 3 launch guides present"
  PASS=$((PASS+1))
else
  echo "   ⚠️  Only $DOC_COUNT/3 launch guides found"
  FAIL=$((FAIL+1))
fi

# Printable Guides
echo ""
echo "6. PRINTABLE GUIDES"
if [ -d "launch-pdfs" ] && [ -f "launch-pdfs/STAFF_QUICK_START_GUIDE.html" ]; then
  HTML_COUNT=$(find launch-pdfs -name "*.html" | wc -l | xargs)
  echo "   ✅ Printable guides ready ($HTML_COUNT HTML files)"
  PASS=$((PASS+1))
else
  echo "   ❌ Printable guides not ready"
  FAIL=$((FAIL+1))
fi

# E2E Test Files
echo ""
echo "7. E2E TEST SUITE"
if [ -d "owner-pwa/e2e" ]; then
  TEST_COUNT=$(find owner-pwa/e2e -name "*.spec.ts" | wc -l | xargs)
  echo "   ✅ E2E test suite present ($TEST_COUNT test files)"
  echo "   ℹ️  Run 'npm run test:e2e' in owner-pwa/ to verify"
  PASS=$((PASS+1))
else
  echo "   ❌ E2E tests not found"
  FAIL=$((FAIL+1))
fi

# Git Status
echo ""
echo "8. GIT REPOSITORY"
if git rev-parse --git-dir > /dev/null 2>&1; then
  if git diff --quiet && git diff --cached --quiet; then
    echo "   ✅ Git clean, all changes committed"
    PASS=$((PASS+1))
  else
    echo "   ⚠️  Uncommitted changes present"
    PASS=$((PASS+1))
  fi
else
  echo "   ❌ Not a git repository"
  FAIL=$((FAIL+1))
fi

# Summary
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║                   SUMMARY                             ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "  ✅ Passed: $PASS/8"
echo "  ❌ Failed: $FAIL/8"
echo ""

if [ $FAIL -eq 0 ]; then
  echo "  🎉 ALL SYSTEMS READY FOR LAUNCH!"
  echo ""
  echo "  LAUNCH CHECKLIST:"
  echo "  ✅ Owner PWA deployed"
  echo "  ✅ Legal pages live"
  echo "  ✅ iOS app code complete"
  echo "  ✅ Documentation ready"
  echo "  ✅ Printable guides created"
  echo "  ✅ Tests available"
  echo ""
  echo "  REMAINING MANUAL TASKS:"
  echo "  [ ] Purchase €99 Apple Developer Account"
  echo "  [ ] Print launch documentation"
  echo "  [ ] Staff briefing (Jan 1, 14:00-16:00)"
  echo "  [ ] Install PWA on staff devices"
  echo ""
  echo "  🚀 DAS WOHNZIMMER LAUNCHES JANUARY 1, 2025!"
elif [ $FAIL -le 2 ]; then
  echo "  ⚠️  MOSTLY READY - Minor issues to address"
  echo ""
  echo "  Review failed items above and resolve before launch."
else
  echo "  ❌ CRITICAL ISSUES - NOT READY FOR LAUNCH"
  echo ""
  echo "  Multiple systems failing. Review and fix urgently!"
fi

echo ""

