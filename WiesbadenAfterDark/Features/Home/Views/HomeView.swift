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
            ScrollView {
                VStack(spacing: 24) {
                    // 1. POINTS BALANCE CARD (Top Priority)
                    if homeViewModel.totalPoints > 0 {
                        pointsBalanceCard
                            .padding(.horizontal)
                    }

                    // 2. QUICK ACTIONS (Check-in & Wallet Pass)
                    quickActionsCard
                        .padding(.horizontal)

                    // 3. EVENT HIGHLIGHTS SECTION
                    eventHighlightsSection

                    // 4. ACTIVE BONUSES BANNER (if any)
                    if homeViewModel.hasActiveBonuses {
                        activeBonusesBanner
                            .padding(.horizontal)
                    }

                    // 5. INVENTORY OFFERS SECTION
                    inventoryOffersSection

                    // 6. NEARBY VENUES SECTION
                    nearbyVenuesSection

                    // 7. REFERRAL CARD (Moved down)
                    if let user = authViewModel.authState.user {
                        VStack(spacing: 12) {
                            ReferralCard(
                                referralCode: user.referralCode,
                                totalEarnings: Int(user.totalPointsEarned * 0.25) // Estimate 25% from referrals
                            )

                            ReferralExplanationView()
                        }
                        .padding(.horizontal)
                    }

                    // 8. RECENT ACTIVITY (Moved to bottom)
                    if !homeViewModel.recentTransactions.isEmpty {
                        RecentTransactionsView(transactions: homeViewModel.recentTransactions)
                            .padding(.horizontal)
                    }

                    // 9. SIGN OUT BUTTON
                    signOutButton
                        .padding(.horizontal)

                    Spacer()
                        .frame(height: 40)
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

    // MARK: - Active Bonuses Banner

    private var activeBonusesBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(Color.gold)

            VStack(alignment: .leading, spacing: 2) {
                Text("Active Bonuses")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                if let summary = homeViewModel.activeBonusesSummary() {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.textTertiary)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color.gold.opacity(0.15),
                    Color.warning.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .strokeBorder(Color.gold.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Points Balance Card

    private var pointsBalanceCard: some View {
        VStack(spacing: 12) {
            // "Your Points" label
            Text("Your Points")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            // HUGE Points Balance
            HStack(alignment: .firstTextBaseline, spacing: 8) {
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

            // Euro value conversion
            Text("= €\(homeViewModel.totalPoints) value")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textSecondary)

            // Venue breakdown (if multiple memberships)
            if homeViewModel.memberships.count > 1 {
                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
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
        .padding(24)
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
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
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
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
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
                    HStack(spacing: 16) {
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
                    HStack(spacing: 16) {
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
                VStack(spacing: 12) {
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
                .padding(.vertical, 40)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Inventory Offers Section

    private var inventoryOffersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Special Offers")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    Text("Limited time bonus points")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                if !homeViewModel.inventoryOffers.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)

                        Text("\(homeViewModel.inventoryOffers.count) deals")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.gold)
                }
            }
            .padding(.horizontal)

            // Offer Cards
            if !homeViewModel.inventoryOffers.isEmpty {
                VStack(spacing: 12) {
                    ForEach(homeViewModel.inventoryOffers.prefix(5), id: \.id) { product in
                        InventoryOfferCard(
                            product: product,
                            venue: homeViewModel.venue(for: product),
                            multiplier: product.bonusMultiplier,
                            expiresAt: product.bonusEndDate
                        )
                        .onTapGesture {
                            selectedProduct = product
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "tag")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.textTertiary)

                    Text("No special offers right now")
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)

                    Text("Check back later for bonus point deals!")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Nearby Venues Section

    private var nearbyVenuesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Nearby Venues")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if !homeViewModel.nearbyVenues.isEmpty {
                    Button {
                        // Navigate to discover tab
                    } label: {
                        Text("See All")
                            .font(.subheadline)
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .padding(.horizontal)

            // Venue Cards
            if !homeViewModel.nearbyVenues.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(homeViewModel.nearbyVenues, id: \.id) { venue in
                            NearbyVenueCard(
                                venue: venue,
                                distance: homeViewModel.distance(to: venue),
                                pointsBalance: homeViewModel.pointsBalance(for: venue.id)
                            )
                            .frame(width: 280)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                // Show all venues if no location
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(homeViewModel.venues.prefix(5), id: \.id) { venue in
                            NearbyVenueCard(
                                venue: venue,
                                distance: nil,
                                pointsBalance: homeViewModel.pointsBalance(for: venue.id)
                            )
                            .frame(width: 280)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Quick Actions Card (Simplified)

    private var quickActionsCard: some View {
        HStack(spacing: 16) {
            // Check-In Button
            Button {
                showVenuePicker = true
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Check In")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.15), Color.blue.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)

            // Wallet Pass Button
            Button {
                showMyPasses = true
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("My Passes")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.15), Color.purple.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.purple.opacity(0.3), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
        }
        .shadow(
            color: Theme.Shadow.sm.color,
            radius: Theme.Shadow.sm.radius,
            x: Theme.Shadow.sm.x,
            y: Theme.Shadow.sm.y
        )
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
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
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
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
            VStack(alignment: .leading, spacing: 8) {
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
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)

                        Text("\(pointsBalance) points")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.gold)
                }
            }
            .padding(12)
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            if transactions.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.textTertiary)

                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: transaction.source.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(transactionColor(for: transaction))
                                .frame(width: 40, height: 40)
                                .background(transactionColor(for: transaction).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            // Description and date
                            VStack(alignment: .leading, spacing: 4) {
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
                        .padding(.vertical, 12)

                        // Divider (except for last item)
                        if index < min(4, transactions.count - 1) {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(20)
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
