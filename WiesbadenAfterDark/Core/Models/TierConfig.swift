//
//  TierConfig.swift
//  WiesbadenAfterDark
//
//  Tier configuration models for venue-specific membership tiers
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Tier Perk

/// Represents a perk/benefit available at a specific tier
struct TierPerk: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var icon: String // SF Symbol name

    init(id: UUID = UUID(), name: String, description: String, icon: String) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
    }
}

// MARK: - Default Tier Perks

extension TierPerk {
    static let defaultBronzePerks: [TierPerk] = [
        TierPerk(name: "Points Earning", description: "Earn 1x points on every purchase", icon: "star.fill")
    ]

    static let defaultSilverPerks: [TierPerk] = [
        TierPerk(name: "Bonus Points", description: "Earn 1.2x points on every purchase", icon: "star.fill"),
        TierPerk(name: "Birthday Bonus", description: "Special birthday reward", icon: "gift.fill")
    ]

    static let defaultGoldPerks: [TierPerk] = [
        TierPerk(name: "Premium Points", description: "Earn 1.5x points on every purchase", icon: "star.fill"),
        TierPerk(name: "Birthday Bonus", description: "Enhanced birthday reward", icon: "gift.fill"),
        TierPerk(name: "Early Event Access", description: "Priority booking for events", icon: "calendar.badge.clock")
    ]

    static let defaultPlatinumPerks: [TierPerk] = [
        TierPerk(name: "Maximum Points", description: "Earn 2x points on every purchase", icon: "star.fill"),
        TierPerk(name: "VIP Birthday", description: "Exclusive birthday celebration", icon: "gift.fill"),
        TierPerk(name: "Early Event Access", description: "First access to all events", icon: "calendar.badge.clock"),
        TierPerk(name: "Reserved Seating", description: "Priority table reservations", icon: "chair.fill"),
        TierPerk(name: "Skip-the-Line", description: "Fast-track venue entry", icon: "figure.walk.motion")
    ]
}

// MARK: - Badge Configuration

/// Represents a custom achievement badge
@Model
final class BadgeConfig: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var venueId: UUID

    var name: String
    var badgeDescription: String
    var iconName: String
    var color: String // Hex color

    // Requirements
    var requiredVisits: Int?
    var requiredSpending: Decimal?
    var requiredReferrals: Int?
    var requiredDays: Int? // e.g., "Visit 5 times in 30 days"

    // Rewards
    var pointsReward: Int
    var bonusMultiplier: Decimal? // e.g., 1.1 for 10% bonus

    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        venueId: UUID,
        name: String,
        description: String,
        iconName: String,
        color: String,
        requiredVisits: Int? = nil,
        requiredSpending: Decimal? = nil,
        requiredReferrals: Int? = nil,
        requiredDays: Int? = nil,
        pointsReward: Int = 0,
        bonusMultiplier: Decimal? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.venueId = venueId
        self.name = name
        self.badgeDescription = description
        self.iconName = iconName
        self.color = color
        self.requiredVisits = requiredVisits
        self.requiredSpending = requiredSpending
        self.requiredReferrals = requiredReferrals
        self.requiredDays = requiredDays
        self.pointsReward = pointsReward
        self.bonusMultiplier = bonusMultiplier
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Venue Tier Configuration

/// Venue-specific tier configuration (customizable by venue owner)
@Model
final class VenueTierConfig: @unchecked Sendable {
    @Attribute(.unique) var id: UUID
    var venueId: UUID

    // MARK: - Tier Thresholds (based on total spending)

    var bronzeMin: Decimal = 0
    var bronzeMax: Decimal = 499
    var silverMin: Decimal = 500
    var silverMax: Decimal = 1999
    var goldMin: Decimal = 2000
    var goldMax: Decimal = 4999
    var platinumMin: Decimal = 5000

    // MARK: - Points Multipliers per Tier

    var bronzeMultiplier: Decimal = 1.0
    var silverMultiplier: Decimal = 1.2
    var goldMultiplier: Decimal = 1.5
    var platinumMultiplier: Decimal = 2.0

    // MARK: - Perks per Tier (JSON encoded)

    var bronzePerksJSON: String
    var silverPerksJSON: String
    var goldPerksJSON: String
    var platinumPerksJSON: String

    // MARK: - Tier Maintenance Rules

