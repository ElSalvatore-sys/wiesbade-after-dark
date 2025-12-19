//
//  CheckInViewModel.swift
//  WiesbadenAfterDark
//
//  ViewModel managing check-in flow and NFC operations
//

import Foundation
import SwiftData

/// Check-in flow states
enum CheckInState: Equatable {
    case idle
    case scanning // NFC scan in progress
    case validating // Validating NFC tag
    case processing // Creating check-in record
    case success(CheckIn) // Check-in successful
    case error(String) // Check-in failed with error message

    static func == (lhs: CheckInState, rhs: CheckInState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.scanning, .scanning),
             (.validating, .validating),
             (.processing, .processing):
            return true
        case (.success(let lhsCheckIn), .success(let rhsCheckIn)):
            return lhsCheckIn.id == rhsCheckIn.id
        case (.error(let lhsMsg), .error(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

/// Main check-in view model
@MainActor
@Observable
final class CheckInViewModel {
    // MARK: - Dependencies

    private let checkInService: CheckInServiceProtocol
    private let walletPassService: WalletPassServiceProtocol
    private let modelContext: ModelContext?

    // MARK: - Published State

    // Check-in state
    var checkInState: CheckInState = .idle
    var isLoading: Bool = false
    var errorMessage: String?

    // Check-in history
    var checkIns: [CheckIn] = []
    var pointTransactions: [PointTransaction] = []

    // Wallet passes
    var walletPasses: [WalletPass] = []

    // Current check-in data
    var currentVenue: Venue?
    var currentEvent: Event?
    var estimatedPoints: Int = 50
    var currentStreak: Int = 1

    // Success data (for success screen)
    var successCheckIn: CheckIn?

    // MARK: - Initialization

    init(
        checkInService: CheckInServiceProtocol? = nil,
        walletPassService: WalletPassServiceProtocol? = nil,
        modelContext: ModelContext? = nil
    ) {
        self.checkInService = checkInService ?? MockCheckInService.shared
        self.walletPassService = walletPassService ?? MockWalletPassService.shared
        self.modelContext = modelContext

        print("🏃 [CheckInViewModel] Initialized")
    }

    // MARK: - Check-In Operations

    /// Performs manual check-in (no NFC)
    func performManualCheckIn(
        userId: UUID,
        venue: Venue,
        membership: VenueMembership,
        event: Event? = nil
    ) async {
        await performCheckIn(
            userId: userId,
            venue: venue,
            membership: membership,
            method: .manual,
            event: event
        )
    }

    /// Performs NFC check-in
    func performNFCCheckIn(
        userId: UUID,
        venue: Venue,
        membership: VenueMembership,
        event: Event? = nil
    ) async {
        checkInState = .scanning
        isLoading = true
        errorMessage = nil

        do {
            // 1. Simulate NFC scan
            let payload = try await checkInService.simulateNFCScan(for: venue)

            checkInState = .validating

            // 2. Validate payload
            let isValid = try await checkInService.validateNFCPayload(payload)

            guard isValid else {
                throw CheckInError.invalidNFCPayload
            }

            // 3. Perform check-in
            await performCheckIn(
                userId: userId,
                venue: venue,
                membership: membership,
                method: .nfc,
                event: event
            )

        } catch {
            errorMessage = error.localizedDescription
            checkInState = .error(error.localizedDescription)
            isLoading = false
        }
    }

    /// Core check-in logic
    private func performCheckIn(
        userId: UUID,
        venue: Venue,
        membership: VenueMembership,
        method: CheckInMethod,
        event: Event?
    ) async {
        checkInState = .processing
        isLoading = true
        errorMessage = nil

        do {
            // Calculate event multiplier
            let eventMultiplier: Decimal = event?.pointsMultiplier ?? 1.0

            // Perform check-in
            let checkIn = try await checkInService.performCheckIn(
                userId: userId,
                venueId: venue.id,
                venueName: venue.name,
                method: method,
                eventId: event?.id,
                eventMultiplier: eventMultiplier,
                amountSpent: nil,
                orderItems: nil,
                venue: venue
            )

            // Update membership points
            let newBalance = membership.pointsBalance + checkIn.pointsEarned

            // Record point transaction
            _ = try await checkInService.recordPointTransaction(
                userId: userId,
                venueId: venue.id,
                venueName: venue.name,
                type: .earn,
                source: .checkIn,
                amount: checkIn.pointsEarned,
                description: "Check-in at \(venue.name)",
                balanceBefore: membership.pointsBalance,
                balanceAfter: newBalance,
                checkInId: checkIn.id
            )

            // Save to SwiftData
            if let context = modelContext {
                context.insert(checkIn)
                try? context.save()
            }

            // Update state
            successCheckIn = checkIn
            checkInState = .success(checkIn)
            isLoading = false

            // Refresh history
            await fetchCheckInHistory(userId: userId)

        } catch {
            errorMessage = error.localizedDescription
            checkInState = .error(error.localizedDescription)
            isLoading = false
        }
    }

    // MARK: - Estimation

    /// Calculates estimated points for upcoming check-in
    func calculateEstimatedPoints(
        for venue: Venue,
        userId: UUID,
        event: Event? = nil
    ) async {
        do {
            // Get current streak
            let streak = try await checkInService.getCurrentStreak(
                userId: userId,
                venueId: venue.id
            )
            currentStreak = streak

            // Calculate points
            let eventMultiplier = event?.pointsMultiplier ?? 1.0
            let isWeekend = Calendar.current.isDateInWeekend(Date())

            let points = checkInService.calculatePoints(
                basePoints: 50,
                eventMultiplier: eventMultiplier,
                streakDay: streak,
                isWeekend: isWeekend
            )

            estimatedPoints = points

        } catch {
            print("❌ [CheckInViewModel] Error calculating points: \(error)")
            estimatedPoints = 50 // Fallback to base points
        }
    }

    // MARK: - History

    /// Fetches check-in history
    func fetchCheckInHistory(userId: UUID, venueId: UUID? = nil) async {
        do {
            checkIns = try await checkInService.fetchCheckInHistory(
                userId: userId,
                venueId: venueId,
                limit: 20
            )
        } catch {
            print("❌ [CheckInViewModel] Error fetching history: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    /// Fetches point transaction history
    func fetchPointTransactions(userId: UUID, venueId: UUID? = nil) async {
        do {
            pointTransactions = try await checkInService.fetchPointTransactions(
                userId: userId,
                venueId: venueId,
                limit: 20
            )
        } catch {
            print("❌ [CheckInViewModel] Error fetching transactions: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Wallet Pass Operations

    /// Generates wallet pass for venue
    func generateWalletPass(
        userId: UUID,
        venue: Venue,
        membership: VenueMembership
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let pass = try await walletPassService.generatePass(
                userId: userId,
                venueId: venue.id,
                venueName: venue.name,
                membership: membership
            )

            // Save to SwiftData
            if let context = modelContext {
                context.insert(pass)
                try? context.save()
            }

            // Refresh passes list
            await fetchWalletPasses(userId: userId)

            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Fetches all wallet passes for user
    func fetchWalletPasses(userId: UUID) async {
        do {
            walletPasses = try await walletPassService.fetchUserPasses(userId: userId)
        } catch {
            print("❌ [CheckInViewModel] Error fetching passes: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    /// Adds pass to Apple Wallet
    func addPassToWallet(_ pass: WalletPass) async {
        isLoading = true
        errorMessage = nil

        do {
            try await walletPassService.addToWallet(pass)

            // Refresh passes list
            if let userId = walletPasses.first?.userId {
                await fetchWalletPasses(userId: userId)
            }

            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Helper Methods

    /// Resets check-in state
    func resetCheckInState() {
        checkInState = .idle
        errorMessage = nil
        successCheckIn = nil
    }

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }
}
