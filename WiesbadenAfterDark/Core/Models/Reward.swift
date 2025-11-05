//
//  Reward.swift
//  WiesbadenAfterDark
//
//  SwiftData model for redeemable rewards
//

import Foundation
import SwiftData

/// Represents a redeemable reward at a venue
@Model
final class Reward: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var venueId: UUID

    var name: String
    var rewardDescription: String
    var imageURL: String?

    var pointsCost: Int
    var cashValue: Decimal

    var stock: Int? // nil = unlimited
    var isActive: Bool

    var category: String?
    var expiryDays: Int? // Days until redemption expires

    var createdAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        venueId: UUID,
        name: String,
        description: String,
        imageURL: String? = nil,
        pointsCost: Int,
        cashValue: Decimal,
        stock: Int? = nil,
        isActive: Bool = true,
        category: String? = nil,
        expiryDays: Int? = 30,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.venueId = venueId
        self.name = name
        self.rewardDescription = description
        self.imageURL = imageURL
        self.pointsCost = pointsCost
        self.cashValue = cashValue
        self.stock = stock
        self.isActive = isActive
        self.category = category
        self.expiryDays = expiryDays
        self.createdAt = createdAt
    }
}

// MARK: - Computed Properties
extension Reward {
    /// Check if reward is available
    var isAvailable: Bool {
        if !isActive {
            return false
        }
        if let stock = stock {
            return stock > 0
        }
        return true
    }

    /// Stock display text
    var stockText: String? {
        guard let stock = stock else {
            return nil
        }
        if stock == 0 {
            return "Out of stock"
        } else if stock <= 5 {
            return "Only \(stock) left"
        }
        return nil
    }

    /// Formatted cash value
    var formattedCashValue: String {
        return "€\(NSDecimalNumber(decimal: cashValue).intValue) value"
    }

    /// Formatted points cost
    var formattedPointsCost: String {
        return "\(pointsCost) points"
    }
}

// MARK: - Mock Data
extension Reward {
    /// Mock rewards for Das Wohnzimmer
    static func mockRewardsForVenue(_ venueId: UUID) -> [Reward] {
        return [
            Reward(
                venueId: venueId,
                name: "Welcome Drink",
                description: "Any house cocktail on your next visit",
                imageURL: "https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=400",
                pointsCost: 250,
                cashValue: 8.00,
                stock: nil, // Unlimited
                category: "Drinks"
            ),
            Reward(
                venueId: venueId,
                name: "VIP Table for 2",
                description: "Reserved seating for one night",
                imageURL: "https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?w=400",
                pointsCost: 800,
                cashValue: 50.00,
                stock: 5,
                category: "Tables"
            ),
            Reward(
                venueId: venueId,
                name: "Bottle Service 20% Off",
                description: "Premium bottle service discount",
                imageURL: "https://images.unsplash.com/photo-1569529465841-dfecdab7503b?w=400",
                pointsCost: 1200,
                cashValue: 60.00,
                stock: 10,
                category: "Bottle Service"
            )
        ]
    }
}
