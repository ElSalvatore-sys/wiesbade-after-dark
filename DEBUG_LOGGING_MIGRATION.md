# Debug Logging Migration Guide

## Summary

This guide explains how to migrate remaining `print()` statements to use `SecureLogger` for production-safe logging.

## Already Migrated

✅ **KeychainService.swift** - Complete
✅ **MockAuthService.swift** - Complete

## Files Still Containing Print Statements (25 remaining)

### Critical (Contains Sensitive Data)
- `AuthenticationViewModel.swift` - 27 print statements (phone numbers, tokens)
- `PaymentViewModel.swift` - payment errors
- `CheckInViewModel.swift` - check-in data
- `BookingViewModel.swift` - booking data
- `WalletPassViewModel.swift` - wallet pass data

### Standard (No Sensitive Data)
- Various other ViewModels and Services (UI state, navigation)

## Migration Pattern

### For ViewModels (Auth, Payment, Sensitive Data)

**Old:**
```swift
print("📱 [AuthViewModel] Sending verification code to: \(phoneNumber)")
```

**New:**
```swift
#if DEBUG
SecureLogger.shared.auth("Sending verification code to: \(phoneNumber)")
#endif
```

### For General Info Logs

**Old:**
```swift
print("ℹ️ [SomeView] Loading data")
```

**New:**
```swift
#if DEBUG
SecureLogger.shared.info("Loading data", category: "SomeView")
#endif
```

### For Success Messages

**Old:**
```swift
print("✅ [Service] Operation completed")
```

**New:**
```swift
#if DEBUG
SecureLogger.shared.success("Operation completed", category: "Service")
#endif
```

### For Errors

**Old:**
```swift
print("❌ [Service] Error: \(error)")
```

**New:**
```swift
SecureLogger.shared.error("Operation failed", error: error, category: "Service")
```

## SecureLogger Methods

### Specialized Methods
- `auth()` - Authentication events (sanitizes phone, tokens)
- `payment()` - Payment events (sanitizes card data)
- `network()` - Network requests (sanitizes headers)
- `data()` - Data operations
- `security()` - Security events (ALWAYS logged, even in production)

### General Methods
- `debug()` - Debug info (DEBUG only)
- `info()` - Informational messages
- `warning()` - Warnings
- `error()` - Errors
- `success()` - Success messages (DEBUG only)

## Quick Xcode Find & Replace

### Step 1: Find all print statements
**Search:** `print\(".*?\)`
**Type:** Regular Expression

### Step 2: Manually review each and replace based on content:

**For Auth-related:**
```swift
#if DEBUG
SecureLogger.shared.auth("\(message)")
#endif
```

**For Payment-related:**
```swift
#if DEBUG
SecureLogger.shared.payment("\(message)")
#endif
```

**For General logging:**
```swift
#if DEBUG
SecureLogger.shared.info("\(message)", category: "Category")
#endif
```

## Why This Matters

### Security Concerns
1. **Phone Numbers** - PII that should be sanitized
2. **Tokens** - Authentication tokens can be intercepted from logs
3. **Payment IDs** - Sensitive financial data
4. **User IDs** - Can be used for tracking

### Production Builds
- `#if DEBUG` ensures logs only appear in development
- Production builds have zero logging overhead
- OSLog provides system-level logging when needed
- SecureLogger automatically sanitizes sensitive patterns

## Automatic Sanitization

SecureLogger automatically redacts:
- Phone numbers: `+491234567890` → `+[REDACTED]`
- Emails: `user@example.com` → `[EMAIL_REDACTED]`
- JWT tokens: `eyJ...` → `[TOKEN_REDACTED]`
- UUIDs: `123e4567-e89b-12d3...` → `[UUID_REDACTED]`
- Card numbers: `4532 1234 5678 9010` → `XXXX-XXXX-XXXX-XXXX`

## Priority Order for Migration

1. **Critical** (Do First):
   - AuthenticationViewModel.swift
   - PaymentViewModel.swift
   - CheckInViewModel.swift
   - WalletPassViewModel.swift
   - BookingViewModel.swift

2. **Important**:
   - MockPaymentService.swift
   - CheckInService.swift
   - WalletPassService.swift

3. **Low Priority** (UI only):
   - Navigation-related ViewModels
   - UI state management

## For Demo

**Current Status:** Since you're building for demo (not production deployment yet), the existing print statements will only show in DEBUG builds. This is acceptable for now.

**Before Production:** All print statements should be migrated to SecureLogger.

## Testing SecureLogger

```swift
// Test in Debug build - should print
SecureLogger.shared.auth("Test message with phone: +491234567890")
// Output: 🔐 [Auth] Test message with phone: +[REDACTED]

// Test in Release build - no console output, but logged to OSLog
SecureLogger.shared.security("Suspicious activity detected", level: .error)
// No console output, but logged to unified logging system
```

## Commands to Check Progress

### Count remaining print statements:
```bash
grep -r "print(" --include="*.swift" WiesbadenAfterDark/ | wc -l
```

### Find files with most print statements:
```bash
grep -r "print(" --include="*.swift" WiesbadenAfterDark/ | cut -d: -f1 | sort | uniq -c | sort -nr
```

### Find print statements with sensitive data:
```bash
grep -r "print.*\+49\|print.*token\|print.*password" --include="*.swift" WiesbadenAfterDark/
```

## Notes

- For demo purposes, DEBUG mode is fine
- Before App Store submission, ALL print() must be removed or guarded
- SecureLogger is production-ready and can be used immediately
- Consider adding unit tests for SecureLogger sanitization
