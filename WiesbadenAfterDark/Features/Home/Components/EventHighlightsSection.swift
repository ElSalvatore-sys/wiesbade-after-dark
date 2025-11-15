//
//  EventHighlightsSection.swift
//  WiesbadenAfterDark
//
//  Purpose: Display event highlights in horizontal scroll
//  Shows: Today's events or upcoming events with preview cards
//

import SwiftUI

/// Section displaying event highlights
/// - Shows today's events first (if any)
/// - Falls back to upcoming events
/// - Empty state when no events scheduled
struct EventHighlightsSection: View {
    // MARK: - Properties

    let todayEvents: [Event]
    let upcomingEvents: [Event]
    let venues: [Venue]
    let onEventTap: (Event) -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(sectionTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    Text(sectionSubtitle)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Button {
                    // Navigate to events tab
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundStyle(Color.primary)
                }
            }
            .padding(.horizontal)

            // Event Cards
            if !todayEvents.isEmpty {
                todayEventsScrollView
            } else if !upcomingEvents.isEmpty {
                upcomingEventsScrollView
            } else {
                emptyStateView
            }
        }
    }

    // MARK: - Subviews

    private var todayEventsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(todayEvents.prefix(3), id: \.id) { event in
                    EventHighlightCard(
                        event: event,
                        venue: venue(for: event),
                        isToday: true
                    )
                    .frame(width: 320)
                    .onTapGesture {
                        onEventTap(event)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var upcomingEventsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(upcomingEvents.prefix(3), id: \.id) { event in
                    EventHighlightCard(
                        event: event,
                        venue: venue(for: event),
                        isToday: false
                    )
                    .frame(width: 320)
                    .onTapGesture {
                        onEventTap(event)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(Color.textTertiary)

            Text("No events scheduled")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text("Check back later for upcoming events!")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
    }

    // MARK: - Computed Properties

    private var sectionTitle: String {
        if !todayEvents.isEmpty {
            return "Tonight's Events"
        } else if !upcomingEvents.isEmpty {
            return "Upcoming Events"
        } else {
            return "Events"
        }
    }

    private var sectionSubtitle: String {
        if !todayEvents.isEmpty {
            return "Happening today"
        } else if !upcomingEvents.isEmpty {
            return "This week"
        } else {
            return "No events scheduled"
        }
    }

    // MARK: - Helpers

    private func venue(for event: Event) -> Venue? {
        venues.first(where: { $0.id == event.venueId })
    }
}

// MARK: - Preview

#Preview("Event Highlights Section - Today") {
    EventHighlightsSection(
        todayEvents: Event.mockEventsForVenue(Venue.mockVenues[0].id),
        upcomingEvents: [],
        venues: Venue.mockVenues,
        onEventTap: { _ in }
    )
}

#Preview("Event Highlights Section - Upcoming") {
    EventHighlightsSection(
        todayEvents: [],
        upcomingEvents: Event.mockEventsForVenue(Venue.mockVenues[0].id),
        venues: Venue.mockVenues,
        onEventTap: { _ in }
    )
}

#Preview("Event Highlights Section - Empty") {
    EventHighlightsSection(
        todayEvents: [],
        upcomingEvents: [],
        venues: Venue.mockVenues,
        onEventTap: { _ in }
    )
}