    var monthlySpendingRequired: Decimal? // Required monthly spending to maintain tier
    var inactivityDowngradeAfterDays: Int? // Days of inactivity before downgrade
    var hasGracePeriod: Bool = true
    var gracePeriodDays: Int = 30
    var tierResetPolicy: TierResetPolicy = .never

    // MARK: - Custom Colors (optional)

    var bronzeColor: String? // Hex color override
    var silverColor: String?
    var goldColor: String?
    var platinumColor: String?

    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        venueId: UUID,
        bronzeMin: Decimal = 0,
        bronzeMax: Decimal = 499,
        silverMin: Decimal = 500,
        silverMax: Decimal = 1999,
        goldMin: Decimal = 2000,
        goldMax: Decimal = 4999,
        platinumMin: Decimal = 5000,
        bronzeMultiplier: Decimal = 1.0,
        silverMultiplier: Decimal = 1.2,
        goldMultiplier: Decimal = 1.5,
        platinumMultiplier: Decimal = 2.0,
        bronzePerks: [TierPerk] = TierPerk.defaultBronzePerks,
        silverPerks: [TierPerk] = TierPerk.defaultSilverPerks,
        goldPerks: [TierPerk] = TierPerk.defaultGoldPerks,
        platinumPerks: [TierPerk] = TierPerk.defaultPlatinumPerks,
        monthlySpendingRequired: Decimal? = nil,
        inactivityDowngradeAfterDays: Int? = nil,
        hasGracePeriod: Bool = true,
        gracePeriodDays: Int = 30,
        tierResetPolicy: TierResetPolicy = .never,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.venueId = venueId
        self.bronzeMin = bronzeMin
        self.bronzeMax = bronzeMax
        self.silverMin = silverMin
        self.silverMax = silverMax
        self.goldMin = goldMin
        self.goldMax = goldMax
        self.platinumMin = platinumMin
        self.bronzeMultiplier = bronzeMultiplier
        self.silverMultiplier = silverMultiplier
        self.goldMultiplier = goldMultiplier
        self.platinumMultiplier = platinumMultiplier
        self.monthlySpendingRequired = monthlySpendingRequired
        self.inactivityDowngradeAfterDays = inactivityDowngradeAfterDays
        self.hasGracePeriod = hasGracePeriod
        self.gracePeriodDays = gracePeriodDays
        self.tierResetPolicy = tierResetPolicy
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // Encode perks to JSON
        self.bronzePerksJSON = Self.encodePerks(bronzePerks)
        self.silverPerksJSON = Self.encodePerks(silverPerks)
        self.goldPerksJSON = Self.encodePerks(goldPerks)
        self.platinumPerksJSON = Self.encodePerks(platinumPerks)
    }

    // MARK: - Helper Methods

    private static func encodePerks(_ perks: [TierPerk]) -> String {
        if let data = try? JSONEncoder().encode(perks),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "[]"
    }

    private static func decodePerks(_ json: String) -> [TierPerk] {
        guard let data = json.data(using: .utf8),
              let perks = try? JSONDecoder().decode([TierPerk].self, from: data) else {
            return []
        }
        return perks
    }
}

// MARK: - Computed Properties

extension VenueTierConfig {
    /// Decoded perks by tier
    var bronzePerks: [TierPerk] {
        Self.decodePerks(bronzePerksJSON)
    }

    var silverPerks: [TierPerk] {
        Self.decodePerks(silverPerksJSON)
    }

    var goldPerks: [TierPerk] {
        Self.decodePerks(goldPerksJSON)
    }

    var platinumPerks: [TierPerk] {
        Self.decodePerks(platinumPerksJSON)
    }

    /// Get tier for a given spending amount
    func tier(for spending: Decimal) -> MembershipTier {
        if spending >= platinumMin {
            return .platinum
        } else if spending >= goldMin {
            return .gold
        } else if spending >= silverMin {
            return .silver
        } else {
            return .bronze
        }
    }

    /// Get spending threshold for a tier
    func threshold(for tier: MembershipTier) -> Decimal {
        switch tier {
        case .bronze: return bronzeMax
        case .silver: return silverMax
        case .gold: return goldMax
        case .platinum: return platinumMin
        }
    }

    /// Get minimum spending for a tier
    func minimum(for tier: MembershipTier) -> Decimal {
        switch tier {
        case .bronze: return bronzeMin
        case .silver: return silverMin
        case .gold: return goldMin
        case .platinum: return platinumMin
        }
    }

