//
//  PaymentConfirmationView.swift
//  WiesbadenAfterDark
//
//  Payment success confirmation screen
//

import SwiftUI

/// Payment confirmation view
struct PaymentConfirmationView: View {
    // MARK: - Properties

    let booking: Booking
    let onDismiss: () -> Void

    // MARK: - Animation State

    @State private var showContent = false
    @State private var showDetails = false
    @State private var pulseAnimation = false

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)

                    // Success Icon
                    ZStack {
                        Circle()
                            .fill(Color.primaryGradient)
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: pulseAnimation
                            )

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showContent)

                    // Success Message
                    VStack(spacing: 8) {
                        Text("Booking Confirmed!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)

                        Text("Your table has been reserved")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    // Booking Details Card
                    VStack(spacing: 20) {
                        // Confirmation Code
                        if let confirmationCode = booking.confirmationCode {
                            VStack(spacing: 8) {
                                Text("Confirmation Code")
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)

                                Text(confirmationCode)
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(Color.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Booking Info
                        VStack(spacing: 16) {
                            detailRow(
                                icon: "building.2.fill",
                                label: "Table Type",
                                value: booking.tableType.displayName
                            )

                            detailRow(
                                icon: "calendar",
                                label: "Date",
                                value: booking.formattedDate
                            )

                            detailRow(
                                icon: "clock.fill",
                                label: "Time",
                                value: booking.timeSlot
                            )

                            detailRow(
                                icon: "person.2.fill",
                                label: "Party Size",
                                value: "\(booking.partySize) guests"
                            )

                            Divider()

                            detailRow(
                                icon: booking.paymentMethod?.icon ?? "creditcard.fill",
                                label: "Payment",
                                value: booking.formattedCost
                            )

                            if let paymentMethod = booking.paymentMethod {
                                HStack {
                                    Text("Method:")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.textSecondary)

                                    Spacer()

                                    HStack(spacing: 4) {
                                        Image(systemName: paymentMethod.icon)
                                            .font(.caption)

                                        Text(paymentMethod.displayName)
                                            .font(.subheadline)
                                    }
                                    .foregroundStyle(Color.textPrimary)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .opacity(showDetails ? 1 : 0)
                    .offset(y: showDetails ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showDetails)

                    // Continue Button
                    Button(action: onDismiss) {
                        Text("Done")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .opacity(showDetails ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: showDetails)

                    Spacer()
                        .frame(height: 40)
                }
                .padding()
            }
        }
        .onAppear {
            showContent = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showDetails = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                pulseAnimation = true
            }
        }
    }

    // MARK: - Helper Views

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.primary)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview {
    PaymentConfirmationView(
        booking: Booking(
            userId: UUID(),
            venueId: UUID(),
            tableType: .vip,
            partySize: 4,
            bookingDate: Date(),
            timeSlot: "21:00 - 23:00",
            totalCost: 120.00,
            paymentMethod: .applePay,
            status: .confirmed,
            confirmationCode: "VIP12345"
        ),
        onDismiss: {}
    )
}
