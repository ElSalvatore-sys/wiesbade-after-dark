//
//  HomeView.swift
//  WiesbadenAfterDark
//
//  Home screen with gamification and event highlights
//  Architecture: Lightweight coordinator - logic delegated to components
//

import SwiftUI
import SwiftData
import CoreLocation

/// Home screen - main app view with inventory gamification and event highlights
/// Refactored from 799 lines to ~200 lines by extracting 8 focused components
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
                    // 1. Active Bonuses Banner (if any)
                    if homeViewModel.hasActiveBonuses {
                        ActiveBonusesBanner(
                            hasActiveBonuses: homeViewModel.hasActiveBonuses,
                            bonusesSummary: homeViewModel.activeBonusesSummary()
                        )
                        .padding(.horizontal)
                    }

                    // 2. Points Balance Card
                    if homeViewModel.totalPoints > 0 {
                        PointsBalanceCard(
                            totalPoints: homeViewModel.totalPoints,
                            memberships: homeViewModel.memberships,
                            venues: homeViewModel.venues
                        )
                        .padding(.horizontal)
                    }

                    // 3. Referral Section
                    if let user = authViewModel.authState.user {
                        ReferralSection(user: user)
                            .padding(.horizontal)
                    }

                    // 4. Recent Transactions
                    if !homeViewModel.recentTransactions.isEmpty {
                        RecentTransactionsView(transactions: homeViewModel.recentTransactions)
                            .padding(.horizontal)
                    }

                    // 5. Event Highlights
                    EventHighlightsSection(
                        todayEvents: homeViewModel.todayEvents,
                        upcomingEvents: homeViewModel.upcomingEvents,
                        venues: homeViewModel.venues,
                        onEventTap: { event in
                            selectedEvent = event
                        }
                    )

                    // 6. Inventory Offers
                    InventoryOffersSection(
                        inventoryOffers: homeViewModel.inventoryOffers,
                        venues: homeViewModel.venues,
                        onProductTap: { product in
                            selectedProduct = product
                        }
                    )

                    // 7. Nearby Venues
                    NearbyVenuesSection(
                        nearbyVenues: homeViewModel.nearbyVenues,
                        allVenues: homeViewModel.venues,
                        distanceCalculator: { venue in
                            homeViewModel.distance(to: venue)
                        },
                        pointsBalanceCalculator: { venueId in
                            homeViewModel.pointsBalance(for: venueId)
                        }
                    )

                    // 8. Quick Actions
                    QuickActionsSection(
                        onCheckIn: {
                            showVenuePicker = true
                        },
                        onMyPasses: {
                            showMyPasses = true
                        },
                        onHistory: {
                            showCheckInHistory = true
                        },
                        onShareReferral: {
                            if let user = authViewModel.authState.user {
                                shareReferralCode(user.referralCode)
                            }
                        },
                        onSignOut: {
                            authViewModel.signOut()
                        }
                    )
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
