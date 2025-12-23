//
//  WalletView.swift
//  WiesbadenAfterDark
//
//  Main wallet view showing points, passes, bookings, and transactions
//

import SwiftUI

/// Main wallet tab view
struct WalletView: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel
    @State private var selectedSection: WalletSection = .passes
    @State private var walletPasses: [WalletPass] = []
    @State private var recentTransactions: [PointTransaction] = []
    @State private var isLoading = false

    private var user: User? {
        authViewModel.authState.user
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Points Overview Card
                    pointsOverviewCard
                        .padding(.horizontal, Theme.Spacing.md)

                    // Section Picker
                    sectionPicker
                        .padding(.horizontal, Theme.Spacing.md)

                    // Content based on selected section
                    switch selectedSection {
                    case .passes:
                        passesSection
                    case .bookings:
                        bookingsSection
                    case .transactions:
                        transactionsSection
                    }
                }
                .padding(.vertical, Theme.Spacing.md)
            }
            .background(Color.appBackground)
            .navigationTitle("Wallet")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable {
                HapticManager.shared.light()
                await loadData()
            }
            .task {
                await loadData()
            }
        }
    }

    // MARK: - Points Overview Card

    private var pointsOverviewCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Points balance
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Total Points")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)

                    Text("\(user?.totalPointsAvailable ?? 0)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primaryGradient)
                }

                Spacer()

                // Tier badge
                if let user = user {
                    tierBadge(for: user.currentTier)
                }
            }

            Divider()

            // Quick stats
            HStack(spacing: Theme.Spacing.xl) {
                quickStat(
                    icon: "arrow.up.circle.fill",
                    value: "\(Int(user?.totalPointsEarned ?? 0))",
                    label: "Earned",
                    color: .success
                )

                quickStat(
                    icon: "arrow.down.circle.fill",
                    value: "\(Int(user?.totalPointsSpent ?? 0))",
                    label: "Spent",
                    color: .error
                )

                quickStat(
                    icon: "wallet.pass.fill",
                    value: "\(walletPasses.count)",
                    label: "Passes",
                    color: .primary
                )
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }

    private func tierBadge(for tier: MembershipTier) -> some View {
        let tierColor = Color(hex: tier.color)
        return VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: tier.icon)
                .font(.title2)
                .foregroundColor(tierColor)

            Text(tier.displayName)
                .font(Typography.captionMedium)
                .fontWeight(.semibold)
                .foregroundColor(tierColor)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(tierColor.opacity(0.15))
        .cornerRadius(Theme.CornerRadius.md)
    }

    private func quickStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(Typography.bodyMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            Text(label)
                .font(Typography.captionSmall)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(WalletSection.allCases, id: \.self) { section in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSection = section
                    }
                    HapticManager.shared.light()
                } label: {
                    Text(section.title)
                        .font(Typography.captionMedium)
                        .fontWeight(selectedSection == section ? .semibold : .medium)
                        .foregroundColor(selectedSection == section ? .white : .textSecondary)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(
                            Group {
                                if selectedSection == section {
                                    Color.primaryGradient
                                } else {
                                    Color.cardBackground
                                }
                            }
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selectedSection == section ? Color.clear : Color.cardBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    // MARK: - Passes Section

    private var passesSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            if walletPasses.isEmpty {
                EmptyStateView(.noPasses)
                    .padding(.top, Theme.Spacing.xl)
            } else {
                ForEach(walletPasses) { pass in
                    NavigationLink(destination: WalletPassDetailView(pass: pass)) {
                        WalletPassCard(pass: pass, mode: .compact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    // MARK: - Bookings Section

    private var bookingsSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            EmptyStateView(.noBookings)
                .padding(.top, Theme.Spacing.xl)
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    // MARK: - Transactions Section

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            if recentTransactions.isEmpty {
                EmptyStateView(.noTransactions)
                    .padding(.top, Theme.Spacing.xl)
            } else {
                ForEach(recentTransactions) { transaction in
                    transactionRow(transaction)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    private func transactionRow(_ transaction: PointTransaction) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            // Icon
            Image(systemName: transaction.source.icon)
                .font(.system(size: 20))
                .foregroundStyle(transactionColor(for: transaction))
                .frame(width: 40, height: 40)
                .background(transactionColor(for: transaction).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))

            // Description and date
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(transaction.shortDescription)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text(transaction.timeAgo)
                    .font(Typography.captionSmall)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            // Amount
            Text(transaction.formattedAmount)
                .font(Typography.bodyMedium)
                .fontWeight(.semibold)
                .foregroundStyle(transaction.amount > 0 ? Color.success : Color.error)
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
    }

    private func transactionColor(for transaction: PointTransaction) -> Color {
        switch transaction.type {
        case .earn: return .blue
        case .redeem: return .error
        case .bonus: return .success
        case .refund: return .warning
        }
    }

    // MARK: - Data Loading

    private func loadData() async {
        guard let user = user else { return }
        isLoading = true

        // Load wallet passes
        do {
            walletPasses = try await RealWalletPassService.shared.fetchUserPasses(userId: user.id)
        } catch {
            print("❌ [WalletView] Failed to load passes: \(error)")
        }

        // Load transactions (mock for now)
        recentTransactions = PointTransaction.mockHistory(
            userId: user.id,
            venueId: UUID(),
            venueName: "Das Wohnzimmer",
            count: 10
        )

        isLoading = false
    }
}

// MARK: - Wallet Section Enum

enum WalletSection: String, CaseIterable {
    case passes = "Passes"
    case bookings = "Bookings"
    case transactions = "History"

    var title: String { rawValue }
}

// MARK: - Preview

#Preview("Wallet View") {
    WalletView()
        .environment(AuthenticationViewModel())
}
