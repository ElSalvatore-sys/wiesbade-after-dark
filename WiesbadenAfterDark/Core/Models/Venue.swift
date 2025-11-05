//
//  Venue.swift
//  WiesbadenAfterDark
//
//  SwiftData model for venues (clubs, bars, restaurants)
//

import Foundation
import SwiftData

/// Venue type categorization
enum VenueType: String, Codable {
    case club = "Club"
    case bar = "Bar"
    case restaurant = "Restaurant"
    case barRestaurantClub = "Bar/Restaurant/Club"
    case lounge = "Lounge"
    case hotel = "Hotel"

    var displayName: String { rawValue }

    var badgeColor: String {
        switch self {
        case .club: return "#8B5CF6" // Purple
        case .bar: return "#3B82F6" // Blue
        case .restaurant: return "#10B981" // Green
        case .barRestaurantClub: return "#EC4899" // Pink
        case .lounge: return "#F59E0B" // Orange
        case .hotel: return "#6366F1" // Indigo
        }
    }
}

/// Represents a venue in the WiesbadenAfterDark platform
@Model
final class Venue: @unchecked Sendable {
    // MARK: - Basic Information

    @Attribute(.unique) var id: UUID
    var name: String
    var slug: String
    var type: VenueType
    var venueDescription: String // "description" is reserved

    // MARK: - Address

    var address: String
    var city: String
    var postalCode: String
    var latitude: Double?
    var longitude: Double?

    // MARK: - Contact Information

    var phone: String?
    var email: String?
    var website: String?
    var instagram: String?

    // MARK: - Media

    var coverImageURL: String?
    var logoURL: String?
    var galleryURLs: [String]

    // MARK: - Details

    var dressCode: String?
    var ageRequirement: String?
    var capacity: Int?
    var avgSpend: Decimal
    var bestNights: [String]

    // MARK: - Opening Hours

    /// Opening hours stored as JSON dictionary: ["monday": "18:00-23:00", "tuesday": "closed"]
    var openingHoursJSON: String

    // MARK: - Stats

    var memberCount: Int
    var rating: Decimal
    var totalEvents: Int
    var totalPosts: Int

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        slug: String,
        type: VenueType,
        description: String,
        address: String,
        city: String,
        postalCode: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        phone: String? = nil,
        email: String? = nil,
        website: String? = nil,
        instagram: String? = nil,
        coverImageURL: String? = nil,
        logoURL: String? = nil,
        galleryURLs: [String] = [],
        dressCode: String? = nil,
        ageRequirement: String? = nil,
        capacity: Int? = nil,
        avgSpend: Decimal = 0,
        bestNights: [String] = [],
        openingHours: [String: String] = [:],
        memberCount: Int = 0,
        rating: Decimal = 0,
        totalEvents: Int = 0,
        totalPosts: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.type = type
        self.venueDescription = description
        self.address = address
        self.city = city
        self.postalCode = postalCode
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone
        self.email = email
        self.website = website
        self.instagram = instagram
        self.coverImageURL = coverImageURL
        self.logoURL = logoURL
        self.galleryURLs = galleryURLs
        self.dressCode = dressCode
        self.ageRequirement = ageRequirement
        self.capacity = capacity
        self.avgSpend = avgSpend
        self.bestNights = bestNights
        self.memberCount = memberCount
        self.rating = rating
        self.totalEvents = totalEvents
        self.totalPosts = totalPosts
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // Encode opening hours to JSON
        if let jsonData = try? JSONEncoder().encode(openingHours),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            self.openingHoursJSON = jsonString
        } else {
            self.openingHoursJSON = "{}"
        }
    }
}

// MARK: - Computed Properties
extension Venue {
    /// Decoded opening hours dictionary
    var openingHours: [String: String] {
        guard let data = openingHoursJSON.data(using: .utf8),
              let hours = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return hours
    }

    /// Full formatted address
    var formattedAddress: String {
        return "\(address), \(postalCode) \(city)"
    }

