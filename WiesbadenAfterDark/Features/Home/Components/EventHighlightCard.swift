//
//  EventHighlightCard.swift
//  WiesbadenAfterDark
//
//  Card component for displaying event highlights on home page
//

import SwiftUI

/// Card displaying an event with timing and special offers
struct EventHighlightCard: View {
    // MARK: - Properties

    let event: Event
    let venue: Venue?
    let isToday: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event Image (if available) - using cached loading
            if let imageURL = event.imageURL {
                CachedAsyncImage(
                    url: URL(string: imageURL),
                    targetSize: CGSize(width: 400, height: 160)
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.inputBackground)
                        .shimmer()
                }
                .frame(height: 160)
                .clipped()
            } else {
                // Placeholder gradient
                Rectangle()
                    .fill(Color.primaryGradient)
                    .frame(height: 160)
                    .overlay {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.3))
                    }
            }

            // Event Details
            VStack(alignment: .leading, spacing: 12) {
                // Date Badge and Points Multiplier
                HStack {
                    // Date Badge
                    HStack(spacing: 4) {
                        Image(systemName: isToday ? "calendar.badge.clock" : "calendar")
                            .font(.caption2)

                        Text(dateLabel)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isToday ? Color.info : Color.textSecondary.opacity(0.3))
                    .clipShape(Capsule())

                    Spacer()

                    // Points Multiplier Badge
                    if let multiplierText = event.pointsMultiplierText {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)

                            Text(multiplierText)
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(pointsMultiplierColor)
                        .clipShape(Capsule())
                    }
                }

                // Event Title
                Text(event.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                // Venue
                if let venue = venue {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.caption)

                        Text(venue.name)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("•")
                            .foregroundStyle(Color.textTertiary)

                        Text(venue.type.rawValue)
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.textSecondary)
                }

                // Time and Cover Charge
                HStack {
                    // Time
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption)

                        Text(event.formattedTimeRange)
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.textSecondary)

                    Spacer()

                    // Cover Charge
                    Text(event.formattedCoverCharge)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(event.coverCharge == nil ? Color.success : Color.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.inputBackground)
                        .clipShape(Capsule())
                }

                // DJ Lineup (if available)
                if !event.djLineup.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "music.mic")
                            .font(.caption)

                        Text(event.formattedLineup)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(Color.textTertiary)
                }

                // RSVP Stats
                HStack(spacing: 16) {
                    // Attending
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.success)

                        Text("\(event.attendingCount) attending")
                            .font(.caption)
                    }

                    // Interested
                    HStack(spacing: 4) {
                        Image(systemName: "star.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.gold)

                        Text("\(event.interestedCount) interested")
                            .font(.caption)
                    }

                    Spacer()
                }
                .foregroundStyle(Color.textSecondary)
            }
            .padding(16)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.xl))
        .shadow(
            color: Theme.Shadow.lg.color,
            radius: Theme.Shadow.lg.radius,
            x: Theme.Shadow.lg.x,
            y: Theme.Shadow.lg.y
        )
    }

    // MARK: - Helpers

    /// Date label based on timing
    private var dateLabel: String {
        let calendar = Calendar.current
        let now = Date()

        if event.startTime <= now && event.endTime > now {
            return "HAPPENING NOW"
        } else if calendar.isDateInToday(event.startTime) {
            return "TONIGHT"
        } else if calendar.isDateInTomorrow(event.startTime) {
            return "TOMORROW"
        } else {
            // Show day of week
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: event.startTime).uppercased()
        }
    }

    /// Points multiplier badge color
    private var pointsMultiplierColor: LinearGradient {
        let multiplier = NSDecimalNumber(decimal: event.pointsMultiplier).doubleValue

        if multiplier >= 3.0 {
            // 3x: Red to orange gradient
            return LinearGradient(
                colors: [Color(hex: "#EF4444"), Color(hex: "#F59E0B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if multiplier >= 2.0 {
            // 2x: Orange gradient
            return LinearGradient(
                colors: [Color(hex: "#F59E0B"), Color(hex: "#FBBF24")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // 1.5x: Primary gradient
            return Color.primaryGradient
        }
    }
}

// MARK: - Preview

#Preview("Event Highlight Cards") {
    let venue = Venue(
        name: "Das Wohnzimmer",
        slug: "das-wohnzimmer",
        type: .club,
        description: "Cozy club in Wiesbaden",
        address: "Langgasse 38",
        city: "Wiesbaden",
        postalCode: "65183",
        latitude: 50.0826,
        longitude: 8.2400
    )

    let events = Event.mockEventsForVenue(venue.id)

    ScrollView {
        VStack(spacing: 20) {
            // Today event
            EventHighlightCard(
                event: events[0],
                venue: venue,
                isToday: true
            )

            // Upcoming events
            ForEach(events.dropFirst(), id: \.id) { event in
                EventHighlightCard(
                    event: event,
                    venue: venue,
                    isToday: false
                )
            }
        }
        .padding()
    }
    .background(Color.appBackground)
}
