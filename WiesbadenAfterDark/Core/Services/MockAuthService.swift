//
//  MockAuthService.swift
//  WiesbadenAfterDark
//
//  Mock implementation of AuthServiceProtocol for testing
//  ⚠️ WARNING: DO NOT USE IN PRODUCTION - FOR TESTING ONLY
//

import Foundation

#if DEBUG
/// Mock authentication service for development and testing ONLY
/// Always returns successful responses with simulated delays
/// ⚠️ This service should NEVER be used in production builds
final class MockAuthService: AuthServiceProtocol {
    // MARK: - Properties

    /// Simulated network delay in seconds
    private let networkDelay: TimeInterval = 2.0

    /// List of valid mock referral codes for testing
    private let validReferralCodes = ["WIESBADEN2024", "VIP123", "WELCOME"]

    // MARK: - Singleton
    static let shared = MockAuthService()

    private init() {}

    // MARK: - AuthServiceProtocol Implementation

    /// Simulates sending a verification code via SMS
    func sendVerificationCode(to phoneNumber: String) async throws {
        #if DEBUG
        SecureLogger.shared.auth("Sending verification code to: \(phoneNumber)")
        #endif

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // In mock mode, we always succeed
        #if DEBUG
        SecureLogger.shared.auth("Verification code sent successfully", level: .success)
        SecureLogger.shared.info("Any 6-digit code will work for verification", category: "MockAuth")
        #endif
    }

    /// Simulates verifying the SMS code
    func verifyCode(_ code: String, for phoneNumber: String) async throws -> AuthToken {
        #if DEBUG
        SecureLogger.shared.auth("Verifying code for phone: \(phoneNumber)")
        #endif

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Validate code format (6 digits)
        guard code.count == 6, code.allSatisfy({ $0.isNumber }) else {
            #if DEBUG
            SecureLogger.shared.auth("Invalid code format", level: .error)
            #endif
            throw AuthError.invalidVerificationCode
        }

        // In mock mode, accept any 6-digit code
        #if DEBUG
        SecureLogger.shared.auth("Code verified successfully", level: .success)
        #endif

        // Generate mock token
        let token = AuthToken.mock()
        #if DEBUG
        SecureLogger.shared.auth("Generated mock token")
        #endif

        return token
    }

    /// Validates a referral code
    func validateReferralCode(_ code: String) async throws -> Bool {
        #if DEBUG
        SecureLogger.shared.info("Validating referral code: \(code)", category: "MockAuth")
        #endif

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Check if code is in our valid list
        let isValid = validReferralCodes.contains(code.uppercased())

        #if DEBUG
        if isValid {
            SecureLogger.shared.success("Referral code is valid", category: "MockAuth")
        } else {
            SecureLogger.shared.info("Referral code is invalid", category: "MockAuth")
        }
        #endif

        return isValid
    }

    /// Creates a mock user account
    @MainActor
    func createAccount(phoneNumber: String, firstName: String?, lastName: String?, referralCode: String?) async throws -> User {
        #if DEBUG
        SecureLogger.shared.auth("Creating account for: \(phoneNumber)")

        if let code = referralCode {
            SecureLogger.shared.info("Using referral code: \(code)", category: "MockAuth")
        }
        #endif

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Generate a unique referral code for this user
        let userReferralCode = generateReferralCode()

        // Create mock user
        let user = User(
            id: UUID(),
            phoneNumber: phoneNumber.replacingOccurrences(of: " ", with: ""),
            phoneCountryCode: "+49",
            phoneVerified: true,
            firstName: firstName,
            lastName: lastName,
            email: nil,
            avatarURL: nil,
            referralCode: userReferralCode,
            referredByCode: referralCode,
            referredBy: nil,
            totalReferrals: 0,
            totalPointsEarned: referralCode != nil ? 50.0 : 0.0, // Bonus points if referred
            totalPointsSpent: 0.0,
            totalPointsAvailable: referralCode != nil ? 50.0 : 0.0,
            isVerified: true,
            isActive: true,
            createdAt: Date(),
            lastLoginAt: Date(),
            preferredLanguage: "de"
        )

        #if DEBUG
        SecureLogger.shared.auth("Account created successfully", level: .success)
        SecureLogger.shared.info("User referral code: \(userReferralCode)", category: "MockAuth")
        #endif

        return user
    }

    /// Simulates refreshing the access token
    func refreshAccessToken() async throws -> AuthToken {
        #if DEBUG
        SecureLogger.shared.auth("Refreshing access token")
        #endif

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Return mock token
        let token = AuthToken(
            accessToken: "mock_refreshed_access_token_\(UUID().uuidString)",
            refreshToken: "mock_refresh_token_\(UUID().uuidString)",
            expiresAt: Date().addingTimeInterval(900), // 15 minutes
            tokenType: "Bearer"
        )

        #if DEBUG
        SecureLogger.shared.auth("Access token refreshed successfully", level: .success)
        #endif

        return token
    }

    /// Simulates fetching the current user profile
    @MainActor
    func fetchCurrentUser() async throws -> User {
        #if DEBUG
        SecureLogger.shared.auth("Fetching current user profile")
        #endif

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Return mock user
        let user = User.mock()

        #if DEBUG
        SecureLogger.shared.auth("User profile fetched successfully", level: .success)
        #endif

        return user
    }

    // MARK: - Helper Methods

    /// Generates a random referral code
    private func generateReferralCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"

        // Generate format: ABC123 (3 letters + 3 numbers)
        var code = ""

        // 3 random letters
        for _ in 0..<3 {
            let randomIndex = Int.random(in: 0..<letters.count)
            let char = letters[letters.index(letters.startIndex, offsetBy: randomIndex)]
            code.append(char)
        }

        // 3 random numbers
        for _ in 0..<3 {
            let randomIndex = Int.random(in: 0..<numbers.count)
            let char = numbers[numbers.index(numbers.startIndex, offsetBy: randomIndex)]
            code.append(char)
        }

        return code
    }
}

// MARK: - Mock Configuration
extension MockAuthService {
    /// Returns list of valid test referral codes
    var testReferralCodes: [String] {
        return validReferralCodes
    }
}
#endif // DEBUG
