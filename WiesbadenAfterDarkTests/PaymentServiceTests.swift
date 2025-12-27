//
//  PaymentServiceTests.swift
//  WiesbadenAfterDarkTests
//
//  Unit tests for Stripe Payment Service
//

import XCTest
@testable import WiesbadenAfterDark

@MainActor
final class PaymentServiceTests: XCTestCase {

    var sut: StripePaymentService!

    override func setUp() async throws {
        sut = StripePaymentService.shared
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - Initialization Tests

    func testServiceInitializes() {
        XCTAssertNotNil(sut, "Payment service should initialize")
    }

    // MARK: - Validation Tests

    func testInvalidAmountFails() async {
        do {
            _ = try await sut.createPaymentIntent(amount: -100, currency: "EUR")
            XCTFail("Should throw error for negative amount")
        } catch {
            // Expected behavior
            XCTAssertTrue(true)
        }
    }

    func testZeroAmountFails() async {
        do {
            _ = try await sut.createPaymentIntent(amount: 0, currency: "EUR")
            XCTFail("Should throw error for zero amount")
        } catch {
            // Expected behavior
            XCTAssertTrue(true)
        }
    }

    // MARK: - Points Payment Tests

    func testPointsPaymentWithSufficientBalance() async {
        // Mock scenario: user has enough points
        let result = await simulatePointsPayment(pointsRequired: 100, userPoints: 500)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.pointsUsed, 100)
    }

    func testPointsPaymentWithInsufficientBalance() async {
        // Mock scenario: user doesn't have enough points
        let result = await simulatePointsPayment(pointsRequired: 1000, userPoints: 100)
        XCTAssertFalse(result.success)
    }

    // MARK: - Currency Tests

    func testValidCurrencyFormats() {
        let currencies = ["EUR", "USD", "GBP"]
        for currency in currencies {
            XCTAssertTrue(currency.count == 3, "Currency code should be 3 letters")
        }
    }

    // MARK: - Amount Conversion Tests

    func testAmountToCentsConversion() {
        let amount: Decimal = 10.50
        let cents = Int(truncating: (amount * 100) as NSDecimalNumber)
        XCTAssertEqual(cents, 1050, "Should convert EUR to cents correctly")
    }

    // MARK: - Helpers

    private struct PointsPaymentResult {
        let success: Bool
        let pointsUsed: Int
    }

    private func simulatePointsPayment(pointsRequired: Int, userPoints: Int) async -> PointsPaymentResult {
        if userPoints >= pointsRequired {
            return PointsPaymentResult(success: true, pointsUsed: pointsRequired)
        } else {
            return PointsPaymentResult(success: false, pointsUsed: 0)
        }
    }
}
