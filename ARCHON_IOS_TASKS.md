# Archon MCP - iOS App Fix Tasks
## WiesbadenAfterDark

---

## Project: iOS App Production Ready

### Owner PWA (Remaining - 35 min)
- [ ] Run QUICK_DATA_IMPORT_GENERIC.sql (5 min)
- [ ] Mobile testing - 10 quick tests (30 min)

### iOS App Critical Fixes (48-67 hours)

#### Phase 1: NFC Check-In (8-12 hours)
- [ ] Add CoreNFC framework to project
- [ ] Create NFCReaderSession implementation
- [ ] Replace simulateNFCScan() with real NFC
- [ ] Handle NFC permission and errors
- [ ] Test on real device with NFC tag

#### Phase 2: Stripe Payments (6-8 hours)
- [ ] Install Stripe iOS SDK
- [ ] Replace MockPaymentService with real Stripe
- [ ] Configure Stripe publishable key
- [ ] Implement payment sheet
- [ ] Test with Stripe test cards

#### Phase 3: Backend Integration (4-6 hours)
- [ ] Fix VenueViewModel real API calls
- [ ] Fix CreatePostView image upload
- [ ] Implement point transactions endpoint
- [ ] Connect all 11 TODO items to real APIs

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
