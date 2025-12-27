//
//  ModelTests.swift
//  WiesbadenAfterDarkTests
//
//  Unit tests for Data Models
//

import XCTest
@testable import WiesbadenAfterDark

final class ModelTests: XCTestCase {

    // MARK: - Venue Tests

    func testVenueDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "Das Wohnzimmer",
            "description": "Gemütliche Bar in Wiesbaden",
            "image_url": "https://example.com/image.jpg",
            "category": "bar",
            "address": "Teststraße 1",
            "rating": 4.5,
            "price_level": 2,
            "is_open": true
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let venue = try decoder.decode(WiesbadenVenueDTO.self, from: json)

        XCTAssertEqual(venue.name, "Das Wohnzimmer")
        XCTAssertEqual(venue.description, "Gemütliche Bar in Wiesbaden")
        XCTAssertEqual(venue.category, "bar")
    }

    // MARK: - Booking Tests

    func testBookingDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440001",
            "venue_id": "550e8400-e29b-41d4-a716-446655440002",
            "user_id": "550e8400-e29b-41d4-a716-446655440003",
            "party_size": 4,
            "booking_date": "2025-01-15T20:00:00Z",
            "status": "confirmed",
            "notes": "Window table please",
            "created_at": "2025-01-01T12:00:00Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let booking = try decoder.decode(WiesbadenBookingDTO.self, from: json)

        XCTAssertEqual(booking.partySize, 4)
        XCTAssertEqual(booking.status, "confirmed")
        XCTAssertEqual(booking.notes, "Window table please")
    }

    // MARK: - Post Tests

    func testPostDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440004",
            "content": "Toller Abend!",
            "type": "status",
            "venue_id": "550e8400-e29b-41d4-a716-446655440005",
            "image_url": "https://example.com/post.jpg",
            "created_at": "2025-01-01T20:00:00Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let post = try decoder.decode(WiesbadenPostDTO.self, from: json)

        XCTAssertEqual(post.content, "Toller Abend!")
        XCTAssertEqual(post.type, "status")
    }

    // MARK: - CheckIn Tests

    func testCheckInDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440006",
            "venue_id": "550e8400-e29b-41d4-a716-446655440007",
            "user_id": "550e8400-e29b-41d4-a716-446655440008",
            "created_at": "2025-01-01T22:00:00Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let checkIn = try decoder.decode(WiesbadenCheckInDTO.self, from: json)

        XCTAssertNotNil(checkIn.id)
        XCTAssertNotNil(checkIn.venueId)
        XCTAssertNotNil(checkIn.userId)
    }

    // MARK: - Loyalty Tier Tests

    func testLoyaltyTierOrdering() {
        let tiers: [LoyaltyTier] = [.bronze, .silver, .gold, .platinum]

        XCTAssertEqual(tiers.count, 4)
        XCTAssertEqual(tiers[0], .bronze)
        XCTAssertEqual(tiers[3], .platinum)
    }

    // MARK: - UUID Validation Tests

    func testUUIDStringValidation() {
        let validUUID = "550e8400-e29b-41d4-a716-446655440000"
        let invalidUUID = "not-a-uuid"

        XCTAssertNotNil(UUID(uuidString: validUUID), "Valid UUID should parse")
        XCTAssertNil(UUID(uuidString: invalidUUID), "Invalid UUID should not parse")
    }

    // MARK: - Date Formatting Tests

    func testISO8601DateParsing() throws {
        let dateString = "2025-01-01T20:00:00Z"
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: dateString)

        XCTAssertNotNil(date, "ISO8601 date should parse correctly")
    }
}
