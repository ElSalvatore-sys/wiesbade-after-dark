//
//  CheckInViewModelTests.swift
//  WiesbadenAfterDarkTests
//
//  Unit tests for Check-In ViewModel
//

import XCTest
@testable import WiesbadenAfterDark

@MainActor
final class CheckInViewModelTests: XCTestCase {

    var sut: CheckInViewModel!

    override func setUp() async throws {
        sut = CheckInViewModel()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - Initialization Tests

    func testViewModelInitializes() {
        XCTAssertNotNil(sut, "ViewModel should initialize")
    }

    func testInitialStateIsCorrect() {
        XCTAssertFalse(sut.isCheckingIn, "Should not be checking in initially")
        XCTAssertFalse(sut.isNFCScanning, "Should not be scanning initially")
        XCTAssertEqual(sut.checkInStatus, .idle, "Status should be idle")
        XCTAssertNil(sut.lastError, "Should have no error initially")
    }

    // MARK: - Reset Tests

    func testResetClearsAllState() {
        // Simulate some state
        sut.showErrorAlert = true

        // Reset
        sut.resetState()

        // Verify
        XCTAssertFalse(sut.isCheckingIn)
        XCTAssertFalse(sut.isNFCScanning)
        XCTAssertEqual(sut.checkInStatus, .idle)
        XCTAssertNil(sut.lastError)
        XCTAssertFalse(sut.showErrorAlert)
    }

    // MARK: - Error Handling Tests

    func testDismissErrorResetsState() {
        sut.showErrorAlert = true

        sut.dismissError()

        XCTAssertFalse(sut.showErrorAlert)
    }

    // MARK: - Cancel Tests

    func testCancelCheckInResetsState() {
        sut.cancelCheckIn()

        XCTAssertFalse(sut.isCheckingIn)
        XCTAssertFalse(sut.isNFCScanning)
    }

    // MARK: - Error Message Tests

    func testNFCNotAvailableErrorMessage() {
        let error = CheckInViewModel.CheckInError.nfcNotAvailable
        XCTAssertEqual(error.errorDescription, "NFC wird auf diesem Gerät nicht unterstützt")
    }

    func testWrongVenueErrorMessage() {
        let error = CheckInViewModel.CheckInError.wrongVenue
        XCTAssertTrue(error.errorDescription?.contains("richtige Venue") ?? false)
    }

    func testAlreadyCheckedInErrorMessage() {
        let error = CheckInViewModel.CheckInError.alreadyCheckedIn
        XCTAssertTrue(error.errorDescription?.contains("bereits") ?? false)
    }

    func testNetworkErrorMessage() {
        let error = CheckInViewModel.CheckInError.networkError
        XCTAssertTrue(error.errorDescription?.contains("Netzwerk") ?? false)
    }
}
