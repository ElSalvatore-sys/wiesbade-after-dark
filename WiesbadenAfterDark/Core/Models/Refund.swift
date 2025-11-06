//
//  Refund.swift
//  WiesbadenAfterDark
//
//  Refund request and tracking model
//

import Foundation
import SwiftData

@Model
final class Refund: Identifiable {
    // MARK: - Identity

    @Attribute(.unique) var id: UUID
    var userId: UUID
    var paymentId: UUID
    var bookingId: UUID?

    // MARK: - Refund Details

    var amount: Decimal
    var reason: String
    var status: RefundStatus

    // MARK: - Stripe References

    var stripeRefundId: String?

    // MARK: - Metadata

    var notes: String?
    var processedBy: UUID? // Admin user ID
    var rejectionReason: String?

    // MARK: - Timestamps

    var requestedAt: Date
    var processedAt: Date?
    var completedAt: Date?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        paymentId: UUID,
        bookingId: UUID? = nil,
        amount: Decimal,
        reason: String,
        status: RefundStatus = .pending,
        stripeRefundId: String? = nil,
        notes: String? = nil,
        processedBy: UUID? = nil,
        rejectionReason: String? = nil,
        requestedAt: Date = Date(),
        processedAt: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.paymentId = paymentId
        self.bookingId = bookingId
        self.amount = amount
        self.reason = reason
        self.status = status
        self.stripeRefundId = stripeRefundId
        self.notes = notes
        self.processedBy = processedBy
        self.rejectionReason = rejectionReason
        self.requestedAt = requestedAt
        self.processedAt = processedAt
        self.completedAt = completedAt
    }

    // MARK: - Computed Properties

    var formattedAmount: String {
        PricingConfig.formatCurrency(amount)
    }

    var formattedDate: String {
        requestedAt.formatted(date: .abbreviated, time: .shortened)
    }

    var isPending: Bool {
        status == .pending || status == .processing
    }

    var isCompleted: Bool {
        status == .completed
    }

    // MARK: - Mock

    static func mock(
        userId: UUID = UUID(),
        amount: Decimal = 120.00,
        status: RefundStatus = .completed
    ) -> Refund {
        return Refund(
            userId: userId,
            paymentId: UUID(),
            bookingId: UUID(),
            amount: amount,
            reason: "Event cancelled by venue",
            status: status,
            stripeRefundId: "re_mock_\(UUID().uuidString.prefix(12))",
            requestedAt: Date().addingTimeInterval(-86400), // 1 day ago
            completedAt: status == .completed ? Date().addingTimeInterval(-3600) : nil
        )
    }
}

/// Refund status
enum RefundStatus: String, Codable {
    case pending = "Pending"
    case processing = "Processing"
    case completed = "Completed"
    case rejected = "Rejected"
    case cancelled = "Cancelled"

    var color: String {
        switch self {
        case .pending, .processing:
            return "warning"
        case .completed:
            return "success"
        case .rejected, .cancelled:
            return "error"
        }
    }

    var icon: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .processing:
            return "arrow.triangle.2.circlepath"
        case .completed:
            return "checkmark.circle.fill"
        case .rejected:
            return "xmark.circle.fill"
        case .cancelled:
            return "xmark.circle"
        }
    }
}
