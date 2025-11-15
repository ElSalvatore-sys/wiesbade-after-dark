//
//  NearbyVenuesSection.swift
//  WiesbadenAfterDark
//
//  Purpose: Display nearby venues in horizontal scroll
//  Shows: Location-based venues or all venues if no location
//

import SwiftUI

/// Section displaying nearby venues
/// - Shows venues sorted by distance (if location available)
/// - Falls back to all venues if no location permission
/// - Horizontal scrolling venue cards
struct NearbyVenuesSection: View {
    // MARK: - Properties

    let nearbyVenues: [Venue]
    let allVenues: [Venue]
    let distanceCalculator: (Venue) -> String?
    let pointsBalanceCalculator: (UUID) -> Int

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Nearby Venues")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if !nearbyVenues.isEmpty {
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
            if !nearbyVenues.isEmpty {
                nearbyVenuesScrollView
            } else {
                allVenuesScrollView
            }
        }
    }

    // MARK: - Subviews

    private var nearbyVenuesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(nearbyVenues, id: \.id) { venue in
                    NearbyVenueCard(
                        venue: venue,
                        distance: distanceCalculator(venue),
                        pointsBalance: pointsBalanceCalculator(venue.id)
                    )
                    .frame(width: 280)
                }
            }
            .padding(.horizontal)
        }
    }

    private var allVenuesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(allVenues.prefix(5), id: \.id) { venue in
                    NearbyVenueCard(
                        venue: venue,
                        distance: nil,
                        pointsBalance: pointsBalanceCalculator(venue.id)
                    )
                    .frame(width: 280)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Preview

#Preview("Nearby Venues Section - With Location") {
    NearbyVenuesSection(
        nearbyVenues: Venue.mockVenues,
        allVenues: Venue.mockVenues,
        distanceCalculator: { _ in "0.5 km" },
        pointsBalanceCalculator: { _ in 120 }
    )
}

#Preview("Nearby Venues Section - No Location") {
    NearbyVenuesSection(
        nearbyVenues: [],
        allVenues: Venue.mockVenues,
        distanceCalculator: { _ in nil },
        pointsBalanceCalculator: { _ in 0 }
    )
}
