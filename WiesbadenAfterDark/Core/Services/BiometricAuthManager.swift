//
//  BiometricAuthManager.swift
//  WiesbadenAfterDark
//
//  Manages biometric authentication (Face ID / Touch ID) for app security
//  Created on 2025-11-06.
//

import Foundation
import LocalAuthentication
import os

/// Manages biometric authentication for the app
/// Provides Face ID / Touch ID authentication for sensitive operations
@MainActor
final class BiometricAuthManager: @unchecked Sendable {

    // MARK: - Singleton

    static let shared = BiometricAuthManager()

    private init() {}

    // MARK: - Properties

    /// The type of biometric authentication available on the device
    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?

        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }

    /// Whether biometric authentication is available on this device
    var isBiometricAvailable: Bool {
        return biometricType != .none
    }

    /// User-friendly name for the biometric type
    var biometricDisplayName: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "Biometric Authentication"
        }
    }

    // MARK: - Authentication Methods

    /// Authenticates the user with biometrics
    /// - Parameter reason: The reason displayed to the user
    /// - Returns: True if authentication succeeded
    /// - Throws: BiometricAuthError if authentication fails
    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        // Check if biometrics are available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            SecureLogger.shared.security("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")", level: .error)
            throw BiometricAuthError.biometricNotAvailable
        }

        // Configure context
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = "Use Passcode"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            if success {
                SecureLogger.shared.logBiometricAuth(success: true)
            }

            return success
        } catch let laError as LAError {
            SecureLogger.shared.logBiometricAuth(success: false, reason: laError.localizedDescription)

            // Map LAError to our custom error
            switch laError.code {
            case .authenticationFailed:
                throw BiometricAuthError.authenticationFailed
            case .userCancel:
                throw BiometricAuthError.userCancelled
            case .userFallback:
                throw BiometricAuthError.userSelectedFallback
            case .biometryNotAvailable:
                throw BiometricAuthError.biometricNotAvailable
            case .biometryNotEnrolled:
                throw BiometricAuthError.biometricNotEnrolled
            case .biometryLockout:
                throw BiometricAuthError.biometricLockout
            default:
                throw BiometricAuthError.unknown(laError)
            }
        }
    }

    /// Authenticates the user for payment operations
    func authenticateForPayment(amount: Decimal) async throws -> Bool {
        let amountStr = CurrencyFormatter.shared.format(amount)
        return try await authenticate(reason: "Authenticate to confirm payment of \(amountStr)")
    }

    /// Authenticates the user for app unlock
    func authenticateForAppUnlock() async throws -> Bool {
        return try await authenticate(reason: "Unlock Wiesbaden After Dark")
    }

    /// Authenticates the user for booking confirmation
    func authenticateForBooking() async throws -> Bool {
        return try await authenticate(reason: "Confirm your table booking")
    }

    /// Authenticates the user for account access
    func authenticateForAccount() async throws -> Bool {
        return try await authenticate(reason: "Access your account settings")
    }

    /// Authenticates the user for points redemption
    func authenticateForPointsRedemption(points: Int) async throws -> Bool {
        return try await authenticate(reason: "Redeem \(points) points")
    }

    // MARK: - Passcode Fallback

    /// Authenticates with device passcode (fallback)
    /// - Parameter reason: The reason displayed to the user
    /// - Returns: True if authentication succeeded
    /// - Throws: BiometricAuthError if authentication fails
    func authenticateWithPasscode(reason: String) async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        // Check if passcode is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            SecureLogger.shared.security("Passcode authentication not available: \(error?.localizedDescription ?? "Unknown error")", level: .error)
            throw BiometricAuthError.passcodeNotSet
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )

            SecureLogger.shared.security("Passcode authentication: \(success ? "success" : "failed")", level: .info)
            return success
        } catch let laError as LAError {
            SecureLogger.shared.security("Passcode authentication failed: \(laError.localizedDescription)", level: .error)
            throw BiometricAuthError.unknown(laError)
        }
    }

    // MARK: - Utility Methods

    /// Checks if a passcode is set on the device
    func isPasscodeSet() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    /// Invalidates any pending biometric contexts
    func invalidate() {
        SecureLogger.shared.security("Biometric context invalidated", level: .default)
    }
}

// MARK: - Biometric Type

enum BiometricType {
    case faceID
    case touchID
    case opticID
    case none
}

// MARK: - Biometric Auth Errors

enum BiometricAuthError: LocalizedError {
    case biometricNotAvailable
    case biometricNotEnrolled
    case biometricLockout
    case authenticationFailed
    case userCancelled
    case userSelectedFallback
    case passcodeNotSet
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device"
        case .biometricNotEnrolled:
            return "Biometric authentication is not set up. Please set up Face ID or Touch ID in Settings"
        case .biometricLockout:
            return "Biometric authentication is locked. Please use your passcode to unlock"
        case .authenticationFailed:
            return "Authentication failed. Please try again"
        case .userCancelled:
            return "Authentication was cancelled"
        case .userSelectedFallback:
            return "Passcode authentication selected"
        case .passcodeNotSet:
            return "No passcode is set on this device"
        case .unknown(let error):
            return "Authentication error: \(error.localizedDescription)"
        }
    }

    var failureReason: String? {
        switch self {
        case .biometricNotAvailable:
            return "This device does not support biometric authentication"
        case .biometricNotEnrolled:
            return "No biometric credentials are enrolled"
        case .biometricLockout:
            return "Too many failed attempts"
        case .authenticationFailed:
            return "The biometric scan did not match"
        case .userCancelled:
            return "User cancelled the authentication prompt"
        case .userSelectedFallback:
            return "User chose to use passcode instead"
        case .passcodeNotSet:
            return "Device passcode must be enabled"
        case .unknown:
            return "An unexpected error occurred"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .biometricNotAvailable:
            return nil
        case .biometricNotEnrolled:
            return "Go to Settings → Face ID & Passcode (or Touch ID & Passcode) to set up biometric authentication"
        case .biometricLockout:
            return "Enter your device passcode to unlock biometric authentication"
        case .authenticationFailed:
            return "Try authenticating again"
        case .userCancelled:
            return "Tap to try again"
        case .userSelectedFallback:
            return "Complete authentication with your passcode"
        case .passcodeNotSet:
            return "Go to Settings to set up a device passcode"
        case .unknown:
            return "Please try again or contact support if the problem persists"
        }
    }
}

// MARK: - Currency Formatter Helper

/// Helper to format currency for biometric prompts
private struct CurrencyFormatter {
    static let shared = CurrencyFormatter()

    private let formatter: NumberFormatter

    private init() {
        formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "de_DE")
    }

    func format(_ amount: Decimal) -> String {
        return formatter.string(from: amount as NSNumber) ?? "€\(amount)"
    }
}
