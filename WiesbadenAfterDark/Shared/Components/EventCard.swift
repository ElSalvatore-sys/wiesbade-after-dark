//
//  EventCard.swift
//  WiesbadenAfterDark
//
//  Event card component for displaying events
//

import SwiftUI

/// Displays event information in a card format
struct EventCard: View {
    let event: Event
    var onGoing: (() -> Void)?
    var onInterested: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Event image (if available) - using cached loading
            if let imageURL = event.imageURL {
                CachedAsyncImage(
                    url: URL(string: imageURL),
                    targetSize: CGSize(width: 400, height: 150)
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.inputBackground)
                        .frame(height: 150)
                        .shimmer()
                }
                .cornerRadius(Theme.CornerRadius.md)
            }

            // Event title & points multiplier
            HStack {
                Text(event.title)
                    .font(Typography.headlineLarge)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)

                Spacer()

                if let multiplier = event.pointsMultiplierText {
                    Text(multiplier)
                        .font(Typography.captionMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gold)
                        .cornerRadius(Theme.CornerRadius.sm)
                }
            }

            // DJ Lineup
            if !event.djLineup.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "music.note")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                    Text(event.formattedLineup)
                        .font(Typography.bodySmall)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
            }

            // Date & Time
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)

                Text(event.formattedDateTime)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)
            }

            // Cover charge & attendance
            HStack {
                // Cover charge
                HStack(spacing: 4) {
                    Image(systemName: "ticket")
                        .font(.system(size: 14))
                    Text(event.formattedCoverCharge)
                        .font(Typography.bodySmall)
                }
                .foregroundColor(.textSecondary)

                Spacer()

                // Attendance
                HStack(spacing: Theme.Spacing.md) {
                    HStack(spacing: 4) {
                        Text("\(event.attendingCount)")
                            .font(Typography.labelMedium)
                            .foregroundColor(.success)
                        Text("going")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }

                    HStack(spacing: 4) {
                        Text("\(event.interestedCount)")
                            .font(Typography.labelMedium)
                            .foregroundColor(.info)
                        Text("interested")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            // Action buttons
            HStack(spacing: Theme.Spacing.md) {
                Button(action: { onGoing?() }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Going")
                    }
                    .font(Typography.buttonSmall)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.success)
                    .cornerRadius(Theme.CornerRadius.md)
                }

                Button(action: { onInterested?() }) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Interested")
                    }
                    .font(Typography.buttonSmall)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.info)
                    .cornerRadius(Theme.CornerRadius.md)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
        .shadow(
            color: Theme.Shadow.sm.color,
            radius: Theme.Shadow.sm.radius,
            x: Theme.Shadow.sm.x,
            y: Theme.Shadow.sm.y
        )
    }
}

// MARK: - Preview
#Preview("Event Card") {
    ScrollView {
        VStack(spacing: Theme.Spacing.lg) {
            ForEach(Event.mockEventsForVenue(UUID()), id: \.id) { event in
                EventCard(event: event) {
                    print("Going to \(event.title)")
                } onInterested: {
                    print("Interested in \(event.title)")
                }
            }
        }
        .padding()
    }
    .background(Color.appBackground)
}
