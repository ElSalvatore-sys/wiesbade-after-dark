//
//  ProductionErrorHandler.swift
//  WiesbadenAfterDark
//
//  Centralized error handling for production with user-friendly messages
//

import Foundation

/// Production-safe error handler that converts technical errors to user-friendly messages
enum ProductionErrorHandler {

    /// Converts API errors to user-friendly messages
    static func handleAPIError(_ error: Error) -> String {
        // Log the technical error for debugging
        ProductionLogger.shared.logError(error, context: "API")

        // Return user-friendly message
        if let apiError = error as? APIError {
            return getUserFriendlyMessage(for: apiError)
        } else if let authError = error as? AuthError {
            return getUserFriendlyMessage(for: authError)
        } else if let urlError = error as? URLError {
            return getNetworkErrorMessage(for: urlError)
        } else {
            return "Something went wrong. Please try again."
        }
    }

    /// User-friendly messages for API errors
    private static func getUserFriendlyMessage(for error: APIError) -> String {
        switch error {
        case .invalidURL:
            return "Invalid request. Please try again."

        case .invalidResponse:
            return "We couldn't connect to the server. Please check your internet connection."

        case .httpError(let statusCode, let message):
            return getHTTPErrorMessage(statusCode: statusCode, message: message)

        case .decodingError:
            return "We're having trouble processing the response. Please try again later."

        case .networkError(let underlyingError):
            if let urlError = underlyingError as? URLError {
                return getNetworkErrorMessage(for: urlError)
            }
            return "Network error. Please check your connection and try again."

        case .unauthorized:
            return "Your session has expired. Please sign in again."

        case .serverError:
            return "Our servers are experiencing issues. Please try again in a few minutes."
        }
    }

    /// User-friendly messages for Auth errors
    private static func getUserFriendlyMessage(for error: AuthError) -> String {
        switch error {
        case .invalidPhoneNumber:
            return "Please enter a valid phone number."

        case .invalidVerificationCode:
            return "Invalid code. Please check and try again."

        case .verificationCodeExpired:
            return "Your code has expired. Please request a new one."

        case .invalidReferralCode:
            return "Invalid referral code. Please check and try again."

        case .accountAlreadyExists:
            return "An account with this phone number already exists."

        case .networkError:
            return "Connection error. Please check your internet."

        case .serverError(let message):
            // Don't expose technical server errors to users
            ProductionLogger.shared.log("Server error: \(message)", level: .error, category: "Auth")
            return "We're experiencing technical difficulties. Please try again later."

        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }

    /// User-friendly messages for HTTP status codes
    private static func getHTTPErrorMessage(statusCode: Int, message: String?) -> String {
        switch statusCode {
        case 400:
            return message ?? "Invalid request. Please check your information and try again."

        case 401:
            return "Your session has expired. Please sign in again."

        case 403:
            return "You don't have permission to access this resource."

        case 404:
            return "The requested resource was not found."

        case 429:
            return "Too many requests. Please wait a moment and try again."

        case 500...599:
            return "Our servers are experiencing issues. Please try again later."

        default:
            return message ?? "Something went wrong. Please try again."
        }
    }

    /// User-friendly messages for network errors
    private static func getNetworkErrorMessage(for error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet:
            return "No internet connection. Please check your network and try again."

        case .networkConnectionLost:
            return "Connection lost. Please check your network and try again."

        case .timedOut:
            return "Request timed out. Please check your connection and try again."

        case .cannotFindHost, .cannotConnectToHost:
            return "Can't reach the server. Please try again later."

        case .dnsLookupFailed:
            return "Network error. Please check your internet connection."

        default:
            return "Network error. Please check your connection and try again."
        }
    }
}
