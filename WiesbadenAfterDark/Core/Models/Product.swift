//
//  Product.swift
//  WiesbadenAfterDark
//
//  SwiftData model for venue products with bonus points system
//

import Foundation
import SwiftData

/// Product category for margin-based points calculation
enum ProductCategory: String, Codable {
    case food = "Food"
    case beverage = "Beverage"
    case other = "Other"

    var displayName: String { rawValue }
}

/// Represents a product/item available at a venue
@Model
final class Product: @unchecked Sendable {
    // MARK: - Basic Information

    @Attribute(.unique) var id: UUID
    var venueId: UUID
    var name: String
    var productDescription: String // "description" is reserved
    var category: ProductCategory

    // MARK: - Pricing & Margins

    /// Selling price to customer
    var price: Decimal
    /// Cost to venue (for margin calculation)
    var cost: Decimal
    /// Calculated margin percentage (e.g., 80.0 for 80%)
    var marginPercent: Decimal

    // MARK: - Bonus Points System

    /// Whether bonus points are currently active for this product
    var bonusPointsActive: Bool
    /// Bonus multiplier (e.g., 2.0 for 2x points, 1.5 for 1.5x points)
    var bonusMultiplier: Decimal

    // MARK: - Inventory Management

    var stockQuantity: Int
    var isAvailable: Bool

    // MARK: - POS Integration

    /// Orderbird POS system product ID for sync
    var orderbirdProductId: String?

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        venueId: UUID,
        name: String,
        description: String = "",
        category: ProductCategory,
        price: Decimal,
        cost: Decimal,
        bonusPointsActive: Bool = false,
        bonusMultiplier: Decimal = 1.0,
        stockQuantity: Int = 0,
        isAvailable: Bool = true,
        orderbirdProductId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.venueId = venueId
        self.name = name
        self.productDescription = description
        self.category = category
        self.price = price
        self.cost = cost
        self.bonusPointsActive = bonusPointsActive
        self.bonusMultiplier = bonusMultiplier
        self.stockQuantity = stockQuantity
        self.isAvailable = isAvailable
        self.orderbirdProductId = orderbirdProductId
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // Calculate margin percentage: (price - cost) / price * 100
        if price > 0 {
            self.marginPercent = ((price - cost) / price) * 100
        } else {
            self.marginPercent = 0
        }
    }
}

// MARK: - Computed Properties
extension Product {
    /// Formatted price display
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: NSDecimalNumber(decimal: price)) ?? "€0.00"
    }

    /// Formatted margin display
    var formattedMargin: String {
        return String(format: "%.1f%%", NSDecimalNumber(decimal: marginPercent).doubleValue)
    }

    /// Active bonus multiplier (returns 1.0 if bonus not active)
    var activeMultiplier: Decimal {
        return bonusPointsActive ? bonusMultiplier : 1.0
    }

    /// Stock status display
    var stockStatus: String {
        if !isAvailable {
            return "Unavailable"
        } else if stockQuantity == 0 {
            return "Out of Stock"
        } else if stockQuantity < 10 {
            return "Low Stock"
        } else {
            return "In Stock"
        }
    }
}

// MARK: - Mock Data
extension Product {
    /// Mock cocktail product with bonus
    static func mockCocktail(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Signature Cocktail",
            description: "Our famous house cocktail with premium spirits",
            category: .beverage,
            price: 12.00,
            cost: 2.40, // 80% margin
            bonusPointsActive: true,
            bonusMultiplier: 2.0,
            stockQuantity: 100,
            isAvailable: true
        )
    }

    /// Mock food item
    static func mockBurger(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Classic Burger",
            description: "Juicy beef burger with fries",
            category: .food,
            price: 15.00,
            cost: 10.50, // 30% margin
            bonusPointsActive: false,
            bonusMultiplier: 1.0,
            stockQuantity: 50,
            isAvailable: true
        )
    }

    /// Mock beer product
    static func mockBeer(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Draft Beer (0.5L)",
            description: "Local craft beer on tap",
            category: .beverage,
            price: 5.50,
            cost: 1.10, // 80% margin
            bonusPointsActive: false,
            bonusMultiplier: 1.0,
            stockQuantity: 200,
            isAvailable: true
        )
    }

    /// Mock wine with bonus
    static func mockWine(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "House Wine (Glass)",
            description: "Selection of red, white, or rosé",
            category: .beverage,
            price: 8.00,
            cost: 1.60, // 80% margin
            bonusPointsActive: true,
            bonusMultiplier: 1.5,
            stockQuantity: 75,
            isAvailable: true
        )
    }

    /// All mock products for a venue
    static func mockProducts(venueId: UUID) -> [Product] {
        return [
            mockCocktail(venueId: venueId),
            mockBurger(venueId: venueId),
            mockBeer(venueId: venueId),
            mockWine(venueId: venueId)
        ]
    }
}
