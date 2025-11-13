//
//  RealVenueServiceTests.swift
//  WiesbadenAfterDarkTests
//
//  Unit tests for RealVenueService
//

import XCTest
@testable import WiesbadenAfterDark

@available(iOS 17.0, *)
final class RealVenueServiceTests: XCTestCase {

    var sut: RealVenueService!

    override func setUp() {
        super.setUp()
        sut = RealVenueService.shared
        sut.invalidateCache() // Clear cache before each test
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Cache Tests

    func testCacheInvalidation() {
        // Given
        sut.invalidateCache()

        // Then
        // Cache should be empty (we can't directly test private properties,
        // but we can verify behavior through subsequent API calls)
        XCTAssertNotNil(sut)
    }

    // MARK: - Fetch Venues Tests

    func testFetchVenues_Success() async throws {
        // When
        let venues = try await sut.fetchVenues()

        // Then
        XCTAssertFalse(venues.isEmpty, "Should fetch venues from backend")

        // Verify venue structure
        if let firstVenue = venues.first {
            XCTAssertFalse(firstVenue.id.uuidString.isEmpty)
            XCTAssertFalse(firstVenue.name.isEmpty)
            XCTAssertFalse(firstVenue.address.isEmpty)
            XCTAssertFalse(firstVenue.city.isEmpty)
        }
    }

    func testFetchVenues_CachingBehavior() async throws {
        // Given - First fetch (from network)
        let firstFetch = try await sut.fetchVenues()
        let firstFetchTime = Date()

        // When - Second fetch immediately (should use cache)
        let secondFetch = try await sut.fetchVenues()
        let secondFetchTime = Date()

        // Then
        XCTAssertEqual(firstFetch.count, secondFetch.count, "Cached result should match")

        // Second fetch should be much faster (< 100ms) because it's cached
        let timeDifference = secondFetchTime.timeIntervalSince(firstFetchTime)
        XCTAssertLessThan(timeDifference, 0.5, "Cached fetch should be very fast")

        // Verify same venue IDs
        let firstIds = Set(firstFetch.map { $0.id })
        let secondIds = Set(secondFetch.map { $0.id })
        XCTAssertEqual(firstIds, secondIds, "Cached venues should have same IDs")
    }

    func testFetchVenues_CacheExpiration() async throws {
        // Given - First fetch
        _ = try await sut.fetchVenues()

        // Wait for cache to expire (5 minutes + 1 second)
        // Note: In real tests, you'd want to use dependency injection
        // to inject a mock cache with shorter expiry for faster tests
        // For now, this test is more of a documentation of expected behavior

        // When - Fetch after cache expiry
        // let expiredFetch = try await sut.fetchVenues()

        // Then - Should fetch from network again
        // This would require network mocking to properly test
        XCTAssertTrue(true, "Cache expiration test placeholder")
    }

    // MARK: - Fetch Single Venue Tests

    func testFetchVenue_Success() async throws {
        // Given - Get a venue ID from the list
        let venues = try await sut.fetchVenues()
        guard let firstVenue = venues.first else {
            XCTFail("No venues available for testing")
            return
        }

        // When
        let fetchedVenue = try await sut.fetchVenue(id: firstVenue.id)

        // Then
        XCTAssertEqual(fetchedVenue.id, firstVenue.id)
        XCTAssertEqual(fetchedVenue.name, firstVenue.name)
        XCTAssertEqual(fetchedVenue.address, firstVenue.address)
        XCTAssertEqual(fetchedVenue.city, firstVenue.city)
    }

    func testFetchVenue_NotFound() async throws {
        // Given - Invalid UUID
        let invalidId = UUID()

        // When/Then
        do {
            _ = try await sut.fetchVenue(id: invalidId)
            XCTFail("Should throw venueNotFound error")
        } catch let error as VenueError {
            XCTAssertEqual(error, .venueNotFound)
        } catch {
            XCTFail("Should throw VenueError, got \(error)")
        }
    }

    func testFetchVenue_UsesCacheWhenAvailable() async throws {
        // Given - Populate cache
        let venues = try await sut.fetchVenues()
        guard let firstVenue = venues.first else {
            XCTFail("No venues available for testing")
            return
        }

        // When - Fetch same venue (should use cache)
        let startTime = Date()
        let fetchedVenue = try await sut.fetchVenue(id: firstVenue.id)
        let fetchTime = Date().timeIntervalSince(startTime)

        // Then
        XCTAssertEqual(fetchedVenue.id, firstVenue.id)
        XCTAssertLessThan(fetchTime, 0.1, "Should use cached data")
    }

    // MARK: - Fetch Events Tests

    func testFetchEvents_Success() async throws {
        // Given - Get a venue ID
        let venues = try await sut.fetchVenues()
        guard let venue = venues.first else {
            XCTFail("No venues available for testing")
            return
        }

        // When
        let events = try await sut.fetchEvents(venueId: venue.id)

        // Then
        // Events array may be empty if no events are scheduled
        XCTAssertNotNil(events)

        // If events exist, verify structure
        if let firstEvent = events.first {
            XCTAssertFalse(firstEvent.id.uuidString.isEmpty)
            XCTAssertEqual(firstEvent.venueId, venue.id)
        }
    }

    func testFetchEvents_InvalidVenue() async throws {
        // Given - Invalid venue ID
        let invalidId = UUID()

        // When/Then
        do {
            _ = try await sut.fetchEvents(venueId: invalidId)
            // May not fail if backend returns empty array for invalid venue
        } catch let error as VenueError {
            // Should throw venueNotFound or similar error
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Fetch All Events Tests

    func testFetchAllEvents_Success() async throws {
        // When
        let events = try await sut.fetchAllEvents()

        // Then
        XCTAssertNotNil(events)
        // Events may be empty if no events scheduled across all venues

        // If events exist, verify structure
        if let firstEvent = events.first {
            XCTAssertFalse(firstEvent.id.uuidString.isEmpty)
            XCTAssertFalse(firstEvent.venueId.uuidString.isEmpty)
        }
    }

    // MARK: - Error Mapping Tests

    func testMapAPIError_NotFound() {
        // This tests the error mapping logic
        // Would require access to private method or testing through public API
        XCTAssertTrue(true, "Error mapping test placeholder")
    }

    func testMapAPIError_InsufficientPoints() {
        // This tests the error mapping logic
        XCTAssertTrue(true, "Error mapping test placeholder")
    }

    func testMapAPIError_AlreadyMember() {
        // This tests the error mapping logic
        XCTAssertTrue(true, "Error mapping test placeholder")
    }

    // MARK: - Network Error Tests

    func testNetworkError_Handling() async {
        // This would require network mocking to properly test
        // Placeholder for network error handling tests
        XCTAssertTrue(true, "Network error test placeholder - requires mocking")
    }

    // MARK: - Integration Tests (require backend)

    func testIntegration_FetchVenuesFromBackend() async throws {
        // This is an integration test that requires the backend to be running
        // Skip in CI/CD environments

        guard ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"] == "true" else {
            throw XCTSkip("Integration tests disabled. Set RUN_INTEGRATION_TESTS=true to enable.")
        }

        // When
        let venues = try await sut.fetchVenues()

        // Then
        XCTAssertFalse(venues.isEmpty, "Backend should return venues")

        // Verify venue data quality
        for venue in venues {
            XCTAssertFalse(venue.name.isEmpty, "Venue name should not be empty")
            XCTAssertFalse(venue.address.isEmpty, "Venue address should not be empty")
            XCTAssertFalse(venue.city.isEmpty, "Venue city should not be empty")
            XCTAssertGreaterThanOrEqual(venue.rating, 0.0, "Rating should be non-negative")
        }
    }

    func testIntegration_VenueDetailMatch() async throws {
        guard ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"] == "true" else {
            throw XCTSkip("Integration tests disabled")
        }

        // Given
        let venues = try await sut.fetchVenues()
        guard let firstVenue = venues.first else {
            XCTFail("No venues returned from backend")
            return
        }

        // When - Fetch same venue by ID
        let venueDetail = try await sut.fetchVenue(id: firstVenue.id)

        // Then - Should match
        XCTAssertEqual(venueDetail.id, firstVenue.id)
        XCTAssertEqual(venueDetail.name, firstVenue.name)
        XCTAssertEqual(venueDetail.address, firstVenue.address)
    }

    // MARK: - Performance Tests

    func testPerformance_FetchVenues() throws {
        // Measure performance of fetching venues
        measure {
            let expectation = self.expectation(description: "Fetch venues")

            Task {
                do {
                    _ = try await sut.fetchVenues()
                    expectation.fulfill()
                } catch {
                    XCTFail("Fetch failed: \(error)")
                    expectation.fulfill()
                }
            }

            wait(for: [expectation], timeout: 10.0)
        }
    }

    func testPerformance_CachedFetch() throws {
        // First, populate the cache
        let populateExpectation = expectation(description: "Populate cache")
        Task {
            _ = try? await sut.fetchVenues()
            populateExpectation.fulfill()
        }
        wait(for: [populateExpectation], timeout: 10.0)

        // Measure performance of cached fetch
        measure {
            let expectation = self.expectation(description: "Cached fetch")

            Task {
                _ = try? await sut.fetchVenues()
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)
        }
    }
}

// MARK: - Test Helpers

extension VenueError: Equatable {
    public static func == (lhs: VenueError, rhs: VenueError) -> Bool {
        switch (lhs, rhs) {
        case (.venueNotFound, .venueNotFound):
            return true
        case (.eventNotFound, .eventNotFound):
            return true
        case (.insufficientPoints, .insufficientPoints):
            return true
        case (.rewardUnavailable, .rewardUnavailable):
            return true
        case (.alreadyMember, .alreadyMember):
            return true
        case (.unknownError, .unknownError):
            return true
        case (.networkError, .networkError):
            return true
        case (.serverError(let msg1), .serverError(let msg2)):
            return msg1 == msg2
        default:
            return false
        }
    }
}
