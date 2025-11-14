//
//  ErrorView.swift
//  WiesbadenAfterDark
//
//  Error handling component for displaying user-friendly error messages
//

import SwiftUI

/// User-friendly error view with retry functionality
struct ErrorView: View {
    let error: AppError
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: error.icon)
                .font(.system(size: 60))
                .foregroundColor(.red.opacity(0.8))

            VStack(spacing: 8) {
                Text(error.title)
                    .font(.headline)

                Text(error.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding(40)
    }
}

/// Comprehensive app error types with user-friendly messaging
enum AppError: Error, Equatable {
    case noInternet
    case serverError(message: String? = nil)
    case authenticationFailed
    case userAlreadyExists
    case invalidCode
    case invalidPhoneNumber
    case invalidReferralCode
    case tokenExpired
    case networkTimeout
    case unknown(Error? = nil)

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.noInternet, .noInternet),
             (.authenticationFailed, .authenticationFailed),
             (.userAlreadyExists, .userAlreadyExists),
             (.invalidCode, .invalidCode),
             (.invalidPhoneNumber, .invalidPhoneNumber),
             (.invalidReferralCode, .invalidReferralCode),
             (.tokenExpired, .tokenExpired),
             (.networkTimeout, .networkTimeout):
            return true
        case (.serverError(let lhsMsg), .serverError(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }

    var title: String {
        switch self {
        case .noInternet:
            return "No Internet Connection"
        case .serverError:
            return "Server Error"
        case .authenticationFailed:
            return "Authentication Failed"
        case .userAlreadyExists:
            return "Account Exists"
        case .invalidCode:
            return "Invalid Code"
        case .invalidPhoneNumber:
            return "Invalid Phone Number"
        case .invalidReferralCode:
            return "Invalid Referral Code"
        case .tokenExpired:
            return "Session Expired"
        case .networkTimeout:
            return "Connection Timeout"
        case .unknown:
            return "Something Went Wrong"
        }
    }

    var message: String {
        switch self {
        case .noInternet:
            return "Please check your internet connection and try again."
        case .serverError(let customMessage):
            if let customMessage = customMessage {
                return customMessage
            }
            return "We're having trouble connecting to our servers. Please try again in a moment."
        case .authenticationFailed:
            return "We couldn't verify your credentials. Please try again."
        case .userAlreadyExists:
            return "This phone number is already registered. Try logging in instead."
        case .invalidCode:
            return "The verification code you entered is incorrect. Please check and try again."
        case .invalidPhoneNumber:
            return "Please enter a valid phone number."
        case .invalidReferralCode:
            return "The referral code you entered is invalid. Please check with the person who referred you."
        case .tokenExpired:
            return "Your session has expired. Please sign in again."
        case .networkTimeout:
            return "The request took too long. Please check your connection and try again."
        case .unknown(let error):
            if let error = error {
                return "An unexpected error occurred: \(error.localizedDescription)"
            }
            return "An unexpected error occurred. Please try again."
        }
    }

    var icon: String {
        switch self {
        case .noInternet:
            return "wifi.slash"
        case .serverError:
            return "server.rack"
        case .authenticationFailed:
            return "lock.slash"
        case .userAlreadyExists:
            return "person.crop.circle.badge.exclamationmark"
        case .invalidCode:
            return "123.rectangle"
        case .invalidPhoneNumber:
            return "phone.badge.exclamationmark"
        case .invalidReferralCode:
            return "gift.slash"
        case .tokenExpired:
            return "clock.badge.exclamationmark"
        case .networkTimeout:
            return "timer.slash"
        case .unknown:
            return "exclamationmark.triangle"
        }
    }

    /// Determines if this error type is retryable
    var isRetryable: Bool {
        switch self {
        case .noInternet, .serverError, .networkTimeout, .tokenExpired:
            return true
        case .authenticationFailed, .invalidCode, .invalidPhoneNumber, .invalidReferralCode:
            return false
        case .userAlreadyExists:
            return false
        case .unknown:
            return true
        }
    }
}

// MARK: - Error Conversion Extensions

extension AppError {
    /// Creates an AppError from a generic Error
    static func from(_ error: Error) -> AppError {
        // Check if it's already an AppError
        if let appError = error as? AppError {
            return appError
        }

        // Check for URLError (network errors)
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternet
            case .timedOut:
                return .networkTimeout
            default:
                return .serverError(message: urlError.localizedDescription)
            }
        }

        // Check for AuthError
        if let authError = error as? AuthError {
            switch authError {
            case .invalidPhoneNumber:
                return .invalidPhoneNumber
            case .invalidVerificationCode:
                return .invalidCode
            case .verificationCodeExpired:
                return .invalidCode
            case .invalidReferralCode:
                return .invalidReferralCode
            case .accountAlreadyExists:
                return .userAlreadyExists
            case .networkError:
                return .noInternet
            case .serverError(let message):
                return .serverError(message: message)
            case .unknownError:
                return .unknown(error)
            }
        }

        // Default to unknown error
        return .unknown(error)
    }
}

#Preview {
    VStack(spacing: 40) {
        ErrorView(error: .noInternet, retryAction: {})
        ErrorView(error: .invalidCode, retryAction: nil)
    }
}
