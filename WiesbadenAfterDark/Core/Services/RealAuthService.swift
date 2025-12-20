//
//  RealAuthService.swift
//  WiesbadenAfterDark
//
//  Real authentication service that connects to the production backend
//  Replaces MockAuthService for production use
//

import Foundation

/// Production authentication service that makes real API calls to the backend
final class RealAuthService: AuthServiceProtocol {
    // MARK: - Properties

    private let apiClient = APIClient.shared
    private let keychainService = KeychainService.shared

    // MARK: - Singleton
    static let shared = RealAuthService()

    private init() {
        #if DEBUG
        print("🔐 [RealAuthService] Initialized with production backend")
        #endif
    }

    // MARK: - AuthServiceProtocol Implementation

    /// Sends a verification code via SMS to the specified phone number
    func sendVerificationCode(to phoneNumber: String) async throws {
        #if DEBUG
        SecureLogger.shared.auth("Sending verification code to: \(phoneNumber)")
        #endif

        struct Request: Encodable {
            let phoneNumber: String
        }

        do {
            // Backend expects phone_number in snake_case (handled by encoder)
            _ = try await apiClient.post(
                APIConfig.Endpoints.sendVerificationCode,
                body: Request(phoneNumber: phoneNumber),
                requiresAuth: false
            ) as EmptyResponse

            #if DEBUG
            SecureLogger.shared.auth("Verification code sent successfully", level: .success)
            #endif
        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.auth("Failed to send verification code: \(error)", level: .error)
            #endif
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }

    /// Verifies the SMS code and returns authentication tokens
    func verifyCode(_ code: String, for phoneNumber: String) async throws -> AuthToken {
        #if DEBUG
        SecureLogger.shared.auth("Verifying code for phone: \(phoneNumber)")
        #endif

        struct Request: Encodable {
            let phoneNumber: String
            let code: String
        }

        struct Response: Decodable {
            let accessToken: String
            let refreshToken: String
            let tokenType: String
            let expiresIn: Int // seconds
            let user: UserDTO? // Present if user already registered

            // No explicit CodingKeys needed - APIClient's .convertFromSnakeCase handles it
            // Backend sends: access_token, refresh_token, token_type, expires_in, user
            // JSONDecoder auto-converts to: accessToken, refreshToken, tokenType, expiresIn, user
        }

        do {
            let response: Response = try await apiClient.post(
                APIConfig.Endpoints.verifyCode,
                body: Request(phoneNumber: phoneNumber, code: code),
                requiresAuth: false
            )

            // Log whether user exists in response
            if let user = response.user {
                print("✅ [RealAuthService] Existing user returned from backend")
                print("   User ID: \(user.id)")
                print("   Phone: \(user.phoneNumber)")
                print("   Verified: \(user.phoneVerified)")
            } else {
                print("ℹ️ [RealAuthService] No user in response - this is a new user")
            }

            // Convert expires_in (seconds) to expiresAt (Date)
            let expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))

            let token = AuthToken(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresAt: expiresAt,
                tokenType: response.tokenType
            )

            #if DEBUG
            SecureLogger.shared.auth("Code verified successfully", level: .success)
            #endif

            // Log authentication success (production-safe)
            ProductionLogger.shared.logAuthAttempt(success: true)

            return token

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.auth("Code verification failed: \(error)", level: .error)
            #endif

            // Log authentication failure (production-safe)
            ProductionLogger.shared.logAuthAttempt(success: false)

            throw mapAPIError(error)
        } catch {
            ProductionLogger.shared.logAuthAttempt(success: false)
            throw AuthError.networkError(error)
        }
    }

    /// Validates a referral code with the backend
    func validateReferralCode(_ code: String) async throws -> Bool {
        #if DEBUG
        SecureLogger.shared.info("Validating referral code: \(code)", category: "RealAuthService")
        #endif

        struct Response: Decodable {
            let valid: Bool
            let referralCode: String?
        }

        do {
            let response: Response = try await apiClient.get(
                APIConfig.Endpoints.validateReferralCode,
                parameters: ["code": code],
                requiresAuth: false
            )

            #if DEBUG
            if response.valid {
                SecureLogger.shared.success("Referral code is valid", category: "RealAuthService")
            } else {
                SecureLogger.shared.info("Referral code is invalid", category: "RealAuthService")
            }
            #endif

            return response.valid

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Referral validation failed", error: error, category: "RealAuthService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }

    /// Creates a new user account with optional referral code and name
    @MainActor
    func createAccount(phoneNumber: String, firstName: String?, lastName: String?, referralCode: String?) async throws -> User {
        #if DEBUG
        SecureLogger.shared.auth("Creating account for: \(phoneNumber)")
        if let code = referralCode {
            SecureLogger.shared.info("Using referral code: \(code)", category: "RealAuthService")
        }
        #endif

        struct Request: Encodable {
            let phoneNumber: String
            let referralCode: String?
            let firstName: String?
            let lastName: String?
        }

        struct Response: Decodable {
            let accessToken: String
            let refreshToken: String
            let tokenType: String
            let expiresIn: Int
            let user: UserDTO
        }

        do {
            let response: Response = try await apiClient.post(
                APIConfig.Endpoints.register,
                body: Request(phoneNumber: phoneNumber, referralCode: referralCode, firstName: firstName, lastName: lastName),
                requiresAuth: false
            )

            // Save the authentication tokens
            let expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))
            let token = AuthToken(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresAt: expiresAt,
                tokenType: response.tokenType
            )

            try keychainService.saveToken(token)
            #if DEBUG
            SecureLogger.shared.auth("Token saved to keychain", level: .success)
            #endif

            // Convert UserDTO to User model
            let user = try convertToUser(from: response.user)

            #if DEBUG
            SecureLogger.shared.auth("Account created successfully", level: .success)
            SecureLogger.shared.info("User ID: \(user.id)", category: "RealAuthService")
            #endif

            return user

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.auth("Account creation failed: \(error)", level: .error)
            #endif
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }

    // MARK: - Token Management

    /// Refreshes the access token using the refresh token
    func refreshAccessToken() async throws -> AuthToken {
        #if DEBUG
        SecureLogger.shared.info("Refreshing access token", category: "RealAuthService")
        #endif

        guard let currentToken = try? keychainService.getToken(),
              !currentToken.refreshToken.isEmpty else {
            throw AuthError.unknownError
        }

        struct Request: Encodable {
            let refreshToken: String
        }

        struct Response: Decodable {
            let accessToken: String
            let tokenType: String
            let expiresIn: Int

            // No explicit CodingKeys needed - APIClient's .convertFromSnakeCase handles it
            // Backend sends: access_token, token_type, expires_in
            // JSONDecoder auto-converts to: accessToken, tokenType, expiresIn
        }

        do {
            let response: Response = try await apiClient.post(
                APIConfig.Endpoints.refreshToken,
                body: Request(refreshToken: currentToken.refreshToken),
                requiresAuth: false
            )

            #if DEBUG
            print("✅ [RealAuthService] Refresh response decoded successfully")
            print("   Token expires in: \(response.expiresIn) seconds")
            #endif

            let expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))
            // Return NEW access token but KEEP existing refresh token
            let newToken = AuthToken(
                accessToken: response.accessToken,
                refreshToken: currentToken.refreshToken,  // ← KEEP the old one!
                expiresAt: expiresAt,
                tokenType: response.tokenType
            )

            try keychainService.saveToken(newToken)

            #if DEBUG
            SecureLogger.shared.success("Access token refreshed successfully", category: "RealAuthService")
            #endif

            // Log token refresh success (production-safe)
            ProductionLogger.shared.logTokenRefresh(success: true)

            return newToken

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Token refresh failed", error: error, category: "RealAuthService")
            #endif

            // Log token refresh failure (production-safe)
            ProductionLogger.shared.logTokenRefresh(success: false)

            throw mapAPIError(error)
        } catch {
            ProductionLogger.shared.logTokenRefresh(success: false)
            throw AuthError.networkError(error)
        }
    }

    /// Fetches the current user profile
    @MainActor
    func fetchCurrentUser() async throws -> User {
        print("📡 [RealAuthService] Fetching current user from backend...")
        print("   URL: \(APIConfig.baseURL)\(APIConfig.Endpoints.userProfile)")

        #if DEBUG
        SecureLogger.shared.info("Fetching current user profile", category: "RealAuthService")
        #endif

        do {
            let userDTO: UserDTO = try await apiClient.get(
                APIConfig.Endpoints.userProfile,
                requiresAuth: true
            )

            print("✅ [RealAuthService] Backend returned user successfully")
            print("   Raw response - ID: \(userDTO.id)")
            print("   Raw response - Phone: \(userDTO.phoneNumber)")
            print("   Raw response - Verified: \(userDTO.phoneVerified)")
            print("   Raw response - Referral Code: \(userDTO.referralCode)")

            let user = try convertToUser(from: userDTO)
            print("✅ [RealAuthService] Converted to User model successfully")

            #if DEBUG
            SecureLogger.shared.success("User profile fetched successfully", category: "RealAuthService")
            #endif

            return user

        } catch let error as APIError {
            print("❌ [RealAuthService] fetchCurrentUser FAILED")
            print("   Error type: APIError")
            print("   Error: \(error)")

            #if DEBUG
            SecureLogger.shared.error("Failed to fetch user profile", error: error, category: "RealAuthService")
            #endif
            throw mapAPIError(error)
        } catch {
            print("❌ [RealAuthService] fetchCurrentUser FAILED")
            print("   Error type: \(type(of: error))")
            print("   Error: \(error)")

            if let urlError = error as? URLError {
                print("   URLError code: \(urlError.code)")
            }

            throw AuthError.networkError(error)
        }
    }

    // MARK: - Helper Methods

    /// Converts backend UserDTO to SwiftData User model
    private func convertToUser(from dto: UserDTO) throws -> User {
        // UserDTO now has UUID and parsed dates - no conversion needed!
        return User(
            id: dto.id,
            phoneNumber: dto.phoneNumber,
            phoneCountryCode: dto.phoneCountryCode ?? "+49",
            phoneVerified: dto.phoneVerified,
            firstName: dto.firstName,
            lastName: dto.lastName,
            email: dto.email,
            avatarURL: dto.avatarUrl,
            referralCode: dto.referralCode,
            referredByCode: dto.referredByCode,
            referredBy: nil, // We don't receive the referrer's UUID from backend
            totalReferrals: dto.totalReferrals,
            totalPointsEarned: dto.totalPointsEarned,
            totalPointsSpent: dto.totalPointsSpent,
            totalPointsAvailable: dto.totalPointsAvailable,
            isVerified: dto.isVerified,
            isActive: dto.isActive,
            createdAt: dto.createdAt,
            lastLoginAt: dto.lastLoginAt,
            preferredLanguage: "de" // Backend doesn't send this yet
        )
    }

    /// Maps APIError to AuthError
    private func mapAPIError(_ error: APIError) -> AuthError {
        switch error {
        case .unauthorized:
            return .verificationCodeExpired
        case .httpError(let statusCode, let message):
            switch statusCode {
            case 400:
                if let message = message, message.contains("verification code") {
                    return .invalidVerificationCode
                } else if let message = message, message.contains("referral") {
                    return .invalidReferralCode
                }
                return .serverError(message ?? "Bad request")
            case 409:
                return .accountAlreadyExists
            default:
                return .serverError(message ?? "Server error")
            }
        case .networkError(let underlyingError):
            return .networkError(underlyingError)
        default:
            return .unknownError
        }
    }
}

