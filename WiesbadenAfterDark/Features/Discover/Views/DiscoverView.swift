//
//  DiscoverView.swift
//  WiesbadenAfterDark
//
//  Venue discovery screen with grid of venues
//

import SwiftUI

/// Main venue discovery view
struct DiscoverView: View {
    @Environment(VenueViewModel.self) private var viewModel
    @State private var navigationPath = NavigationPath()
    @State private var selectedVenueId: UUID?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // Background
                Color.appBackground.ignoresSafeArea()

                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                            // Header
                            Text("Discover Venues")
                                .font(Typography.displayMedium)
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, geometry.size.width * 0.05)
                                .padding(.top, Theme.Spacing.md)

                            // Active Deals Section (moved from Home)
                            if !viewModel.inventoryOffers.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.cardGap) {
                                    // Section Header
                                    HStack {
                                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                            Text("Active Deals")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.textPrimary)

                                            Text("Bonus points on these items")
                                                .font(.caption)
                                                .foregroundColor(.textSecondary)
                                        }

                                        Spacer()

                                        HStack(spacing: Theme.Spacing.xs) {
                                            Image(systemName: "flame.fill")
                                                .font(.caption)
                                                .foregroundColor(.orange)

                                            Text("\(viewModel.inventoryOffers.count) deals")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.textSecondary)
                                        }
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)

                                    // Deals ScrollView
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: Theme.Spacing.cardGap) {
                                            ForEach(viewModel.inventoryOffers.prefix(10), id: \.id) { product in
                                                InventoryOfferCard(
                                                    product: product,
                                                    venue: viewModel.venues.first(where: { $0.id == product.venueId }),
                                                    multiplier: product.bonusMultiplier,
                                                    expiresAt: product.bonusEndDate
                                                )
                                                .frame(width: 320)
                                            }
                                        }
                                        .padding(.horizontal, geometry.size.width * 0.05)
                                    }
                                }
                                .padding(.vertical, Theme.Spacing.sm)

                                // Divider
                                Divider()
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                    .padding(.vertical, Theme.Spacing.sm)
                            }

                            // Venues list (single column, responsive)
                            if viewModel.venues.isEmpty && !viewModel.isLoading {
                                EmptyStateView(.noVenues)
                            } else {
                                LazyVStack(spacing: Theme.Spacing.cardPadding) {
                                    ForEach(Array(viewModel.venues.enumerated()), id: \.element.id) { index, venue in
                                        VenueCard(venue: venue) {
                                            // CRITICAL FIX: Only select if not already selected
                                            if selectedVenueId != venue.id {
                                                selectedVenueId = venue.id
                                                Task {
                                                    await viewModel.selectVenue(venue)
                                                    navigationPath.append(venue.id)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, geometry.size.width * 0.05)
                                        .staggeredAppear(index: index)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, Theme.Spacing.xl)
                    }
                    .refreshable {
                        HapticManager.shared.light()
                        await viewModel.fetchVenues()
                    }
                }

                // Skeleton loading overlay
                if viewModel.isLoading && viewModel.venues.isEmpty {
                    DiscoverLoadingSkeleton()
                }
            }
            .navigationDestination(for: UUID.self) { venueId in
                if let venue = viewModel.venues.first(where: { $0.id == venueId }) {
                    VenueDetailView(venue: venue)
                        .onDisappear {
                            // CRITICAL FIX: Clear state when navigating back
                            print("🔙 [DiscoverView] Navigating back, clearing state")
                            selectedVenueId = nil
                            viewModel.clearSelectedVenue()
                        }
                }
            }
            .task {
                if viewModel.venues.isEmpty {
                    await viewModel.fetchVenues()
                }
            }
            .alert("Error Loading Venues", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
                Button("Retry") {
                    Task {
                        await viewModel.fetchVenues()
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "Could not load venues. Please check your connection.")
            }
        }
    }
}


// MARK: - Preview
#Preview("Discover View") {
    DiscoverView()
        .environment(VenueViewModel())
}
