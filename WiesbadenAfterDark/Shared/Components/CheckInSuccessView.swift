//
//  CheckInSuccessView.swift
//  WiesbadenAfterDark
//
//  Success screen shown after successful check-in with celebration effects
//

import SwiftUI

/// Check-in success celebration screen with confetti, haptics, and animations
struct CheckInSuccessView: View {
    // MARK: - Properties

    let checkIn: CheckIn
    let onDismiss: () -> Void

    // MARK: - Animation State

    @State private var showContent = false
    @State private var showPoints = false
    @State private var showBreakdown = false
    @State private var pulseAnimation = false
    @State private var confettiTrigger = 0
    @State private var displayedPoints: Int = 0
    @State private var showShareSheet = false

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color.appBackground
                .ignoresSafeArea()

            // Confetti overlay (reuse from TierUpgradeCelebration)
            ConfettiView(trigger: confettiTrigger, tierColor: .purple)

            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)

                    // Success Icon
                    ZStack {
                        // Outer glow ring
                        Circle()
                            .fill(Color.primaryGradient)
                            .frame(width: 140, height: 140)
                            .opacity(showContent ? 0.3 : 0)
                            .scaleEffect(showContent ? 1.2 : 0.8)
                            .animation(.easeOut(duration: 0.8), value: showContent)

                        // Main circle
                        Circle()
                            .fill(Color.primaryGradient)
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: pulseAnimation
                            )

                        // Checkmark icon with bounce
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(showContent ? 0 : -90))
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3), value: showContent)

                    // Success Message
                    VStack(spacing: 8) {
                        Text("Check-In Erfolgreich!")
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
                        // Large Points Display with counting animation
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                // Sparkle icon
                                Image(systemName: "sparkles")
                                    .font(.title)
                                    .foregroundStyle(.orange)
                                    .opacity(showPoints ? 1 : 0)
                                    .scaleEffect(showPoints ? 1 : 0.5)
                                    .rotationEffect(.degrees(showPoints ? 0 : -180))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5), value: showPoints)

                                // Animated counting points display
                                Text("+\(displayedPoints)")
                                    .font(.system(size: 64, weight: .bold))
                                    .foregroundStyle(Color.primaryGradient)
                                    .contentTransition(.numericText())
                                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: displayedPoints)

                                // Sparkle icon
                                Image(systemName: "sparkles")
                                    .font(.title)
                                    .foregroundStyle(.orange)
                                    .opacity(showPoints ? 1 : 0)
                                    .scaleEffect(showPoints ? 1 : 0.5)
                                    .rotationEffect(.degrees(showPoints ? 0 : 180))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5), value: showPoints)
                            }

                            Text("Punkte verdient")
                                .font(.headline)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .opacity(showPoints ? 1 : 0)
                        .scaleEffect(showPoints ? 1 : 0.5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: showPoints)

                        // Streak Badge (if applicable)
                        if checkIn.isStreakBonus {
                            HStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .font(.title2)
                                    .foregroundStyle(.orange)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Tag \(checkIn.streakDay) Serie!")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.orange)

                                    Text("Morgen weitermachen!")
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
                                Text("Punkte-Aufschlüsselung")
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
                                    label: "Basis-Punkte",
                                    value: "\(checkIn.basePoints)",
                                    color: Color.primary
                                )

                                // Event/Weekend Multiplier
                                if checkIn.pointsMultiplier > 1.0 {
                                    breakdownRow(
                                        icon: "calendar.badge.clock",
                                        label: "Event/Wochenend-Bonus",
                                        value: "×\(String(format: "%.1f", NSDecimalNumber(decimal: checkIn.pointsMultiplier).doubleValue))",
                                        color: Color.secondary
                                    )
                                }

                                // Streak Multiplier
                                if checkIn.isStreakBonus {
                                    breakdownRow(
                                        icon: "flame.fill",
                                        label: "Serien-Bonus",
                                        value: "×\(String(format: "%.1f", NSDecimalNumber(decimal: checkIn.streakMultiplier).doubleValue))",
                                        color: .orange
                                    )
                                }

                                Divider()
                                    .padding(.horizontal, 16)

                                // Total
                                breakdownRow(
                                    icon: "creditcard.fill",
                                    label: "Gesamt verdient",
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

                    // Action Buttons
                    VStack(spacing: 12) {
                        // Share Button
                        Button(action: { showShareSheet = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Teilen")
                            }
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                            )
                        }

                        // Continue Button
                        Button(action: onDismiss) {
                            Text("Weiter")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primaryGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
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
            // Play celebration sound with haptic burst
            SoundManager.shared.playCheckInSuccess(withHaptic: true)

            // Trigger confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                confettiTrigger += 1
            }

            // Trigger animations in sequence
            withAnimation {
                showContent = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showPoints = true
                }

                // Start counting animation for points
                animatePointsCount()
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
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
    }

    // MARK: - Share Text

    private var shareText: String {
        var text = "🎉 Gerade bei \(checkIn.venueName) eingecheckt! +\(checkIn.pointsEarned) Punkte verdient"
        if checkIn.isStreakBonus {
            text += " 🔥 Tag \(checkIn.streakDay) Serie!"
        }
        text += " #WiesbadenAfterDark"
        return text
    }

    // MARK: - Points Counting Animation

    private func animatePointsCount() {
        let duration = 1.0
        let steps = min(checkIn.pointsEarned, 30) // Max 30 steps for smooth animation
        let pointsPerStep = Double(checkIn.pointsEarned) / Double(steps)
        let stepDuration = duration / Double(steps)

        for step in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (stepDuration * Double(step))) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    displayedPoints = min(Int(Double(step + 1) * pointsPerStep), checkIn.pointsEarned)
                }

                // Small haptic on each increment
                if step % 5 == 0 {
                    HapticManager.shared.light()
                }
            }
        }

        // Play points earned sound when count finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            SoundManager.shared.playPointsEarned(withHaptic: true)
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

// MARK: - Share Sheet

/// UIKit share sheet wrapper for SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
