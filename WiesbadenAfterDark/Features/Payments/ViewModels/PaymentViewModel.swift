//
//  PaymentViewModel.swift
//  WiesbadenAfterDark
//
//  Payment state management
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class PaymentViewModel {
    // MARK: - State

    var paymentState: PaymentState = .idle
    var selectedPaymentMethod: PaymentMethodType?
    var errorMessage: String?

    // MARK: - Services

    private let paymentService: PaymentServiceProtocol
    private let bookingService: BookingServiceProtocol
    private let modelContext: ModelContext?

    // MARK: - Initialization

    init(
        paymentService: PaymentServiceProtocol? = nil,
        bookingService: BookingServiceProtocol? = nil,
        modelContext: ModelContext? = nil
    ) {
        self.paymentService = paymentService ?? MockPaymentService.shared
        self.modelContext = modelContext
        self.bookingService = bookingService ?? BookingService(
            paymentService: self.paymentService,
            modelContext: modelContext
        )

        print("💳 [PaymentVM] Initialized with modelContext: \(modelContext != nil ? "✅ YES" : "❌ NO")")
    }

    // MARK: - Payment Methods

    /// Process table booking payment
    func processBookingPayment(
        userId: UUID,
        venueId: UUID,
        tableType: TableType,
        partySize: Int,
        bookingDate: Date,
        timeSlot: String,
        specialRequests: String?,
        paymentMethod: PaymentMethodType,
        pointsToUse: Int? = nil
    ) async {
        paymentState = .processing

        do {
            let result = try await bookingService.createBooking(
                userId: userId,
                venueId: venueId,
                tableType: tableType,
                partySize: partySize,
                bookingDate: bookingDate,
                timeSlot: timeSlot,
                specialRequests: specialRequests,
                paymentMethod: paymentMethod,
                pointsToUse: pointsToUse
            )

            if result.success, let booking = result.booking {
                paymentState = .success(booking)
                print("✅ [PaymentVM] Booking payment successful")
            } else {
                throw PaymentError.paymentFailed(result.errorMessage ?? "Unknown error")
            }
        } catch {
            errorMessage = error.localizedDescription
            paymentState = .failed(error.localizedDescription)
            print("❌ [PaymentVM] Payment failed: \(error.localizedDescription)")
        }
    }

    /// Process card payment
    func processCardPayment(
        amount: Decimal,
        description: String
    ) async {
        paymentState = .processing

        do {
            // Create payment intent
            let intentId = try await paymentService.createPaymentIntent(
                amount: amount,
                currency: "EUR"
            )

            // Confirm payment
            let result = try await paymentService.confirmPayment(
                paymentIntentId: intentId,
                paymentMethod: .card
            )

            if result.success {
                paymentState = .cardPaymentSucceeded(result.chargeId ?? "")
                print("✅ [PaymentVM] Card payment successful")
            } else {
                throw PaymentError.paymentFailed(result.errorMessage ?? "Payment declined")
            }
        } catch {
            errorMessage = error.localizedDescription
            paymentState = .failed(error.localizedDescription)
            print("❌ [PaymentVM] Card payment failed: \(error.localizedDescription)")
        }
    }

    /// Process Apple Pay payment
    func processApplePayPayment(
        amount: Decimal,
        description: String
    ) async {
        paymentState = .processing

        do {
            let result = try await paymentService.processApplePayPayment(
                amount: amount,
                description: description
            )

            if result.success {
                paymentState = .applePaySucceeded(result.chargeId ?? "")
                print("✅ [PaymentVM] Apple Pay successful")
            } else {
                throw PaymentError.paymentFailed(result.errorMessage ?? "Apple Pay failed")
            }
        } catch {
            errorMessage = error.localizedDescription
            paymentState = .failed(error.localizedDescription)
            print("❌ [PaymentVM] Apple Pay failed: \(error.localizedDescription)")
        }
    }

    /// Process points payment
    func processPointsPayment(
        userId: UUID,
        points: Int,
        description: String
    ) async {
        paymentState = .processing

        do {
            let result = try await paymentService.processPointsPayment(
                userId: userId,
                points: points,
                description: description
            )

            if result.success {
                paymentState = .pointsPaymentSucceeded(points)
                print("✅ [PaymentVM] Points payment successful")
            } else {
                throw PaymentError.insufficientPoints
            }
        } catch {
            errorMessage = error.localizedDescription
            paymentState = .failed(error.localizedDescription)
            print("❌ [PaymentVM] Points payment failed: \(error.localizedDescription)")
        }
    }

    /// Process point purchase
    func purchasePoints(
        userId: UUID,
        package: PointPackage,
        paymentMethod: PaymentMethodType
    ) async {
        paymentState = .processing

        do {
            // Process payment for points
            let result: PaymentResult

            switch paymentMethod {
            case .card:
                let intentId = try await paymentService.createPaymentIntent(
                    amount: package.price,
                    currency: "EUR"
                )
                result = try await paymentService.confirmPayment(
                    paymentIntentId: intentId,
                    paymentMethod: .card
                )

            case .applePay:
                result = try await paymentService.processApplePayPayment(
                    amount: package.price,
                    description: "Point Purchase - \(package.name) Pack"
                )

            default:
                throw PaymentError.paymentFailed("Unsupported payment method")
            }

            if result.success {
                // Create points purchase record
                let purchase = PointsPurchase(
                    userId: userId,
                    paymentId: UUID(), // TODO: Use real payment ID
                    pointsAmount: package.points,
                    cashAmount: package.price,
                    bonusPoints: package.bonus,
                    packageName: package.name
                )

                paymentState = .pointsPurchaseSucceeded(purchase)
                print("✅ [PaymentVM] Points purchase successful")
            } else {
                throw PaymentError.paymentFailed(result.errorMessage ?? "Purchase failed")
            }
        } catch {
            errorMessage = error.localizedDescription
            paymentState = .failed(error.localizedDescription)
            print("❌ [PaymentVM] Points purchase failed: \(error.localizedDescription)")
        }
    }

    /// Reset state
    func reset() {
        paymentState = .idle
        selectedPaymentMethod = nil
        errorMessage = nil
    }
}

// MARK: - Payment State

enum PaymentState: Equatable {
    case idle
    case processing
    case success(Booking)
    case cardPaymentSucceeded(String) // chargeId
    case applePaySucceeded(String) // chargeId
    case pointsPaymentSucceeded(Int) // points used
    case pointsPurchaseSucceeded(PointsPurchase)
    case failed(String)

    static func == (lhs: PaymentState, rhs: PaymentState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.processing, .processing):
            return true
        case (.success(let b1), .success(let b2)):
            return b1.id == b2.id
        case (.cardPaymentSucceeded(let c1), .cardPaymentSucceeded(let c2)):
            return c1 == c2
        case (.applePaySucceeded(let c1), .applePaySucceeded(let c2)):
            return c1 == c2
        case (.pointsPaymentSucceeded(let p1), .pointsPaymentSucceeded(let p2)):
            return p1 == p2
        case (.pointsPurchaseSucceeded(let p1), .pointsPurchaseSucceeded(let p2)):
            return p1.id == p2.id
        case (.failed(let e1), .failed(let e2)):
            return e1 == e2
        default:
            return false
        }
    }
}
