//
//  VenueCard.swift
//  WiesbadenAfterDark
//
//  Venue card component for displaying venues in grid/list
//

import SwiftUI

/// Displays venue information in a card format
struct VenueCard: View {
    let venue: Venue
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // Background image with caching
                if let imageURL = venue.coverImageURL {
                    CachedAsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.cardBackground)
                            .frame(height: 200)
                            .shimmer()
                    }
                } else {
                    Rectangle()
                        .fill(Color.cardBackground)
                        .frame(height: 200)
                }

                // Gradient overlay for text readability
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .bottom,
                    endPoint: .center
                )

                // Content overlay
                VStack(alignment: .leading) {
                    Spacer()

                    // Venue name
                    Text(venue.name)
                        .font(Typography.titleSmall)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)

                    // Bottom info row
                    HStack {
                        // Member count
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 12))
                            Text("\(venue.memberCount)")
                                .font(Typography.captionMedium)
                        }
                        .foregroundColor(.white.opacity(0.9))

                        Spacer()

                        // Rating
                        StarRating(
                            rating: venue.rating,
                            size: 12,
                            color: .gold,
                            showRatingText: false
                        )
                    }
                }
                .padding(Theme.Spacing.md)

                // Venue type badge
                VenueTypeBadge(type: venue.type, size: .small)
                    .padding(Theme.Spacing.sm)
            }
            .frame(height: 200)
            .cornerRadius(Theme.CornerRadius.lg)
            .shadow(
                color: Theme.Shadow.md.color,
                radius: Theme.Shadow.md.radius,
                x: Theme.Shadow.md.x,
                y: Theme.Shadow.md.y
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview("Venue Card") {
    VStack(spacing: Theme.Spacing.lg) {
        VenueCard(venue: Venue.mockDasWohnzimmer()) {
            print("Tapped Das Wohnzimmer")
        }
    }
    .padding()
    .background(Color.appBackground)
}
