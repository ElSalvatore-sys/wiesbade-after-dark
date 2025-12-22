//
//  WidgetSettings.swift
//  WiesbadenAfterDarkWidget
//
//  Shared configuration for widget - reads from App Group UserDefaults
//

import Foundation

/// Widget settings that reads API credentials from App Group shared storage
/// This ensures no hardcoded API keys in source code (Apple App Store compliance)
/// NOTE: Named WidgetSettings to avoid conflict with WidgetKit's WidgetConfiguration protocol
enum WidgetSettings {

    /// App Group identifier for sharing data between main app and widget
    /// IMPORTANT: Must match the App Group ID in both entitlements files
    static let appGroupIdentifier = "group.com.ea-solutions.WiesbadenAfterDark"

    /// UserDefaults keys
    private enum Keys {
        static let supabaseURL = "supabase_url"
        static let supabaseAnonKey = "supabase_anon_key"
        static let cachedVenues = "cached_venues"
        static let cachedEvents = "cached_events"
        static let lastCacheUpdate = "last_cache_update"
    }

    /// Shared UserDefaults for App Group
    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    /// Supabase API URL - read from App Group or use default public URL
    static var supabaseURL: String {
        sharedDefaults?.string(forKey: Keys.supabaseURL)
            ?? "https://yyplbhrqtaeyzmcxpfli.supabase.co/functions/v1"
    }

    /// Supabase anon key - MUST be set by main app via App Group
    /// Returns nil if not configured (widget will use cached/placeholder data)
    static var supabaseAnonKey: String? {
        sharedDefaults?.string(forKey: Keys.supabaseAnonKey)
    }

    /// Check if API is properly configured
    static var isConfigured: Bool {
        supabaseAnonKey != nil
    }

    // MARK: - Cache Management

    /// Save venues to cache for offline widget access
    static func cacheVenues(_ venues: [WidgetVenue]) {
        guard let data = try? JSONEncoder().encode(venues) else { return }
        sharedDefaults?.set(data, forKey: Keys.cachedVenues)
        sharedDefaults?.set(Date(), forKey: Keys.lastCacheUpdate)
    }

    /// Save events to cache for offline widget access
    static func cacheEvents(_ events: [WidgetEvent]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        sharedDefaults?.set(data, forKey: Keys.cachedEvents)
        sharedDefaults?.set(Date(), forKey: Keys.lastCacheUpdate)
    }

    /// Get cached venues
    static var cachedVenues: [WidgetVenue]? {
        guard let data = sharedDefaults?.data(forKey: Keys.cachedVenues),
              let venues = try? JSONDecoder().decode([WidgetVenue].self, from: data) else {
            return nil
        }
        return venues
    }

    /// Get cached events
    static var cachedEvents: [WidgetEvent]? {
        guard let data = sharedDefaults?.data(forKey: Keys.cachedEvents),
              let events = try? JSONDecoder().decode([WidgetEvent].self, from: data) else {
            return nil
        }
        return events
    }

    /// Check if cache is fresh (less than 1 hour old)
    static var isCacheFresh: Bool {
        guard let lastUpdate = sharedDefaults?.object(forKey: Keys.lastCacheUpdate) as? Date else {
            return false
        }
        return Date().timeIntervalSince(lastUpdate) < 3600 // 1 hour
    }
}

// MARK: - Main App Configuration Helper

/// Call this from the main app to configure the widget
extension WidgetSettings {

    /// Configure widget with API credentials (call from main app on launch)
    static func configureWidget(supabaseURL: String, anonKey: String) {
        sharedDefaults?.set(supabaseURL, forKey: Keys.supabaseURL)
        sharedDefaults?.set(anonKey, forKey: Keys.supabaseAnonKey)
    }
}
