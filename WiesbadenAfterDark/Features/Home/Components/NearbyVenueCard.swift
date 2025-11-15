//
//  NearbyVenueCard.swift
//  WiesbadenAfterDark
//
//  Purpose: Display venue card with image, info, distance, and points balance
//  Used in: Home screen nearby venues section
//

import SwiftUI

/// Card displaying venue preview with distance and points
/// - Shows venue cover image
/// - Displays name, type, and optional distance
/// - Shows points balance if > 0
struct NearbyVenueCard: View {
    // MARK: - Properties

    let venue: Venue
    let distance: String?
    let pointsBalance: Int

    // MARK: - Body

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

// MARK: - Preview

#Preview("Nearby Venue Card") {
    NearbyVenueCard(
        venue: Venue.mockVenues[0],
        distance: "0.3 km",
        pointsBalance: 450
    )
    .frame(width: 200)
    .padding()
}
