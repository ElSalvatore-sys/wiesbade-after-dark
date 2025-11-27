//
//  MockCheckInService.swift
//  WiesbadenAfterDark
//
//  Mock implementation of check-in service for development
//

import Foundation
import SwiftData

@MainActor
final class MockCheckInService: CheckInServiceProtocol {
    // MARK: - Properties

    static let shared = MockCheckInService()

    private let nfcScanDelay: TimeInterval = 0.8  // Reduced for faster demo experience
    private let networkDelay: TimeInterval = 0.3  // Reduced for faster demo experience

    // In-memory storage for mock data
    private var checkIns: [CheckIn] = []
    private var transactions: [PointTransaction] = []

    private init() {
        print("✅ [MockCheckInService] Initialized")
    }

    // MARK: - Check-In Operations

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
        print("🏃 [CheckIn] Starting check-in at \(venueName)")
        print("   User: \(userId.uuidString.prefix(8))...")
        print("   Method: \(method.rawValue)")
        if let amount = amountSpent {
            print("   Amount spent: €\(NSDecimalNumber(decimal: amount).doubleValue)")
        }
        if let items = orderItems {
            print("   Order items: \(items.count) items")
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Check if already checked in today
        if hasCheckedInToday(userId: userId, venueId: venueId) {
            print("❌ [CheckIn] User already checked in today")
            throw CheckInError.alreadyCheckedInToday
        }

        // Get current streak
        let streakDay = try await getCurrentStreak(userId: userId, venueId: venueId)
        print("🔥 [CheckIn] Current streak: Day \(streakDay)")

        // Calculate streak multiplier
        let streakMultiplier: Decimal = {
            switch streakDay {
            case 1: return 1.0
            case 2: return 1.2
            case 3: return 1.5
            case 4: return 2.0
            default: return 2.5 // Day 5+
            }
        }()

        // Calculate weekend multiplier
        let isWeekend = Calendar.current.isDateInWeekend(Date())
        let weekendMultiplier: Decimal = isWeekend ? 1.2 : 1.0

        // Calculate points based on purchase or check-in
        let basePoints: Int
        let totalPoints: Int
        let calculationMethod: String

        if let items = orderItems, let venue = venue {
            // Margin-based calculation using total amount from order items
            // Note: MockCheckInService uses simplified calculation as it doesn't have detailed margin data
            let calculator = PointsCalculatorService.shared
            let totalAmount = items.reduce(into: Decimal(0)) { $0 += $1.totalPrice }

            let points = calculator.calculateSimplePoints(
                amount: totalAmount,
                category: .beverages, // Default category for mock
                venue: venue,
                bonusMultiplier: 1.0
            )

            totalPoints = NSDecimalNumber(decimal: points).intValue
            basePoints = totalPoints
            calculationMethod = "Margin-based (order total)"

            print("🎯 [CheckIn] Margin-based points calculation:")
            print("   Items: \(items.count)")
            print("   Total amount: €\(NSDecimalNumber(decimal: totalAmount).doubleValue)")
            print("   Total: \(totalPoints) pts")

        } else if let amount = amountSpent, let venue = venue {
            // Simple margin-based calculation (assume default category)
            let calculator = PointsCalculatorService.shared
            let points = calculator.calculateSimplePoints(
                amount: amount,
                category: .beverages, // Default category when not specified
                venue: venue,
                bonusMultiplier: 1.0
            )

            totalPoints = NSDecimalNumber(decimal: points).intValue
            basePoints = totalPoints
            calculationMethod = "Margin-based (simple)"

            print("🎯 [CheckIn] Simple margin-based points:")
            print("   Amount: €\(NSDecimalNumber(decimal: amount).doubleValue)")
            print("   Category: Beverages (default)")
            print("   Total: \(totalPoints) pts")

        } else {
            // Traditional check-in based points (no purchase)
            let checkInBasePoints = 50

            totalPoints = calculatePoints(
                basePoints: checkInBasePoints,
                eventMultiplier: eventMultiplier,
                streakDay: streakDay,
                isWeekend: isWeekend
            )
            basePoints = checkInBasePoints
            calculationMethod = "Check-in based"

            print("🎯 [CheckIn] Traditional check-in points:")
            print("   Base: \(basePoints) pts")
            if eventMultiplier > 1.0 {
                print("   Event multiplier: ×\(NSDecimalNumber(decimal: eventMultiplier).doubleValue)")
            }
            if isWeekend {
                print("   Weekend bonus: ×\(NSDecimalNumber(decimal: weekendMultiplier).doubleValue)")
            }
            if streakDay > 1 {
                print("   Streak multiplier (Day \(streakDay)): ×\(NSDecimalNumber(decimal: streakMultiplier).doubleValue)")
            }
            print("   Total: \(totalPoints) pts")
        }

        // Create check-in record
        let checkIn = CheckIn(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            checkInTime: Date(),
            checkInMethod: method,
            pointsEarned: totalPoints,
            basePoints: basePoints,
            pointsMultiplier: eventMultiplier * weekendMultiplier,
            eventId: eventId,
            streakDay: streakDay,
            isStreakBonus: streakDay > 1,
            streakMultiplier: streakMultiplier
        )

        // Store check-in
        checkIns.append(checkIn)

        print("✅ [CheckIn] Check-in recorded successfully")
        print("   Points earned: \(totalPoints)")
        print("   Streak: Day \(streakDay)")

        return checkIn
    }

