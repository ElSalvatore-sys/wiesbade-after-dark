//
//  TransactionServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Protocol for transaction history management with backend sync
//

import Foundation

/// Protocol for managing transaction history with backend integration
protocol TransactionServiceProtocol {
    /// Fetches transactions from the backend with pagination
    /// - Parameters:
    ///   - userId: User ID to fetch transactions for
    ///   - page: Page number (1-based)
    ///   - limit: Number of transactions per page (default: 20)
    /// - Returns: Array of transactions for the requested page
    /// - Throws: APIError if request fails
    func fetchTransactions(userId: UUID, page: Int, limit: Int) async throws -> [PointTransaction]

    /// Syncs transactions from backend to local SwiftData storage
    /// - Parameter userId: User ID to sync transactions for
    /// - Throws: APIError if sync fails
    func syncTransactions(userId: UUID) async throws

    /// Gets transaction history from local SwiftData storage
    /// - Parameters:
    ///   - userId: User ID to fetch transactions for
    ///   - venueId: Optional venue ID to filter by specific venue
    /// - Returns: Array of transactions from local storage
    func getTransactionHistory(userId: UUID, venueId: UUID?) -> [PointTransaction]

    /// Filters transactions by type, date range
    /// - Parameters:
    ///   - userId: User ID to filter transactions for
    ///   - type: Optional transaction type filter
    ///   - startDate: Optional start date for date range filter
    ///   - endDate: Optional end date for date range filter
    ///   - venueId: Optional venue ID to filter by specific venue
    /// - Returns: Filtered array of transactions
    func filterTransactions(
        userId: UUID,
        type: TransactionType?,
        startDate: Date?,
        endDate: Date?,
        venueId: UUID?
    ) -> [PointTransaction]

    /// Creates a new transaction on the backend
    /// - Parameter transaction: Transaction to create
    /// - Returns: Created transaction from backend
    /// - Throws: APIError if creation fails
    func createTransaction(_ transaction: PointTransaction) async throws -> PointTransaction

    /// Gets total count of transactions for pagination
    /// - Parameter userId: User ID to count transactions for
    /// - Returns: Total number of transactions
    func getTotalTransactionCount(userId: UUID) -> Int
}
