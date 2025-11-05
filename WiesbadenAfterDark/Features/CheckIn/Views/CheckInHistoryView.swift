//
//  CheckInHistoryView.swift
//  WiesbadenAfterDark
//
//  Complete check-in history view with stats
//

import SwiftUI

/// Check-in history view
struct CheckInHistoryView: View {
    // MARK: - Properties

    let userId: UUID
    var venueId: UUID? = nil // Optional: filter by specific venue

    // MARK: - View Model

    @State private var viewModel: CheckInViewModel

    // MARK: - UI State

    @State private var isRefreshing = false
    @State private var selectedCheckIn: CheckIn?

    // MARK: - Computed Properties

    private var totalCheckIns: Int {
        viewModel.checkIns.count
    }

    private var totalPointsEarned: Int {
        viewModel.checkIns.reduce(0) { $0 + $1.pointsEarned }
    }

    private var averagePointsPerCheckIn: Int {
        guard totalCheckIns > 0 else { return 0 }
        return totalPointsEarned / totalCheckIns
    }

    private var streakCheckIns: Int {
        viewModel.checkIns.filter { $0.isStreakBonus }.count
    }

    // MARK: - Initialization

    init(userId: UUID, venueId: UUID? = nil) {
        self.userId = userId
        self.venueId = venueId

        self._viewModel = State(initialValue: CheckInViewModel(
            checkInService: MockCheckInService.shared,
            walletPassService: MockWalletPassService.shared
        ))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats Summary
                statsSection

                // Check-Ins List
                checkInsListSection
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle(venueId == nil ? "Check-In History" : "Venue Check-Ins")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await refreshData()
        }
        .task {
            await loadData()
        }
        .sheet(item: $selectedCheckIn) { checkIn in
            NavigationStack {
                checkInDetailView(for: checkIn)
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Statistics")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()
            }

            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                statCard(
                    icon: "checkmark.circle.fill",
                    value: "\(totalCheckIns)",
                    label: "Total Check-Ins",
                    color: Color.primary
                )

                statCard(
                    icon: "star.fill",
                    value: "\(totalPointsEarned)",
                    label: "Points Earned",
                    color: .orange
                )

                statCard(
                    icon: "chart.bar.fill",
                    value: "\(averagePointsPerCheckIn)",
                    label: "Avg. Per Check-In",
                    color: Color.secondary
                )

                statCard(
                    icon: "flame.fill",
                    value: "\(streakCheckIns)",
                    label: "Streak Bonuses",
                    color: .red
                )
            }
        }
    }

    // MARK: - Check-Ins List

    private var checkInsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("History")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if isRefreshing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            // List
            if viewModel.checkIns.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.checkIns) { checkIn in
                    Button(action: {
                        selectedCheckIn = checkIn
                    }) {
                        CheckInCard(checkIn: checkIn, mode: .compact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 50))
                .foregroundStyle(Color.textSecondary.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Check-Ins Yet")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Text("Start checking in to venues to see your history here")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(60)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Stat Card

    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Theme.Shadow.sm.color, radius: Theme.Shadow.sm.radius, x: Theme.Shadow.sm.x, y: Theme.Shadow.sm.y)
    }

    // MARK: - Check-In Detail View

    private func checkInDetailView(for checkIn: CheckIn) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                CheckInCard(checkIn: checkIn, mode: .full)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Check-In Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    selectedCheckIn = nil
                }
            }
        }
    }

    // MARK: - Data Loading

    private func loadData() async {
        await viewModel.fetchCheckInHistory(
            userId: userId,
            venueId: venueId
        )
    }

    private func refreshData() async {
        isRefreshing = true
        await loadData()
        isRefreshing = false
    }
}

// MARK: - Preview

#Preview("All Check-Ins") {
    NavigationStack {
        CheckInHistoryView(userId: UUID())
    }
}

#Preview("Venue Check-Ins") {
    NavigationStack {
        CheckInHistoryView(
            userId: UUID(),
            venueId: Venue.mock().id
        )
    }
}

#Preview("Empty State") {
    NavigationStack {
        CheckInHistoryView(userId: UUID())
    }
}
