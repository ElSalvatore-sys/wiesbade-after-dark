//
//  BookingDetailView.swift
//  WiesbadenAfterDark
//
//  Booking detail view with cancel/refund options
//

import SwiftUI

/// Booking detail view
struct BookingDetailView: View {
    // MARK: - Properties

    let booking: Booking
    let userId: UUID

    // MARK: - State

    @State private var showCancelAlert = false
    @State private var isCancelling = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Booking Card
                BookingCard(
                    booking: booking,
                    venueName: "Mock Venue", // TODO: Fetch venue name
                    mode: .full
                )

                // Confirmation Code (if available)
                if let confirmationCode = booking.confirmationCode {
                    confirmationCodeSection(code: confirmationCode)
                }

                // Special Requests
                if let specialRequests = booking.specialRequests, !specialRequests.isEmpty {
                    specialRequestsSection(requests: specialRequests)
                }

                // Price Breakdown
                PriceBreakdownView.forBooking(
                    tableType: booking.tableType,
                    pointsUsed: booking.pointsUsed
                )

                // Actions
                if booking.status != .cancelled && booking.bookingDate > Date() {
                    actionButtons
                }
            }
            .padding(Theme.Spacing.md)
        }
        .background(Color.appBackground)
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Cancel Booking", isPresented: $showCancelAlert) {
            Button("Cancel Booking", role: .destructive) {
                cancelBooking()
            }
            Button("Keep Booking", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this booking? You may be eligible for a refund.")
        }
    }

    // MARK: - Sections

    private func confirmationCodeSection(code: String) -> some View {
        VStack(spacing: Theme.Spacing.cardGap) {
            Text("Confirmation Code")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text(code)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.primary)
                .padding(Theme.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(Color.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))

            Text("Show this code at the venue")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(Theme.Spacing.cardPadding)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
    }

    private func specialRequestsSection(requests: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.cardGap) {
            Text("Special Requests")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text(requests)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.cardPadding)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: Theme.Spacing.cardGap) {
            // Contact Venue
            Button(action: {
                // TODO: Contact venue
            }) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text("Contact Venue")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.md)
                .background(Color.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
            }

            // Cancel Booking
            Button(action: {
                showCancelAlert = true
            }) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text(isCancelling ? "Cancelling..." : "Cancel Booking")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.md)
                .background(Color.error)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
            }
            .disabled(isCancelling)
        }
    }

    // MARK: - Cancel Booking

    private func cancelBooking() {
        isCancelling = true

        Task {
            // TODO: Call BookingService.cancelBooking()
            print("🚫 Cancelling booking: \(booking.id)")

            try? await Task.sleep(nanoseconds: 1_000_000_000)

            isCancelling = false
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BookingDetailView(
            booking: Booking(
                userId: UUID(),
                venueId: UUID(),
                tableType: .vip,
                partySize: 4,
                bookingDate: Date().addingTimeInterval(86400),
                timeSlot: "21:00 - 23:00",
                totalCost: 120.00,
                paymentMethod: .applePay,
                status: .confirmed,
                specialRequests: "Window seat preferred",
                confirmationCode: "VIP12345"
            ),
            userId: UUID()
        )
    }
}