    func simulateNFCScan(for venue: Venue) async throws -> String {
        print("📱 [NFC] Starting NFC scan...")
        print("   Venue: \(venue.name)")

        // Simulate NFC scan delay
        try await Task.sleep(nanoseconds: UInt64(nfcScanDelay * 1_000_000_000))

        // Generate mock NFC payload
        let payload = "wad://check-in/\(venue.id.uuidString)/\(Date().timeIntervalSince1970)"

        print("✅ [NFC] Tag detected")
        print("   Payload: \(payload.prefix(40))...")

        return payload
    }

    func validateNFCPayload(_ payload: String) async throws -> Bool {
        print("🔍 [NFC] Validating payload...")

        // Simple validation: check if payload starts with expected prefix
        guard payload.hasPrefix("wad://check-in/") else {
            print("❌ [NFC] Invalid payload format")
            throw CheckInError.invalidNFCPayload
        }

        // Extract components
        let components = payload.replacingOccurrences(of: "wad://check-in/", with: "")
            .components(separatedBy: "/")

        guard components.count >= 2,
              UUID(uuidString: components[0]) != nil else {
            print("❌ [NFC] Invalid venue ID in payload")
            throw CheckInError.invalidNFCPayload
        }

        print("✅ [NFC] Payload validated successfully")
        return true
    }

    func calculatePoints(
        basePoints: Int,
        eventMultiplier: Decimal,
        streakDay: Int,
        isWeekend: Bool
    ) -> Int {
        // Calculate streak multiplier
        let streakMultiplier: Decimal = {
            switch streakDay {
            case 1: return 1.0
            case 2: return 1.2
            case 3: return 1.5
            case 4: return 2.0
            default: return 2.5
            }
        }()

        // Weekend multiplier
        let weekendMultiplier: Decimal = isWeekend ? 1.2 : 1.0

        // Total multiplier
        let totalMultiplier = eventMultiplier * streakMultiplier * weekendMultiplier

        // Calculate final points
        let points = Double(basePoints) * NSDecimalNumber(decimal: totalMultiplier).doubleValue

        return Int(points)
    }

    // MARK: - History & Streak

