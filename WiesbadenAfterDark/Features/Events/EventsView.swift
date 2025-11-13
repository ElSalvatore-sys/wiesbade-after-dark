//
//  EventsView.swift
//  WiesbadenAfterDark
//
//  Global events view showing all events across all venues
//

import SwiftUI
import SwiftData

/// Main global events view
struct EventsView: View {
    @Environment(VenueViewModel.self) private var venueViewModel
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedEvent: Event?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(.primary)
                } else if let error = errorMessage {
                    errorStateView(message: error)
                } else if events.isEmpty {
                    emptyStateView
                } else {
                    eventsListView
                }
            }
            .navigationTitle("Events")
            .task {
                await loadEvents()
            }
            .refreshable {
                await loadEvents()
            }
        }
    }

    // MARK: - Events List

    private var eventsListView: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(events) { event in
                    EventCard(
                        event: event,
                        onGoing: {
                            Task {
                                await handleRSVP(event: event, status: .going)
                            }
                        },
                        onInterested: {
                            Task {
                                await handleRSVP(event: event, status: .interested)
                            }
                        }
                    )
                    .onTapGesture {
                        selectedEvent = event
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.md)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)

            VStack(spacing: Theme.Spacing.xs) {
                Text("No Events Yet")
                    .font(Typography.titleMedium)
                    .foregroundColor(.textPrimary)

                Text("Check back soon for exciting events")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Theme.Spacing.xl)
    }

    // MARK: - Error State

    private func errorStateView(message: String) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.error)

            VStack(spacing: Theme.Spacing.xs) {
                Text("Unable to Load Events")
                    .font(Typography.titleMedium)
                    .foregroundColor(.textPrimary)

                Text(message)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                Task {
                    await loadEvents()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(Typography.buttonMedium)
                .foregroundColor(.white)
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, Theme.Spacing.md)
                .background(Color.primary)
                .cornerRadius(Theme.CornerRadius.md)
            }
        }
        .padding(Theme.Spacing.xl)
    }

    // MARK: - Data Loading

    private func loadEvents() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch all events from the venue service
            let fetchedEvents = try await MockVenueService.shared.fetchAllEvents()

            // Sort by start time (upcoming first)
            events = fetchedEvents.sorted { $0.startTime < $1.startTime }

            print("✅ [EventsView] Loaded \(events.count) events")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [EventsView] Failed to load events: \(error)")
        }

        isLoading = false
    }

    // MARK: - RSVP Handling

    private func handleRSVP(event: Event, status: RSVPStatus) async {
        do {
            try await MockVenueService.shared.rsvpEvent(eventId: event.id, status: status)
            print("✅ [EventsView] RSVP successful: \(status.rawValue)")

            // Reload events to show updated counts
            await loadEvents()
        } catch {
            print("❌ [EventsView] RSVP failed: \(error)")
            errorMessage = "Failed to update RSVP. Please try again."
        }
    }
}

// MARK: - Preview
#Preview("Events View") {
    let modelContainer = try! ModelContainer(
        for: Schema([User.self, Venue.self, Event.self]),
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let venueViewModel = VenueViewModel(modelContext: modelContainer.mainContext)

    return EventsView()
        .environment(venueViewModel)
        .modelContainer(modelContainer)
}
