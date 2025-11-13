//
//  Product.swift
//  WiesbadenAfterDark
//
//  SwiftData model for venue products with inventory gamification
//

import Foundation
import SwiftData

/// Represents a product at a venue with inventory management
@Model
final class Product: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var name: String
    var productDescription: String
    var venueId: UUID

    // Pricing
    var price: Decimal
    var category: String // "Food", "Drink", "Merchandise"

    // Inventory gamification
    var hasBonus: Bool
    var bonusMultiplier: Decimal // 2.0 = 2x points, 3.0 = 3x points
    var bonusReason: String? // "Expiring Soon", "Excess Stock", "Daily Special"
    var expiresAt: Date? // For time-sensitive offers

    // Product details
    var imageURL: String?
    var stock: Int?
    var isAvailable: Bool

    // Timestamps
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        venueId: UUID,
        price: Decimal,
        category: String,
        hasBonus: Bool = false,
        bonusMultiplier: Decimal = 1.0,
        bonusReason: String? = nil,
        expiresAt: Date? = nil,
        imageURL: String? = nil,
        stock: Int? = nil,
        isAvailable: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.productDescription = description
        self.venueId = venueId
        self.price = price
        self.category = category
        self.hasBonus = hasBonus
        self.bonusMultiplier = bonusMultiplier
        self.bonusReason = bonusReason
        self.expiresAt = expiresAt
        self.imageURL = imageURL
        self.stock = stock
        self.isAvailable = isAvailable
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Computed Properties
extension Product {
    /// Formatted price
    var formattedPrice: String {
        return "€\(NSDecimalNumber(decimal: price).doubleValue, specifier: "%.2f")"
    }

    /// Bonus multiplier badge text
    var bonusMultiplierText: String? {
        if hasBonus && bonusMultiplier > 1.0 {
            let value = NSDecimalNumber(decimal: bonusMultiplier).intValue
            return "\(value)x POINTS"
        }
        return nil
    }

    /// Check if offer is expiring soon
    var isExpiringSoon: Bool {
        guard let expiresAt = expiresAt else { return false }
        let hoursUntilExpiry = Calendar.current.dateComponents([.hour], from: Date(), to: expiresAt).hour ?? 0
        return hoursUntilExpiry <= 24
    }

    /// Time remaining until expiry
    var timeRemaining: String? {
        guard let expiresAt = expiresAt else { return nil }

        let now = Date()
        if expiresAt < now { return "Expired" }

        let components = Calendar.current.dateComponents([.hour, .minute], from: now, to: expiresAt)

        if let hours = components.hour, hours > 0 {
            return "Expires in \(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "Expires in \(minutes)m"
        }

        return "Expiring soon"
    }

    /// Check if product is in stock
    var inStock: Bool {
        if let stock = stock {
            return stock > 0
        }
        return isAvailable
    }

    /// Stock display text
    var stockText: String? {
        guard let stock = stock else { return nil }

        if stock == 0 {
            return "Out of Stock"
        } else if stock <= 5 {
            return "Only \(stock) left!"
        }

        return nil
    }
}

// MARK: - Mock Data
extension Product {
    /// Mock products with bonus offers for a venue
    static func mockProductsWithBonuses(venueId: UUID) -> [Product] {
        let calendar = Calendar.current
        let now = Date()

        // Expiring soon: Orange Juice (expires in 6 hours)
        let expiryDate = calendar.date(byAdding: .hour, value: 6, to: now)!

        let orangeJuice = Product(
            name: "Fresh Orange Juice",
            description: "Freshly squeezed orange juice - must sell today!",
            venueId: venueId,
            price: 4.50,
            category: "Drink",
            hasBonus: true,
            bonusMultiplier: 2.0,
            bonusReason: "Expiring Soon",
            expiresAt: expiryDate,
            imageURL: "🍊",
            stock: 8,
            isAvailable: true
        )

        // Excess stock: House Beer (3x points)
        let houseBeer = Product(
            name: "House Lager",
            description: "Crisp German lager - overstocked special!",
            venueId: venueId,
            price: 3.50,
            category: "Drink",
            hasBonus: true,
            bonusMultiplier: 3.0,
            bonusReason: "Excess Stock",
            expiresAt: nil,
            imageURL: "🍺",
            stock: 50,
            isAvailable: true
        )

        // Daily special: Currywurst (2x points)
        let expiresTonight = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: now)!

        let currywurst = Product(
            name: "Currywurst Special",
            description: "Traditional German currywurst with fries",
            venueId: venueId,
            price: 7.90,
            category: "Food",
            hasBonus: true,
            bonusMultiplier: 2.0,
            bonusReason: "Today's Special",
            expiresAt: expiresTonight,
            imageURL: "🌭",
            stock: 12,
            isAvailable: true
        )

        // Limited time: Cocktail of the Week (2x points)
        let cocktailExpiry = calendar.date(byAdding: .day, value: 2, to: now)!

        let cocktail = Product(
            name: "Wiesbaden Sunset",
            description: "Signature cocktail with premium spirits",
            venueId: venueId,
            price: 9.50,
            category: "Drink",
            hasBonus: true,
            bonusMultiplier: 2.0,
            bonusReason: "Cocktail of the Week",
            expiresAt: cocktailExpiry,
            imageURL: "🍹",
            stock: nil,
            isAvailable: true
        )

        // Regular products (no bonus)
        let schnitzel = Product(
            name: "Wiener Schnitzel",
            description: "Classic breaded veal cutlet",
            venueId: venueId,
            price: 14.90,
            category: "Food",
            hasBonus: false,
            bonusMultiplier: 1.0,
            bonusReason: nil,
            expiresAt: nil,
            imageURL: "🍖",
            stock: nil,
            isAvailable: true
        )

        return [orangeJuice, houseBeer, currywurst, cocktail, schnitzel]
    }

    /// Mock products for multiple venues
    static func mockAllProductsWithBonuses(venues: [UUID: String]) -> [Product] {
        var allProducts: [Product] = []

        for (venueId, _) in venues {
            let products = mockProductsWithBonuses(venueId: venueId)
            allProducts.append(contentsOf: products)
        }

        return allProducts
    }
}
