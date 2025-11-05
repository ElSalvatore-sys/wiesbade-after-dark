//
//  MockAuthService.swift
//  WiesbadenAfterDark
//
//  Mock implementation of AuthServiceProtocol for testing
//  This will be replaced with real API calls once backend is deployed
//

import Foundation

/// Mock authentication service for development and testing
/// Always returns successful responses with simulated delays
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
        print("📱 [MockAuthService] Sending verification code to: \(phoneNumber)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // In mock mode, we always succeed
        print("✅ [MockAuthService] Verification code sent successfully")
        print("💡 [MockAuthService] Any 6-digit code will work for verification")
    }

    /// Simulates verifying the SMS code
    func verifyCode(_ code: String, for phoneNumber: String) async throws -> AuthToken {
        print("🔐 [MockAuthService] Verifying code: \(code) for phone: \(phoneNumber)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Validate code format (6 digits)
        guard code.count == 6, code.allSatisfy({ $0.isNumber }) else {
            print("❌ [MockAuthService] Invalid code format")
            throw AuthError.invalidVerificationCode
        }

        // In mock mode, accept any 6-digit code
        print("✅ [MockAuthService] Code verified successfully")

        // Generate mock token
        let token = AuthToken.mock()
        print("🎫 [MockAuthService] Generated mock token: \(token.accessToken)")

        return token
    }

    /// Validates a referral code
    func validateReferralCode(_ code: String) async throws -> Bool {
        print("🎁 [MockAuthService] Validating referral code: \(code)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Check if code is in our valid list
        let isValid = validReferralCodes.contains(code.uppercased())

        if isValid {
            print("✅ [MockAuthService] Referral code is valid")
        } else {
            print("❌ [MockAuthService] Referral code is invalid")
        }

        return isValid
    }

    /// Creates a mock user account
    @MainActor
    func createAccount(phoneNumber: String, referralCode: String?) async throws -> User {
        print("👤 [MockAuthService] Creating account for: \(phoneNumber)")

        if let code = referralCode {
            print("🎁 [MockAuthService] Using referral code: \(code)")
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Generate a unique referral code for this user
        let userReferralCode = generateReferralCode()

        // Create mock user
        let user = User(
            id: UUID(),
            phoneNumber: phoneNumber.replacingOccurrences(of: " ", with: ""),
            phoneCountryCode: "+49",
            name: nil,
            email: nil,
            avatarURL: nil,
            referralCode: userReferralCode,
            referredBy: nil,
            pointsBalance: referralCode != nil ? 50 : 0, // Bonus points if referred
            createdAt: Date(),
            lastLoginAt: Date(),
            preferredLanguage: "de"
        )

        print("✅ [MockAuthService] Account created successfully")
        print("🎫 [MockAuthService] User referral code: \(userReferralCode)")

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