    /// Get multiplier for a tier
    func multiplier(for tier: MembershipTier) -> Decimal {
        switch tier {
        case .bronze: return bronzeMultiplier
        case .silver: return silverMultiplier
        case .gold: return goldMultiplier
        case .platinum: return platinumMultiplier
        }
    }

    /// Get perks for a tier
    func perks(for tier: MembershipTier) -> [TierPerk] {
        switch tier {
        case .bronze: return bronzePerks
        case .silver: return silverPerks
        case .gold: return goldPerks
        case .platinum: return platinumPerks
        }
    }

    /// Get custom color for a tier (if set)
    func customColor(for tier: MembershipTier) -> String? {
        switch tier {
        case .bronze: return bronzeColor
        case .silver: return silverColor
        case .gold: return goldColor
        case .platinum: return platinumColor
        }
    }
}

// MARK: - Tier Reset Policy

enum TierResetPolicy: String, Codable, CaseIterable {
    case never = "Never"
    case annually = "Annually"
    case quarterly = "Quarterly"
    case monthly = "Monthly"

    var displayName: String { rawValue }

    var description: String {
        switch self {
        case .never: return "Tiers are permanent and never reset"
        case .annually: return "Tiers reset every year on January 1st"
        case .quarterly: return "Tiers reset every 3 months"
        case .monthly: return "Tiers reset every month"
        }
    }
}

// MARK: - Tier Progress Data

/// Represents a user's progress toward the next tier
struct TierProgress: Identifiable {
    var id: UUID = UUID()
    var currentTier: MembershipTier
    var nextTier: MembershipTier?
    var currentSpending: Decimal
    var nextTierThreshold: Decimal?
    var progressPercentage: Double
    var amountToNextTier: Decimal?
    var daysAtCurrentTier: Int
    var perks: [TierPerk]
    var multiplier: Decimal

    /// Formatted progress text
    var progressText: String {
        guard let nextTier = nextTier,
              let threshold = nextTierThreshold,
              let amount = amountToNextTier else {
            return "Maximum tier reached!"
        }

        let currentFormatted = String(format: "€%.0f", NSDecimalNumber(decimal: currentSpending).doubleValue)
        let thresholdFormatted = String(format: "€%.0f", NSDecimalNumber(decimal: threshold).doubleValue)

        return "\(currentFormatted) / \(thresholdFormatted) to \(nextTier.displayName)"
    }

    /// Formatted amount needed
    var amountNeededText: String? {
        guard let amount = amountToNextTier, let nextTier = nextTier else {
            return nil
        }

        let formatted = String(format: "€%.0f", NSDecimalNumber(decimal: amount).doubleValue)
        return "\(formatted) more to \(nextTier.displayName) tier"
    }
}

// MARK: - Mock Data

extension VenueTierConfig {
    /// Create default configuration for a venue
    static func defaultConfig(venueId: UUID) -> VenueTierConfig {
        return VenueTierConfig(venueId: venueId)
    }

    /// Create mock configuration for testing
    static func mock(venueId: UUID) -> VenueTierConfig {
        return VenueTierConfig(
            venueId: venueId,
            bronzeMax: 299,
            silverMin: 300,
            silverMax: 999,
            goldMin: 1000,
            goldMax: 2999,
            platinumMin: 3000,
            monthlySpendingRequired: 100,
            inactivityDowngradeAfterDays: 90,
            hasGracePeriod: true,
            gracePeriodDays: 30,
            tierResetPolicy: .annually
        )
    }
}

extension BadgeConfig {
    /// Mock badge configurations
    static func mockBadges(venueId: UUID) -> [BadgeConfig] {
        return [
            BadgeConfig(
                venueId: venueId,
                name: "Regular",
                description: "Visit 10 times in 30 days",
                iconName: "calendar.badge.checkmark",
                color: "#3B82F6",
                requiredVisits: 10,
                requiredDays: 30,
                pointsReward: 500
            ),
            BadgeConfig(
                venueId: venueId,
                name: "Big Spender",
                description: "Spend €1,000 total",
                iconName: "dollarsign.circle.fill",
                color: "#10B981",
                requiredSpending: 1000,
                pointsReward: 1000
            ),
            BadgeConfig(
                venueId: venueId,
                name: "Ambassador",
                description: "Refer 5 friends",
                iconName: "person.2.fill",
                color: "#F59E0B",
                requiredReferrals: 5,
                pointsReward: 750,
                bonusMultiplier: 1.1
            )
        ]
    }
}
