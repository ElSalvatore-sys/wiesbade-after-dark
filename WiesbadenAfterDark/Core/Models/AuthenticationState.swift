//
//  AuthenticationState.swift
//  WiesbadenAfterDark
//
//  Represents the current authentication state of the app
//

import Foundation

/// Represents the various states of user authentication
enum AuthenticationState: Equatable {
    /// Initial state, checking for existing session
    case initializing

    /// No authenticated user, showing onboarding/login
    case unauthenticated

    /// User is in the process of authenticating
    case authenticating

    /// User is authenticated with their user data
    case authenticated(User)

    /// Authentication failed with an error
    case error(String)

    /// Helper to check if user is authenticated
    var isAuthenticated: Bool {
        if case .authenticated = self {
            return true
        }
        return false
    }

    /// Helper to get the authenticated user
    var user: User? {
        if case .authenticated(let user) = self {
            return user
        }
        return nil
    }

    /// Helper to get error message
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }

    /// Implement Equatable for state comparisons
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing),
             (.unauthenticated, .unauthenticated),
             (.authenticating, .authenticating):
            return true
        case (.authenticated(let lhsUser), .authenticated(let rhsUser)):
            return lhsUser.id == rhsUser.id
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

/// Route enum for navigation in the onboarding flow
enum OnboardingRoute: Hashable {
    case welcome
    case phoneInput
    case verification(phoneNumber: String)
    case nameInput
    case referralCode
}
