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
                VStack(alignment: .leading, spacing: Theme.Spacing.cardGap) {
                    // Title & Rating Row
                    HStack(alignment: .top) {
                        Text(venue.name)
                            .font(Typography.titleSmall)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                            .lineLimit(2)

                        Spacer()

                        // Rating
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.gold)
                                .font(.caption)
                            Text(venue.formattedRating)
                                .font(Typography.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    // Member Count Row
                    HStack(spacing: Theme.Spacing.sm) {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "person.2.fill")
                                .font(.caption2)
                            Text("\(venue.memberCount) members")
                                .font(Typography.captionMedium)
                        }
                        .foregroundColor(.textSecondary)

                        // Open status indicator
                        if venue.isOpenNow {
                            HStack(spacing: Theme.Spacing.xs) {
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
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "star.circle.fill")
                            .foregroundColor(.gold)
                            .font(.caption)
                        Text("Earn up to 10% in points")
                            .font(Typography.captionMedium)
                            .fontWeight(.medium)
                            .foregroundColor(.gold)
                    }
                    .padding(.top, Theme.Spacing.xs)
                }
                .padding(Theme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
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
