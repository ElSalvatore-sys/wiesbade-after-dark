//
//  WiesbadenAfterDarkWidget.swift
//  WiesbadenAfterDarkWidget
//
//  Created by Ali on 22.12.2025.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct VenueEntry: TimelineEntry {
    let date: Date
    let venue: WidgetVenue?
    let events: [WidgetEvent]
    let configuration: ConfigurationAppIntent
}

struct WidgetVenue: Codable {
    let id: String
    let name: String
    let type: String
    let rating: Double
    let imageUrl: String?
    let isOpen: Bool
}

struct WidgetEvent: Codable, Identifiable {
    let id: String
    let title: String
    let venueName: String
    let startDate: Date
    let imageUrl: String?
}

// MARK: - Timeline Provider
struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> VenueEntry {
        VenueEntry(
            date: Date(),
            venue: WidgetVenue(
                id: "1",
                name: "Das Wohnzimmer",
                type: "Bar",
                rating: 4.7,
                imageUrl: nil,
                isOpen: true
            ),
            events: [
                WidgetEvent(
                    id: "1",
                    title: "Live Jazz Night",
                    venueName: "Das Wohnzimmer",
                    startDate: Date(),
                    imageUrl: nil
                )
            ],
            configuration: ConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> VenueEntry {
        await getEntry(for: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<VenueEntry> {
        let entry = await getEntry(for: configuration)

        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!

        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func getEntry(for configuration: ConfigurationAppIntent) async -> VenueEntry {
        // Fetch real data from Supabase
        do {
            let events = try await fetchUpcomingEvents()
            let venue = try await fetchFeaturedVenue()

            return VenueEntry(
                date: Date(),
                venue: venue,
                events: events,
                configuration: configuration
            )
        } catch {
            // Return static placeholder on error
            return VenueEntry(
                date: Date(),
                venue: WidgetVenue(
                    id: "1",
                    name: "Das Wohnzimmer",
                    type: "Bar",
                    rating: 4.7,
                    imageUrl: nil,
                    isOpen: true
                ),
                events: [
                    WidgetEvent(
                        id: "1",
                        title: "Live Jazz Night",
                        venueName: "Das Wohnzimmer",
                        startDate: Date(),
                        imageUrl: nil
                    )
                ],
                configuration: configuration
            )
        }
    }

    private func fetchUpcomingEvents() async throws -> [WidgetEvent] {
        // Check if API is configured via App Group
        guard let apiKey = WidgetSettings.supabaseAnonKey else {
            // Return cached events if available, otherwise throw
            if let cached = WidgetSettings.cachedEvents {
                return cached
            }
            throw WidgetError.notConfigured
        }

        let url = URL(string: "\(WidgetSettings.supabaseURL)/events/upcoming")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "apikey")

        let (data, _) = try await URLSession.shared.data(for: request)

        struct EventsResponse: Codable {
            let events: [EventDTO]
        }

        struct EventDTO: Codable {
            let id: String
            let title: String
            let venue_name: String?
            let start_time: String
            let image_url: String?
        }

        let response = try JSONDecoder().decode(EventsResponse.self, from: data)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let events = response.events.prefix(3).map { dto in
            WidgetEvent(
                id: dto.id,
                title: dto.title,
                venueName: dto.venue_name ?? "Unknown",
                startDate: dateFormatter.date(from: dto.start_time) ?? Date(),
                imageUrl: dto.image_url
            )
        }

        // Cache for offline use
        WidgetSettings.cacheEvents(Array(events))

        return Array(events)
    }

    private func fetchFeaturedVenue() async throws -> WidgetVenue? {
        // Check if API is configured via App Group
        guard let apiKey = WidgetSettings.supabaseAnonKey else {
            // Return cached venue if available
            return WidgetSettings.cachedVenues?.first
        }

        let url = URL(string: "\(WidgetSettings.supabaseURL)/venues")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "apikey")

        let (data, _) = try await URLSession.shared.data(for: request)

        struct VenuesResponse: Codable {
            let venues: [VenueDTO]
        }

        struct VenueDTO: Codable {
            let id: String
            let name: String
            let venue_type: String?
            let rating: Double?
            let image_url: String?
        }

        let response = try JSONDecoder().decode(VenuesResponse.self, from: data)

        let venues = response.venues.map { dto in
            WidgetVenue(
                id: dto.id,
                name: dto.name,
                type: dto.venue_type ?? "Venue",
                rating: dto.rating ?? 4.5,
                imageUrl: dto.image_url,
                isOpen: true
            )
        }

        // Cache for offline use
        WidgetSettings.cacheVenues(venues)

        return venues.first
    }
}

// MARK: - Widget Errors
enum WidgetError: Error {
    case notConfigured
    case networkError
}

// MARK: - App Intent Configuration
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Konfiguration"
    static var description = IntentDescription("Wähle was du sehen möchtest")

    @Parameter(title: "Zeige Events", default: true)
    var showEvents: Bool

    @Parameter(title: "Zeige Venue", default: true)
    var showVenue: Bool
}

// MARK: - Widget Views

struct SmallWidgetView: View {
    let entry: VenueEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.purple)
                Text("WAD")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
            }

            Spacer()

            // Next Event
            if let event = entry.events.first {
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text(event.venueName)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(formatDate(event.startDate))
                        .font(.caption2)
                        .foregroundColor(.purple)
                }
            } else {
                Text("Keine Events")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEE, HH:mm"
        return formatter.string(from: date)
    }
}

