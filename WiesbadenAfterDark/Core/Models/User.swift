//
//  User.swift
//  WiesbadenAfterDark
//
//  SwiftData model for user accounts
//

import Foundation
import SwiftData

/// Represents a user account in the WiesbadenAfterDark platform
@Model
final class User: @unchecked Sendable {
    /// Unique identifier for the user
    @Attribute(.unique) var id: UUID

    /// User's phone number in E.164 format (e.g., "+4917012345678")
    var phoneNumber: String

    /// Country code for the phone number (e.g., "+49")
    var phoneCountryCode: String

    /// User's display name (optional)
    var name: String?

    /// User's email address (optional)
    var email: String?

    /// URL to user's profile avatar (optional)
    var avatarURL: String?

    /// User's unique referral code for inviting others
    var referralCode: String

    /// ID of the user who referred this user (optional)
    var referredBy: UUID?

    /// Total points balance
    var pointsBalance: Int

    /// Account creation timestamp
    var createdAt: Date

    /// Last login timestamp
    var lastLoginAt: Date?

    /// User's preferred language (ISO 639-1 code)
    var preferredLanguage: String

    /// Initialize a new User
    init(
        id: UUID = UUID(),
        phoneNumber: String,
        phoneCountryCode: String = "+49",
        name: String? = nil,
        email: String? = nil,
        avatarURL: String? = nil,
        referralCode: String,
        referredBy: UUID? = nil,
        pointsBalance: Int = 0,
        createdAt: Date = Date(),
        lastLoginAt: Date? = nil,
        preferredLanguage: String = "de"
    ) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.phoneCountryCode = phoneCountryCode
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.referralCode = referralCode
        self.referredBy = referredBy
        self.pointsBalance = pointsBalance
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.preferredLanguage = preferredLanguage
    }
}

// MARK: - Computed Properties
extension User {
    /// Full formatted phone number for display
    var formattedPhoneNumber: String {
        return phoneCountryCode + " " + phoneNumber.formattedAsPhoneNumber()
    }

    /// Display name or phone number fallback
    var displayName: String {
        return name ?? formattedPhoneNumber
    }
}

// MARK: - Mock User Generation
extension User {
    /// Creates a mock user for testing
    static func mock() -> User {
        return User(
            id: UUID(),
            phoneNumber: "17012345678",
            phoneCountryCode: "+49",
            name: "Test User",
            referralCode: "TEST\(Int.random(in: 100...999))",
            pointsBalance: 100
        )
    }
}
