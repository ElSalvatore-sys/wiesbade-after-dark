//
//  MyPassesView.swift
//  WiesbadenAfterDark
//
//  View showing all user's wallet passes
//

import SwiftUI

/// My passes view
struct MyPassesView: View {
    // MARK: - Properties

    let userId: UUID

    // MARK: - View Model

    @State private var viewModel: CheckInViewModel

    // MARK: - UI State

    @State private var isRefreshing = false
    @State private var selectedPass: WalletPass?

    // MARK: - Computed Properties

    private var totalPasses: Int {
        viewModel.walletPasses.count
    }

    private var totalPoints: Int {
        viewModel.walletPasses.reduce(0) { $0 + $1.pointsBalance }
    }

    private var passesInWallet: Int {
        viewModel.walletPasses.filter { $0.isAddedToWallet }.count
    }

    private var averagePoints: Int {
        guard totalPasses > 0 else { return 0 }
        return totalPoints / totalPasses
    }

    // MARK: - Initialization

    init(userId: UUID) {
        self.userId = userId

        self._viewModel = State(initialValue: CheckInViewModel(
            checkInService: MockCheckInService.shared,
            walletPassService: MockWalletPassService.shared
        ))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats Section
                if !viewModel.walletPasses.isEmpty {
                    statsSection
                }

                // Passes List
                passesListSection
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("My Passes")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await refreshData()
        }
        .task {
            await loadData()
        }
        .navigationDestination(item: $selectedPass) { pass in
            WalletPassDetailView(pass: pass)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 16) {
            // Summary Card
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Points")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)

                        Text("\(totalPoints)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color.primaryGradient)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(totalPasses)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textPrimary)

                        Text(totalPasses == 1 ? "Pass" : "Passes")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                Divider()

                HStack(spacing: 24) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(passesInWallet)")
                                .font(.headline)
                                .foregroundStyle(Color.textPrimary)

                            Text("In Wallet")
                                .font(.caption2)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(Color.primary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(averagePoints)")
                                .font(.headline)
                                .foregroundStyle(Color.textPrimary)

                            Text("Avg. Points")
                                .font(.caption2)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }

                    Spacer()
                }
            }
            .padding(20)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Theme.Shadow.md.color, radius: Theme.Shadow.md.radius, x: Theme.Shadow.md.x, y: Theme.Shadow.md.y)
        }
    }

    // MARK: - Passes List

    private var passesListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !viewModel.walletPasses.isEmpty {
                HStack {
                    Text("Your Passes")
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    if isRefreshing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }

            if viewModel.walletPasses.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.walletPasses) { pass in
                    WalletPassCard(
                        pass: pass,
                        mode: .compact,
                        onTap: {
                            selectedPass = pass
                        }
                    )
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.primaryGradient.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "wallet.pass")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.primaryGradient)
            }

            // Message
            VStack(spacing: 8) {
                Text("No Wallet Passes")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Text("Generate a pass from your venue rewards tab to get started")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Info Cards
            VStack(spacing: 12) {
                infoCard(
                    icon: "qrcode",
                    title: "Quick Check-Ins",
                    description: "Scan QR code at venue"
                )

                infoCard(
                    icon: "wave.3.right",
                    title: "NFC Support",
                    description: "Tap to check in instantly"
                )

                infoCard(
                    icon: "star.fill",
                    title: "Earn Points",
                    description: "Get rewards automatically"
                )
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Helper Views

    private func infoCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Data Loading

    private func loadData() async {
        await viewModel.fetchWalletPasses(userId: userId)
    }

    private func refreshData() async {
        isRefreshing = true
        await loadData()
        isRefreshing = false
    }
}

// MARK: - Preview

#Preview("With Passes") {
    NavigationStack {
        MyPassesView(userId: UUID())
    }
}

#Preview("Empty State") {
    NavigationStack {
        MyPassesView(userId: UUID())
    }
}
