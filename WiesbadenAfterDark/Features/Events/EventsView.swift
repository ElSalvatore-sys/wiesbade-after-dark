//
//  EventsView.swift
//  WiesbadenAfterDark
//
//  Global events view showing all events across all venues
//

import SwiftUI
import SwiftData

// MARK: - Time Filter Enum

enum TimeFilter: String, CaseIterable {
    case all = "All Events"
    case thisWeek = "This Week"
    case thisWeekend = "This Weekend"
}

/// Main global events view
struct EventsView: View {
    @Environment(VenueViewModel.self) private var venueViewModel
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedEvent: Event?
    @State private var selectedTimeFilter: TimeFilter = .all

    // MARK: - Computed Properties

    private var filteredEvents: [Event] {
        let now = Date()
        let calendar = Calendar.current

        switch selectedTimeFilter {
        case .all:
            return events

        case .thisWeek:
            // Events within next 7 days
            guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: now) else {
                return events
            }
            return events.filter { $0.startTime >= now && $0.startTime <= weekEnd }

        case .thisWeekend:
            // Find this weekend's Saturday and Sunday
            let weekday = calendar.component(.weekday, from: now)
            // weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday

            // Calculate days until Saturday (7)
            let daysUntilSaturday = (7 - weekday + 7) % 7
            let daysUntilSunday = (1 - weekday + 7) % 7

            // If today is Saturday or Sunday, include today
            let saturdayStart: Date
            let sundayEnd: Date

            if weekday == 7 {
                // Today is Saturday
                saturdayStart = calendar.startOfDay(for: now)
            } else if weekday == 1 {
                // Today is Sunday
                saturdayStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: now)!)
            } else {
                saturdayStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: daysUntilSaturday, to: now)!)
            }

            // Sunday end is end of Sunday
            if weekday == 1 {
                // Today is Sunday
                sundayEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
            } else {
                let sunday = calendar.date(byAdding: .day, value: weekday == 7 ? 1 : daysUntilSunday, to: now)!
                sundayEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: sunday))!
            }

            return events.filter { $0.startTime >= saturdayStart && $0.startTime < sundayEnd }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(.primary)
                } else if let error = errorMessage {
                    errorStateView(message: error)
                } else {
                    VStack(spacing: 0) {
                        // Filter chips
                        filterChipsView
                            .padding(.top, Theme.Spacing.sm)

                        if filteredEvents.isEmpty {
                            Spacer()
                            emptyStateView
                            Spacer()
                        } else {
                            eventsListView
                        }
                    }
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

    // MARK: - Filter Chips

    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(TimeFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedTimeFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTimeFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
        }
    }

    // MARK: - Events List

    private var eventsListView: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(filteredEvents) { event in
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
                Text(emptyStateTitle)
                    .font(Typography.titleMedium)
                    .foregroundColor(.textPrimary)

                Text(emptyStateMessage)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Show "View All" button if filtering and there are events
            if selectedTimeFilter != .all && !events.isEmpty {
                Button(action: {
                    withAnimation {
                        selectedTimeFilter = .all
                    }
                }) {
                    Text("View All Events")
                        .font(Typography.buttonMedium)
                        .foregroundColor(.primary)
                }
                .padding(.top, Theme.Spacing.sm)
            }
        }
        .padding(Theme.Spacing.xl)
    }

    private var emptyStateTitle: String {
        switch selectedTimeFilter {
        case .all:
            return "No Events Yet"
        case .thisWeek:
            return "No Events This Week"
        case .thisWeekend:
            return "No Events This Weekend"
        }
    }

    private var emptyStateMessage: String {
        switch selectedTimeFilter {
        case .all:
            return "Check back soon for exciting events"
        case .thisWeek:
            return "No events scheduled for the next 7 days"
        case .thisWeekend:
            return "No events scheduled for this weekend"
        }
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

// MARK: - Filter Chip Component

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.captionMedium)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    Group {
                        if isSelected {
                            Color.primaryGradient
                        } else {
                            Color.cardBackground
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.cardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
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
