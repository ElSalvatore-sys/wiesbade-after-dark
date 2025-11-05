//
//  CheckInView.swift
//  WiesbadenAfterDark
//
//  Main check-in screen for venue check-ins
//

import SwiftUI

/// Main check-in view
struct CheckInView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties

    let venue: Venue
    let membership: VenueMembership
    let event: Event?
    let userId: UUID

    // MARK: - View Model

    @State private var viewModel: CheckInViewModel

    // MARK: - UI State

    @State private var showNFCSheet = false
    @State private var showSuccessView = false

    // MARK: - Initialization

    init(venue: Venue, membership: VenueMembership, event: Event? = nil, userId: UUID) {
        self.venue = venue
        self.membership = membership
        self.event = event
        self.userId = userId

        // Initialize view model
        self._viewModel = State(initialValue: CheckInViewModel(
            checkInService: MockCheckInService.shared,
            walletPassService: MockWalletPassService.shared,
            modelContext: nil
        ))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Venue Header
                venueHeader

                // Points Estimation Card
                pointsEstimationCard

                // Check-In Methods
                checkInMethodsSection

                // Recent Check-Ins
                recentCheckInsSection
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Check In")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNFCSheet) {
            NFCReaderSheet(
                venue: venue,
                membership: membership,
                event: event,
                userId: userId,
                viewModel: viewModel
            )
        }
        .fullScreenCover(isPresented: $showSuccessView) {
            if let successCheckIn = viewModel.successCheckIn {
                CheckInSuccessView(checkIn: successCheckIn) {
                    showSuccessView = false
                    dismiss()
                }
            }
        }
        .task {
            // Load data when view appears
            await viewModel.calculateEstimatedPoints(
                for: venue,
                userId: userId,
                event: event
            )
            await viewModel.fetchCheckInHistory(
                userId: userId,
                venueId: venue.id
            )
        }
        .onChange(of: viewModel.checkInState) { _, newState in
            if case .success = newState {
                showSuccessView = true
            }
        }
    }

    // MARK: - Venue Header

    private var venueHeader: some View {
        VStack(spacing: 16) {
            // Venue Image
            ZStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 100, height: 100)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
            }

            // Venue Info
            VStack(spacing: 8) {
                Text(venue.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                if let event = event {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.caption)

                        Text(event.title)
                            .font(.subheadline)

                        if event.pointsMultiplier > 1.0 {
                            Text("×\(String(format: "%.1f", NSDecimalNumber(decimal: event.pointsMultiplier).doubleValue))")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    .foregroundStyle(Color.textSecondary)
                }

                // Current Balance
                HStack(spacing: 4) {
                    Text("Current Balance:")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)

                    Text("\(membership.pointsBalance) pts")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                }
            }
        }
    }

    // MARK: - Points Estimation Card

    private var pointsEstimationCard: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("You'll Earn")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if viewModel.currentStreak > 1 {
                    StreakBadge(
                        streakDay: viewModel.currentStreak,
                        multiplier: calculateStreakMultiplier(viewModel.currentStreak),
                        size: .medium
                    )
                }
            }

            // Points Display
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.estimatedPoints)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.primaryGradient)

                    Text("Estimated Points")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                // Breakdown
                VStack(alignment: .trailing, spacing: 6) {
                    breakdownItem(label: "Base", value: "50")

                    if let event = event, event.pointsMultiplier > 1.0 {
                        breakdownItem(
                            label: "Event",
                            value: "×\(String(format: "%.1f", NSDecimalNumber(decimal: event.pointsMultiplier).doubleValue))"
                        )
                    }

                    if Calendar.current.isDateInWeekend(Date()) {
                        breakdownItem(label: "Weekend", value: "×1.2")
                    }

                    if viewModel.currentStreak > 1 {
                        breakdownItem(
                            label: "Streak",
                            value: "×\(String(format: "%.1f", NSDecimalNumber(decimal: calculateStreakMultiplier(viewModel.currentStreak)).doubleValue))"
                        )
                    }
                }
                .font(.caption)
            }

            // New Balance Preview
            Divider()

            HStack {
                Text("New Balance")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                Text("\(membership.pointsBalance + viewModel.estimatedPoints) pts")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.Shadow.md.color, radius: Theme.Shadow.md.radius, x: Theme.Shadow.md.x, y: Theme.Shadow.md.y)
    }

    // MARK: - Check-In Methods

    private var checkInMethodsSection: some View {
        VStack(spacing: 16) {
            // NFC Check-In Button (Primary)
            Button(action: {
                showNFCSheet = true
            }) {
                HStack {
                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("NFC Check-In")
                            .font(.headline)

                        Text("Tap to scan NFC tag")
                            .font(.caption)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .foregroundStyle(.white)
                .padding(20)
                .background(Color.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }

            // Manual Check-In Button (Secondary)
            Button(action: {
                Task {
                    await viewModel.performManualCheckIn(
                        userId: userId,
                        venue: venue,
                        membership: membership,
                        event: event
                    )
                }
            }) {
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Manual Check-In")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("No NFC tag available?")
                            .font(.caption2)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundStyle(Color.textPrimary)
                .padding(16)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(viewModel.isLoading)
        }
    }

    // MARK: - Recent Check-Ins

    private var recentCheckInsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Check-Ins")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if !viewModel.checkIns.isEmpty {
                    Button(action: {
                        // Navigate to full history
                    }) {
                        Text("See All")
                            .font(.subheadline)
                            .foregroundStyle(Color.primary)
                    }
                }
            }

            if viewModel.checkIns.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.checkIns.prefix(3)) { checkIn in
                    CheckInCard(checkIn: checkIn, mode: .compact)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 40))
                .foregroundStyle(Color.textSecondary.opacity(0.5))

            Text("No check-ins yet")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            Text("Check in to start earning points!")
                .font(.caption)
                .foregroundStyle(Color.textSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helper Views

    private func breakdownItem(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(Color.textSecondary)
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
        }
    }

    // MARK: - Helper Methods

    private func calculateStreakMultiplier(_ streakDay: Int) -> Decimal {
        switch streakDay {
        case 1: return 1.0
        case 2: return 1.2
        case 3: return 1.5
        case 4: return 2.0
        default: return 2.5
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CheckInView(
            venue: Venue.mock(),
            membership: VenueMembership(
                userId: UUID(),
                venueId: Venue.mock().id,
                pointsBalance: 450,
                tier: .gold
            ),
            event: nil,
            userId: UUID()
        )
    }
}

#Preview("With Event") {
    NavigationStack {
        CheckInView(
            venue: Venue.mock(),
            membership: VenueMembership(
                userId: UUID(),
                venueId: Venue.mock().id,
                pointsBalance: 1200,
                tier: .platinum
            ),
            event: Event(
                title: "Friday Night Live",
                description: "Special event with bonus points",
                venueId: Venue.mock().id,
                startTime: Date(),
                endTime: Date().addingTimeInterval(14400),
                coverCharge: 15.00,
                genre: "Live Music",
                pointsMultiplier: 1.5
            ),
            userId: UUID()
        )
    }
}
