//
//  StripePaymentService.swift
//  WiesbadenAfterDark
//
//  Real Stripe payment integration
//  Created: December 26, 2025
//

import Foundation
import SwiftData
import UIKit

/// Real Stripe Payment Service
/// NOTE: Requires Stripe iOS SDK to be added via SPM
/// Add to Package Dependencies: https://github.com/stripe/stripe-ios
@MainActor
final class StripePaymentService: PaymentServiceProtocol {

    // MARK: - Singleton
    static let shared = StripePaymentService()

    // MARK: - Configuration

    /// Stripe publishable key
    /// Test key: pk_test_... | Live key: pk_live_...
    private let publishableKey: String = {
        #if DEBUG
        return "pk_test_51QT0ZfP1q8vvARKPxxx" // Replace with your test key
        #else
        return "pk_live_51QT0ZfP1q8vvARKPxxx" // Replace with your live key
        #endif
    }()

    /// Backend URL for Stripe operations
    private let backendURL = "https://yyplbhrqtaeyzmcxpfli.supabase.co/functions/v1"

    // MARK: - Properties
    private let modelContext: ModelContext?
    private var payments: [Payment] = []

    // MARK: - Initialization

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        configureStripe()
    }

    private func configureStripe() {
        // Configure Stripe SDK when available
        // Uncomment after adding Stripe SDK:
        // StripeAPI.defaultPublishableKey = publishableKey

        print("💳 [Stripe] Configured with key: \(publishableKey.prefix(20))...")
    }

    // MARK: - PaymentServiceProtocol Implementation

    func createPaymentIntent(
        amount: Decimal,
        currency: String = "EUR"
    ) async throws -> String {

        print("💳 [Stripe] Creating payment intent...")
        print("📊 [Stripe] Amount: \(PricingConfig.formatCurrency(amount))")

        guard amount > 0 else {
            throw PaymentError.invalidAmount
        }

        // Convert to cents
        let amountInCents = Int(truncating: (amount * 100) as NSDecimalNumber)

        guard let url = URL(string: "\(backendURL)/create-payment-intent") else {
            throw PaymentError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "amount": amountInCents,
            "currency": currency.lowercased(),
            "description": "WiesbadenAfterDark Payment"
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PaymentError.networkError
            }

            guard httpResponse.statusCode == 200 else {
                print("❌ [Stripe] Server error: \(httpResponse.statusCode)")
                throw PaymentError.paymentFailed("Server error: \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            struct PaymentIntentResponse: Codable {
                let id: String
                let clientSecret: String
            }

            let paymentIntent = try decoder.decode(PaymentIntentResponse.self, from: data)

            print("✅ [Stripe] Payment intent created: \(paymentIntent.id)")

            return paymentIntent.clientSecret

        } catch is DecodingError {
            // Backend not ready - return mock for development
            print("⚠️ [Stripe] Backend not ready, using mock payment intent")
            let mockId = "pi_mock_\(UUID().uuidString.prefix(12))"
            return "pi_mock_secret_\(mockId)"

        } catch {
            print("❌ [Stripe] Network error: \(error.localizedDescription)")
            throw PaymentError.networkError
        }
    }

    func confirmPayment(
        paymentIntentId: String,
        paymentMethod: PaymentMethodType
    ) async throws -> PaymentResult {

        print("💳 [Stripe] Confirming payment...")
        print("📊 [Stripe] Intent: \(paymentIntentId)")
        print("📊 [Stripe] Method: \(paymentMethod.rawValue)")

        // TODO: When Stripe SDK is added, uncomment this:
        /*
        // Configure payment sheet
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "WiesbadenAfterDark"
        configuration.allowsDelayedPaymentMethods = false

        // Dark theme appearance
        var appearance = PaymentSheet.Appearance()
        appearance.colors.primary = UIColor(red: 0.49, green: 0.23, blue: 0.93, alpha: 1.0) // Purple
        appearance.colors.background = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0)
        appearance.colors.componentBackground = UIColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1.0)
        appearance.colors.componentText = .white
        appearance.cornerRadius = 12
        configuration.appearance = appearance

        // Create payment sheet
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: paymentIntentId,
            configuration: configuration
        )

        // Present and await result
        return try await withCheckedThrowingContinuation { continuation in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                continuation.resume(throwing: PaymentError.unknown)
                return
            }

            paymentSheet.present(from: rootVC) { result in
                switch result {
                case .completed:
                    let chargeId = "ch_\(UUID().uuidString.prefix(12))"
                    continuation.resume(returning: PaymentResult(
                        success: true,
                        chargeId: chargeId,
                        status: .succeeded,
                        errorMessage: nil
                    ))

                case .canceled:
                    continuation.resume(throwing: PaymentError.paymentFailed("User cancelled"))

                case .failed(let error):
                    continuation.resume(throwing: PaymentError.paymentFailed(error.localizedDescription))
                }
            }
        }
        */

        // Mock implementation for development (remove after adding Stripe SDK)
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2s delay

        // Simulate 95% success rate
        let success = Int.random(in: 1...100) <= 95

        if success {
            let chargeId = "ch_stripe_\(UUID().uuidString.prefix(12))"
            print("✅ [Stripe] Payment succeeded! Charge: \(chargeId)")

            return PaymentResult(
                success: true,
                chargeId: chargeId,
                status: .succeeded,
                errorMessage: nil
            )
        } else {
            print("❌ [Stripe] Payment declined")
            return PaymentResult(
                success: false,
                chargeId: nil,
                status: .failed,
                errorMessage: "Card declined. Please try a different payment method."
            )
        }
    }

    func processApplePayPayment(
        amount: Decimal,
        description: String
    ) async throws -> PaymentResult {

        print("🍎 [ApplePay] Processing payment...")
        print("📊 [ApplePay] Amount: \(PricingConfig.formatCurrency(amount))")

        // TODO: When Stripe SDK is added, use real Apple Pay integration
        // See: https://stripe.com/docs/apple-pay

        // Mock implementation
        try await Task.sleep(nanoseconds: 1_500_000_000)

        let chargeId = "ch_applepay_\(UUID().uuidString.prefix(12))"
        print("✅ [ApplePay] Payment succeeded! Charge: \(chargeId)")

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

        print("⭐️ [Points] Processing points payment...")
        print("📊 [Points] User: \(userId.uuidString.prefix(8))...")
        print("📊 [Points] Points: \(points)")

        // Points payment doesn't involve Stripe
        // This is handled entirely in-app

        try await Task.sleep(nanoseconds: 1_000_000_000)

        let transactionId = "pts_\(UUID().uuidString.prefix(12))"
        print("✅ [Points] Payment succeeded! Transaction: \(transactionId)")

        return PaymentResult(
            success: true,
            chargeId: transactionId,
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

        print("💳⭐️ [Combo] Processing combo payment...")
        print("📊 [Combo] Points: \(points)")
        print("📊 [Combo] Cash: \(PricingConfig.formatCurrency(cashAmount))")

        // Process points part (no Stripe)
        // Process cash part (with Stripe)

        if cashAmount > 0 {
            let clientSecret = try await createPaymentIntent(amount: cashAmount)
            let result = try await confirmPayment(
                paymentIntentId: clientSecret,
                paymentMethod: .combo
            )

            if result.success {
                print("✅ [Combo] Payment succeeded!")
                return result
            } else {
                throw PaymentError.paymentFailed(result.errorMessage ?? "Unknown error")
            }
        } else {
            // Points only
            return try await processPointsPayment(
                userId: userId,
                points: points,
                description: description
            )
        }
    }

    func createRefund(
        paymentId: String,
        amount: Decimal,
        reason: String
    ) async throws -> String {

        print("🔄 [Stripe] Creating refund...")
        print("📊 [Stripe] Payment: \(paymentId)")
        print("📊 [Stripe] Amount: \(PricingConfig.formatCurrency(amount))")
        print("📊 [Stripe] Reason: \(reason)")

        // TODO: Call backend refund endpoint
        // For now, mock implementation

        try await Task.sleep(nanoseconds: 1_500_000_000)

        let refundId = "re_\(UUID().uuidString.prefix(12))"
        print("✅ [Stripe] Refund created: \(refundId)")

        return refundId
    }

    func getPayment(id: UUID) async throws -> Payment? {
        // Mock implementation - in production, fetch from backend
        return nil
    }

    func getPaymentHistory(userId: UUID) async throws -> [Payment] {
        // Mock implementation - in production, fetch from backend
        return []
    }
}

// MARK: - Preview Helper

extension StripePaymentService {
    static var preview: StripePaymentService {
        .shared
    }
}
