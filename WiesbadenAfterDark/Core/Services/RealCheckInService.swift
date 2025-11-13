//
//  RealCheckInService.swift
//  WiesbadenAfterDark
//
//  Production check-in service that connects to the backend API
//  Handles spending-based points calculation with backend integration
//

import Foundation
import SwiftData

/// Production check-in service with real backend integration
@MainActor
final class RealCheckInService: CheckInServiceProtocol {
    // MARK: - Properties

    static let shared = RealCheckInService()
    private let apiClient = APIClient.shared
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0

    private init() {
        #if DEBUG
        print("✅ [RealCheckInService] Initialized with production backend")
        #endif
    }

    // MARK: - Check-In Operations

    /// Performs a check-in at a venue with spending data
    func performCheckIn(
        userId: UUID,
        venueId: UUID,
        venueName: String,
        method: CheckInMethod,
        eventId: UUID? = nil,
        eventMultiplier: Decimal = 1.0,
        amountSpent: Decimal? = nil,
        orderItems: [OrderItem]? = nil,
        venue: Venue? = nil
    ) async throws -> CheckIn {
        #if DEBUG
        print("🏃 [RealCheckInService] Starting check-in")
        print("   Venue: \(venueName)")
        print("   User: \(userId.uuidString.prefix(8))...")
        print("   Method: \(method.rawValue)")
        if let amount = amountSpent {
            print("   Amount spent: €\(NSDecimalNumber(decimal: amount).doubleValue)")
        }
        if let items = orderItems {
            print("   Order items: \(items.count)")
        }
        #endif

        // Prepare request
        let request = CheckInRequest(
            userId: userId,
            venueId: venueId,
            method: method.rawValue,
            amountSpent: amountSpent,
            orderItems: orderItems,
            eventId: eventId
        )

        // Perform check-in with retry logic
        let response = try await performWithRetry {
            try await self.apiClient.post(
                APIConfig.Endpoints.checkIn,
                body: request,
                requiresAuth: true
            ) as CheckInResponse
        }

        #if DEBUG
        print("✅ [RealCheckInService] Check-in successful")
        print("   Points earned: \(response.checkIn.pointsEarned)")
        print("   Base points: \(response.checkIn.basePoints)")
        print("   Bonus points: \(response.checkIn.bonusPoints)")
        print("   Streak bonus: \(response.checkIn.streakBonus)")
        print("   Streak day: \(response.checkIn.streakDay)")
        print("   New balance: \(response.checkIn.newBalance)")
        #endif

        // Convert response to CheckIn model
        let checkIn = CheckIn(
            id: response.checkIn.id,
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            checkInTime: Date(),
            checkInMethod: method,
            pointsEarned: response.checkIn.pointsEarned,
            basePoints: response.checkIn.basePoints,
            pointsMultiplier: eventMultiplier,
            eventId: eventId,
            streakDay: response.checkIn.streakDay,
            isStreakBonus: response.checkIn.streakDay > 1,
            streakMultiplier: calculateStreakMultiplier(for: response.checkIn.streakDay)
        )

        return checkIn
    }

    /// Simulates NFC tag scan (not used in production - would use CoreNFC)
    func simulateNFCScan(for venue: Venue) async throws -> String {
        #if DEBUG
        print("📱 [RealCheckInService] NFC scan simulation (use CoreNFC in production)")
        #endif

        // In production, this would use CoreNFC to read actual NFC tags
        // For now, generate a mock payload
        return "wad://check-in/\(venue.id.uuidString)/\(Date().timeIntervalSince1970)"
    }

    /// Validates NFC payload
    func validateNFCPayload(_ payload: String) async throws -> Bool {
        #if DEBUG
        print("🔍 [RealCheckInService] Validating NFC payload")
        #endif

        // Simple validation: check if payload starts with expected prefix
        guard payload.hasPrefix("wad://check-in/") else {
            throw CheckInError.invalidNFCPayload
        }

        // Extract components
        let components = payload.replacingOccurrences(of: "wad://check-in/", with: "")
            .components(separatedBy: "/")

        guard components.count >= 2,
              UUID(uuidString: components[0]) != nil else {
            throw CheckInError.invalidNFCPayload
        }

        return true
    }

    /// Calculates points for a check-in (client-side estimation only)
    /// Note: Production points are calculated server-side with margin data
    func calculatePoints(
        basePoints: Int,
        eventMultiplier: Decimal,
        streakDay: Int,
        isWeekend: Bool
    ) -> Int {
        let streakMultiplier = calculateStreakMultiplier(for: streakDay)
        let weekendMultiplier: Decimal = isWeekend ? 1.2 : 1.0
        let totalMultiplier = eventMultiplier * streakMultiplier * weekendMultiplier
        let points = Double(basePoints) * NSDecimalNumber(decimal: totalMultiplier).doubleValue

        return Int(points)
    }

    // MARK: - History & Streak

