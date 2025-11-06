//
//  PaymentSheet.swift
//  WiesbadenAfterDark
//
//  Main payment flow coordinator
//

import SwiftUI

/// Payment sheet for booking payments
struct PaymentSheet: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties

    let booking: BookingDetails
    let userId: UUID

    // MARK: - State

    @State private var viewModel: PaymentViewModel?
    @State private var showSuccess = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let vm = viewModel {
                        // Booking Summary
                        bookingSummary

                        // Payment Method Selector
                        if vm.selectedPaymentMethod == nil {
                            PaymentMethodSelector(
                                amount: booking.totalCost,
                                pointsCost: booking.pointsCost,
                                availablePoints: booking.userPoints,
                                onSelect: { method in
                                    vm.selectedPaymentMethod = method
                                    processPayment(method: method)
                                }
                            )
                        }

                        // Processing State
                        if case .processing = vm.paymentState {
                            processingView
                        }

                        // Error State
                        if case .failed(let message) = vm.paymentState {
                            errorView(message: message)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if let vm = viewModel, case .processing = vm.paymentState {
                        EmptyView()
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showSuccess) {
                if let vm = viewModel, case .success(let confirmedBooking) = vm.paymentState {
                    PaymentConfirmationView(
                        booking: confirmedBooking,
                        onDismiss: {
                            showSuccess = false
                            dismiss()
                        }
                    )
                }
            }
            .onChange(of: viewModel?.paymentState) { _, newState in
                if case .success = newState {
                    showSuccess = true
                }
            }
            .onAppear {
                if viewModel == nil {
                    print("💳 [PaymentSheet] Initializing PaymentViewModel with modelContext")
                    viewModel = PaymentViewModel(modelContext: modelContext)
                }
            }
        }
    }

    // MARK: - Booking Summary

    private var bookingSummary: some View {
        VStack(spacing: 16) {
            Text("Booking Summary")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)

            VStack(alignment: .leading, spacing: 12) {
                summaryRow(label: "Venue", value: booking.venueName)
                summaryRow(label: "Table", value: booking.tableType.displayName)
                summaryRow(label: "Date", value: booking.date.formatted(date: .long, time: .omitted))
                summaryRow(label: "Time", value: booking.timeSlot)
                summaryRow(label: "Guests", value: "\(booking.partySize)")

                Divider()

                summaryRow(
                    label: "Total",
                    value: PricingConfig.formatCurrency(booking.totalCost),
                    isTotal: true
                )
            }
            .padding(16)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func summaryRow(label: String, value: String, isTotal: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(isTotal ? .headline : .subheadline)
                .foregroundStyle(isTotal ? Color.textPrimary : Color.textSecondary)

            Spacer()

            Text(value)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .medium)
                .foregroundStyle(isTotal ? Color.primary : Color.textPrimary)
        }
    }

    // MARK: - Processing View

    private var processingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.primary)

            Text("Processing Payment...")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text("Please wait while we process your payment")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)

            Text("Payment Failed")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                viewModel?.reset()
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Payment Processing

    private func processPayment(method: PaymentMethodType) {
        guard let vm = viewModel else {
            print("❌ [PaymentSheet] Cannot process payment - viewModel is nil!")
            return
        }

        Task {
            await vm.processBookingPayment(
                userId: userId,
                venueId: booking.venueId,
                tableType: booking.tableType,
                partySize: booking.partySize,
                bookingDate: booking.date,
                timeSlot: booking.timeSlot,
                specialRequests: booking.specialRequests,
                paymentMethod: method,
                pointsToUse: method == .points ? booking.pointsCost : nil
            )
        }
    }
}

// MARK: - Booking Details

struct BookingDetails {
    let venueId: UUID
    let venueName: String
    let tableType: TableType
    let partySize: Int
    let date: Date
    let timeSlot: String
    let specialRequests: String?
    let totalCost: Decimal
    let pointsCost: Int
    let userPoints: Int
}

// MARK: - Preview

#Preview {
    PaymentSheet(
        booking: BookingDetails(
            venueId: UUID(),
            venueName: "Das Loft",
            tableType: .vip,
            partySize: 4,
            date: Date(),
            timeSlot: "21:00 - 23:00",
            specialRequests: nil,
            totalCost: 120.00,
            pointsCost: 2400,
            userPoints: 3000
        ),
        userId: UUID()
    )
}
