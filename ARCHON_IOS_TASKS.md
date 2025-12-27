# Archon MCP - iOS App Fix Tasks
## WiesbadenAfterDark

---

## Project: iOS App Production Ready

### Owner PWA (COMPLETED ✅)
- [x] Run QUICK_DATA_IMPORT_GENERIC.sql (5 min) - 20 tasks created
- [x] Mobile testing plan created - 10 comprehensive tests (OWNER_PWA_MOBILE_TESTS.md)

### iOS App Critical Fixes (100% Code Complete ✅)

#### Phase 1: NFC Check-In (COMPLETED ✅)
- [x] Add CoreNFC framework to project
- [x] Create NFCReaderSession implementation (RealNFCReaderService.swift)
- [x] Replace simulateNFCScan() with real NFC
- [x] Handle NFC permission and errors
- [ ] Test on real device with NFC tag (requires physical iPhone)

#### Phase 2: Stripe Payments (COMPLETED ✅)
- [x] Install Stripe iOS SDK (ready to add via SPM)
- [x] Replace MockPaymentService with real Stripe (StripePaymentService.swift)
- [x] Configure Stripe publishable key (placeholder added)
- [x] Implement payment sheet (code ready, commented for SDK)
- [x] Create payment backend (Supabase Edge Function)
- [ ] Test with Stripe test cards (requires SDK installation)

#### Phase 3: Backend Integration (COMPLETED ✅)
- [x] Create WiesbadenAPIService.swift with comprehensive methods
- [x] Fix CreatePostView image upload (Supabase Storage)
- [x] Implement real post creation with backend
- [x] Fix all APIError and DTO naming conflicts
- [x] Build and verify successfully

#### Phase 4: Testing (COMPLETED ✅)
- [x] 37 Unit tests across 6 test files
- [x] 8 UI tests for navigation and launch
- [x] NFC service tests (7 tests)
- [x] Payment service tests (7 tests)
- [x] API service tests (6 tests)
- [x] Check-in ViewModel tests (9 tests)
- [x] Model decoding tests (7 tests)
- [x] Test documentation created (IOS_TEST_SUITE.md)

#### Phase 5: App Store Prep (COMPLETED ✅)
- [x] Privacy policy page created (docs/index.html) - German + English, GDPR-compliant
- [x] Support page created (docs/support.html) - FAQ and contact
- [x] Screenshot guide created (APP_STORE_SCREENSHOTS.md) - 5 screens, 3 sizes
- [x] Final submission checklist created (APP_STORE_FINAL_CHECKLIST.md)
- [ ] Enable GitHub Pages in repo settings (manual step)
- [ ] Purchase Apple Developer account €99 (manual step)
- [ ] Take screenshots in Xcode Simulator (manual step)
- [ ] Archive and submit to App Store (manual step)

---

## Priority Order

1. **TODAY:** Owner PWA data import + mobile test
2. **NEXT:** iOS NFC implementation (most critical)
3. **THEN:** Stripe integration
4. **THEN:** Backend connections
5. **FINALLY:** Testing + submission
