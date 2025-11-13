//
//  OrderItem.swift
//  WiesbadenAfterDark
//
//  Model representing an item in an order for points calculation
//

import Foundation

/// Represents an item in an order for points calculation
struct OrderItem: Codable, Sendable {
    // MARK: - Properties

    let productId: UUID?
    let productName: String
    let category: String // e.g., "beverages", "food", "bottle_service"
    let quantity: Int
    let price: Decimal
    let bonusMultiplier: Decimal? // Optional bonus multiplier for special items

    // MARK: - Initialization

    init(
        productId: UUID? = nil,
        productName: String,
        category: String,
        quantity: Int = 1,
        price: Decimal,
        bonusMultiplier: Decimal? = nil
    ) {
        self.productId = productId
        self.productName = productName
        self.category = category
        self.quantity = quantity
        self.price = price
        self.bonusMultiplier = bonusMultiplier
    }

    // MARK: - Computed Properties

    /// Total price for this line item
    var totalPrice: Decimal {
        return price * Decimal(quantity)
    }
}

// MARK: - Mock Data
extension OrderItem {
    /// Creates a mock order item for testing
    static func mock(
        productName: String = "Aperol Spritz",
        category: String = "beverages",
        quantity: Int = 2,
        price: Decimal = 8.50,
        bonusMultiplier: Decimal? = 2.0
    ) -> OrderItem {
        return OrderItem(
            productId: UUID(),
            productName: productName,
            category: category,
            quantity: quantity,
            price: price,
            bonusMultiplier: bonusMultiplier
        )
    }

    /// Creates an array of mock order items
    static func mockItems() -> [OrderItem] {
        return [
            OrderItem(
                productId: UUID(),
                productName: "Aperol Spritz",
                category: "beverages",
                quantity: 2,
                price: 8.50,
                bonusMultiplier: 2.0
            ),
            OrderItem(
                productId: UUID(),
                productName: "Premium Burger",
                category: "food",
                quantity: 1,
                price: 14.50,
                bonusMultiplier: 1.5
            ),
            OrderItem(
                productId: UUID(),
                productName: "Craft Beer",
                category: "beverages",
                quantity: 3,
                price: 6.00,
                bonusMultiplier: 1.0
            )
        ]
    }
}
