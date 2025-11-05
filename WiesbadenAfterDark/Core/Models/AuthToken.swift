//
//  AuthToken.swift
//  WiesbadenAfterDark
//
//  Model for JWT authentication tokens
//

import Foundation

/// Represents authentication tokens returned from the backend
struct AuthToken: Codable {
    /// JWT access token for API authentication
    let accessToken: String

    /// Refresh token for obtaining new access tokens
    let refreshToken: String

    /// Token expiration timestamp
    let expiresAt: Date

    /// Token type (usually "Bearer")
    let tokenType: String

    /// Initializes a new AuthToken
    init(accessToken: String, refreshToken: String, expiresAt: Date, tokenType: String = "Bearer") {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.tokenType = tokenType
    }

    /// Checks if the access token is expired
    var isExpired: Bool {
        return Date() >= expiresAt
    }

    /// Returns the token in Authorization header format
    var authorizationHeader: String {
        return "\(tokenType) \(accessToken)"
    }
}

// MARK: - Mock Token Generation
extension AuthToken {
    /// Creates a mock token for testing purposes
    /// - Returns: Mock AuthToken valid for 24 hours
    static func mock() -> AuthToken {
        let expiresAt = Date().addingTimeInterval(24 * 60 * 60) // 24 hours
        return AuthToken(
            accessToken: "mock_jwt_token_\(UUID().uuidString.prefix(12))",
            refreshToken: "mock_refresh_token_\(UUID().uuidString.prefix(12))",
            expiresAt: expiresAt,
            tokenType: "Bearer"
        )
    }
}
