//
//  Product.swift
//  WiesbadenAfterDark
//
//  SwiftData model for venue products with bonus points system
//

import Foundation
import SwiftData

/// Product category categorization with UI support
enum ProductCategory: String, Codable {
    case beverages = "Beverages"
    case food = "Food"
    case spirits = "Spirits"
    case cocktails = "Cocktails"
    case wine = "Wine"
    case beer = "Beer"
    case desserts = "Desserts"
    case appetizers = "Appetizers"

    var displayName: String { rawValue }

    var badgeColor: String {
        switch self {
        case .beverages: return "#3B82F6" // Blue
        case .food: return "#10B981" // Green
        case .spirits: return "#8B5CF6" // Purple
        case .cocktails: return "#EC4899" // Pink
        case .wine: return "#DC2626" // Red
        case .beer: return "#F59E0B" // Orange
        case .desserts: return "#F97316" // Orange
        case .appetizers: return "#14B8A6" // Teal
        }
    }
}

/// Represents a product (food/drink item) at a venue
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
    var cost: Decimal?
    /// Calculated margin percentage (stored for performance)
    var marginPercent: Decimal

    // MARK: - Bonus Points System

    /// Whether bonus points are currently active for this product
    var bonusPointsActive: Bool
    /// Bonus multiplier (e.g., 2.0 for 2x points, 1.5 for 1.5x points)
    var bonusMultiplier: Decimal
    /// Description of the bonus offer
    var bonusDescription: String?
    /// When the bonus starts
    var bonusStartDate: Date?
    /// When the bonus ends
    var bonusEndDate: Date?

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
        cost: Decimal? = nil,
        bonusPointsActive: Bool = false,
        bonusMultiplier: Decimal = 1.0,
        bonusDescription: String? = nil,
        bonusStartDate: Date? = nil,
        bonusEndDate: Date? = nil,
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
        self.bonusDescription = bonusDescription
        self.bonusStartDate = bonusStartDate
        self.bonusEndDate = bonusEndDate
        self.stockQuantity = stockQuantity
        self.isAvailable = isAvailable
        self.orderbirdProductId = orderbirdProductId
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // Calculate margin percentage: (price - cost) / price * 100
        if let cost = cost, price > 0 {
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

    /// Check if product is in stock
    var isInStock: Bool {
        return stockQuantity > 0
    }

    /// Check if bonus is currently active (within date range)
    var isBonusActive: Bool {
        guard bonusPointsActive else { return false }

        let now = Date()

        // If no dates are set, bonus is always active when flag is true
        if bonusStartDate == nil && bonusEndDate == nil {
            return true
        }

        // Check if current time is within bonus period
        if let start = bonusStartDate, now < start {
            return false
        }

        if let end = bonusEndDate, now > end {
            return false
        }

        return true
    }

    /// Active bonus multiplier (returns 1.0 if bonus not active)
    var activeMultiplier: Decimal {
        return isBonusActive ? bonusMultiplier : 1.0
    }

    /// Formatted bonus display
    var formattedBonus: String? {
        guard isBonusActive else { return nil }

        let multiplierInt = NSDecimalNumber(decimal: bonusMultiplier).intValue
        return "\(multiplierInt)x Points"
    }

    /// Profit margin calculation
    var profitMargin: Decimal? {
        guard let cost = cost, cost > 0 else { return nil }
        return ((price - cost) / price) * 100
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

    /// Check if product is available for purchase (in stock and marked as available)
    var canPurchase: Bool {
        return isAvailable && isInStock
    }

    /// Calculate bonus points earned for this product
    /// - Parameter basePoints: Base points per euro spent
    /// - Returns: Total bonus points for this product
    func calculateBonusPoints(basePoints: Decimal = 1.0) -> Decimal {
        guard isBonusActive else {
            return price * basePoints
        }

        return price * basePoints * bonusMultiplier
    }
}

// MARK: - Mock Data
extension Product {
    /// Mock product for Das Wohnzimmer
    static func mockAperolSpritz(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Aperol Spritz",
            category: .cocktails,
            price: 8.50,
            cost: 2.50,
            stockQuantity: 50,
            isAvailable: true,
            bonusPointsActive: true,
            bonusMultiplier: 2.0,
            bonusDescription: "Happy Hour Special",
            bonusStartDate: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
            bonusEndDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date())
        )
    }

    /// Mock Mojito
    static func mockMojito(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Mojito",
            category: .cocktails,
            price: 9.00,
            cost: 2.80,
            stockQuantity: 45,
            isAvailable: true,
            bonusPointsActive: false,
            bonusMultiplier: 1.0
        )
    }

    /// Mock Gin & Tonic
    static func mockGinTonic(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Gin & Tonic",
            category: .cocktails,
            price: 10.50,
            cost: 3.20,
            stockQuantity: 60,
            isAvailable: true,
            bonusPointsActive: true,
            bonusMultiplier: 1.5,
            bonusDescription: "Premium Night",
            bonusStartDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            bonusEndDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
        )
    }

    /// Mock Craft Beer
    static func mockCraftBeer(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Local Craft Beer",
            category: .beer,
            price: 6.50,
            cost: 2.00,
            stockQuantity: 24,
            isAvailable: true,
            bonusPointsActive: false,
            bonusMultiplier: 1.0
        )
    }

    /// Mock Burger
    static func mockBurger(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Classic Burger",
            description: "Juicy beef burger with fries",
            category: .food,
            price: 14.50,
            cost: 5.50,
            stockQuantity: 30,
            isAvailable: true,
            bonusPointsActive: false,
            bonusMultiplier: 1.0
        )
    }

    /// Mock Fries
    static func mockFries(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Sweet Potato Fries",
            category: .food,
            price: 5.50,
            cost: 1.50,
            stockQuantity: 40,
            isAvailable: true,
            bonusPointsActive: false,
            bonusMultiplier: 1.0
        )
    }

    /// Mock Wine
    static func mockWine(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "House Red Wine",
            category: .wine,
            price: 7.00,
            cost: 2.50,
            stockQuantity: 0, // Out of stock
            isAvailable: false,
            bonusPointsActive: false,
            bonusMultiplier: 1.0
        )
    }

    /// Mock Dessert
    static func mockDessert(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Chocolate Lava Cake",
            category: .desserts,
            price: 8.00,
            cost: 2.80,
            stockQuantity: 15,
            isAvailable: true,
            bonusPointsActive: true,
            bonusMultiplier: 3.0,
            bonusDescription: "Triple Points Dessert!",
            bonusStartDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            bonusEndDate: Calendar.current.date(byAdding: .hour, value: 3, to: Date())
        )
    }

    /// Get all mock products for a venue
    static func mockProductsForVenue(_ venueId: UUID) -> [Product] {
        return [
            mockAperolSpritz(venueId: venueId),
            mockMojito(venueId: venueId),
            mockGinTonic(venueId: venueId),
            mockCraftBeer(venueId: venueId),
            mockBurger(venueId: venueId),
            mockFries(venueId: venueId),
            mockWine(venueId: venueId),
            mockDessert(venueId: venueId)
        ]
    }
}