    /// Fetches check-in history for a user
    func fetchCheckInHistory(
        userId: UUID,
        venueId: UUID? = nil,
        limit: Int = 20
    ) async throws -> [CheckIn] {
        #if DEBUG
        print("📋 [RealCheckInService] Fetching check-in history")
        print("   User: \(userId.uuidString.prefix(8))...")
        if let venueId = venueId {
            print("   Venue filter: \(venueId.uuidString.prefix(8))...")
        }
        print("   Limit: \(limit)")
        #endif

        let response: CheckInHistoryResponse = try await apiClient.get(
            APIConfig.Endpoints.checkInHistory(userId: userId.uuidString),
            parameters: venueId != nil ? ["venueId": venueId!.uuidString] : nil,
            requiresAuth: true
        )

        #if DEBUG
        print("✅ [RealCheckInService] Found \(response.checkIns.count) check-ins")
        #endif

        // Convert DTOs to CheckIn models
        return response.checkIns.prefix(limit).map { dto in
            CheckIn(
                id: dto.id,
                userId: dto.userId,
                venueId: dto.venueId,
                venueName: dto.venueName,
                checkInTime: dto.checkInTime,
                checkInMethod: CheckInMethod(rawValue: dto.method) ?? .manual,
                pointsEarned: dto.pointsEarned,
                basePoints: dto.basePoints,
                pointsMultiplier: dto.eventMultiplier ?? 1.0,
                eventId: dto.eventId,
                streakDay: dto.streakDay,
                isStreakBonus: dto.streakDay > 1,
                streakMultiplier: calculateStreakMultiplier(for: dto.streakDay)
            )
        }
    }

    /// Gets current streak information for user at venue
    func getCurrentStreak(userId: UUID, venueId: UUID) async throws -> Int {
        #if DEBUG
        print("🔥 [RealCheckInService] Fetching current streak")
        print("   User: \(userId.uuidString.prefix(8))...")
        print("   Venue: \(venueId.uuidString.prefix(8))...")
        #endif

        let response: StreakResponse = try await apiClient.get(
            APIConfig.Endpoints.currentStreak(userId: userId.uuidString),
            parameters: ["venueId": venueId.uuidString],
            requiresAuth: true
        )

        #if DEBUG
        print("✅ [RealCheckInService] Current streak: Day \(response.streakDay)")
        #endif

        return response.streakDay
    }

    // MARK: - Point Transactions

    /// Fetches point transaction history
    func fetchPointTransactions(
        userId: UUID,
        venueId: UUID? = nil,
        limit: Int = 20
    ) async throws -> [PointTransaction] {
        #if DEBUG
        print("💰 [RealCheckInService] Fetching point transactions")
        #endif

        // For now, return empty array - this would need a backend endpoint
        // TODO: Implement when backend adds point transactions endpoint
        return []
    }

    /// Records a point transaction
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
        checkInId: UUID? = nil
    ) async throws -> PointTransaction {
        #if DEBUG
        print("💰 [RealCheckInService] Recording point transaction")
        print("   Type: \(type.rawValue)")
        print("   Amount: \(amount > 0 ? "+" : "")\(amount) pts")
        #endif

        // Create local transaction
        let transaction = PointTransaction(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            type: type,
            source: source,
            amount: amount,
            transactionDescription: description,
            balanceBefore: balanceBefore,
            balanceAfter: balanceAfter,
            checkInId: checkInId,
            timestamp: Date()
        )

        // TODO: Send to backend when endpoint is available

        return transaction
    }

    // MARK: - Helper Methods

    /// Calculates streak multiplier based on streak day
    private func calculateStreakMultiplier(for streakDay: Int) -> Decimal {
        switch streakDay {
        case 1: return 1.0
        case 2: return 1.2
        case 3: return 1.5
        case 4: return 2.0
        default: return 2.5 // Day 5+
        }
    }

    /// Performs an operation with retry logic
    private func performWithRetry<T>(
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        var delay = retryDelay

        for attempt in 1...maxRetries {
            do {
                return try await operation()
            } catch let error as APIError {
                lastError = error

                // Don't retry on client errors (4xx) except 429 (rate limit)
                if case .httpError(let statusCode, _) = error {
                    if statusCode >= 400 && statusCode < 500 && statusCode != 429 {
                        throw error
                    }
                }

                // Don't retry on unauthorized
                if case .unauthorized = error {
                    throw error
                }

                #if DEBUG
                print("⚠️ [RealCheckInService] Attempt \(attempt) failed: \(error)")
                if attempt < maxRetries {
                    print("   Retrying in \(delay)s...")
                }
                #endif

                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    delay *= 2 // Exponential backoff
                }
            } catch {
                lastError = error
                throw error // Non-API errors don't get retried
            }
        }

        throw lastError ?? CheckInError.networkError
    }
}

// MARK: - Request/Response Types

private struct CheckInRequest: Encodable {
    let userId: UUID
    let venueId: UUID
    let method: String
    let amountSpent: Decimal?
    let orderItems: [OrderItem]?
    let eventId: UUID?
}

private struct CheckInResponse: Decodable {
    let checkIn: CheckInDTO

    struct CheckInDTO: Decodable {
        let id: UUID
        let pointsEarned: Int
        let basePoints: Int
        let bonusPoints: Int
        let streakBonus: Decimal
        let streakDay: Int
        let newBalance: Double
    }
}

private struct CheckInHistoryResponse: Decodable {
    let checkIns: [CheckInDTO]

    struct CheckInDTO: Decodable {
        let id: UUID
        let userId: UUID
        let venueId: UUID
        let venueName: String
        let checkInTime: Date
        let method: String
        let pointsEarned: Int
        let basePoints: Int
        let eventId: UUID?
        let eventMultiplier: Decimal?
        let streakDay: Int
    }
}

private struct StreakResponse: Decodable {
    let streakDay: Int
    let lastCheckIn: Date?
}
