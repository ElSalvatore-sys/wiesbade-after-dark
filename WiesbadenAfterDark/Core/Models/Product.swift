//
//  Product.swift
//  WiesbadenAfterDark
//
//  SwiftData model for venue products with bonus points system and inventory gamification
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
    /// Reason for bonus (e.g., "Expiring Soon", "Excess Stock", "Happy Hour Special")
    var bonusReason: String?
    /// When the bonus starts
    var bonusStartDate: Date?
    /// When the bonus ends / product expires
    var bonusEndDate: Date?

    // MARK: - Inventory Management

    var stockQuantity: Int
    var isAvailable: Bool

    // MARK: - UI Assets

    /// Product image URL or emoji
    var imageURL: String?

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
        bonusReason: String? = nil,
        bonusStartDate: Date? = nil,
        bonusEndDate: Date? = nil,
        stockQuantity: Int = 0,
        isAvailable: Bool = true,
        imageURL: String? = nil,
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
        self.bonusReason = bonusReason
        self.bonusStartDate = bonusStartDate
        self.bonusEndDate = bonusEndDate
        self.stockQuantity = stockQuantity
        self.isAvailable = isAvailable
        self.imageURL = imageURL
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

    /// Bonus multiplier badge text (for UI)
    var bonusMultiplierText: String? {
        guard isBonusActive else { return nil }
        let value = NSDecimalNumber(decimal: bonusMultiplier).intValue
        return "\(value)x POINTS"
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

    /// Stock display text (for gamification UI)
    var stockText: String? {
        if stockQuantity == 0 {
            return "Out of Stock"
        } else if stockQuantity <= 5 {
            return "Only \(stockQuantity) left!"
        }
        return nil
    }

    /// Check if product is available for purchase (in stock and marked as available)
    var canPurchase: Bool {
        return isAvailable && isInStock
    }

    /// Check if offer is expiring soon (within 24 hours)
    var isExpiringSoon: Bool {
        guard let expiresAt = bonusEndDate else { return false }
        let hoursUntilExpiry = Calendar.current.dateComponents([.hour], from: Date(), to: expiresAt).hour ?? 0
        return hoursUntilExpiry <= 24
    }

    /// Time remaining until expiry
    var timeRemaining: String? {
        guard let expiresAt = bonusEndDate else { return nil }

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
    /// Mock product for Das Wohnzimmer - Aperol Spritz with bonus
    static func mockAperolSpritz(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Aperol Spritz",
            description: "Classic Italian aperitif",
            category: .cocktails,
            price: 8.50,
            cost: 2.50,
            bonusPointsActive: true,
            bonusMultiplier: 2.0,
            bonusReason: "Happy Hour Special",
            bonusStartDate: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
            bonusEndDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()),
            stockQuantity: 50,
            isAvailable: true,
            imageURL: "🍹"
        )
    }

    /// Mock orange juice expiring soon (gamification example)
    static func mockOrangeJuice(venueId: UUID) -> Product {
        let expiryDate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        return Product(
            venueId: venueId,
            name: "Fresh Orange Juice",
            description: "Freshly squeezed orange juice - must sell today!",
            category: .beverages,
            price: 4.50,
            cost: 1.20,
            bonusPointsActive: true,
            bonusMultiplier: 2.0,
            bonusReason: "Expiring Soon",
            bonusStartDate: Date(),
            bonusEndDate: expiryDate,
            stockQuantity: 8,
            isAvailable: true,
            imageURL: "🍊"
        )
    }

    /// Mock house beer with excess stock (3x points)
    static func mockHouseBeer(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "House Lager",
            description: "Crisp German lager - overstocked special!",
            category: .beer,
            price: 3.50,
            cost: 1.00,
            bonusPointsActive: true,
            bonusMultiplier: 3.0,
            bonusReason: "Excess Stock",
            bonusStartDate: Date(),
            bonusEndDate: nil,
            stockQuantity: 50,
            isAvailable: true,
            imageURL: "🍺"
        )
    }

    /// Mock currywurst daily special
    static func mockCurrywurst(venueId: UUID) -> Product {
        let expiresTonight = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
        return Product(
            venueId: venueId,
            name: "Currywurst Special",
            description: "Traditional German currywurst with fries",
            category: .food,
            price: 7.90,
            cost: 3.50,
            bonusPointsActive: true,
            bonusMultiplier: 2.0,
            bonusReason: "Today's Special",
            bonusStartDate: Date(),
            bonusEndDate: expiresTonight,
            stockQuantity: 12,
            isAvailable: true,
            imageURL: "🌭"
        )
    }

    /// Mock burger
    static func mockBurger(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Classic Burger",
            description: "Juicy beef burger with fries",
            category: .food,
            price: 14.50,
            cost: 5.50,
            bonusPointsActive: false,
            bonusMultiplier: 1.0,
            stockQuantity: 30,
            isAvailable: true,
            imageURL: "🍔"
        )
    }

    /// Mock dessert with high bonus
    static func mockDessert(venueId: UUID) -> Product {
        return Product(
            venueId: venueId,
            name: "Chocolate Lava Cake",
            description: "Decadent chocolate dessert",
            category: .desserts,
            price: 8.00,
            cost: 2.80,
            bonusPointsActive: true,
            bonusMultiplier: 3.0,
            bonusReason: "Triple Points Dessert!",
            bonusStartDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            bonusEndDate: Calendar.current.date(byAdding: .hour, value: 3, to: Date()),
            stockQuantity: 15,
            isAvailable: true,
            imageURL: "🍰"
        )
    }

    /// Get all mock products for a venue (comprehensive set)
    static func mockProductsForVenue(_ venueId: UUID) -> [Product] {
        return [
            mockOrangeJuice(venueId: venueId),
            mockHouseBeer(venueId: venueId),
            mockCurrywurst(venueId: venueId),
            mockAperolSpritz(venueId: venueId),
            mockBurger(venueId: venueId),
            mockDessert(venueId: venueId)
        ]
    }
}
