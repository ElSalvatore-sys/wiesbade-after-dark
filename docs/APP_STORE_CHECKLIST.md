# App Store Submission Checklist

## Before Submission

### Apple Developer Account
- [ ] Enrolled in Apple Developer Program ($99/year)
- [ ] Team set up in App Store Connect
- [ ] Certificates and profiles created

### App Preparation
- [x] App icon (1024x1024)
- [x] Launch screen
- [x] All required Info.plist keys
- [x] Privacy descriptions for permissions
- [x] Widget extension
- [x] No hardcoded API keys (App Groups for widget)
- [ ] Screenshots (6.7", 6.5", iPad if applicable)
- [ ] App preview video (optional)

### App Store Connect Setup
- [ ] Create new app
- [ ] Set bundle ID: com.ea-solutions.WiesbadenAfterDark.WiesbadenAfterDark
- [ ] Enter app name and subtitle
- [ ] Select categories (Lifestyle, Entertainment)
- [ ] Set age rating to 17+ (Alcohol content)
- [ ] Enter description (English & German)
- [ ] Add keywords
- [ ] Set pricing (Free)
- [ ] Add support URL
- [ ] Add privacy policy URL
- [ ] Upload screenshots

### Build Upload
- [ ] Archive build in Xcode
- [ ] Upload to App Store Connect
- [ ] Select build for review
- [ ] Complete export compliance
- [ ] Submit for review

### Legal Requirements
- [x] Privacy Policy
- [x] Terms of Service
- [ ] GDPR compliance verified
- [ ] Age gate (17+ content)

### Testing Before Submission
- [ ] Test on multiple devices
- [ ] Test all features work
- [ ] Test offline behavior
- [ ] Test push notifications (after APNs setup)
- [ ] Test widget
- [ ] Run XCTest unit tests
- [ ] Memory leak check with Instruments
- [ ] Crash-free session verified

## Common Rejection Reasons to Avoid

1. Crashes or bugs
2. Incomplete app / placeholder content
3. Missing privacy policy
4. Inaccurate metadata
5. Hidden features
6. Misleading screenshots
7. Hardcoded test credentials

## After Approval

- [ ] Enable phased release (optional)
- [ ] Set up App Analytics
- [ ] Monitor crash reports
- [ ] Respond to reviews
- [ ] Plan version 1.1 updates

## Technical Compliance Status

| Item | Status | Notes |
|------|--------|-------|
| Force Unwraps | 2 minor | Safe patterns (nil check before unwrap) |
| Memory Leaks | None | No retain cycles detected |
| Background Modes | OK | Only remote-notification |
| Third-Party Deps | None | Apple frameworks only |
| API Keys | Compliant | Using App Groups, no hardcoded keys |
| Bundle ID | OK | com.ea-solutions.WiesbadenAfterDark.WiesbadenAfterDark |
| Version | 1.0 (1) | Ready for submission |
