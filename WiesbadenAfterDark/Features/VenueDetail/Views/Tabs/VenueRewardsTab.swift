//
//  VenueRewardsTab.swift
//  WiesbadenAfterDark
//
//  Rewards tab showing redeemable rewards and points
//

import SwiftUI

/// Rewards tab with points and redeemable rewards
struct VenueRewardsTab: View {
    @Environment(VenueViewModel.self) private var viewModel
    @Environment(AuthenticationViewModel.self) private var authViewModel

    let venue: Venue

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]

    @State private var showCheckInView = false
    @State private var showWalletPassDetail = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Membership check
                if let membership = viewModel.membership {
                    // Points balance header
                    PointsBalanceCard(membership: membership, venue: venue)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.top, Theme.Spacing.md)

                    // Quick Actions (Check-In & Wallet Pass)
                    QuickActionsSection(
                        venue: venue,
                        membership: membership,
                        onCheckInTap: {
                            showCheckInView = true
                        },
                        onWalletPassTap: {
                            showWalletPassDetail = true
                        }
                    )
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Rewards section
                    Text("Available Rewards")
                        .font(Typography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, Theme.Spacing.lg)

                    if viewModel.rewards.isEmpty {
                        EmptyRewardsState()
                    } else {
                        LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                            ForEach(viewModel.rewards, id: \.id) { reward in
                                RewardCard(
                                    reward: reward,
                                    userPoints: membership.pointsBalance,
                                    onRedeem: {
                                        Task {
                                            await viewModel.redeemReward(reward)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                    }
                } else {
                    // Not a member state
                    NotMemberState(venue: venue)
                }
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Color.appBackground)
        .navigationDestination(isPresented: $showCheckInView) {
            if let userId = authViewModel.authState.user?.id,
               let membership = viewModel.membership {
                CheckInView(
                    venue: venue,
                    membership: membership,
                    event: nil,
                    userId: userId
                )
            }
        }
        .sheet(isPresented: $showWalletPassDetail) {
            NavigationStack {
                if let userId = authViewModel.authState.user?.id {
                    // TODO: Show existing pass if already generated
                    Text("Wallet Pass - Coming Soon")
                        .navigationTitle("Wallet Pass")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") {
                                    showWalletPassDetail = false
                                }
                            }
                        }
                }
            }
        }
    }
}

// MARK: - Quick Actions Section

private struct QuickActionsSection: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel

    let venue: Venue
    let membership: VenueMembership
    let onCheckInTap: () -> Void
    let onWalletPassTap: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Check-In Button
            Button(action: onCheckInTap) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Check In")
                            .font(Typography.bodyMedium)
                            .fontWeight(.semibold)

                        Text("Earn points")
                            .font(Typography.captionSmall)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundStyle(.white)
                .padding(Theme.Spacing.md)
                .background(Color.primaryGradient)
                .cornerRadius(Theme.CornerRadius.md)
            }

            // Wallet Pass Button
            Button(action: onWalletPassTap) {
                VStack(spacing: 8) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)

                    Text("Pass")
                        .font(Typography.captionSmall)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.md)
                .background(Color.cardBackground)
                .cornerRadius(Theme.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
            }
            .frame(width: 90)
        }
    }
}

// MARK: - Points Balance Card
private struct PointsBalanceCard: View {
    let membership: VenueMembership
    let venue: Venue

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Points display
            VStack(spacing: Theme.Spacing.sm) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gold)

                    Text("\(membership.pointsBalance)")
                        .font(Typography.displayMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }

                Text("Available Points")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
            }

            Divider()
                .background(Color.textTertiary.opacity(0.2))

            // Tier info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Tier")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)

                    Text(membership.tier.displayName)
                        .font(Typography.headlineMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                // Tier badge
                Text(membership.tier.displayName)
                    .font(Typography.labelMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, 6)
                    .background(Color(hex: membership.tier.color))
                    .cornerRadius(Theme.CornerRadius.pill)
            }

            // Stats row
            HStack(spacing: Theme.Spacing.lg) {
                StatItem(
                    label: "Total Earned",
                    value: "\(membership.totalPointsEarned)"
                )

                Divider()
                    .frame(height: 30)
                    .background(Color.textTertiary.opacity(0.2))

                StatItem(
                    label: "Redeemed",
                    value: "\(membership.totalPointsRedeemed)"
                )

                Divider()
                    .frame(height: 30)
                    .background(Color.textTertiary.opacity(0.2))

                StatItem(
                    label: "Visit Count",
                    value: "\(membership.totalVisits)"
                )
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.primaryGradientStart.opacity(0.1),
                    Color.cardBackground
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Theme.CornerRadius.lg)
        .shadow(
            color: Theme.Shadow.md.color,
            radius: Theme.Shadow.md.radius,
            x: Theme.Shadow.md.x,
            y: Theme.Shadow.md.y
        )
    }
}

private struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Typography.headlineMedium)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Text(label)
                .font(Typography.captionSmall)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Not Member State
private struct NotMemberState: View {
    @Environment(VenueViewModel.self) private var viewModel
    @Environment(AuthenticationViewModel.self) private var authViewModel

    let venue: Venue

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
                .frame(height: 60)

            // Icon
            ZStack {
                Circle()
                    .fill(Color.primaryGradient.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "gift.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.primary)
            }

            // Title & description
            VStack(spacing: Theme.Spacing.md) {
                Text("Join to Earn Rewards")
                    .font(Typography.titleLarge)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)

                Text("Become a member of \(venue.name) to start earning points and unlock exclusive rewards!")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, Theme.Spacing.xl)

            // Benefits list
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                BenefitRow(
                    icon: "star.fill",
                    text: "Earn points with every visit"
                )

                BenefitRow(
                    icon: "gift.fill",
                    text: "Redeem exclusive rewards"
                )

                BenefitRow(
                    icon: "crown.fill",
                    text: "Unlock VIP perks and discounts"
                )
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.md)

            // Join button
            Button(action: {
                Task {
                    if let userId = authViewModel.authState.user?.id {
                        await viewModel.joinVenue(userId: userId)
                    }
                }
            }) {
                Text("Join \(venue.name)")
                    .font(Typography.button)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.primaryGradient)
                    .cornerRadius(Theme.CornerRadius.lg)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.lg)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

private struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.gold)
                .frame(width: 24)

            Text(text)
                .font(Typography.bodyMedium)
                .foregroundColor(.textPrimary)

            Spacer()
        }
    }
}

// MARK: - Empty Rewards State
private struct EmptyRewardsState: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "gift")
                .font(.system(size: 50))
                .foregroundColor(.textTertiary)

            Text("No Rewards Available")
                .font(Typography.titleMedium)
                .foregroundColor(.textPrimary)

            Text("Check back soon for exciting rewards!")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.horizontal, Theme.Spacing.xl)
    }
}

// MARK: - Preview
#Preview("Venue Rewards Tab - Member") {
    VenueRewardsTab(venue: Venue.mockDasWohnzimmer())
        .environment(VenueViewModel())
        .environment(AuthenticationViewModel())
}

#Preview("Venue Rewards Tab - Non-Member") {
    let viewModel = VenueViewModel()
    return VenueRewardsTab(venue: Venue.mockDasWohnzimmer())
        .environment(viewModel)
        .environment(AuthenticationViewModel())
}
