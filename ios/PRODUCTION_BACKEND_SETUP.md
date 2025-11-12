# iOS App - Production Backend Setup

## Overview

The iOS app has been configured to connect to the production backend at:
```
https://wiesbade-after-dark-production.up.railway.app
```

## What's Been Done

### 1. Created API Configuration (`APIConfig.swift`)
- **Location**: `WiesbadenAfterDark/Core/Services/APIConfig.swift`
- **Base URL**: `https://wiesbade-after-dark-production.up.railway.app`
- **Endpoints**: All API endpoints mapped (auth, venues, bookings, check-ins, payments, etc.)
- **Headers**: Configuration for authentication tokens

### 2. Created Network Client (`APIClient.swift`)
- **Location**: `WiesbadenAfterDark/Core/Services/APIClient.swift`
- **Methods**: GET, POST, PUT, DELETE
- **Features**:
  - Automatic JSON encoding/decoding
  - Bearer token authentication
  - Error handling
  - Debug logging
  - 30s request timeout, 60s resource timeout

### 3. Updated Info.plist
- **Change**: Removed localhost exception for development
- **Result**: App now requires HTTPS for all connections
- **Production**: Uses secure HTTPS connection to Railway backend

## Next Steps: Replace Mock Services

The app currently uses Mock services. To connect to the real backend, you need to implement real service classes.

### Example: Creating a Real Auth Service

Create `RealAuthService.swift`:

```swift
import Foundation

final class RealAuthService: AuthServiceProtocol {
    private let apiClient = APIClient.shared

    func sendVerificationCode(to phoneNumber: String) async throws {
        struct Request: Encodable {
            let phoneNumber: String
        }

        try await apiClient.post(
            APIConfig.Endpoints.sendVerificationCode,
            body: Request(phoneNumber: phoneNumber),
            requiresAuth: false
        )
    }

    func verifyCode(_ code: String, for phoneNumber: String) async throws -> AuthToken {
        struct Request: Encodable {
            let phoneNumber: String
            let code: String
        }

        struct Response: Decodable {
            let accessToken: String
            let refreshToken: String
            let expiresAt: Date
        }

        let response: Response = try await apiClient.post(
            APIConfig.Endpoints.verifyCode,
            body: Request(phoneNumber: phoneNumber, code: code),
            requiresAuth: false
        )

        return AuthToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: response.expiresAt
        )
    }

    func validateReferralCode(_ code: String) async throws -> Bool {
        struct Response: Decodable {
            let valid: Bool
        }

        let response: Response = try await apiClient.get(
            APIConfig.Endpoints.validateReferralCode,
            parameters: ["code": code],
            requiresAuth: false
        )

        return response.valid
    }

    @MainActor
    func createAccount(phoneNumber: String, referralCode: String?) async throws -> User {
        struct Request: Encodable {
            let phoneNumber: String
            let referralCode: String?
        }

        let user: User = try await apiClient.post(
            APIConfig.Endpoints.register,
            body: Request(phoneNumber: phoneNumber, referralCode: referralCode),
            requiresAuth: true
        )

        return user
    }
}
```

### Then Update the ViewModel

In `AuthenticationViewModel.swift`, change line 34:

```swift
// Before:
authService: AuthServiceProtocol = MockAuthService.shared,

// After:
authService: AuthServiceProtocol = RealAuthService(),
```

### Services to Update

1. **MockAuthService** → Create `RealAuthService`
   - File: `WiesbadenAfterDark/Core/Services/MockAuthService.swift`
   - Endpoints: `/auth/send-code`, `/auth/verify-code`, `/auth/register`

2. **MockVenueService** → Create `RealVenueService`
   - File: `WiesbadenAfterDark/Core/Services/MockVenueService.swift`
   - Endpoints: `/venues`, `/venues/{id}`, `/venues/{id}/events`, etc.

3. **MockPaymentService** → Use `StripePaymentService`
   - File: `WiesbadenAfterDark/Core/Services/MockPaymentService.swift`
   - Endpoints: `/payments/create-intent`, `/payments/confirm`

4. **MockCheckInService** → Create `RealCheckInService`
   - File: `WiesbadenAfterDark/Core/Services/MockCheckInService.swift`
   - Endpoints: `/check-ins`, `/check-ins/user/{id}/streak`

5. **MockWalletPassService** → Create `RealWalletPassService`
   - File: `WiesbadenAfterDark/Core/Services/MockWalletPassService.swift`
   - Endpoints: `/wallet-passes/generate/{id}`

## Testing the Connection

### 1. Test with a Simple Endpoint

Add this to test the connection:

```swift
Task {
    do {
        let venues: [Venue] = try await APIClient.shared.get("/venues", requiresAuth: false)
        print("✅ Successfully connected to backend. Found \(venues.count) venues")
    } catch {
        print("❌ Connection failed: \(error)")
    }
}
```

### 2. Check Console Logs

When making API calls, you'll see:
```
🌐 [APIClient] GET https://wiesbade-after-dark-production.up.railway.app/venues
📡 [APIClient] Response: 200
```

### 3. Handle Errors

The APIClient automatically handles:
- 401 Unauthorized → Logs user out
- 400-499 Client errors → Shows error message
- 500-599 Server errors → Shows "Server error"
- Network failures → Shows "Network error"

## Production Checklist

Before deploying to TestFlight/App Store:

- [ ] All Mock services replaced with Real services
- [ ] Token refresh logic implemented
- [ ] Error messages are user-friendly
- [ ] Loading states work correctly
- [ ] Offline mode handled gracefully (SwiftData caching)
- [ ] HTTPS enforced (already done ✓)
- [ ] No hardcoded localhost URLs (already done ✓)
- [ ] Production API key for Stripe configured
- [ ] Backend health check on app launch

## Backend API Documentation

Refer to the backend API docs for request/response schemas:
- Backend repo: Check `backend/app/routers/` for endpoint definitions
- Base URL: `https://wiesbade-after-dark-production.up.railway.app`
- Health check: `GET /health`
- API docs: `GET /docs` (FastAPI automatic documentation)

## Troubleshooting

### Connection Refused
- Verify Railway deployment is running
- Check the base URL in `APIConfig.swift`
- Test the endpoint in Postman/browser first

### 401 Unauthorized
- Check token is being saved in Keychain
- Verify token is included in request headers
- Check token hasn't expired

### Decoding Errors
- Ensure backend response matches Swift model
- Check snake_case ↔ camelCase conversion
- Add debug logging to see raw JSON response

### Certificate Errors
- Ensure backend uses valid SSL certificate
- Railway provides automatic SSL - should work out of the box
- Check `NSAppTransportSecurity` allows HTTPS (already configured ✓)
