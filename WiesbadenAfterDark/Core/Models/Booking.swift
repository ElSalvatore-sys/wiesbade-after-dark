//
//  Booking.swift
//  WiesbadenAfterDark
//
//  SwiftData model for table bookings
//

import Foundation
import SwiftData

/// Table booking status
enum BookingStatus: String, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
    case completed = "Completed"
}

/// Table type options
enum TableType: String, Codable, CaseIterable {
    case standard = "Standard Table"
    case vip = "VIP Section"
    case premium = "Premium Booth"

    var displayName: String { rawValue }

    var maxCapacity: Int {
        switch self {
        case .standard: return 6
        case .vip: return 8
        case .premium: return 12
        }
    }

    var basePrice: Decimal {
        switch self {
        case .standard: return 50.00
        case .vip: return 120.00
        case .premium: return 200.00
        }
    }

    var pointsCost: Int {
        switch self {
        case .standard: return 1000
        case .vip: return 2400
        case .premium: return 4000
        }
    }

    var icon: String {
        switch self {
        case .standard: return "table.furniture"
        case .vip: return "star.circle.fill"
        case .premium: return "crown.fill"
        }
    }

    var description: String {
        switch self {
        case .standard: return "Standard seating area"
        case .vip: return "Priority seating with premium service"
        case .premium: return "Exclusive area with bottle service"
        }
    }

    var minimumSpend: Int {
        switch self {
        case .standard: return 100
        case .vip: return 250
        case .premium: return 500
        }
    }
}

/// Represents a table booking at a venue
@Model
final class Booking: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var userId: UUID
    var venueId: UUID

    var tableType: TableType
    var partySize: Int
    var bookingDate: Date
    var timeSlot: String

    var totalCost: Decimal
    var paidWithPoints: Bool
    var pointsUsed: Int?

    // MARK: - Payment Details

    var paymentId: UUID?
    var paymentStatus: PaymentStatus
    var paymentMethod: PaymentMethodType?
    var amountPaid: Decimal? // Actual cash amount paid (after points deduction)

    var status: BookingStatus

    var specialRequests: String?
    var confirmationCode: String?

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        venueId: UUID,
        tableType: TableType,
        partySize: Int,
        bookingDate: Date,
        timeSlot: String,
        totalCost: Decimal,
        paidWithPoints: Bool = false,
        pointsUsed: Int? = nil,
        paymentId: UUID? = nil,
        paymentStatus: PaymentStatus = .pending,
        paymentMethod: PaymentMethodType? = nil,
        amountPaid: Decimal? = nil,
        status: BookingStatus = .pending,
        specialRequests: String? = nil,
        confirmationCode: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.tableType = tableType
        self.partySize = partySize
        self.bookingDate = bookingDate
        self.timeSlot = timeSlot
        self.totalCost = totalCost
        self.paidWithPoints = paidWithPoints
        self.pointsUsed = pointsUsed
        self.paymentId = paymentId
        self.paymentStatus = paymentStatus
        self.paymentMethod = paymentMethod
        self.amountPaid = amountPaid
        self.status = status
        self.specialRequests = specialRequests
        self.confirmationCode = confirmationCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Computed Properties
extension Booking {
    /// Formatted booking date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: bookingDate)
    }

    /// Formatted total cost
    var formattedCost: String {
        return "€\(NSDecimalNumber(decimal: totalCost).intValue)"
    }

    /// Payment method display
    var paymentMethodText: String {
        return paidWithPoints ? "Paid with Points" : "Paid with Card"
    }
}
