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

    /// Whether the phone number has been verified
    var phoneVerified: Bool

    /// User's first name (optional)
    var firstName: String?

    /// User's last name (optional)
    var lastName: String?

    /// User's email address (optional)
    var email: String?

    /// URL to user's profile avatar (optional)
    var avatarURL: String?

    /// User's unique referral code for inviting others
    var referralCode: String

    /// Referral code of the user who referred this user (optional)
    var referredByCode: String?

    /// ID of the user who referred this user (optional)
    var referredBy: UUID?

    /// Total number of users this user has referred
    var totalReferrals: Int

    /// Total points earned across all venues
    var totalPointsEarned: Double

    /// Total points spent across all venues
    var totalPointsSpent: Double

    /// Total points available across all venues
    var totalPointsAvailable: Double

    /// Whether the user's email is verified
    var isVerified: Bool

    /// Whether the user account is active
    var isActive: Bool

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
        phoneVerified: Bool = false,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        avatarURL: String? = nil,
        referralCode: String,
        referredByCode: String? = nil,
        referredBy: UUID? = nil,
        totalReferrals: Int = 0,
        totalPointsEarned: Double = 0.0,
        totalPointsSpent: Double = 0.0,
        totalPointsAvailable: Double = 0.0,
        isVerified: Bool = false,
        isActive: Bool = true,
        createdAt: Date = Date(),
        lastLoginAt: Date? = nil,
        preferredLanguage: String = "de"
    ) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.phoneCountryCode = phoneCountryCode
        self.phoneVerified = phoneVerified
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatarURL = avatarURL
        self.referralCode = referralCode
        self.referredByCode = referredByCode
        self.referredBy = referredBy
        self.totalReferrals = totalReferrals
        self.totalPointsEarned = totalPointsEarned
        self.totalPointsSpent = totalPointsSpent
        self.totalPointsAvailable = totalPointsAvailable
        self.isVerified = isVerified
        self.isActive = isActive
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

    /// Full name combining first and last name
    var fullName: String? {
        switch (firstName, lastName) {
        case (let first?, let last?):
            return "\(first) \(last)"
        case (let first?, nil):
            return first
        case (nil, let last?):
            return last
        case (nil, nil):
            return nil
        }
    }

    /// Display name with fallback to phone number
    var displayName: String {
        return fullName ?? formattedPhoneNumber
    }

    /// Total points for display (integer)
    var totalPoints: Int {
        return Int(totalPointsAvailable)
    }

    /// Current membership tier based on total points earned
    var currentTier: MembershipTier {
        switch totalPointsEarned {
        case 0..<500:
            return .bronze
        case 500..<2000:
            return .silver
        case 2000..<5000:
            return .gold
        default:
            return .platinum
        }
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
            phoneVerified: true,
            firstName: "Test",
            lastName: "User",
            referralCode: "TEST\(Int.random(in: 100...999))",
            totalReferrals: 0,
            totalPointsEarned: 150.0,
            totalPointsSpent: 50.0,
            totalPointsAvailable: 100.0,
            isVerified: true,
            isActive: true
        )
    }
}
