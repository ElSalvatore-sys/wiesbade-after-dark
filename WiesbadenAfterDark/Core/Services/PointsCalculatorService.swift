//
//  PointsCalculatorService.swift
//  WiesbadenAfterDark
//
//  Service for calculating loyalty points using margin-based algorithm
//  Formula: points = amount × 10% × (category_margin / venue_max_margin) × bonus_multiplier
//

import Foundation

/// Order item for points calculation
struct OrderItem: Codable, Sendable {
    let productId: UUID
    let name: String
    let category: ProductCategory
    let price: Decimal
    let quantity: Int
    let marginPercent: Decimal
    let bonusMultiplier: Decimal

    var subtotal: Decimal {
        return price * Decimal(quantity)
    }
}

/// Result of points calculation with breakdown
struct PointsCalculationResult: Codable, Sendable {
    let totalPoints: Decimal
    let basePoints: Decimal
    let bonusPoints: Decimal
    let breakdown: [PointsBreakdownItem]

    var roundedPoints: Int {
        return Int(totalPoints.rounded())
    }
}

/// Individual item breakdown in points calculation
struct PointsBreakdownItem: Codable, Sendable {
    let itemName: String
    let amount: Decimal
    let marginPercent: Decimal
    let marginRatio: Decimal
    let bonusMultiplier: Decimal
    let points: Decimal
}

/// Protocol for points calculation service
protocol PointsCalculatorServiceProtocol: Sendable {
    /// Calculate points for a purchase amount using venue's margin configuration
    /// - Parameters:
    ///   - amount: Total purchase amount in euros
    ///   - categoryMargin: Margin percentage for the product category (e.g., 80.0 for beverages)
    ///   - venueMaxMargin: Maximum margin across all venue categories
    ///   - bonusMultiplier: Bonus multiplier if active (default 1.0)
    /// - Returns: Calculated points as Decimal
    func calculatePoints(
        amount: Decimal,
        categoryMargin: Decimal,
        venueMaxMargin: Decimal,
        bonusMultiplier: Decimal
    ) -> Decimal

    /// Calculate points for multiple order items with detailed breakdown
    /// - Parameters:
    ///   - orderItems: Array of order items
    ///   - venue: Venue for margin configuration
    /// - Returns: Detailed calculation result with breakdown
    func calculatePointsForOrder(
        orderItems: [OrderItem],
        venue: Venue
    ) -> PointsCalculationResult

    /// Calculate points for a simple purchase (no item details)
    /// - Parameters:
    ///   - amount: Total purchase amount
    ///   - category: Product category (for margin lookup)
    ///   - venue: Venue for margin configuration
    ///   - bonusMultiplier: Bonus multiplier if active (default 1.0)
    /// - Returns: Calculated points
    func calculateSimplePoints(
        amount: Decimal,
        category: ProductCategory,
        venue: Venue,
        bonusMultiplier: Decimal
    ) -> Decimal
}

/// Implementation of margin-based points calculation
final class PointsCalculatorService: PointsCalculatorServiceProtocol, @unchecked Sendable {

    // MARK: - Constants

    /// Base points rate: 10% of purchase amount
    private let basePointsRate: Decimal = 0.10

    // MARK: - Singleton

    static let shared = PointsCalculatorService()

    private init() {}

    // MARK: - Public Methods

    func calculatePoints(
        amount: Decimal,
        categoryMargin: Decimal,
        venueMaxMargin: Decimal,
        bonusMultiplier: Decimal = 1.0
    ) -> Decimal {
        // Prevent division by zero
        guard venueMaxMargin > 0 else {
            return 0
        }

        // Calculate margin ratio (0.0 to 1.0)
        let marginRatio = categoryMargin / venueMaxMargin

        // Calculate base points
        let basePoints = amount * basePointsRate * marginRatio

        // Apply bonus multiplier
        let finalPoints = basePoints * bonusMultiplier

        // Round to 2 decimal places
        return (finalPoints * 100).rounded() / 100
    }

