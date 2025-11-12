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
            try await apiClient.post(
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
        }

        do {
            let response: Response = try await apiClient.post(
                APIConfig.Endpoints.verifyCode,
                body: Request(phoneNumber: phoneNumber, code: code),
                requiresAuth: false
            )

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

            return token

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.auth("Code verification failed: \(error)", level: .error)
            #endif
            throw mapAPIError(error)
        } catch {
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

    /// Creates a new user account with optional referral code
    @MainActor
    func createAccount(phoneNumber: String, referralCode: String?) async throws -> User {
        #if DEBUG
        SecureLogger.shared.auth("Creating account for: \(phoneNumber)")
        if let code = referralCode {
            SecureLogger.shared.info("Using referral code: \(code)", category: "RealAuthService")
        }
        #endif

        struct Request: Encodable {
            let phoneNumber: String
            let referralCode: String?
        }

        struct Response: Decodable {
            let accessToken: String
            let refreshToken: String
            let tokenType: String
            let expiresIn: Int
            let user: UserDTO
        }

        struct UserDTO: Decodable {
            let id: String
            let phoneNumber: String
            let phoneCountryCode: String
            let name: String?
            let email: String?
            let avatarUrl: String?
            let referralCode: String
            let referredBy: String?
            let pointsBalance: Int
            let createdAt: String
            let lastLoginAt: String?
            let preferredLanguage: String
        }

        do {
            let response: Response = try await apiClient.post(
                APIConfig.Endpoints.register,
                body: Request(phoneNumber: phoneNumber, referralCode: referralCode),
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
            let refreshToken: String
            let tokenType: String
            let expiresIn: Int
        }

        do {
            let response: Response = try await apiClient.post(
                APIConfig.Endpoints.refreshToken,
                body: Request(refreshToken: currentToken.refreshToken),
                requiresAuth: false
            )

            let expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))
            let newToken = AuthToken(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresAt: expiresAt,
                tokenType: response.tokenType
            )

            try keychainService.saveToken(newToken)

            #if DEBUG
            SecureLogger.shared.success("Access token refreshed successfully", category: "RealAuthService")
            #endif

            return newToken

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Token refresh failed", error: error, category: "RealAuthService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }

    /// Fetches the current user profile
    @MainActor
    func fetchCurrentUser() async throws -> User {
        #if DEBUG
        SecureLogger.shared.info("Fetching current user profile", category: "RealAuthService")
        #endif

        struct UserDTO: Decodable {
            let id: String
            let phoneNumber: String
            let phoneCountryCode: String
            let name: String?
            let email: String?
            let avatarUrl: String?
            let referralCode: String
            let referredBy: String?
            let pointsBalance: Int
            let createdAt: String
            let lastLoginAt: String?
            let preferredLanguage: String
        }

        do {
            let userDTO: UserDTO = try await apiClient.get(
                APIConfig.Endpoints.userProfile,
                requiresAuth: true
            )

            let user = try convertToUser(from: userDTO)

            #if DEBUG
            SecureLogger.shared.success("User profile fetched successfully", category: "RealAuthService")
            #endif

            return user

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to fetch user profile", error: error, category: "RealAuthService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }

    // MARK: - Helper Methods

    /// Converts backend UserDTO to SwiftData User model
    private func convertToUser(from dto: UserDTO) throws -> User {
        guard let userId = UUID(uuidString: dto.id) else {
            throw AuthError.serverError("Invalid user ID format")
        }

        let referredById: UUID? = if let referredBy = dto.referredBy {
            UUID(uuidString: referredBy)
        } else {
            nil
        }

        // Parse ISO8601 date
        let dateFormatter = ISO8601DateFormatter()
        guard let createdAt = dateFormatter.date(from: dto.createdAt) else {
            throw AuthError.serverError("Invalid date format")
        }

        let lastLoginAt: Date? = if let lastLogin = dto.lastLoginAt {
            dateFormatter.date(from: lastLogin)
        } else {
            nil
        }

        return User(
            id: userId,
            phoneNumber: dto.phoneNumber,
            phoneCountryCode: dto.phoneCountryCode,
            name: dto.name,
            email: dto.email,
            avatarURL: dto.avatarUrl,
            referralCode: dto.referralCode,
            referredBy: referredById,
            pointsBalance: dto.pointsBalance,
            createdAt: createdAt,
            lastLoginAt: lastLoginAt,
            preferredLanguage: dto.preferredLanguage
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
    let id: String
    let phoneNumber: String
    let phoneCountryCode: String
    let name: String?
    let email: String?
    let avatarUrl: String?
    let referralCode: String
    let referredBy: String?
    let pointsBalance: Int
    let createdAt: String
    let lastLoginAt: String?
    let preferredLanguage: String
}
