//
//  PricingConfig.swift
//  WiesbadenAfterDark
//
//  Centralized pricing configuration
//

import Foundation

/// Point package
struct PointPackage: Identifiable {
    let id = UUID()
    let name: String
    let points: Int
    let price: Decimal
    let bonus: Int

    var totalPoints: Int {
        points + bonus
    }

    var pricePerPoint: Decimal {
        price / Decimal(totalPoints)
    }

    var savingsPercent: Int {
        guard bonus > 0 else { return 0 }
        let result = (Decimal(bonus) / Decimal(points)) * 100
        return NSDecimalNumber(decimal: result).intValue
    }

    var displayPrice: String {
        return String(format: "€%.2f", NSDecimalNumber(decimal: price).doubleValue)
    }
}

/// Centralized pricing configuration
struct PricingConfig {
    // MARK: - Table Prices (Cash)

    static let standardTablePrice: Decimal = 50.00
    static let vipTablePrice: Decimal = 120.00
    static let premiumTablePrice: Decimal = 200.00

    // MARK: - Table Prices (Points)

    static let standardTablePoints: Int = 1000
    static let vipTablePoints: Int = 2400
    static let premiumTablePoints: Int = 4000

    // MARK: - Point Conversion

    /// Conversion rate: 50 points = €1
    static let pointsPerEuro: Decimal = 50

    /// Convert points to euros
    static func pointsToEuro(_ points: Int) -> Decimal {
        return Decimal(points) / pointsPerEuro
    }

    /// Convert euros to points
    static func euroToPoints(_ euro: Decimal) -> Int {
        let result = euro * pointsPerEuro
        return NSDecimalNumber(decimal: result).intValue
    }

    // MARK: - Point Packages

    static let packages: [PointPackage] = [
        PointPackage(
            name: "Starter",
            points: 500,
            price: 5.00,
            bonus: 0
        ),
        PointPackage(
            name: "Value",
            points: 1000,
            price: 10.00,
            bonus: 500
        ),
        PointPackage(
            name: "Premium",
            points: 2000,
            price: 20.00,
            bonus: 1500
        ),
        PointPackage(
            name: "Ultimate",
            points: 5000,
            price: 50.00,
            bonus: 5000
        )
    ]

    // MARK: - Helper Methods

    /// Get price for table type
    static func priceForTable(_ type: TableType) -> Decimal {
        switch type {
        case .standard:
            return standardTablePrice
        case .vip:
            return vipTablePrice
        case .premium:
            return premiumTablePrice
        }
    }

    /// Get points cost for table type
    static func pointsForTable(_ type: TableType) -> Int {
        switch type {
        case .standard:
            return standardTablePoints
        case .vip:
            return vipTablePoints
        case .premium:
            return premiumTablePoints
        }
    }

    /// Format currency
    static func formatCurrency(_ amount: Decimal) -> String {
        return String(format: "€%.2f", NSDecimalNumber(decimal: amount).doubleValue)
    }

    /// Format points
    static func formatPoints(_ points: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return "\(formatter.string(from: NSNumber(value: points)) ?? "\(points)") pts"
    }
}