struct MediumWidgetView: View {
    let entry: VenueEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left: Venue Info
            if let venue = entry.venue {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(.purple)
                        Text("WiesbadenAfterDark")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(venue.name)
                        .font(.headline)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(venue.type)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", venue.rating))
                                .font(.caption)
                        }
                    }

                    HStack(spacing: 4) {
                        Circle()
                            .fill(venue.isOpen ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        Text(venue.isOpen ? "Geöffnet" : "Geschlossen")
                            .font(.caption2)
                            .foregroundColor(venue.isOpen ? .green : .red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Right: Events List
            VStack(alignment: .leading, spacing: 6) {
                Text("Nächste Events")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)

                ForEach(entry.events.prefix(2)) { event in
                    VStack(alignment: .leading, spacing: 1) {
                        Text(event.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Text(formatTime(event.startDate))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEE HH:mm"
        return formatter.string(from: date)
    }
}

struct LargeWidgetView: View {
    let entry: VenueEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.title2)
                    .foregroundColor(.purple)

                VStack(alignment: .leading) {
                    Text("WiesbadenAfterDark")
                        .font(.headline)
                    Text("Dein Nachtleben Guide")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let venue = entry.venue {
                    VStack(alignment: .trailing) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(venue.isOpen ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(venue.isOpen ? "Offen" : "Zu")
                                .font(.caption)
                        }
                    }
                }
            }

            Divider()

            // Featured Venue
            if let venue = entry.venue {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Featured Venue")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .textCase(.uppercase)

                        Text(venue.name)
                            .font(.title3)
                            .fontWeight(.bold)

                        HStack(spacing: 8) {
                            Label(venue.type, systemImage: "building.2")
                                .font(.caption)

                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", venue.rating))
                            }
                            .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }

            Divider()

            // Events
            Text("Kommende Events")
                .font(.caption)
                .foregroundColor(.purple)
                .textCase(.uppercase)

            ForEach(entry.events.prefix(3)) { event in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(event.venueName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatDate(event.startDate))
                            .font(.caption)
                            .fontWeight(.medium)
                        Text(formatTime(event.startDate))
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
                .padding(.vertical, 4)
            }

            Spacer()
        }
        .padding()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Widget Entry View
struct WiesbadenAfterDarkWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Definition
struct WiesbadenAfterDarkWidget: Widget {
    let kind: String = "WiesbadenAfterDarkWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            WiesbadenAfterDarkWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("WiesbadenAfterDark")
        .description("Sieh kommende Events und Venues auf einen Blick.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle
@main
struct WiesbadenAfterDarkWidgetBundle: WidgetBundle {
    var body: some Widget {
        WiesbadenAfterDarkWidget()
    }
}

// MARK: - Previews
#Preview(as: .systemSmall) {
    WiesbadenAfterDarkWidget()
} timeline: {
    VenueEntry(
        date: .now,
        venue: WidgetVenue(id: "1", name: "Das Wohnzimmer", type: "Bar", rating: 4.7, imageUrl: nil, isOpen: true),
        events: [
            WidgetEvent(id: "1", title: "Live Jazz Night", venueName: "Das Wohnzimmer", startDate: Date(), imageUrl: nil)
        ],
        configuration: ConfigurationAppIntent()
    )
}

#Preview(as: .systemMedium) {
    WiesbadenAfterDarkWidget()
} timeline: {
    VenueEntry(
        date: .now,
        venue: WidgetVenue(id: "1", name: "Das Wohnzimmer", type: "Bar", rating: 4.7, imageUrl: nil, isOpen: true),
        events: [
            WidgetEvent(id: "1", title: "Live Jazz Night", venueName: "Das Wohnzimmer", startDate: Date(), imageUrl: nil),
            WidgetEvent(id: "2", title: "Techno Freitag", venueName: "Club Galerie", startDate: Date().addingTimeInterval(86400), imageUrl: nil)
        ],
        configuration: ConfigurationAppIntent()
    )
}

#Preview(as: .systemLarge) {
    WiesbadenAfterDarkWidget()
} timeline: {
    VenueEntry(
        date: .now,
        venue: WidgetVenue(id: "1", name: "Das Wohnzimmer", type: "Bar", rating: 4.7, imageUrl: nil, isOpen: true),
        events: [
            WidgetEvent(id: "1", title: "Live Jazz Night", venueName: "Das Wohnzimmer", startDate: Date(), imageUrl: nil),
            WidgetEvent(id: "2", title: "Techno Freitag", venueName: "Club Galerie", startDate: Date().addingTimeInterval(86400), imageUrl: nil),
            WidgetEvent(id: "3", title: "Cocktail Masterclass", venueName: "Hemingways", startDate: Date().addingTimeInterval(172800), imageUrl: nil)
        ],
        configuration: ConfigurationAppIntent()
    )
}