    func calculatePointsForOrder(
        orderItems: [OrderItem],
        venue: Venue
    ) -> PointsCalculationResult {
        let venueMaxMargin = venue.maxMarginPercent
        var totalPoints: Decimal = 0
        var basePoints: Decimal = 0
        var breakdown: [PointsBreakdownItem] = []

        for item in orderItems {
            let itemAmount = item.subtotal
            let marginRatio = venueMaxMargin > 0 ? item.marginPercent / venueMaxMargin : 0

            // Calculate points for this item
            let itemBasePoints = itemAmount * basePointsRate * marginRatio
            let itemFinalPoints = itemBasePoints * item.bonusMultiplier

            totalPoints += itemFinalPoints
            basePoints += itemBasePoints

            // Add to breakdown
            breakdown.append(PointsBreakdownItem(
                itemName: item.name,
                amount: itemAmount,
                marginPercent: item.marginPercent,
                marginRatio: marginRatio,
                bonusMultiplier: item.bonusMultiplier,
                points: (itemFinalPoints * 100).rounded() / 100
            ))
        }

        let bonusPoints = totalPoints - basePoints

        return PointsCalculationResult(
            totalPoints: (totalPoints * 100).rounded() / 100,
            basePoints: (basePoints * 100).rounded() / 100,
            bonusPoints: (bonusPoints * 100).rounded() / 100,
            breakdown: breakdown
        )
    }

    func calculateSimplePoints(
        amount: Decimal,
        category: ProductCategory,
        venue: Venue,
        bonusMultiplier: Decimal = 1.0
    ) -> Decimal {
        // Get category margin from venue
        let categoryMargin: Decimal = switch category {
        case .food:
            venue.foodMarginPercent
        case .beverage:
            venue.beverageMarginPercent
        case .other:
            venue.defaultMarginPercent
        }

        return calculatePoints(
            amount: amount,
            categoryMargin: categoryMargin,
            venueMaxMargin: venue.maxMarginPercent,
            bonusMultiplier: bonusMultiplier
        )
    }
}

// MARK: - Helper Extensions
extension PointsCalculationResult {
    /// Human-readable summary of calculation
    var summary: String {
        var lines: [String] = []
        lines.append("Points Calculation Summary")
        lines.append("─────────────────────────")

        for item in breakdown {
            let marginRatioPercent = item.marginRatio * 100
            let bonusLabel = item.bonusMultiplier > 1 ? " (\(item.bonusMultiplier)x bonus)" : ""
            lines.append("\(item.itemName): €\(item.amount) × \(String(format: "%.0f%%", NSDecimalNumber(decimal: marginRatioPercent).doubleValue)) margin\(bonusLabel) = \(item.points) pts")
        }

        lines.append("─────────────────────────")
        lines.append("Base Points: \(basePoints)")
        if bonusPoints > 0 {
            lines.append("Bonus Points: +\(bonusPoints)")
        }
        lines.append("Total Points: \(totalPoints)")

        return lines.joined(separator: "\n")
    }
}

// MARK: - Example Usage & Documentation
/*
 Example Calculations:

 1. High-Margin Beverage (No Bonus)
    - Purchase: €100 on cocktails
    - Margin: 80%
    - Venue max margin: 80%
    - Calculation: €100 × 10% × (80/80) × 1.0 = 10 points
    - Effective reward: 10%

 2. Low-Margin Food
    - Purchase: €100 on food
    - Margin: 30%
    - Venue max margin: 80%
    - Calculation: €100 × 10% × (30/80) × 1.0 = 3.75 points
    - Effective reward: 3.75%

 3. Beverage with 2x Bonus (Moving Inventory)
    - Purchase: €100 on beverages
    - Margin: 80%
    - Venue max margin: 80%
    - Bonus: 2.0x
    - Calculation: €100 × 10% × (80/80) × 2.0 = 20 points
    - Effective reward: 20%

 Usage:

 let calculator = PointsCalculatorService.shared

 // Simple calculation
 let points = calculator.calculateSimplePoints(
     amount: 100.00,
     category: .beverage,
     venue: venue,
     bonusMultiplier: 1.0
 )

 // Detailed order calculation
 let orderItems = [
     OrderItem(productId: UUID(), name: "Cocktail", category: .beverage,
               price: 12.00, quantity: 2, marginPercent: 80.0, bonusMultiplier: 2.0),
     OrderItem(productId: UUID(), name: "Burger", category: .food,
               price: 15.00, quantity: 1, marginPercent: 30.0, bonusMultiplier: 1.0)
 ]

 let result = calculator.calculatePointsForOrder(
     orderItems: orderItems,
     venue: venue
 )

 print(result.summary)
 */
