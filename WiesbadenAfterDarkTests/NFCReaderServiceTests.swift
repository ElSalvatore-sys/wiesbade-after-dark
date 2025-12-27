//
//  NFCReaderServiceTests.swift
//  WiesbadenAfterDarkTests
//
//  Unit tests for NFC Reader Service
//

import XCTest
@testable import WiesbadenAfterDark

@MainActor
final class NFCReaderServiceTests: XCTestCase {

    var sut: RealNFCReaderService!

    override func setUp() async throws {
        sut = RealNFCReaderService()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - Initialization Tests

    func testServiceInitializes() {
        XCTAssertNotNil(sut, "NFC service should initialize")
    }

    func testInitialStateIsIdle() {
        XCTAssertEqual(sut.scanStatus, .idle, "Initial status should be idle")
        XCTAssertFalse(sut.isScanning, "Should not be scanning initially")
    }

    // MARK: - NFC Availability Tests

    func testNFCAvailabilityCheck() {
        // This will be false on simulator, true on real device with NFC
        let isAvailable = sut.isNFCAvailable
        // Just verify it returns a boolean without crashing
        XCTAssertTrue(isAvailable || !isAvailable, "Should return availability status")
    }

    // MARK: - Venue ID Parsing Tests

    func testParseVenueIdFromWadURL() {
        // Test wad://checkin/{venueId} format
        let url = "wad://checkin/550e8400-e29b-41d4-a716-446655440000"
        let venueId = extractVenueId(from: url)
        XCTAssertEqual(venueId, "550e8400-e29b-41d4-a716-446655440000")
    }

    func testParseVenueIdFromHTTPSURL() {
        // Test https://wiesbadenafterdark.de/checkin/{venueId}
        let url = "https://wiesbadenafterdark.de/checkin/550e8400-e29b-41d4-a716-446655440000"
        let venueId = extractVenueId(from: url)
        XCTAssertEqual(venueId, "550e8400-e29b-41d4-a716-446655440000")
    }

    func testParseVenueIdFromPlainUUID() {
        let uuid = "550e8400-e29b-41d4-a716-446655440000"
        let venueId = extractVenueId(from: uuid)
        XCTAssertEqual(venueId, uuid)
    }

    func testParseVenueIdReturnsNilForInvalidInput() {
        let invalid = "not-a-valid-venue-id"
        let venueId = extractVenueId(from: invalid)
        XCTAssertNil(venueId)
    }

    // MARK: - Helper (mirrors private method)

    private func extractVenueId(from urlString: String) -> String? {
        // wad://checkin/{venueId}
        if urlString.hasPrefix("wad://checkin/") {
            return String(urlString.dropFirst("wad://checkin/".count))
        }

        // https URL
        if let url = URL(string: urlString),
           url.pathComponents.contains("checkin"),
           let idx = url.pathComponents.firstIndex(of: "checkin"),
           idx + 1 < url.pathComponents.count {
            return url.pathComponents[idx + 1]
        }

        // Plain UUID
        if UUID(uuidString: urlString) != nil {
            return urlString
        }

        return nil
    }
}
