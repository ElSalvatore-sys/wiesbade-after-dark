//
//  Event.swift
//  WiesbadenAfterDark
//
//  SwiftData model for venue events
//

import Foundation
import SwiftData

/// Represents an event at a venue
@Model
final class Event: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var title: String
    var eventDescription: String
    var venueId: UUID

    // Event timing
    var startTime: Date
    var endTime: Date

    // Event details
    var djLineup: [String]
    var coverCharge: Decimal?
    var genre: String?

    // Stats
    var attendingCount: Int
    var interestedCount: Int

    // Rewards
    var pointsMultiplier: Decimal

    // Media
    var imageURL: String?

    // Status
    var isCancelled: Bool

    // Timestamps
    var createdAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        venueId: UUID,
        startTime: Date,
        endTime: Date,
        djLineup: [String] = [],
        coverCharge: Decimal? = nil,
        genre: String? = nil,
        attendingCount: Int = 0,
        interestedCount: Int = 0,
        pointsMultiplier: Decimal = 1.0,
        imageURL: String? = nil,
        isCancelled: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.eventDescription = description
        self.venueId = venueId
        self.startTime = startTime
        self.endTime = endTime
        self.djLineup = djLineup
        self.coverCharge = coverCharge
        self.genre = genre
        self.attendingCount = attendingCount
        self.interestedCount = interestedCount
        self.pointsMultiplier = pointsMultiplier
        self.imageURL = imageURL
        self.isCancelled = isCancelled
        self.createdAt = createdAt
    }
}

// MARK: - Computed Properties
extension Event {
    /// Check if event is in the future
    var isUpcoming: Bool {
        return startTime > Date()
    }

    /// Formatted date and time display
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d · h:mm a"
        return formatter.string(from: startTime)
    }

    /// Formatted date only
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: startTime)
    }

    /// Formatted time range
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        return "\(start) - \(end)"
    }

    /// Formatted DJ lineup
    var formattedLineup: String {
        if djLineup.isEmpty {
            return "No lineup announced"
        }
        return djLineup.joined(separator: ", ")
    }

    /// Formatted cover charge
    var formattedCoverCharge: String {
        guard let charge = coverCharge else {
            return "Free"
        }
        return "€\(NSDecimalNumber(decimal: charge).intValue)"
    }

    /// Total RSVP count
    var totalRSVPs: Int {
        return attendingCount + interestedCount
    }

    /// Points multiplier badge text
    var pointsMultiplierText: String? {
        if pointsMultiplier > 1.0 {
            let value = NSDecimalNumber(decimal: pointsMultiplier).doubleValue
            return String(format: "%.1fx Points", value)
        }
        return nil
    }
}

// MARK: - Mock Data
extension Event {
    /// Mock events for Das Wohnzimmer
    static func mockEventsForVenue(_ venueId: UUID) -> [Event] {
        let calendar = Calendar.current
        let now = Date()

        // Get upcoming Friday
        var components = calendar.dateComponents([.year, .month, .day, .weekday], from: now)
        let currentWeekday = components.weekday ?? 1
        let daysUntilFriday = (6 - currentWeekday + 7) % 7
        let friday = calendar.date(byAdding: .day, value: daysUntilFriday == 0 ? 7 : daysUntilFriday, to: now)!

        // Friday Night Fever
        let fridayStart = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: friday)!
        let fridayEnd = calendar.date(byAdding: .hour, value: 6, to: fridayStart)!

        let fridayEvent = Event(
            title: "Friday Night Fever",
            description: "DJ Marcus Berlin spinning house & techno all night long",
            venueId: venueId,
            startTime: fridayStart,
            endTime: fridayEnd,
            djLineup: ["DJ Marcus Berlin"],
            coverCharge: 10.00,
            genre: "House & Techno",
            attendingCount: 127,
            interestedCount: 43,
            pointsMultiplier: 1.5,
            imageURL: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800"
        )

        // Saturday Slam
        let saturday = calendar.date(byAdding: .day, value: 1, to: friday)!
        let saturdayStart = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: saturday)!
        let saturdayEnd = calendar.date(byAdding: .hour, value: 5, to: saturdayStart)!

        let saturdayEvent = Event(
            title: "Saturday Slam",
            description: "The biggest party of the week with resident DJs",
            venueId: venueId,
            startTime: saturdayStart,
            endTime: saturdayEnd,
            djLineup: ["Luna & Friends"],
            coverCharge: 12.00,
            genre: "House & EDM",
            attendingCount: 89,
            interestedCount: 67,
            pointsMultiplier: 2.0,
            imageURL: "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800"
        )

        // Sunday Chill Sessions
        let sunday = calendar.date(byAdding: .day, value: 1, to: saturday)!
        let sundayStart = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: sunday)!
        let sundayEnd = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: sunday)!

        let sundayEvent = Event(
            title: "Sunday Chill Sessions",
            description: "Relaxed vibes with live acoustic performances",
            venueId: venueId,
            startTime: sundayStart,
            endTime: sundayEnd,
            djLineup: ["Acoustic Band"],
            coverCharge: 5.00,
            genre: "Acoustic & Chill",
            attendingCount: 34,
            interestedCount: 21,
            pointsMultiplier: 1.0,
            imageURL: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800"
        )

        return [fridayEvent, saturdayEvent, sundayEvent]
    }
}
