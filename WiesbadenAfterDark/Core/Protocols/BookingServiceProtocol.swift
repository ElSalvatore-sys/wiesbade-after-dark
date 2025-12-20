//
//  BookingServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Protocol for booking service operations
//

import Foundation

/// Booking result
struct BookingResult {
    let success: Bool
    let booking: Booking?
    let errorMessage: String?
}

/// Booking service protocol
@MainActor
protocol BookingServiceProtocol {
    /// Create a new booking with payment
    func createBooking(
        userId: UUID,
        venueId: UUID,
        tableType: TableType,
        partySize: Int,
        bookingDate: Date,
        timeSlot: String,
        specialRequests: String?,
        paymentMethod: PaymentMethodType,
        pointsToUse: Int?
    ) async throws -> BookingResult

    /// Get booking by ID
    func getBooking(id: UUID) async throws -> Booking?

    /// Get user bookings
    func getUserBookings(userId: UUID) async throws -> [Booking]

    /// Get venue bookings
    func getVenueBookings(venueId: UUID, date: Date) async throws -> [Booking]

    /// Cancel booking
    func cancelBooking(
        bookingId: UUID,
        reason: String,
        requestRefund: Bool
    ) async throws -> Bool

    /// Update booking
    func updateBooking(
        bookingId: UUID,
        partySize: Int?,
        specialRequests: String?
    ) async throws -> Booking

    /// Confirm booking (venue action)
    func confirmBooking(bookingId: UUID) async throws -> Bool

    /// Complete booking (after event)
    func completeBooking(bookingId: UUID) async throws -> Bool

    /// Check availability
    func checkAvailability(
        venueId: UUID,
        date: Date,
        timeSlot: String,
        tableType: TableType
    ) async throws -> Bool
}

/// Booking error types
enum BookingError: LocalizedError {
    case invalidDate
    case invalidPartySize
    case tableNotAvailable
    case bookingNotFound
    case cancellationFailed(String)
    case paymentRequired
    case alreadyCancelled
    case pastBooking
    case saveFailed
    case fetchFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "Invalid booking date"
        case .invalidPartySize:
            return "Party size exceeds table capacity"
        case .tableNotAvailable:
            return "This table is not available at the selected time"
        case .bookingNotFound:
            return "Booking not found"
        case .cancellationFailed(let message):
            return "Failed to cancel: \(message)"
        case .paymentRequired:
            return "Payment is required to complete booking"
        case .alreadyCancelled:
            return "This booking has already been cancelled"
        case .pastBooking:
            return "Cannot modify past bookings"
        case .saveFailed:
            return "Failed to save booking to database"
        case .fetchFailed:
            return "Failed to fetch booking data"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
