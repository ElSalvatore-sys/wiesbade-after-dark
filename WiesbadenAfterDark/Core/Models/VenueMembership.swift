//
//  VenueMembership.swift
//  WiesbadenAfterDark
//
//  SwiftData model for user's venue membership
//

import Foundation
import SwiftData

/// Represents a user's membership at a specific venue
@Model
final class VenueMembership: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var userId: UUID
    var venueId: UUID

    var joinedAt: Date
    var pointsBalance: Int
    var tier: MembershipTier

    // Stats
    var totalSpent: Decimal
    var totalVisits: Int
    var totalPointsEarned: Int
    var totalPointsRedeemed: Int

    // Status
    var isActive: Bool
    var lastVisitAt: Date?

    // Expiration tracking
    var lastActivityDate: Date // Last activity for expiration calculation (check-in, redemption, etc.)
    var nextExpirationDate: Date? // Next scheduled expiration date (lastActivity + 180 days)

    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        venueId: UUID,
        joinedAt: Date = Date(),
        pointsBalance: Int = 0,
        tier: MembershipTier = .bronze,
        totalSpent: Decimal = 0,
        totalVisits: Int = 0,
        totalPointsEarned: Int = 0,
        totalPointsRedeemed: Int = 0,
        isActive: Bool = true,
        lastVisitAt: Date? = nil,
        lastActivityDate: Date = Date(),
        nextExpirationDate: Date? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.joinedAt = joinedAt
        self.pointsBalance = pointsBalance
        self.tier = tier
        self.totalSpent = totalSpent
        self.totalVisits = totalVisits
        self.totalPointsEarned = totalPointsEarned
        self.totalPointsRedeemed = totalPointsRedeemed
        self.isActive = isActive
        self.lastVisitAt = lastVisitAt
        self.lastActivityDate = lastActivityDate
        self.nextExpirationDate = nextExpirationDate
        self.updatedAt = updatedAt
    }
}

// MARK: - Computed Properties
extension VenueMembership {
    /// Formatted points balance
    var formattedPointsBalance: String {
        return "\(pointsBalance) points"
    }

    /// Formatted total spent
    var formattedTotalSpent: String {
        return "€\(NSDecimalNumber(decimal: totalSpent).intValue)"
    }

    /// Member since display
    var memberSinceText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return "Member since \(formatter.string(from: joinedAt))"
    }

    /// Calculate tier based on points earned
    var calculatedTier: MembershipTier {
        if totalPointsEarned >= 5000 {
            return .platinum
        } else if totalPointsEarned >= 2500 {
            return .gold
        } else if totalPointsEarned >= 1000 {
            return .silver
        } else {
            return .bronze
        }
    }

    // MARK: - Expiration Properties

    /// Calculate expiration date based on last activity (180 days from last activity)
    var calculatedExpirationDate: Date {
        return Calendar.current.date(byAdding: .day, value: 180, to: lastActivityDate) ?? lastActivityDate
    }

    /// Days until points expire
    var daysUntilExpiry: Int {
        let expirationDate = nextExpirationDate ?? calculatedExpirationDate
        let components = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate)
        return max(0, components.day ?? 0)
    }

    /// Whether points are expiring soon (within 30 days)
    var hasExpiringPoints: Bool {
        guard pointsBalance > 0 else { return false }
        return daysUntilExpiry <= 30 && daysUntilExpiry > 0
    }

    /// Whether points have already expired
    var hasExpiredPoints: Bool {
        let expirationDate = nextExpirationDate ?? calculatedExpirationDate
        return Date() >= expirationDate && pointsBalance > 0
    }

    /// Is expiring soon (within 30 days but more than 7 days)
    var isExpiringSoon: Bool {
        return daysUntilExpiry > 7 && daysUntilExpiry <= 30
    }

    /// Is expiring critically soon (within 7 days)
    var isExpiringCritical: Bool {
        return daysUntilExpiry > 0 && daysUntilExpiry <= 7
    }

    /// Points that will expire (all points if within expiration window)
    var expiringPoints: Int {
        return hasExpiringPoints || hasExpiredPoints ? pointsBalance : 0
    }

    /// Human-readable expiration message
    var expirationMessage: String {
        if hasExpiredPoints {
            return "\(pointsBalance) points expired"
        } else if daysUntilExpiry == 0 {
            return "\(pointsBalance) points expire today"
        } else if daysUntilExpiry == 1 {
            return "\(pointsBalance) points expire tomorrow"
        } else if hasExpiringPoints {
            return "\(pointsBalance) points expire in \(daysUntilExpiry) days"
        } else {
            return "No expiring points"
        }
    }
}

// MARK: - Mock Data
extension VenueMembership {
    /// Mock membership for testing
    static func mockMembership(userId: UUID, venueId: UUID) -> VenueMembership {
        let joinDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()

        return VenueMembership(
            userId: userId,
            venueId: venueId,
            joinedAt: joinDate,
            pointsBalance: 450,
            tier: .gold,
            totalSpent: 285.50,
            totalVisits: 8,
            totalPointsEarned: 2850,
            totalPointsRedeemed: 2400,
            lastVisitAt: Calendar.current.date(byAdding: .day, value: -3, to: Date())
        )
    }
}
