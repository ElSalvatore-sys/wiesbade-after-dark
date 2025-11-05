//
//  AuthServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Core protocol for authentication operations
//  Enables dependency injection and easy testing
//

import Foundation

/// Defines the contract for authentication services
/// This protocol allows us to swap between mock and real implementations
protocol AuthServiceProtocol {
    /// Sends a verification code to the specified phone number via SMS
    /// - Parameter phoneNumber: E.164 formatted phone number (e.g., "+4917012345678")
    /// - Throws: AuthError if the request fails
    func sendVerificationCode(to phoneNumber: String) async throws

    /// Verifies the SMS code for a given phone number
    /// - Parameters:
    ///   - code: The 6-digit verification code
    ///   - phoneNumber: E.164 formatted phone number
    /// - Returns: AuthToken containing JWT and refresh tokens
    /// - Throws: AuthError if verification fails
    func verifyCode(_ code: String, for phoneNumber: String) async throws -> AuthToken

    /// Validates a referral code
    /// - Parameter code: The referral code to validate
    /// - Returns: True if valid, false otherwise
    /// - Throws: AuthError if validation fails
    func validateReferralCode(_ code: String) async throws -> Bool

    /// Creates a user account with optional referral code
    /// - Parameters:
    ///   - phoneNumber: E.164 formatted phone number
    ///   - referralCode: Optional referral code
    /// - Returns: User object with account details
    /// - Throws: AuthError if account creation fails
    @MainActor func createAccount(phoneNumber: String, referralCode: String?) async throws -> User
}

/// Custom errors for authentication operations
enum AuthError: LocalizedError {
    case invalidPhoneNumber
    case invalidVerificationCode
    case verificationCodeExpired
    case invalidReferralCode
    case accountAlreadyExists
    case networkError(Error)
    case serverError(String)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidPhoneNumber:
            return "Please enter a valid phone number"
        case .invalidVerificationCode:
            return "Invalid verification code. Please try again."
        case .verificationCodeExpired:
            return "Verification code has expired. Please request a new one."
        case .invalidReferralCode:
            return "Invalid referral code. Please check and try again."
        case .accountAlreadyExists:
            return "An account with this phone number already exists"
        case .networkError:
            return "Connection error. Please check your internet."
        case .serverError(let message):
            return message
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
}
