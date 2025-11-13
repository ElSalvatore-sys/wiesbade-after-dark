//
//  CheckInServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Protocol for check-in operations and NFC handling
//

import Foundation

/// Check-in service protocol defining NFC and check-in operations
protocol CheckInServiceProtocol {
    /// Performs a check-in at a venue
    /// - Parameters:
    ///   - userId: User's ID
    ///   - venueId: Venue's ID
    ///   - venueName: Venue name
    ///   - method: Check-in method (NFC, QR, Manual)
    ///   - eventId: Optional event ID if checking in for specific event
    ///   - eventMultiplier: Event points multiplier (1.0 = no event)
    ///   - amountSpent: Optional amount spent for margin-based points
    ///   - orderItems: Optional order items for detailed points calculation
    ///   - venue: Optional venue object for additional context
    /// - Returns: Created CheckIn record
    func performCheckIn(
        userId: UUID,
        venueId: UUID,
        venueName: String,
        method: CheckInMethod,
        eventId: UUID?,
        eventMultiplier: Decimal,
        amountSpent: Decimal?,
        orderItems: [OrderItem]?,
        venue: Venue?
    ) async throws -> CheckIn

    /// Simulates NFC tag scan (for mock implementation)
    /// - Parameter venue: The venue being checked into
    /// - Returns: NFC payload string
    func simulateNFCScan(for venue: Venue) async throws -> String

    /// Validates NFC payload
    /// - Parameter payload: NFC tag payload to validate
    /// - Returns: True if valid, throws error if invalid
    func validateNFCPayload(_ payload: String) async throws -> Bool

    /// Calculates points for a check-in
    /// - Parameters:
    ///   - basePoints: Base points amount (default 50)
    ///   - eventMultiplier: Event multiplier (1.0 = no event)
    ///   - streakDay: Current streak day (1-based)
    ///   - isWeekend: Whether check-in is on weekend
    /// - Returns: Total points to award
    func calculatePoints(
        basePoints: Int,
        eventMultiplier: Decimal,
        streakDay: Int,
        isWeekend: Bool
    ) -> Int

    /// Fetches check-in history for a user
    /// - Parameters:
    ///   - userId: User's ID
    ///   - venueId: Optional venue ID to filter by
    ///   - limit: Maximum number of records to return
    /// - Returns: Array of CheckIn records
    func fetchCheckInHistory(
        userId: UUID,
        venueId: UUID?,
        limit: Int
    ) async throws -> [CheckIn]

    /// Gets current streak information for user at venue
    /// - Parameters:
    ///   - userId: User's ID
    ///   - venueId: Venue's ID
    /// - Returns: Current streak day (1 if no streak or expired)
    func getCurrentStreak(userId: UUID, venueId: UUID) async throws -> Int

    /// Fetches point transaction history
    /// - Parameters:
    ///   - userId: User's ID
    ///   - venueId: Optional venue ID to filter by
    ///   - limit: Maximum number of records
    /// - Returns: Array of PointTransaction records
    func fetchPointTransactions(
        userId: UUID,
        venueId: UUID?,
        limit: Int
    ) async throws -> [PointTransaction]

    /// Records a point transaction
    /// - Parameters:
    ///   - userId: User's ID
    ///   - venueId: Venue's ID
    ///   - venueName: Venue name
    ///   - type: Transaction type (earn/redeem/bonus)
    ///   - source: Transaction source
    ///   - amount: Points amount
    ///   - description: Transaction description
    ///   - balanceBefore: Balance before transaction
    ///   - balanceAfter: Balance after transaction
    ///   - checkInId: Optional related check-in ID
    /// - Returns: Created PointTransaction record
    @MainActor
    func recordPointTransaction(
        userId: UUID,
        venueId: UUID,
        venueName: String,
        type: TransactionType,
        source: TransactionSource,
        amount: Int,
        description: String,
        balanceBefore: Int,
        balanceAfter: Int,
        checkInId: UUID?
    ) async throws -> PointTransaction
}

/// Check-in service errors
enum CheckInError: LocalizedError {
    case invalidNFCPayload
    case venueNotFound
    case userNotFound
    case alreadyCheckedInToday
    case networkError
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidNFCPayload:
            return "Invalid NFC tag. Please try again."
        case .venueNotFound:
            return "Venue not found."
        case .userNotFound:
            return "User not found."
        case .alreadyCheckedInToday:
            return "You've already checked in today. Come back tomorrow!"
        case .networkError:
            return "Network error. Please check your connection."
        case .unauthorized:
            return "Unauthorized. Please log in again."
        }
    }
}
