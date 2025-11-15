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
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image Section
                ZStack(alignment: .topTrailing) {
                    // Background image with caching
                    if let imageURL = venue.coverImageURL {
                        CachedAsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 180)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.cardBackground)
                                .frame(height: 180)
                                .shimmer()
                        }
                    } else {
                        Rectangle()
                            .fill(Color.cardBackground)
                            .frame(height: 180)
                    }

                    // Venue type badge
                    VenueTypeBadge(type: venue.type, size: .small)
                        .padding(Theme.Spacing.sm)
                }
                .frame(height: 180)

                // Content Section
                VStack(alignment: .leading, spacing: 12) {
                    // Title & Rating Row
                    HStack(alignment: .top) {
                        Text(venue.name)
                            .font(Typography.titleSmall)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                            .lineLimit(2)

                        Spacer()

                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.gold)
                                .font(.caption)
                            Text(venue.formattedRating)
                                .font(Typography.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    // Member Count Row
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.caption2)
                            Text("\(venue.memberCount) members")
                                .font(Typography.captionMedium)
                        }
                        .foregroundColor(.textSecondary)

                        // Open status indicator
                        if venue.isOpenNow {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                Text("Open")
                                    .font(Typography.captionMedium)
                                    .foregroundColor(.green)
                            }
                        }
                    }

                    // Description
                    Text(venue.venueDescription)
                        .font(Typography.bodySmall)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)

                    // Points Rate Badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.circle.fill")
                            .foregroundColor(.gold)
                            .font(.caption)
                        Text("Earn up to 10% in points")
                            .font(Typography.captionMedium)
                            .fontWeight(.medium)
                            .foregroundColor(.gold)
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.cardBackground)
            .cornerRadius(Theme.CornerRadius.lg)
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 4
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