// MARK: - Private Response Types

private struct EmptyResponse: Decodable {}

private struct UserDTO: Decodable {
    let id: UUID
    let email: String?
    let firstName: String?
    let lastName: String?
    let phoneNumber: String
    let phoneCountryCode: String?
    let phoneVerified: Bool
    let avatarUrl: String?
    let referralCode: String
    let referredByCode: String?
    let totalReferrals: Int
    let totalPointsEarned: Double
    let totalPointsSpent: Double
    let totalPointsAvailable: Double
    let isVerified: Bool
    let isActive: Bool
    let createdAt: Date
    let lastLoginAt: Date?

    enum CodingKeys: String, CodingKey {
        // No explicit raw values - APIClient's .convertFromSnakeCase handles it!
        // Backend sends: phone_number, first_name, created_at (snake_case)
        // JSONDecoder auto-converts to: phoneNumber, firstName, createdAt (camelCase)
        // These case names match the converted camelCase keys ✅
        case id, email
        case firstName, lastName
        case phoneNumber, phoneCountryCode, phoneVerified
        case avatarUrl, referralCode, referredByCode
        case totalReferrals, totalPointsEarned, totalPointsSpent, totalPointsAvailable
        case isVerified, isActive
        case createdAt, lastLoginAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        phoneCountryCode = try container.decodeIfPresent(String.self, forKey: .phoneCountryCode)
        phoneVerified = try container.decode(Bool.self, forKey: .phoneVerified)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        referralCode = try container.decode(String.self, forKey: .referralCode)
        referredByCode = try container.decodeIfPresent(String.self, forKey: .referredByCode)
        totalReferrals = try container.decode(Int.self, forKey: .totalReferrals)
        totalPointsEarned = try container.decode(Double.self, forKey: .totalPointsEarned)
        totalPointsSpent = try container.decode(Double.self, forKey: .totalPointsSpent)
        totalPointsAvailable = try container.decode(Double.self, forKey: .totalPointsAvailable)
        isVerified = try container.decode(Bool.self, forKey: .isVerified)
        isActive = try container.decode(Bool.self, forKey: .isActive)

        // CUSTOM DATE PARSING
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Parse created_at
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            if let date = dateFormatter.date(from: createdAtString) {
                createdAt = date
            } else {
                // Fallback: try without fractional seconds
                dateFormatter.formatOptions = [.withInternetDateTime]
                createdAt = dateFormatter.date(from: createdAtString) ?? Date()
            }
        } else {
            createdAt = Date()
        }

        // Parse last_login_at
        if let lastLoginString = try? container.decodeIfPresent(String.self, forKey: .lastLoginAt) {
            // lastLoginString is already unwrapped to String, no need for second unwrap
            if let date = dateFormatter.date(from: lastLoginString) {
                lastLoginAt = date
            } else {
                dateFormatter.formatOptions = [.withInternetDateTime]
                lastLoginAt = dateFormatter.date(from: lastLoginString)
            }
        } else {
            lastLoginAt = nil
        }
    }
}
