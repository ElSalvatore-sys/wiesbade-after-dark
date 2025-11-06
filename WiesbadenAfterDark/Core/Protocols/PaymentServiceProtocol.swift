//
//  PaymentServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Protocol for payment service operations
//

import Foundation

/// Payment result
struct PaymentResult {
    let success: Bool
    let chargeId: String?
    let status: PaymentStatus
    let errorMessage: String?
}

/// Payment service protocol
@MainActor
protocol PaymentServiceProtocol {
    /// Create a payment intent
    func createPaymentIntent(
        amount: Decimal,
        currency: String
    ) async throws -> String

    /// Confirm payment with Stripe
    func confirmPayment(
        paymentIntentId: String,
        paymentMethod: PaymentMethodType
    ) async throws -> PaymentResult

    /// Process Apple Pay payment
    func processApplePayPayment(
        amount: Decimal,
        description: String
    ) async throws -> PaymentResult

    /// Process points payment
    func processPointsPayment(
        userId: UUID,
        points: Int,
        description: String
    ) async throws -> PaymentResult

    /// Process combo payment (points + cash)
    func processComboPayment(
        userId: UUID,
        points: Int,
        cashAmount: Decimal,
        description: String
    ) async throws -> PaymentResult

    /// Create refund
    func createRefund(
        paymentId: String,
        amount: Decimal,
        reason: String
    ) async throws -> String

    /// Get payment by ID
    func getPayment(id: UUID) async throws -> Payment?

    /// Get user payment history
    func getPaymentHistory(userId: UUID) async throws -> [Payment]
}

/// Payment error types
enum PaymentError: LocalizedError {
    case invalidAmount
    case insufficientFunds
    case insufficientPoints
    case paymentFailed(String)
    case refundFailed(String)
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid payment amount"
        case .insufficientFunds:
            return "Insufficient funds"
        case .insufficientPoints:
            return "Not enough points for this transaction"
        case .paymentFailed(let message):
            return "Payment failed: \(message)"
        case .refundFailed(let message):
            return "Refund failed: \(message)"
        case .networkError:
            return "Network connection error"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
