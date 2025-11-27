//
//  HomeView.swift
//  WiesbadenAfterDark
//
//  Home screen with gamification and event highlights
//

import SwiftUI
import SwiftData
import CoreLocation

/// Home screen - main app view with inventory gamification and event highlights
struct HomeView: View {
    // MARK: - Properties

    @Environment(AuthenticationViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var homeViewModel = HomeViewModel()

    // MARK: - UI State

    @State private var showMyPasses = false
    @State private var showCheckInHistory = false
    @State private var selectedEvent: Event?
    @State private var selectedProduct: Product?
    @State private var expiringMemberships: [VenueMembership] = []
    @State private var showExpiringPointsSheet = false
    @State private var selectedMembership: VenueMembership?

    // Check-in flow
    @State private var showVenuePicker = false
    @State private var selectedVenueForCheckIn: Venue?
    @State private var selectedMembershipForCheckIn: VenueMembership?
    @State private var showCheckInView = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Points Balance Card
                        if homeViewModel.totalPoints > 0 {
                            pointsBalanceCard
                                .padding(.horizontal)
                        }

                        // Quick Actions (Check-in, Wallet)
                        quickActionsSection
                            .padding(.horizontal)

                        // Recent Transactions
                        if !homeViewModel.recentTransactions.isEmpty {
                            RecentTransactionsView(transactions: homeViewModel.recentTransactions)
                                .padding(.horizontal)
                        }

                        // Event Highlights Section
                        eventHighlightsSection

                        Spacer()
                            .frame(height: Theme.Spacing.xl)
                    }
                    .padding(.top)
                }
                .background(Color.appBackground.ignoresSafeArea())
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.large)
                .refreshable {
                    if let user = authViewModel.authState.user {
                        await homeViewModel.refresh(userId: user.id)
                    }
                }
                .task {
                    // Load home data on appear
                    if let user = authViewModel.authState.user {
                        await homeViewModel.loadHomeData(userId: user.id)
                    }
                }

                // Loading overlay - show only on initial load
                if homeViewModel.isLoading && homeViewModel.venues.isEmpty {
                    VStack(spacing: Theme.Spacing.md) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                            .scaleEffect(1.5)

                        Text("Loading your points...")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.appBackground)
                }
            }
            .alert("Error", isPresented: .constant(homeViewModel.errorMessage != nil)) {
                Button("OK") {
                    homeViewModel.clearError()
                }
                Button("Retry") {
                    if let user = authViewModel.authState.user {
                        Task {
                            await homeViewModel.loadHomeData(userId: user.id)
                        }
                    }
                }
            } message: {
                Text(homeViewModel.errorMessage ?? "An error occurred")
            }
            .sheet(isPresented: $showMyPasses) {
                if let user = authViewModel.authState.user {
                    NavigationStack {
                        MyPassesView(userId: user.id)
                    }
                }
            }
            .sheet(isPresented: $showCheckInHistory) {
                if let user = authViewModel.authState.user {
                    NavigationStack {
                        CheckInHistoryView(userId: user.id)
                    }
                }
            }
            .sheet(isPresented: $showVenuePicker) {
                if let user = authViewModel.authState.user {
                    VenuePickerView(
                        venues: homeViewModel.venues,
                        userMemberships: homeViewModel.memberships,
                        userId: user.id
                    ) { venue, membership in
                        selectedVenueForCheckIn = venue
                        selectedMembershipForCheckIn = membership
                        showCheckInView = true
                    }
                }
            }
            .sheet(isPresented: $showCheckInView) {
                if let user = authViewModel.authState.user,
                   let venue = selectedVenueForCheckIn,
                   let membership = selectedMembershipForCheckIn {
                    NavigationStack {
                        CheckInView(
                            venue: venue,
                            membership: membership,
                            event: nil,
                            userId: user.id
                        )
                    }
                }
            }
        }
    }

    // MARK: - Points Balance Card

    private var pointsBalanceCard: some View {
        VStack(spacing: Theme.Spacing.cardGap) {
            // "Your Points" label
            Text("Your Points")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            // HUGE Points Balance
            HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.sm) {
                Text("\(homeViewModel.totalPoints)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Image(systemName: "star.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.orange)
            }

            // Euro value conversion (10:1 ratio - 10 points = €1)
            Text("= €\(homeViewModel.totalPoints / 10) value")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textSecondary)

            // Venue breakdown (if multiple memberships)
            if homeViewModel.memberships.count > 1 {
                Divider()
                    .padding(.vertical, Theme.Spacing.xs)

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Points by Venue")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)

                    ForEach(homeViewModel.memberships.prefix(3), id: \.id) { membership in
                        if let venue = homeViewModel.venues.first(where: { $0.id == membership.venueId }) {
                            HStack {
                                Text(venue.name)
                                    .font(.caption)
                                    .foregroundStyle(Color.textPrimary)

                                Spacer()

                                Text("\(membership.pointsBalance) pts")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.12),
                    Color.orange.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.gold.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(
            color: Color.orange.opacity(0.15),
            radius: 20,
            x: 0,
            y: 10
        )
    }

    // MARK: - Event Highlights Section

    private var eventHighlightsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(eventSectionTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    Text(eventSectionSubtitle)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Button {
                    // Navigate to events tab
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundStyle(Color.primary)
                }
            }
            .padding(.horizontal)

            // Event Cards
            if !homeViewModel.todayEvents.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.md) {
                        ForEach(homeViewModel.todayEvents.prefix(3), id: \.id) { event in
                            EventHighlightCard(
                                event: event,
                                venue: homeViewModel.venue(for: event),
                                isToday: true
                            )
                            .frame(width: 320)
                            .onTapGesture {
                                selectedEvent = event
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else if !homeViewModel.upcomingEvents.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.md) {
                        ForEach(homeViewModel.upcomingEvents.prefix(3), id: \.id) { event in
                            EventHighlightCard(
                                event: event,
                                venue: homeViewModel.venue(for: event),
                                isToday: false
                            )
                            .frame(width: 320)
                            .onTapGesture {
                                selectedEvent = event
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                // Empty state
                VStack(spacing: Theme.Spacing.cardGap) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.textTertiary)

                    Text("No events scheduled")
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)

                    Text("Check back later for upcoming events!")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.xl)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.Spacing.cardGap) {
                // Check-In (Show venue picker)
                quickActionButton(
                    icon: "wave.3.right.circle.fill",
                    title: "Check In",
                    color: .purple
                ) {
                    HapticManager.shared.medium()
                    showVenuePicker = true
                }

                // My Passes
                quickActionButton(
                    icon: "wallet.pass.fill",
                    title: "My Passes",
                    color: .blue
                ) {
                    HapticManager.shared.light()
                    showMyPasses = true
                }

                // History
                quickActionButton(
                    icon: "clock.fill",
                    title: "History",
                    color: .green
                ) {
                    HapticManager.shared.light()
                    showCheckInHistory = true
                }

                // Share Referral
                quickActionButton(
                    icon: "gift.fill",
                    title: "Refer Friend",
                    color: .orange
                ) {
                    HapticManager.shared.light()
                    // Share referral code
                    if let user = authViewModel.authState.user {
                        shareReferralCode(user.referralCode)
                    }
                }
            }

            // Sign Out Button
            Button(action: {
                authViewModel.signOut()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
            }
            .padding(.top, Theme.Spacing.sm)
        }
    }

    // MARK: - Helper Views

    private func quickActionButton(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.cardGap) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.cardPadding)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Computed Properties

    private var eventSectionTitle: String {
        if !homeViewModel.todayEvents.isEmpty {
            return "Tonight's Events"
        } else if !homeViewModel.upcomingEvents.isEmpty {
            return "Upcoming Events"
        } else {
            return "Events"
        }
    }

    private var eventSectionSubtitle: String {
        if !homeViewModel.todayEvents.isEmpty {
            return "Happening today"
        } else if !homeViewModel.upcomingEvents.isEmpty {
            return "This week"
        } else {
            return "No events scheduled"
        }
    }

    // MARK: - Helper Methods

    private func shareReferralCode(_ code: String) {
        let text = "Join Wiesbaden After Dark with my referral code: \(code)"
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Nearby Venue Card Component

struct NearbyVenueCard: View {
    let venue: Venue
    let distance: String?
    let pointsBalance: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Venue Image
            AsyncImage(url: URL(string: venue.coverImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.inputBackground)
            }
            .frame(height: 140)
            .clipped()

            // Venue Info
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text(venue.name)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                HStack {
                    Text(venue.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)

                    if let distance = distance {
                        Text("•")
                            .foregroundStyle(Color.textTertiary)

                        Text(distance)
                            .font(.caption)
                            .foregroundStyle(Color.info)
                    }
                }

                if pointsBalance > 0 {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.caption2)

                        Text("\(pointsBalance) points")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.gold)
                }
            }
            .padding(Theme.Spacing.cardGap)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .shadow(
            color: Theme.Shadow.md.color,
            radius: Theme.Shadow.md.radius,
            x: Theme.Shadow.md.x,
            y: Theme.Shadow.md.y
        )
    }
}