    /// Check if venue is currently open
    var isOpenNow: Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let dayName = getDayName(from: weekday)

        guard let todayHours = openingHours[dayName.lowercased()],
              todayHours.lowercased() != "closed" else {
            return false
        }

        // Parse hours like "18:00-04:00"
        let components = todayHours.split(separator: "-")
        guard components.count == 2 else { return false }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let openTime = formatter.date(from: String(components[0])),
              let closeTime = formatter.date(from: String(components[1])) else {
            return false
        }

        let nowTime = formatter.string(from: now)
        guard let currentTime = formatter.date(from: nowTime) else { return false }

        // Handle closing time after midnight
        if closeTime < openTime {
            return currentTime >= openTime || currentTime <= closeTime
        } else {
            return currentTime >= openTime && currentTime <= closeTime
        }
    }

    /// Next opening time if currently closed
    var nextOpeningInfo: String? {
        if isOpenNow {
            return nil
        }

        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let dayName = getDayName(from: weekday)

        // Check if opens later today
        if let todayHours = openingHours[dayName.lowercased()],
           todayHours.lowercased() != "closed" {
            let components = todayHours.split(separator: "-")
            if components.count == 2 {
                return "Opens today at \(components[0])"
            }
        }

        // Find next open day
        for offset in 1...7 {
            let nextDay = calendar.date(byAdding: .day, value: offset, to: now)!
            let nextWeekday = calendar.component(.weekday, from: nextDay)
            let nextDayName = getDayName(from: nextWeekday)

            if let hours = openingHours[nextDayName.lowercased()],
               hours.lowercased() != "closed" {
                return "Opens \(nextDayName)"
            }
        }

        return "Closed"
    }

    /// Helper to get day name from weekday component
    private func getDayName(from weekday: Int) -> String {
        switch weekday {
        case 1: return "Sunday"
        case 2: return "Monday"
        case 3: return "Tuesday"
        case 4: return "Wednesday"
        case 5: return "Thursday"
        case 6: return "Friday"
        case 7: return "Saturday"
        default: return "Monday"
        }
    }

    /// Formatted rating display
    var formattedRating: String {
        return String(format: "%.1f", NSDecimalNumber(decimal: rating).doubleValue)
    }
}

// MARK: - Mock Data
extension Venue {
    /// Generic mock venue (returns Das Wohnzimmer)
    static func mock() -> Venue {
        return mockDasWohnzimmer()
    }

    /// Das Wohnzimmer mock venue with real data
    static func mockDasWohnzimmer() -> Venue {
        return Venue(
            name: "Das Wohnzimmer",
            slug: "das-wohnzimmer",
            type: .barRestaurantClub,
            description: "Wiesbaden's favorite bar, restaurant, and club. Experience great food, drinks, and nightlife in the heart of the city.",
            address: "Schwalbacher Str. 51",
            city: "Wiesbaden",
            postalCode: "65183",
            latitude: 50.0826,
            longitude: 8.2403,
            phone: "+49 (0) 611 ...",
            email: "info@daswz-wiesbaden.com",
            website: "https://daswz-wiesbaden.com/",
            instagram: "@daswohnzimmer_wiesbaden",
            coverImageURL: "https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=800",
            logoURL: nil,
            galleryURLs: [],
            dressCode: "Smart casual",
            ageRequirement: "18+",
            capacity: 150,
            avgSpend: 35.00,
            bestNights: ["Friday", "Saturday"],
            openingHours: [
                "monday": "closed",
                "tuesday": "18:00-01:00",
                "wednesday": "18:00-04:00",
                "thursday": "18:00-01:00",
                "friday": "18:00-04:00",
                "saturday": "15:00-04:00",
                "sunday": "18:00-23:30"
            ],
            memberCount: 847,
            rating: 4.7,
            totalEvents: 24,
            totalPosts: 156
        )
    }
}
