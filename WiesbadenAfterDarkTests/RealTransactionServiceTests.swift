//
//  RealTransactionServiceTests.swift
//  WiesbadenAfterDarkTests
//
//  Unit tests for RealTransactionService
//

import XCTest
import SwiftData
@testable import WiesbadenAfterDark

final class RealTransactionServiceTests: XCTestCase {
    // MARK: - Properties

    var sut: RealTransactionService!
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    var testUserId: UUID!
    var testVenueId: UUID!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Create in-memory model container for testing
        let schema = Schema([PointTransaction.self])
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)

        // Initialize service
        sut = RealTransactionService(modelContext: modelContext)

        // Create test identifiers
        testUserId = UUID()
        testVenueId = UUID()
    }

    override func tearDownWithError() throws {
        sut = nil
        modelContext = nil
        modelContainer = nil
        testUserId = nil
        testVenueId = nil

        try super.tearDownWithError()
    }

    // MARK: - Local Storage Tests

    func testGetTransactionHistory_EmptyStorage() {
        // When
        let transactions = sut.getTransactionHistory(userId: testUserId)

        // Then
        XCTAssertTrue(transactions.isEmpty, "Should return empty array for new user")
    }

    func testGetTransactionHistory_WithTransactions() throws {
        // Given
        let transaction1 = createMockTransaction(hoursAgo: 1)
        let transaction2 = createMockTransaction(hoursAgo: 2)
        let transaction3 = createMockTransaction(hoursAgo: 3)

        modelContext.insert(transaction1)
        modelContext.insert(transaction2)
        modelContext.insert(transaction3)
        try modelContext.save()

        // When
        let transactions = sut.getTransactionHistory(userId: testUserId)

        // Then
        XCTAssertEqual(transactions.count, 3, "Should return all transactions")
        XCTAssertEqual(transactions[0].id, transaction1.id, "Should be sorted by timestamp descending")
    }

    func testGetTransactionHistory_FilterByVenue() throws {
        // Given
        let venue1Id = UUID()
        let venue2Id = UUID()

        let transaction1 = createMockTransaction(venueId: venue1Id, hoursAgo: 1)
        let transaction2 = createMockTransaction(venueId: venue2Id, hoursAgo: 2)
        let transaction3 = createMockTransaction(venueId: venue1Id, hoursAgo: 3)

        modelContext.insert(transaction1)
        modelContext.insert(transaction2)
        modelContext.insert(transaction3)
        try modelContext.save()

        // When
        let transactions = sut.getTransactionHistory(userId: testUserId, venueId: venue1Id)

        // Then
        XCTAssertEqual(transactions.count, 2, "Should return only venue1 transactions")
        XCTAssertTrue(transactions.allSatisfy { $0.venueId == venue1Id }, "All transactions should be for venue1")
    }

    // MARK: - Filter Tests

    func testFilterTransactions_ByType() throws {
        // Given
        let earnTransaction = createMockTransaction(type: .earn, hoursAgo: 1)
        let redeemTransaction = createMockTransaction(type: .redeem, hoursAgo: 2)
        let bonusTransaction = createMockTransaction(type: .bonus, hoursAgo: 3)

        modelContext.insert(earnTransaction)
        modelContext.insert(redeemTransaction)
        modelContext.insert(bonusTransaction)
        try modelContext.save()

        // When
        let earnTransactions = sut.filterTransactions(userId: testUserId, type: .earn)

        // Then
        XCTAssertEqual(earnTransactions.count, 1, "Should return only earn transactions")
        XCTAssertEqual(earnTransactions[0].type, .earn, "Transaction should be earn type")
    }

    func testFilterTransactions_ByDateRange() throws {
        // Given
        let now = Date()
        let twoDaysAgo = now.addingTimeInterval(-2 * 24 * 3600)
        let fiveDaysAgo = now.addingTimeInterval(-5 * 24 * 3600)

        let recentTransaction = createMockTransaction(timestamp: now.addingTimeInterval(-3600))
        let oldTransaction = createMockTransaction(timestamp: fiveDaysAgo)

        modelContext.insert(recentTransaction)
        modelContext.insert(oldTransaction)
        try modelContext.save()

        // When
        let filtered = sut.filterTransactions(
            userId: testUserId,
            startDate: twoDaysAgo,
            endDate: now
        )

        // Then
        XCTAssertEqual(filtered.count, 1, "Should return only recent transaction")
        XCTAssertEqual(filtered[0].id, recentTransaction.id, "Should return the recent transaction")
    }

    func testFilterTransactions_ByVenue() throws {
        // Given
        let venue1Id = UUID()
        let venue2Id = UUID()

        let venue1Transaction = createMockTransaction(venueId: venue1Id, hoursAgo: 1)
        let venue2Transaction = createMockTransaction(venueId: venue2Id, hoursAgo: 2)

        modelContext.insert(venue1Transaction)
        modelContext.insert(venue2Transaction)
        try modelContext.save()

        // When
        let filtered = sut.filterTransactions(userId: testUserId, venueId: venue1Id)

        // Then
        XCTAssertEqual(filtered.count, 1, "Should return only venue1 transaction")
        XCTAssertEqual(filtered[0].venueId, venue1Id, "Transaction should be for venue1")
    }

    func testFilterTransactions_CombinedFilters() throws {
        // Given
        let venue1Id = UUID()
        let venue2Id = UUID()
        let now = Date()
        let twoDaysAgo = now.addingTimeInterval(-2 * 24 * 3600)

        // Recent earn at venue1 - should match
        let match = createMockTransaction(
            type: .earn,
            venueId: venue1Id,
            timestamp: now.addingTimeInterval(-3600)
        )

        // Recent redeem at venue1 - wrong type
        let wrongType = createMockTransaction(
            type: .redeem,
            venueId: venue1Id,
            timestamp: now.addingTimeInterval(-7200)
        )

        // Old earn at venue1 - wrong date
        let wrongDate = createMockTransaction(
            type: .earn,
            venueId: venue1Id,
            timestamp: now.addingTimeInterval(-5 * 24 * 3600)
        )

        // Recent earn at venue2 - wrong venue
        let wrongVenue = createMockTransaction(
            type: .earn,
            venueId: venue2Id,
            timestamp: now.addingTimeInterval(-3600)
        )

        modelContext.insert(match)
        modelContext.insert(wrongType)
        modelContext.insert(wrongDate)
        modelContext.insert(wrongVenue)
        try modelContext.save()

        // When
        let filtered = sut.filterTransactions(
            userId: testUserId,
            type: .earn,
            startDate: twoDaysAgo,
            endDate: now,
            venueId: venue1Id
        )

        // Then
        XCTAssertEqual(filtered.count, 1, "Should return only matching transaction")
        XCTAssertEqual(filtered[0].id, match.id, "Should return the correct transaction")
    }

    // MARK: - Count Tests

    func testGetTotalTransactionCount_Empty() {
        // When
        let count = sut.getTotalTransactionCount(userId: testUserId)

        // Then
        XCTAssertEqual(count, 0, "Should return 0 for empty storage")
    }

    func testGetTotalTransactionCount_WithTransactions() throws {
        // Given
        for i in 0..<5 {
            let transaction = createMockTransaction(hoursAgo: Double(i))
            modelContext.insert(transaction)
        }
        try modelContext.save()

        // When
        let count = sut.getTotalTransactionCount(userId: testUserId)

        // Then
        XCTAssertEqual(count, 5, "Should return correct count")
    }

    func testGetTotalTransactionCount_OnlyCountsUserTransactions() throws {
        // Given
        let otherUserId = UUID()

        // Add transactions for test user
        for i in 0..<3 {
            let transaction = createMockTransaction(hoursAgo: Double(i))
            modelContext.insert(transaction)
        }

        // Add transactions for other user
        for i in 0..<2 {
            let transaction = createMockTransaction(userId: otherUserId, hoursAgo: Double(i))
            modelContext.insert(transaction)
        }

        try modelContext.save()

        // When
        let count = sut.getTotalTransactionCount(userId: testUserId)

        // Then
        XCTAssertEqual(count, 3, "Should only count test user's transactions")
    }

    // MARK: - Pagination Tests

    func testPagination_FirstPage() throws {
        // Given: Create 25 transactions
        for i in 0..<25 {
            let transaction = createMockTransaction(hoursAgo: Double(i))
            modelContext.insert(transaction)
        }
        try modelContext.save()

        // When: Fetch first page (20 items)
        let allTransactions = sut.getTransactionHistory(userId: testUserId)
        let firstPage = Array(allTransactions.prefix(20))

        // Then
        XCTAssertEqual(firstPage.count, 20, "First page should have 20 items")
        XCTAssertEqual(allTransactions.count, 25, "Total should be 25")
    }

    func testPagination_SecondPage() throws {
        // Given: Create 25 transactions
        for i in 0..<25 {
            let transaction = createMockTransaction(hoursAgo: Double(i))
            modelContext.insert(transaction)
        }
        try modelContext.save()

        // When: Fetch second page (remaining 5 items)
        let allTransactions = sut.getTransactionHistory(userId: testUserId)
        let secondPage = Array(allTransactions.dropFirst(20))

        // Then
        XCTAssertEqual(secondPage.count, 5, "Second page should have 5 items")
    }

    // MARK: - DTO Conversion Tests

    func testDTOConversion_EarnTransaction() {
        // Given
        let transaction = createMockTransaction(type: .earn, source: .checkIn)

        // When
        let dto = convertToDTO(transaction)

        // Then
        XCTAssertEqual(dto.id, transaction.id)
        XCTAssertEqual(dto.userId, transaction.userId)
        XCTAssertEqual(dto.amount, transaction.amount)
        XCTAssertEqual(dto.type.lowercased(), "earn")
        XCTAssertEqual(dto.balanceBefore, transaction.balanceBefore)
        XCTAssertEqual(dto.balanceAfter, transaction.balanceAfter)
    }

    func testDTOConversion_RedeemTransaction() {
        // Given
        let transaction = createMockTransaction(type: .redeem, source: .rewardRedemption)

        // When
        let dto = convertToDTO(transaction)

        // Then
        XCTAssertEqual(dto.type.lowercased(), "redeem")
    }

    func testDTOConversion_WithCheckInId() {
        // Given
        let checkInId = UUID()
        let transaction = createMockTransaction(checkInId: checkInId)

        // When
        let dto = convertToDTO(transaction)

        // Then
        XCTAssertEqual(dto.checkInId, checkInId)
    }

    // MARK: - Edge Cases

    func testFilterTransactions_NoResults() throws {
        // Given
        let transaction = createMockTransaction(type: .earn)
        modelContext.insert(transaction)
        try modelContext.save()

        // When: Filter by different type
        let filtered = sut.filterTransactions(userId: testUserId, type: .redeem)

        // Then
        XCTAssertTrue(filtered.isEmpty, "Should return empty array when no matches")
    }

    func testGetTransactionHistory_DifferentUser() throws {
        // Given
        let transaction = createMockTransaction()
        modelContext.insert(transaction)
        try modelContext.save()

        // When: Query with different user ID
        let otherUserId = UUID()
        let transactions = sut.getTransactionHistory(userId: otherUserId)

        // Then
        XCTAssertTrue(transactions.isEmpty, "Should not return other user's transactions")
    }

    func testTransactionOrdering_MostRecentFirst() throws {
        // Given
        let oldest = createMockTransaction(hoursAgo: 48)
        let middle = createMockTransaction(hoursAgo: 24)
        let newest = createMockTransaction(hoursAgo: 1)

        // Insert in random order
        modelContext.insert(middle)
        modelContext.insert(newest)
        modelContext.insert(oldest)
        try modelContext.save()

        // When
        let transactions = sut.getTransactionHistory(userId: testUserId)

        // Then
        XCTAssertEqual(transactions[0].id, newest.id, "First should be newest")
        XCTAssertEqual(transactions[1].id, middle.id, "Second should be middle")
        XCTAssertEqual(transactions[2].id, oldest.id, "Third should be oldest")
    }

    // MARK: - Helper Methods

    private func createMockTransaction(
        userId: UUID? = nil,
        type: TransactionType = .earn,
        source: TransactionSource = .checkIn,
        venueId: UUID? = nil,
        hoursAgo: Double = 1,
        timestamp: Date? = nil,
        checkInId: UUID? = nil
    ) -> PointTransaction {
        let transactionTimestamp = timestamp ?? Date().addingTimeInterval(-hoursAgo * 3600)

        return PointTransaction(
            userId: userId ?? testUserId,
            venueId: venueId ?? testVenueId,
            venueName: "Test Venue",
            type: type,
            source: source,
            amount: type == .redeem ? -100 : 50,
            transactionDescription: "Test transaction",
            balanceBefore: 100,
            balanceAfter: type == .redeem ? 0 : 150,
            checkInId: checkInId,
            timestamp: transactionTimestamp,
            createdAt: transactionTimestamp
        )
    }

    private func convertToDTO(_ transaction: PointTransaction) -> TransactionDTO {
        var metadata: [String: Any] = [
            "venueName": transaction.venueName
        ]

        if let rewardId = transaction.rewardId {
            metadata["rewardId"] = rewardId.uuidString
        }

        return TransactionDTO(
            id: transaction.id,
            userId: transaction.userId,
            venueId: transaction.venueId,
            amount: transaction.amount,
            type: transaction.type.rawValue.lowercased(),
            source: transaction.source.rawValue.replacingOccurrences(of: " ", with: "").lowercased(),
            balanceBefore: transaction.balanceBefore,
            balanceAfter: transaction.balanceAfter,
            createdAt: transaction.createdAt,
            checkInId: transaction.checkInId,
            metadata: metadata
        )
    }
}
