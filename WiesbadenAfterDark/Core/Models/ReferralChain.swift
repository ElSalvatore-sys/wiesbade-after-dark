//
//  ReferralChain.swift
//  WiesbadenAfterDark
//
//  SwiftData model for 5-level referral chain tracking
//

import Foundation
import SwiftData

/// Represents a user's referral chain tracking up to 5 levels of referrers
/// Each level receives 25% of points earned by their referrals
@Model
final class ReferralChain: @unchecked Sendable {
    /// Unique identifier for the referral chain record
    @Attribute(.unique) var id: UUID

    /// The user ID this referral chain belongs to
    var userId: UUID

    /// When this referral chain was created
    var createdAt: Date

    // MARK: - Referrer Chain (5 Levels)

    /// Level 1: Direct referrer (immediate person who referred this user)
    var level1ReferrerId: UUID?

    /// Level 2: Referrer of level 1 referrer
    var level2ReferrerId: UUID?

    /// Level 3: Referrer of level 2 referrer
    var level3ReferrerId: UUID?

    /// Level 4: Referrer of level 3 referrer
    var level4ReferrerId: UUID?

    /// Level 5: Referrer of level 4 referrer
    var level5ReferrerId: UUID?

    // MARK: - Lifetime Earnings Per Level

    /// Total points earned from level 1 referrals (25% per transaction)
    var level1TotalEarnings: Decimal

    /// Total points earned from level 2 referrals (25% per transaction)
    var level2TotalEarnings: Decimal

    /// Total points earned from level 3 referrals (25% per transaction)
    var level3TotalEarnings: Decimal

    /// Total points earned from level 4 referrals (25% per transaction)
    var level4TotalEarnings: Decimal

    /// Total points earned from level 5 referrals (25% per transaction)
    var level5TotalEarnings: Decimal

    // MARK: - Initialization

    /// Initialize a new ReferralChain
    init(
        id: UUID = UUID(),
        userId: UUID,
        createdAt: Date = Date(),
        level1ReferrerId: UUID? = nil,
        level2ReferrerId: UUID? = nil,
        level3ReferrerId: UUID? = nil,
        level4ReferrerId: UUID? = nil,
        level5ReferrerId: UUID? = nil,
        level1TotalEarnings: Decimal = 0,
        level2TotalEarnings: Decimal = 0,
        level3TotalEarnings: Decimal = 0,
        level4TotalEarnings: Decimal = 0,
        level5TotalEarnings: Decimal = 0
    ) {
        self.id = id
        self.userId = userId
        self.createdAt = createdAt
        self.level1ReferrerId = level1ReferrerId
        self.level2ReferrerId = level2ReferrerId
        self.level3ReferrerId = level3ReferrerId
        self.level4ReferrerId = level4ReferrerId
        self.level5ReferrerId = level5ReferrerId
        self.level1TotalEarnings = level1TotalEarnings
        self.level2TotalEarnings = level2TotalEarnings
        self.level3TotalEarnings = level3TotalEarnings
        self.level4TotalEarnings = level4TotalEarnings
        self.level5TotalEarnings = level5TotalEarnings
    }
}

// MARK: - Computed Properties
extension ReferralChain {
    /// Total earnings across all levels
    var totalEarnings: Decimal {
        return level1TotalEarnings +
               level2TotalEarnings +
               level3TotalEarnings +
               level4TotalEarnings +
               level5TotalEarnings
    }

    /// Number of active referrer levels in the chain
    var activeReferrerLevels: Int {
        var count = 0
        if level1ReferrerId != nil { count += 1 }
        if level2ReferrerId != nil { count += 1 }
        if level3ReferrerId != nil { count += 1 }
        if level4ReferrerId != nil { count += 1 }
        if level5ReferrerId != nil { count += 1 }
        return count
    }

    /// Array of all referrer IDs (excluding nil values)
    var allReferrerIds: [UUID] {
        var ids: [UUID] = []
        if let level1 = level1ReferrerId { ids.append(level1) }
        if let level2 = level2ReferrerId { ids.append(level2) }
        if let level3 = level3ReferrerId { ids.append(level3) }
        if let level4 = level4ReferrerId { ids.append(level4) }
        if let level5 = level5ReferrerId { ids.append(level5) }
        return ids
    }
}

// MARK: - Helper Methods
extension ReferralChain {
    /// Get referrer ID for a specific level (1-5)
    func getReferrerId(forLevel level: Int) -> UUID? {
        switch level {
        case 1: return level1ReferrerId
        case 2: return level2ReferrerId
        case 3: return level3ReferrerId
        case 4: return level4ReferrerId
        case 5: return level5ReferrerId
        default: return nil
        }
    }

    /// Get total earnings for a specific level (1-5)
    func getTotalEarnings(forLevel level: Int) -> Decimal {
        switch level {
        case 1: return level1TotalEarnings
        case 2: return level2TotalEarnings
        case 3: return level3TotalEarnings
        case 4: return level4TotalEarnings
        case 5: return level5TotalEarnings
        default: return 0
        }
    }

    /// Add earnings to a specific level (1-5)
    func addEarnings(_ amount: Decimal, toLevel level: Int) {
        switch level {
        case 1: level1TotalEarnings += amount
        case 2: level2TotalEarnings += amount
        case 3: level3TotalEarnings += amount
        case 4: level4TotalEarnings += amount
        case 5: level5TotalEarnings += amount
        default: break
        }
    }
}

// MARK: - Mock Data
extension ReferralChain {
    /// Creates a mock referral chain for testing
    static func mock() -> ReferralChain {
        return ReferralChain(
            id: UUID(),
            userId: UUID(),
            createdAt: Date(),
            level1ReferrerId: UUID(),
            level2ReferrerId: UUID(),
            level3ReferrerId: UUID(),
            level1TotalEarnings: 25.50,
            level2TotalEarnings: 15.75,
            level3TotalEarnings: 8.25
        )
    }
}
