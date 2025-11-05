//
//  WalletPassServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Protocol for Apple Wallet pass generation and management
//

import Foundation

/// Wallet pass service protocol
protocol WalletPassServiceProtocol {
    /// Generates an Apple Wallet pass for a venue membership
    /// - Parameters:
    ///   - userId: User's ID
    ///   - venueId: Venue's ID
    ///   - venueName: Venue name
    ///   - membership: User's venue membership
    /// - Returns: Generated WalletPass
    func generatePass(
        userId: UUID,
        venueId: UUID,
        venueName: String,
        membership: VenueMembership
    ) async throws -> WalletPass

    /// Fetches all wallet passes for a user
    /// - Parameter userId: User's ID
    /// - Returns: Array of WalletPass records
    func fetchUserPasses(userId: UUID) async throws -> [WalletPass]

    /// Fetches a specific wallet pass
    /// - Parameters:
    ///   - userId: User's ID
    ///   - venueId: Venue's ID
    /// - Returns: WalletPass if exists, nil otherwise
    func fetchPass(userId: UUID, venueId: UUID) async throws -> WalletPass?

    /// Marks a pass as added to Apple Wallet
    /// - Parameter passId: Pass ID
    @MainActor
    func markPassAsAdded(passId: UUID) async throws

    /// Updates pass with latest membership data
    /// - Parameters:
    ///   - passId: Pass ID
    ///   - membership: Updated membership data
    @MainActor
    func updatePass(passId: UUID, membership: VenueMembership) async throws

    /// Simulates adding pass to Apple Wallet (mock implementation)
    /// - Parameter pass: WalletPass to add
    func addToWallet(_ pass: WalletPass) async throws

    /// Deletes a wallet pass
    /// - Parameter passId: Pass ID
    @MainActor
    func deletePass(passId: UUID) async throws
}

/// Wallet pass service errors
enum WalletPassError: LocalizedError {
    case passAlreadyExists
    case passNotFound
    case generationFailed
    case invalidMembership
    case networkError

    var errorDescription: String? {
        switch self {
        case .passAlreadyExists:
            return "You already have a pass for this venue."
        case .passNotFound:
            return "Wallet pass not found."
        case .generationFailed:
            return "Failed to generate wallet pass. Please try again."
        case .invalidMembership:
            return "Invalid membership. Please join the venue first."
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}
