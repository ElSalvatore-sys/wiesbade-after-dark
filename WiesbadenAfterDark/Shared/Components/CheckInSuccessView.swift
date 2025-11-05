//
//  CheckInSuccessView.swift
//  WiesbadenAfterDark
//
//  Success screen shown after successful check-in
//

import SwiftUI

/// Check-in success celebration screen
struct CheckInSuccessView: View {
    // MARK: - Properties

    let checkIn: CheckIn
    let onDismiss: () -> Void

    // MARK: - Animation State

    @State private var showContent = false
    @State private var showPoints = false
    @State private var showBreakdown = false
    @State private var pulseAnimation = false

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
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
                        Text("Check-In Successful!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)

                        Text(checkIn.venueName)
                            .font(.title3)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    // Points Earned Card
                    VStack(spacing: 20) {
                        // Large Points Display
                        VStack(spacing: 8) {
                            Text("+\(checkIn.pointsEarned)")
                                .font(.system(size: 64, weight: .bold))
                                .foregroundStyle(Color.primaryGradient)

                            Text("Points Earned")
                                .font(.headline)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .opacity(showPoints ? 1 : 0)
                        .scaleEffect(showPoints ? 1 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: showPoints)

                        // Streak Badge (if applicable)
                        if checkIn.isStreakBonus {
                            HStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .font(.title2)
                                    .foregroundStyle(.orange)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Day \(checkIn.streakDay) Streak!")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.orange)

                                    Text("Keep it going tomorrow!")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.textSecondary)
                                }

                                Spacer()

                                Text("×\(String(format: "%.1f", NSDecimalNumber(decimal: checkIn.streakMultiplier).doubleValue))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.orange)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                                    )
                            )
                            .opacity(showBreakdown ? 1 : 0)
                            .offset(y: showBreakdown ? 0 : 10)
                            .animation(.easeOut(duration: 0.4).delay(0.6), value: showBreakdown)
                        }

                        // Points Breakdown
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text("Points Breakdown")
                                    .font(.headline)
                                    .foregroundStyle(Color.textPrimary)

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)

                            Divider()
                                .padding(.horizontal, 16)

                            VStack(spacing: 12) {
                                // Base Points
                                breakdownRow(
                                    icon: "star.fill",
                                    label: "Base Points",
                                    value: "\(checkIn.basePoints)",
                                    color: Color.primary
                                )

                                // Event/Weekend Multiplier
                                if checkIn.pointsMultiplier > 1.0 {
                                    breakdownRow(
                                        icon: "calendar.badge.clock",
                                        label: "Event/Weekend Bonus",
                                        value: "×\(String(format: "%.1f", NSDecimalNumber(decimal: checkIn.pointsMultiplier).doubleValue))",
                                        color: Color.secondary
                                    )
                                }

                                // Streak Multiplier
                                if checkIn.isStreakBonus {
                                    breakdownRow(
                                        icon: "flame.fill",
                                        label: "Streak Bonus",
                                        value: "×\(String(format: "%.1f", NSDecimalNumber(decimal: checkIn.streakMultiplier).doubleValue))",
                                        color: .orange
                                    )
                                }

                                Divider()
                                    .padding(.horizontal, 16)

                                // Total
                                breakdownRow(
                                    icon: "creditcard.fill",
                                    label: "Total Earned",
                                    value: "+\(checkIn.pointsEarned)",
                                    color: Color.primary,
                                    isBold: true
                                )
                            }
                            .padding(16)
                        }
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.Shadow.md.color, radius: Theme.Shadow.md.radius, x: Theme.Shadow.md.x, y: Theme.Shadow.md.y)
                        .opacity(showBreakdown ? 1 : 0)
                        .offset(y: showBreakdown ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.7), value: showBreakdown)
                    }
                    .padding(.horizontal)

                    // Check-In Details
                    VStack(spacing: 12) {
                        detailRow(
                            icon: methodIcon,
                            label: "Check-In Method",
                            value: checkIn.checkInMethod.rawValue
                        )

                        detailRow(
                            icon: "clock.fill",
                            label: "Time",
                            value: checkIn.checkInTime.formatted(date: .omitted, time: .shortened)
                        )

                        detailRow(
                            icon: "calendar",
                            label: "Date",
                            value: checkIn.checkInTime.formatted(date: .abbreviated, time: .omitted)
                        )
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .opacity(showBreakdown ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.9), value: showBreakdown)

                    // Continue Button
                    Button(action: onDismiss) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .opacity(showBreakdown ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(1.1), value: showBreakdown)

                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .onAppear {
            // Trigger animations in sequence
            withAnimation {
                showContent = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showPoints = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showBreakdown = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                pulseAnimation = true
            }
        }
    }

    // MARK: - Helper Views

    private func breakdownRow(
        icon: String,
        label: String,
        value: String,
        color: Color,
        isBold: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(isBold ? .bold : .semibold)
                .foregroundStyle(color)
        }
    }

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

    private var methodIcon: String {
        switch checkIn.checkInMethod {
        case .nfc:
            return "wave.3.right.circle.fill"
        case .qr:
            return "qrcode"
        case .manual:
            return "hand.tap.fill"
        }
    }
}

// MARK: - Preview

#Preview("Regular Check-In") {
    CheckInSuccessView(
        checkIn: CheckIn.mock(),
        onDismiss: {}
    )
}

#Preview("Streak Check-In") {
    CheckInSuccessView(
        checkIn: CheckIn(
            userId: UUID(),
            venueId: UUID(),
            venueName: "Das Loft",
            checkInTime: Date(),
            checkInMethod: .nfc,
            pointsEarned: 180,
            basePoints: 50,
            pointsMultiplier: 1.44, // 1.2 weekend × 1.2 event
            eventId: UUID(),
            streakDay: 5,
            isStreakBonus: true,
            streakMultiplier: 2.5
        ),
        onDismiss: {}
    )
}

#Preview("Simple Check-In") {
    CheckInSuccessView(
        checkIn: CheckIn(
            userId: UUID(),
            venueId: UUID(),
            venueName: "Nacht & Nebel",
            checkInTime: Date(),
            checkInMethod: .qr,
            pointsEarned: 50,
            basePoints: 50,
            pointsMultiplier: 1.0,
            eventId: nil,
            streakDay: 1,
            isStreakBonus: false,
            streakMultiplier: 1.0
        ),
        onDismiss: {}
    )
}
