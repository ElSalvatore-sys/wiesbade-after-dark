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