    func fetchCheckInHistory(
        userId: UUID,
        venueId: UUID? = nil,
        limit: Int = 20
    ) async throws -> [CheckIn] {
        print("📋 [CheckIn] Fetching check-in history")
        print("   User: \(userId.uuidString.prefix(8))...")
        if let venueId = venueId {
            print("   Venue: \(venueId.uuidString.prefix(8))...")
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Filter by user and optionally by venue
        var filtered = checkIns.filter { $0.userId == userId }
        if let venueId = venueId {
            filtered = filtered.filter { $0.venueId == venueId }
        }

        // Sort by check-in time (most recent first)
        let sorted = filtered.sorted { $0.checkInTime > $1.checkInTime }

        // Limit results
        let limited = Array(sorted.prefix(limit))

        print("✅ [CheckIn] Found \(limited.count) check-ins")

        return limited
    }

    func getCurrentStreak(userId: UUID, venueId: UUID) async throws -> Int {
        print("🔥 [Streak] Calculating current streak...")

        // Get all check-ins for this user at this venue
        let venueCheckIns = checkIns
            .filter { $0.userId == userId && $0.venueId == venueId }
            .sorted { $0.checkInTime > $1.checkInTime } // Most recent first

        guard let lastCheckIn = venueCheckIns.first else {
            print("   No previous check-ins - starting Day 1")
            return 1 // First check-in
        }

        // Check if last check-in was within 24 hours
        let now = Date()
        let hoursSinceLastCheckIn = now.timeIntervalSince(lastCheckIn.checkInTime) / 3600

        if hoursSinceLastCheckIn > 24 {
            print("   Streak expired (last check-in \(Int(hoursSinceLastCheckIn))h ago)")
            return 1 // Streak expired, reset to Day 1
        }

        // Streak continues - increment from last streak day
        let newStreakDay = lastCheckIn.streakDay + 1

        print("   Streak continues: Day \(newStreakDay)")
        return newStreakDay
    }

    // MARK: - Point Transactions

    func fetchPointTransactions(
        userId: UUID,
        venueId: UUID? = nil,
        limit: Int = 20
    ) async throws -> [PointTransaction] {
        print("💰 [Transactions] Fetching point transactions")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Filter by user and optionally by venue
        var filtered = transactions.filter { $0.userId == userId }
        if let venueId = venueId {
            filtered = filtered.filter { $0.venueId == venueId }
        }

        // Sort by timestamp (most recent first)
        let sorted = filtered.sorted { $0.timestamp > $1.timestamp }

        // Limit results
        let limited = Array(sorted.prefix(limit))

        print("✅ [Transactions] Found \(limited.count) transactions")

        return limited
    }

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
        print("💰 [Transaction] Recording transaction")
        print("   Type: \(type.rawValue)")
        print("   Amount: \(amount > 0 ? "+" : "")\(amount) pts")
        print("   Balance: \(balanceBefore) → \(balanceAfter)")

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

        transactions.append(transaction)

        print("✅ [Transaction] Transaction recorded")

        return transaction
    }

    // MARK: - Helper Methods

    /// Checks if user has already checked in today
    private func hasCheckedInToday(userId: UUID, venueId: UUID) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return checkIns.contains { checkIn in
            checkIn.userId == userId &&
            checkIn.venueId == venueId &&
            calendar.isDate(checkIn.checkInTime, inSameDayAs: today)
        }
    }

    // MARK: - Mock Data Generation

    /// Seeds mock check-in history for testing
    func seedMockData(userId: UUID, venueId: UUID, venueName: String) {
        print("🌱 [MockCheckInService] Seeding mock data...")

        let mockCheckIns = CheckIn.mockHistory(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            count: 5
        )

        checkIns.append(contentsOf: mockCheckIns)

        let mockTransactions = PointTransaction.mockHistory(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            count: 10
        )

        transactions.append(contentsOf: mockTransactions)

        print("✅ [MockCheckInService] Seeded \(mockCheckIns.count) check-ins and \(mockTransactions.count) transactions")
    }
}
