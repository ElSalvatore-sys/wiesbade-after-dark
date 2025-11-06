//
//  PointsPurchase.swift
//  WiesbadenAfterDark
//
//  Point purchase record model
//

import Foundation
import SwiftData

@Model
final class PointsPurchase: Identifiable {
    // MARK: - Identity

    @Attribute(.unique) var id: UUID
    var userId: UUID
    var paymentId: UUID

    // MARK: - Points Details

    var pointsAmount: Int
    var cashAmount: Decimal
    var bonusPoints: Int
    var totalPoints: Int // pointsAmount + bonusPoints

    // MARK: - Package Info

    var packageName: String // "Starter", "Value", "Premium", "Ultimate"

    // MARK: - Timestamps

    var createdAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        paymentId: UUID,
        pointsAmount: Int,
        cashAmount: Decimal,
        bonusPoints: Int,
        packageName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.paymentId = paymentId
        self.pointsAmount = pointsAmount
        self.cashAmount = cashAmount
        self.bonusPoints = bonusPoints
        self.totalPoints = pointsAmount + bonusPoints
        self.packageName = packageName
        self.createdAt = createdAt
    }

    // MARK: - Computed Properties

    var formattedAmount: String {
        PricingConfig.formatCurrency(cashAmount)
    }

    var formattedPoints: String {
        PricingConfig.formatPoints(totalPoints)
    }

    var formattedDate: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    var hasBonusPoints: Bool {
        bonusPoints > 0
    }

    var savingsPercent: Int {
        guard bonusPoints > 0 else { return 0 }
        let result = (Decimal(bonusPoints) / Decimal(pointsAmount)) * 100
        return NSDecimalNumber(decimal: result).intValue
    }

    // MARK: - Mock

    static func mock(
        userId: UUID = UUID(),
        package: PointPackage = PricingConfig.packages[2] // Premium
    ) -> PointsPurchase {
        return PointsPurchase(
            userId: userId,
            paymentId: UUID(),
            pointsAmount: package.points,
            cashAmount: package.price,
            bonusPoints: package.bonus,
            packageName: package.name,
            createdAt: Date().addingTimeInterval(-7200) // 2 hours ago
        )
    }
}
