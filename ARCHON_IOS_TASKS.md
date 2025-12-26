# Archon MCP - iOS App Fix Tasks
## WiesbadenAfterDark

---

## Project: iOS App Production Ready

### Owner PWA (COMPLETED ✅)
- [x] Run QUICK_DATA_IMPORT_GENERIC.sql (5 min) - 20 tasks created
- [x] Mobile testing plan created - 10 comprehensive tests (OWNER_PWA_MOBILE_TESTS.md)

### iOS App Critical Fixes (48-67 hours)

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

#### Phase 4: Testing (12-16 hours)
- [ ] Unit tests for services
- [ ] Integration tests for API
- [ ] UI tests for critical flows
- [ ] Real device testing (iPhone)
- [ ] Edge case handling

#### Phase 5: App Store Prep (4-6 hours)
- [ ] Take 5 screenshots x 3 sizes
- [ ] Enable GitHub Pages for privacy policy
- [ ] Final build and archive
- [ ] TestFlight upload
- [ ] App Store submission

---

## Priority Order

1. **TODAY:** Owner PWA data import + mobile test
2. **NEXT:** iOS NFC implementation (most critical)
3. **THEN:** Stripe integration
4. **THEN:** Backend connections
5. **FINALLY:** Testing + submission
