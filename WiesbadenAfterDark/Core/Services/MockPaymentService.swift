//
//  MockPaymentService.swift
//  WiesbadenAfterDark
//
//  Mock payment service for testing and development
//

import Foundation
import SwiftData

@MainActor
final class MockPaymentService: PaymentServiceProtocol {
    // MARK: - Singleton

    static let shared = MockPaymentService()

    // MARK: - Properties

    private var payments: [Payment] = []

    // MARK: - PaymentServiceProtocol

    func createPaymentIntent(
        amount: Decimal,
        currency: String = "EUR"
    ) async throws -> String {
        print("💳 [MockPayment] Creating payment intent...")
        print("📊 [MockPayment] Amount: \(PricingConfig.formatCurrency(amount))")

        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s

        // Generate mock payment intent ID
        let intentId = "pi_mock_\(UUID().uuidString.prefix(12))"

        print("✅ [MockPayment] Payment intent created: \(intentId)")

        return intentId
    }

    func confirmPayment(
        paymentIntentId: String,
        paymentMethod: PaymentMethodType
    ) async throws -> PaymentResult {
        print("💳 [MockPayment] Confirming payment...")
        print("📊 [MockPayment] Intent ID: \(paymentIntentId)")
        print("📊 [MockPayment] Method: \(paymentMethod.rawValue)")

        // Simulate payment processing
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2s

        // Simulate 95% success rate
        let success = Int.random(in: 1...100) <= 95

        if success {
            let chargeId = "ch_mock_\(UUID().uuidString.prefix(12))"
            print("✅ [MockPayment] Payment succeeded!")
            print("📝 [MockPayment] Charge ID: \(chargeId)")

            return PaymentResult(
                success: true,
                chargeId: chargeId,
                status: .succeeded,
                errorMessage: nil
            )
        } else {
            print("❌ [MockPayment] Payment failed - Insufficient funds")

            return PaymentResult(
                success: false,
                chargeId: nil,
                status: .failed,
                errorMessage: "Insufficient funds. Please try a different card."
            )
        }
    }

    func processApplePayPayment(
        amount: Decimal,
        description: String
    ) async throws -> PaymentResult {
        print("🍎 [MockApplePay] Starting Apple Pay...")
        print("📊 [MockApplePay] Amount: \(PricingConfig.formatCurrency(amount))")
        print("📝 [MockApplePay] Description: \(description)")

        // Simulate Face ID / Touch ID
        print("🔐 [MockApplePay] Waiting for biometric authentication...")
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1s

        print("✅ [MockApplePay] Biometric authentication successful")

        // Simulate payment processing
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s

        let chargeId = "ch_applepay_\(UUID().uuidString.prefix(12))"
        print("✅ [MockApplePay] Payment succeeded!")
        print("📝 [MockApplePay] Charge ID: \(chargeId)")

        return PaymentResult(
            success: true,
            chargeId: chargeId,
            status: .succeeded,
            errorMessage: nil
        )
    }

    func processPointsPayment(
        userId: UUID,
        points: Int,
        description: String
    ) async throws -> PaymentResult {
        print("⭐ [MockPoints] Processing points payment...")
        print("📊 [MockPoints] Points: \(PricingConfig.formatPoints(points))")
        print("📝 [MockPoints] Description: \(description)")

        // TODO: Check if user has enough points
        // For mock, assume they do

        print("✅ [MockPoints] Points deducted successfully")

        return PaymentResult(
            success: true,
            chargeId: "pts_\(UUID().uuidString.prefix(12))",
            status: .succeeded,
            errorMessage: nil
        )
    }

    func processComboPayment(
        userId: UUID,
        points: Int,
        cashAmount: Decimal,
        description: String
    ) async throws -> PaymentResult {
        print("💰 [MockCombo] Processing combo payment...")
        print("📊 [MockCombo] Points: \(PricingConfig.formatPoints(points))")
        print("📊 [MockCombo] Cash: \(PricingConfig.formatCurrency(cashAmount))")
        print("📝 [MockCombo] Description: \(description)")

        // Simulate processing
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2s

        print("✅ [MockCombo] Combo payment succeeded")

        return PaymentResult(
            success: true,
            chargeId: "ch_combo_\(UUID().uuidString.prefix(12))",
            status: .succeeded,
            errorMessage: nil
        )
    }

    func createRefund(
        paymentId: String,
        amount: Decimal,
        reason: String
    ) async throws -> String {
        print("🔄 [MockRefund] Creating refund...")
        print("📊 [MockRefund] Payment ID: \(paymentId)")
        print("📊 [MockRefund] Amount: \(PricingConfig.formatCurrency(amount))")
        print("📝 [MockRefund] Reason: \(reason)")

        // Simulate processing
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s

        let refundId = "re_mock_\(UUID().uuidString.prefix(12))"
        print("✅ [MockRefund] Refund created: \(refundId)")

        return refundId
    }

    func getPayment(id: UUID) async throws -> Payment? {
        return payments.first { $0.id == id }
    }

    func getPaymentHistory(userId: UUID) async throws -> [Payment] {
        // Return mock payment history
        return [
            Payment.mock(userId: userId, amount: 120.00, status: .succeeded),
            Payment.mock(userId: userId, amount: 50.00, status: .succeeded),
            Payment.mock(userId: userId, amount: 10.00, status: .succeeded, description: "Point Purchase - Value Pack")
        ]
    }
}
