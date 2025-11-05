//
//  VenueEventsTab.swift
//  WiesbadenAfterDark
//
//  Events tab showing upcoming venue events
//

import SwiftUI

/// Events tab with event list and RSVP
struct VenueEventsTab: View {
    @Environment(VenueViewModel.self) private var viewModel

    let venue: Venue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Header
                Text("Upcoming Events")
                    .font(Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)

                // Events list
                if viewModel.events.isEmpty {
                    EmptyEventsState()
                } else {
                    VStack(spacing: Theme.Spacing.md) {
                        ForEach(viewModel.events, id: \.id) { event in
                            EventCard(
                                event: event,
                                onGoing: {
                                    Task {
                                        await viewModel.rsvpEvent(event, status: .going)
                                    }
                                },
                                onInterested: {
                                    Task {
                                        await viewModel.rsvpEvent(event, status: .interested)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                }
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Color.appBackground)
    }
}

// MARK: - Empty State
private struct EmptyEventsState: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.textTertiary)

            Text("No Upcoming Events")
                .font(Typography.titleMedium)
                .foregroundColor(.textPrimary)

            Text("Check back soon for exciting events!")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal, Theme.Spacing.xl)
    }
}

// MARK: - Preview
#Preview("Venue Events Tab") {
    VenueEventsTab(venue: Venue.mockDasWohnzimmer())
        .environment(VenueViewModel())
}
