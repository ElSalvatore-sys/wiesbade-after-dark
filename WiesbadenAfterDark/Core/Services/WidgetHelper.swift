//
//  WidgetHelper.swift
//  WiesbadenAfterDark
//
//  Helper to configure widget with API credentials via App Group
//

import Foundation
import WidgetKit

/// Helper class to configure widget extension with API credentials
/// Call `WidgetHelper.configure()` on app launch to enable widget API access
enum WidgetHelper {

    /// App Group identifier (must match widget's WidgetConfiguration)
    private static let appGroupIdentifier = "group.com.ea-solutions.WiesbadenAfterDark"

    /// UserDefaults keys (must match widget's WidgetConfiguration)
    private enum Keys {
        static let supabaseURL = "supabase_url"
        static let supabaseAnonKey = "supabase_anon_key"
    }

    /// Configure widget with API credentials from APIConfig
    /// Call this from your App's init or on app launch
    static func configure() {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("⚠️ WidgetHelper: Failed to access App Group UserDefaults")
            return
        }

        // Share API configuration with widget
        defaults.set(APIConfig.baseURL, forKey: Keys.supabaseURL)
        defaults.set(APIConfig.supabaseAnonKey, forKey: Keys.supabaseAnonKey)

        print("✅ WidgetHelper: Configured widget with API credentials")

        // Reload widget timelines to fetch fresh data
        reloadWidgets()
    }

    /// Reload all widget timelines
    static func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Reload specific widget timeline
    static func reloadWidget(kind: String = "WiesbadenAfterDarkWidget") {
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }

    /// Cache venue data for widget (call after fetching venues)
    static func cacheVenues(_ venues: [Venue]) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }

        // Convert to widget-friendly format
        let widgetVenues = venues.prefix(5).map { venue in
            [
                "id": venue.id.uuidString,
                "name": venue.name,
                "type": venue.type.rawValue,
                "rating": venue.rating,
                "image_url": venue.coverImageURL ?? "",
                "is_open": true // Could be computed from opening hours
            ] as [String: Any]
        }

        if let data = try? JSONSerialization.data(withJSONObject: widgetVenues) {
            defaults.set(data, forKey: "cached_venues")
            defaults.set(Date(), forKey: "last_cache_update")
        }
    }

    /// Cache event data for widget (call after fetching events)
    static func cacheEvents(_ events: [Event]) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }

        let dateFormatter = ISO8601DateFormatter()

        // Convert to widget-friendly format
        let widgetEvents = events.prefix(5).map { event in
            [
                "id": event.id.uuidString,
                "title": event.title,
                "venue_name": "", // Would need to join with venue
                "start_date": dateFormatter.string(from: event.startTime),
                "image_url": event.imageURL ?? ""
            ] as [String: Any]
        }

        if let data = try? JSONSerialization.data(withJSONObject: widgetEvents) {
            defaults.set(data, forKey: "cached_events")
            defaults.set(Date(), forKey: "last_cache_update")
        }
    }
}
