//
//  TierUpgradeCelebration.swift
//  WiesbadenAfterDark
//
//  Celebration animation for tier upgrades with confetti and badge reveal
//

import SwiftUI

// MARK: - Tier Upgrade Celebration

/// Full-screen celebration view for tier upgrades
struct TierUpgradeCelebrationView: View {
    // MARK: - Properties

    let fromTier: MembershipTier
    let toTier: MembershipTier
    let venueName: String
    var onDismiss: () -> Void
    var onShare: (() -> Void)?

    @State private var showBadge = false
    @State private var showContent = false
    @State private var confettiTrigger = 0

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background Overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            // Confetti
            ConfettiView(trigger: confettiTrigger, tierColor: Color(hex: toTier.color))

            // Main Content
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()

                // Tier Badge Reveal
                tierBadgeReveal

                // Congratulations Text
                if showContent {
                    congratulationsText
                }

                // Benefits Preview
                if showContent {
                    benefitsPreview
                }

                Spacer()

                // Action Buttons
                if showContent {
                    actionButtons
                }
            }
            .padding(Theme.Spacing.xl)
        }
        .onAppear {
            performAnimation()
        }
    }

    // MARK: - Tier Badge Reveal

    private var tierBadgeReveal: some View {
        ZStack {
            // Glow Effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: toTier.color).opacity(showBadge ? 0.4 : 0),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 20)

            // Badge Circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: toTier.color),
                            Color(hex: toTier.color).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .shadow(color: Color(hex: toTier.color).opacity(0.6), radius: 30, x: 0, y: 15)
                .scaleEffect(showBadge ? 1.0 : 0.1)
                .opacity(showBadge ? 1.0 : 0)

            // Tier Icon
            Image(systemName: toTier.icon)
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(showBadge ? 1.0 : 0.1)
                .opacity(showBadge ? 1.0 : 0)
        }
        .scaleEffect(showBadge ? 1.0 : 0.8)
    }

    // MARK: - Congratulations Text

    private var congratulationsText: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("Congratulations!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .transition(.scale.combined(with: .opacity))

            Text("You've reached \(toTier.displayName) tier!")
                .font(Typography.h2)
                .foregroundColor(Color(hex: toTier.color))
                .transition(.scale.combined(with: .opacity))

            Text("at \(venueName)")
                .font(Typography.body)
                .foregroundColor(.white.opacity(0.8))
                .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Benefits Preview

    private var benefitsPreview: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("New Benefits Unlocked")
                .font(Typography.h3)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                benefitItem(
                    icon: "star.fill",
                    text: "\(formatMultiplier(toTier.defaultMultiplier)) Points Multiplier"
                )

                if toTier == .silver || toTier == .gold || toTier == .platinum {
                    benefitItem(
                        icon: "gift.fill",
                        text: "Birthday Bonus Rewards"
                    )
                }

                if toTier == .gold || toTier == .platinum {
                    benefitItem(
                        icon: "calendar.badge.clock",
                        text: "Early Event Access"
                    )
                }

                if toTier == .platinum {
                    benefitItem(
                        icon: "figure.walk.motion",
                        text: "VIP Skip-the-Line Access"
                    )
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                        .stroke(Color(hex: toTier.color).opacity(0.5), lineWidth: 2)
                )
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func benefitItem(icon: String, text: String) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: toTier.color))
                .font(.system(size: 18))
                .frame(width: 24)

            Text(text)
                .font(Typography.body)
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 18))
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Share Button
            if let onShare = onShare {
                Button(action: onShare) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Achievement")
                    }
                    .font(Typography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: toTier.color),
                                Color(hex: toTier.color).opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(Theme.CornerRadius.lg)
                }
            }

            // Continue Button
            Button(action: onDismiss) {
                Text("Continue")
                    .font(Typography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(Theme.CornerRadius.lg)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Animation Sequence

    private func performAnimation() {
        // Badge reveal
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showBadge = true
        }

        // Trigger confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            confettiTrigger += 1
        }

        // Show content
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }

    // MARK: - Helpers

    private func formatMultiplier(_ multiplier: Decimal) -> String {
        let value = NSDecimalNumber(decimal: multiplier).doubleValue
        return String(format: "%.1fx", value)
    }
}

// MARK: - Confetti View

/// Confetti animation overlay
struct ConfettiView: View {
    let trigger: Int
    let tierColor: Color

    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiPiece(particle: particle)
            }
        }
        .onChange(of: trigger) { _, _ in
            generateConfetti()
        }
    }

    private func generateConfetti() {
        let colors: [Color] = [
            tierColor,
            .yellow,
            .orange,
            .pink,
            .purple,
            .blue
        ]

        particles = (0..<100).map { i in
            ConfettiParticle(
                id: UUID(),
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: -20,
                color: colors.randomElement() ?? tierColor,
                size: CGFloat.random(in: 6...12),
                rotation: Double.random(in: 0...360),
                speed: CGFloat.random(in: 2...5)
            )
        }

        // Animate particles falling
        withAnimation(.linear(duration: 4.0)) {
            particles = particles.map { particle in
                var updated = particle
                updated.y = UIScreen.main.bounds.height + 100
                updated.x += CGFloat.random(in: -100...100)
                updated.rotation += Double.random(in: 360...720)
                return updated
            }
        }

        // Clear particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            particles.removeAll()
        }
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var rotation: Double
    let speed: CGFloat
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 1.5)
            .rotationEffect(.degrees(particle.rotation))
            .position(x: particle.x, y: particle.y)
    }
}

// MARK: - Badge Achievement Toast

/// Compact toast notification for badge unlocks
struct BadgeAchievementToast: View {
    let badgeName: String
    let icon: String
    let color: Color

    @State private var show = false

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Badge Unlocked!")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)

                Text(badgeName)
                    .font(Typography.bodyBold)
                    .foregroundColor(.textPrimary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 20))
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(
            color: Theme.Shadow.lg.color,
            radius: Theme.Shadow.lg.radius,
            x: Theme.Shadow.lg.x,
            y: Theme.Shadow.lg.y
        )
        .scaleEffect(show ? 1.0 : 0.8)
        .opacity(show ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                show = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Tier Upgrade - Gold") {
    TierUpgradeCelebrationView(
        fromTier: .silver,
        toTier: .gold,
        venueName: "Das Wohnzimmer",
        onDismiss: {},
        onShare: {}
    )
}

#Preview("Tier Upgrade - Platinum") {
    TierUpgradeCelebrationView(
        fromTier: .gold,
        toTier: .platinum,
        venueName: "Park Café",
        onDismiss: {},
        onShare: {}
    )
}

#Preview("Badge Toast") {
    BadgeAchievementToast(
        badgeName: "Regular Visitor",
        icon: "calendar.badge.checkmark",
        color: .blue
    )
    .padding()
    .background(Color.appBackground)
}
