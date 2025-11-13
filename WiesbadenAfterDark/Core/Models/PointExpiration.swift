//
//  PointExpiration.swift
//  WiesbadenAfterDark
//
//  SwiftData model for tracking point expiration per venue
//

import Foundation
import SwiftData

/// Represents point expiration tracking for a venue membership
@Model
final class PointExpiration: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID

    // Relationships
    var membershipId: UUID
    var userId: UUID
    var venueId: UUID
    var venueName: String

    // Expiration details
    var pointsAtRisk: Int // Number of points that will expire
    var lastActivityDate: Date // Last activity date for this venue
    var expirationDate: Date // When points will expire (lastActivity + 180 days)
    var daysUntilExpiry: Int // Computed days remaining

    // Warning tracking
    var warningShownAt: Date? // When the 30-day warning was first shown
    var lastWarningDate: Date? // Last time we warned the user
    var pushNotificationSent: Bool // Whether push notification was sent
    var userDismissedWarning: Bool // User explicitly dismissed the warning
    var remindLaterDate: Date? // When to remind again if user chose "remind later"

    // Status
    var isExpired: Bool // Whether points have already expired
    var expirationExecutedAt: Date? // When expiration was processed

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        membershipId: UUID,
        userId: UUID,
        venueId: UUID,
        venueName: String,
        pointsAtRisk: Int,
        lastActivityDate: Date,
        expirationDate: Date,
        warningShownAt: Date? = nil,
        lastWarningDate: Date? = nil,
        pushNotificationSent: Bool = false,
        userDismissedWarning: Bool = false,
        remindLaterDate: Date? = nil,
        isExpired: Bool = false,
        expirationExecutedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.membershipId = membershipId
        self.userId = userId
        self.venueId = venueId
        self.venueName = venueName
        self.pointsAtRisk = pointsAtRisk
        self.lastActivityDate = lastActivityDate
        self.expirationDate = expirationDate

        // Calculate days until expiry
        let components = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate)
        self.daysUntilExpiry = max(0, components.day ?? 0)

        self.warningShownAt = warningShownAt
        self.lastWarningDate = lastWarningDate
        self.pushNotificationSent = pushNotificationSent
        self.userDismissedWarning = userDismissedWarning
        self.remindLaterDate = remindLaterDate
        self.isExpired = isExpired
        self.expirationExecutedAt = expirationExecutedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Computed Properties
extension PointExpiration {
    /// Whether this expiration should show a warning (within 30 days)
    var shouldShowWarning: Bool {
        guard !isExpired else { return false }
        guard !userDismissedWarning else { return false }

        // Check if user chose "remind later" and it's not time yet
        if let remindDate = remindLaterDate, Date() < remindDate {
            return false
        }

        return daysUntilExpiry <= 30 && daysUntilExpiry > 0
    }

    /// Whether points have already expired
    var hasExpired: Bool {
        return Date() >= expirationDate || isExpired
    }

    /// Urgency level based on days remaining
    var urgencyLevel: ExpirationUrgency {
        if daysUntilExpiry <= 0 {
            return .expired
        } else if daysUntilExpiry <= 7 {
            return .critical
        } else if daysUntilExpiry <= 14 {
            return .high
        } else if daysUntilExpiry <= 30 {
            return .medium
        } else {
            return .low
        }
    }

    /// Formatted expiration date
    var formattedExpirationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: expirationDate)
    }

    /// Human-readable expiry message
    var expiryMessage: String {
        if hasExpired {
            return "Expired"
        } else if daysUntilExpiry == 0 {
            return "Expires today"
        } else if daysUntilExpiry == 1 {
            return "Expires tomorrow"
        } else if daysUntilExpiry <= 7 {
            return "Expires in \(daysUntilExpiry) days"
        } else {
            return "Expires \(formattedExpirationDate)"
        }
    }

    /// Update days until expiry (call this to refresh the computed value)
    func updateDaysUntilExpiry() {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate)
        self.daysUntilExpiry = max(0, components.day ?? 0)
    }
}

// MARK: - Urgency Level
enum ExpirationUrgency: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    case expired = "Expired"

    var color: String {
        switch self {
        case .low:
            return "textSecondary"
        case .medium:
            return "warning"
        case .high:
            return "orange"
        case .critical, .expired:
            return "error"
        }
    }

    var icon: String {
        switch self {
        case .low:
            return "clock"
        case .medium:
            return "exclamationmark.circle"
        case .high, .critical:
            return "exclamationmark.triangle.fill"
        case .expired:
            return "xmark.circle.fill"
        }
    }
}

// MARK: - Mock Data
extension PointExpiration {
    /// Create a mock expiration for testing
    static func mock(
        userId: UUID,
        venueId: UUID,
        venueName: String,
        daysUntilExpiry: Int = 15
    ) -> PointExpiration {
        let lastActivity = Calendar.current.date(byAdding: .day, value: -(180 - daysUntilExpiry), to: Date()) ?? Date()
        let expiration = Calendar.current.date(byAdding: .day, value: daysUntilExpiry, to: Date()) ?? Date()

        return PointExpiration(
            membershipId: UUID(),
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            pointsAtRisk: Int.random(in: 200...800),
            lastActivityDate: lastActivity,
            expirationDate: expiration,
            warningShownAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            pushNotificationSent: daysUntilExpiry <= 7
        )
    }

    /// Create multiple mock expirations
    static func mockExpirations(userId: UUID) -> [PointExpiration] {
        let venues = [
            ("The Golden Lion", 3),
            ("Riverside Lounge", 15),
            ("Jazz Club Wiesbaden", 25),
            ("Cocktail Paradise", 7)
        ]

        return venues.map { (name, days) in
            mock(userId: userId, venueId: UUID(), venueName: name, daysUntilExpiry: days)
        }
    }
}
