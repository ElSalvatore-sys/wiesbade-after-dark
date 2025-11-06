//
//  Payment.swift
//  WiesbadenAfterDark
//
//  Payment transaction model
//

import Foundation
import SwiftData

@Model
final class Payment: Identifiable {
    // MARK: - Identity

    @Attribute(.unique) var id: UUID
    var userId: UUID
    var venueId: UUID?

    // MARK: - Payment Details

    var amount: Decimal
    var currency: String // "EUR"
    var paymentMethod: PaymentMethodType
    var status: PaymentStatus

    // MARK: - Stripe References

    var stripePaymentIntentId: String?
    var stripeChargeId: String?

    // MARK: - Related Entities

    var bookingId: UUID?
    var pointsPurchaseId: UUID?

    // MARK: - Points Used (Combo Payments)

    var pointsUsed: Int?
    var pointsValue: Decimal? // Value of points in EUR

    // MARK: - Metadata

    var paymentDescription: String
    var receiptURL: String?
    var refundedAmount: Decimal?
    var refundedAt: Date?

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        venueId: UUID? = nil,
        amount: Decimal,
        currency: String = "EUR",
        paymentMethod: PaymentMethodType,
        status: PaymentStatus = .pending,
        stripePaymentIntentId: String? = nil,
        stripeChargeId: String? = nil,
        bookingId: UUID? = nil,
        pointsPurchaseId: UUID? = nil,
        pointsUsed: Int? = nil,
        pointsValue: Decimal? = nil,
        paymentDescription: String,
        receiptURL: String? = nil,
        refundedAmount: Decimal? = nil,
        refundedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.amount = amount
        self.currency = currency
        self.paymentMethod = paymentMethod
        self.status = status
        self.stripePaymentIntentId = stripePaymentIntentId
        self.stripeChargeId = stripeChargeId
        self.bookingId = bookingId
        self.pointsPurchaseId = pointsPurchaseId
        self.pointsUsed = pointsUsed
        self.pointsValue = pointsValue
        self.paymentDescription = paymentDescription
        self.receiptURL = receiptURL
        self.refundedAmount = refundedAmount
        self.refundedAt = refundedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Computed Properties

    var formattedAmount: String {
        PricingConfig.formatCurrency(amount)
    }

    var formattedDate: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    var isRefunded: Bool {
        status == .refunded || status == .partiallyRefunded
    }

    var isSuccessful: Bool {
        status == .succeeded
    }

    var isPending: Bool {
        status == .pending || status == .processing
    }

    // MARK: - Mock

    static func mock(
        userId: UUID = UUID(),
        amount: Decimal = 120.00,
        paymentMethod: PaymentMethodType = .card,
        status: PaymentStatus = .succeeded,
        description: String = "Table Booking - VIP Section"
    ) -> Payment {
        return Payment(
            userId: userId,
            venueId: UUID(),
            amount: amount,
            paymentMethod: paymentMethod,
            status: status,
            stripePaymentIntentId: "pi_mock_\(UUID().uuidString.prefix(12))",
            stripeChargeId: "ch_mock_\(UUID().uuidString.prefix(12))",
            bookingId: UUID(),
            paymentDescription: description,
            createdAt: Date().addingTimeInterval(-3600) // 1 hour ago
        )
    }
}
