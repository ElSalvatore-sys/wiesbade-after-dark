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

                            // Venues list (single column, responsive)
                            if viewModel.venues.isEmpty && !viewModel.isLoading {
                                EmptyStateView()
                            } else {
                                LazyVStack(spacing: 20) {
                                    ForEach(viewModel.venues, id: \.id) { venue in
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
                                    }
                                }
                            }
                        }
                        .padding(.bottom, Theme.Spacing.xl)
                    }
                    .refreshable {
                        await viewModel.fetchVenues()
                    }
                }

                // Loading overlay
                if viewModel.isLoading && viewModel.venues.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .scaleEffect(1.5)
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

// MARK: - Empty State
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)

            Text("No Venues Yet")
                .font(Typography.titleMedium)
                .foregroundColor(.textPrimary)

            Text("Check back soon for exciting venues!")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
        .padding(.horizontal, Theme.Spacing.xl)
    }
}

// MARK: - Preview
#Preview("Discover View") {
    DiscoverView()
        .environment(VenueViewModel())
}
