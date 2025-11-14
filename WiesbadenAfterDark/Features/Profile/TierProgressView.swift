//
//  TierProgressView.swift
//  WiesbadenAfterDark
//
//  Customer-facing tier progression view with progress tracking
//

import SwiftUI

/// Displays user's tier progression with visual progress bar and benefits
struct TierProgressView: View {
    // MARK: - Properties

    let progress: TierProgress
    let venueName: String
    var onShareAchievement: (() -> Void)?

    @State private var animateProgress = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Current Tier Badge
            tierBadgeSection

            // Progress Bar
            if progress.nextTier != nil {
                progressSection
            } else {
                maxTierSection
            }

            // Current Benefits
            benefitsSection

            // Next Tier Preview (if not at max)
            if let nextTier = progress.nextTier {
                nextTierPreview(nextTier)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.xl)
        .shadow(
            color: Theme.Shadow.lg.color,
            radius: Theme.Shadow.lg.radius,
            x: Theme.Shadow.lg.x,
            y: Theme.Shadow.lg.y
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateProgress = true
            }
        }
    }

    // MARK: - Tier Badge Section

    private var tierBadgeSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Tier Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [tierColor, tierColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .shadow(color: tierColor.opacity(0.5), radius: 20, x: 0, y: 10)

                Image(systemName: progress.currentTier.icon)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            // Tier Name
            Text(progress.currentTier.displayName)
                .font(Typography.titleLarge)
                .foregroundColor(.textPrimary)

            // Days at Tier
            Text("Member for \(progress.daysAtCurrentTier) days")
                .font(Typography.captionMedium)
                .foregroundColor(.textSecondary)

            // Multiplier Badge
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)

                Text("\(formatMultiplier(progress.multiplier)) Points")
                    .font(Typography.captionMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.sm)
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Progress Text
            HStack {
                Text(progress.progressText)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(Int(progress.progressPercentage))%")
                    .font(Typography.headlineMedium)
                    .foregroundColor(.primary)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)

                    // Progress Fill
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .fill(LinearGradient(
                            colors: [tierColor, tierColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(
                            width: animateProgress ?
                                geometry.size.width * CGFloat(progress.progressPercentage / 100.0) : 0,
                            height: 12
                        )
                        .shadow(color: tierColor.opacity(0.4), radius: 8, x: 0, y: 2)
                }
            }
            .frame(height: 12)

            // Amount Needed Text
            if let amountNeeded = progress.amountNeededText {
                HStack {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundColor(.primary)

                    Text(amountNeeded)
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)

                    Spacer()
                }
            }
        }
    }

    // MARK: - Max Tier Section

    private var maxTierSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20))

                Text("Maximum Tier Reached!")
                    .font(Typography.headlineLarge)
                    .foregroundColor(.textPrimary)

                Spacer()
            }

            Text("You've achieved the highest tier at \(venueName). Enjoy all exclusive benefits!")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Theme.Spacing.md)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Theme.CornerRadius.md)
    }

    // MARK: - Benefits Section

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Your Benefits")
                .font(Typography.headlineLarge)
                .foregroundColor(.textPrimary)

            ForEach(progress.perks) { perk in
                HStack(alignment: .top, spacing: Theme.Spacing.md) {
                    Image(systemName: perk.icon)
                        .font(.system(size: 18))
                        .foregroundColor(tierColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(perk.name)
                            .font(Typography.headlineMedium)
                            .foregroundColor(.textPrimary)

                        Text(perk.description)
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Next Tier Preview

    private func nextTierPreview(_ nextTier: MembershipTier) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Unlock at \(nextTier.displayName)")
                    .font(Typography.headlineLarge)
                    .foregroundColor(.textPrimary)

                Spacer()

                Image(systemName: "lock.fill")
                    .foregroundColor(.textSecondary)
                    .font(.system(size: 16))
            }

            // Show a teaser of next tier benefits
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(hex: nextTier.color))
                        .font(.system(size: 14))

                    Text("\(formatMultiplier(nextTier.defaultMultiplier)) Points Multiplier")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)
                }

                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundColor(Color(hex: nextTier.color))
                        .font(.system(size: 14))

                    Text("Exclusive perks and rewards")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)
                }

                if nextTier == .platinum {
                    HStack {
                        Image(systemName: "figure.walk.motion")
                            .foregroundColor(Color(hex: nextTier.color))
                            .font(.system(size: 14))

                        Text("VIP skip-the-line access")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private var tierColor: Color {
        Color(hex: progress.currentTier.color)
    }

    private func formatMultiplier(_ multiplier: Decimal) -> String {
        let value = NSDecimalNumber(decimal: multiplier).doubleValue
        return String(format: "%.1fx", value)
    }
}

// MARK: - Tier History View

/// Shows the user's tier progression history
struct TierHistoryView: View {
    let membership: VenueMembership
    let venueName: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("Tier History")
                .font(Typography.titleLarge)
                .foregroundColor(.textPrimary)

            VStack(spacing: Theme.Spacing.md) {
                tierHistoryItem(
                    tier: membership.tier,
                    date: membership.joinedAt,
                    status: "Current Tier",
                    isCurrent: true
                )

                // In production, you'd fetch actual tier change history
                // For now, showing join date
                tierHistoryItem(
                    tier: .bronze,
                    date: membership.joinedAt,
                    status: "Joined",
                    isCurrent: false
                )
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
        .shadow(
            color: Theme.Shadow.md.color,
            radius: Theme.Shadow.md.radius,
            x: Theme.Shadow.md.x,
            y: Theme.Shadow.md.y
        )
    }

    private func tierHistoryItem(
        tier: MembershipTier,
        date: Date,
        status: String,
        isCurrent: Bool
    ) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            // Timeline Dot
            ZStack {
                Circle()
                    .stroke(Color(hex: tier.color), lineWidth: 2)
                    .frame(width: 20, height: 20)

                if isCurrent {
                    Circle()
                        .fill(Color(hex: tier.color))
                        .frame(width: 12, height: 12)
                }
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Text(tier.displayName)
                        .font(Typography.headlineMedium)
                        .foregroundColor(.textPrimary)

                    if isCurrent {
                        Text("Current")
                            .font(Typography.captionMedium)
                            .foregroundColor(.white)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Color.primary)
                            .cornerRadius(Theme.CornerRadius.sm)
                    }
                }

                Text(formattedDate(date))
                    .font(Typography.captionMedium)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("Tier Progress - Silver") {
    ScrollView {
        VStack(spacing: Theme.Spacing.lg) {
            TierProgressView(
                progress: TierProgress(
                    currentTier: .silver,
                    nextTier: .gold,
                    currentSpending: 750,
                    nextTierThreshold: 2000,
                    progressPercentage: 30.0,
                    amountToNextTier: 1250,
                    daysAtCurrentTier: 45,
                    perks: TierPerk.defaultSilverPerks,
                    multiplier: 1.2
                ),
                venueName: "Das Wohnzimmer"
            )

            TierHistoryView(
                membership: VenueMembership.mockMembership(
                    userId: UUID(),
                    venueId: UUID()
                ),
                venueName: "Das Wohnzimmer"
            )
        }
        .padding()
        .background(Color.appBackground)
    }
}

#Preview("Tier Progress - Platinum (Max)") {
    TierProgressView(
        progress: TierProgress(
            currentTier: .platinum,
            nextTier: nil,
            currentSpending: 8500,
            nextTierThreshold: nil,
            progressPercentage: 100.0,
            amountToNextTier: nil,
            daysAtCurrentTier: 120,
            perks: TierPerk.defaultPlatinumPerks,
            multiplier: 2.0
        ),
        venueName: "Das Wohnzimmer"
    )
    .padding()
    .background(Color.appBackground)
}