// MARK: - Recent Transactions View Component

struct RecentTransactionsView: View {
    let transactions: [PointTransaction]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            if transactions.isEmpty {
                // Empty state
                VStack(spacing: Theme.Spacing.cardGap) {
                    Image(systemName: "clock")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.textTertiary)

                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.lg)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                        HStack(spacing: Theme.Spacing.cardGap) {
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
                                    .font(.subheadline)
                                    .foregroundStyle(Color.textPrimary)
                                    .lineLimit(1)

                                Text(transaction.timeAgo)
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }

                            Spacer()

                            // Amount
                            Text(transaction.formattedAmount)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(transaction.amount > 0 ? Color.success : Color.error)
                        }
                        .padding(.vertical, Theme.Spacing.cardGap)

                        // Divider (except for last item)
                        if index < min(4, transactions.count - 1) {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(Theme.Spacing.cardPadding)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .shadow(
            color: Theme.Shadow.md.color,
            radius: Theme.Shadow.md.radius,
            x: Theme.Shadow.md.x,
            y: Theme.Shadow.md.y
        )
    }

    private func transactionColor(for transaction: PointTransaction) -> Color {
        switch transaction.type {
        case .earn: return .blue
        case .redeem: return .red
        case .bonus: return .green
        case .refund: return .orange
        }
    }
}

// MARK: - Preview

#Preview("Home View") {
    HomeView()
        .environment(AuthenticationViewModel())
}
