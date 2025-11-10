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

    /// Park Café - High-end nightclub
    static func mockParkCafe() -> Venue {
        return Venue(
            name: "Park Café",
            slug: "park-cafe",
            type: .club,
            description: "Wiesbaden's premier high-end nightclub with strict dress code and downtown glamour",
            address: "Wilhelmstraße 36",
            city: "Wiesbaden",
            postalCode: "65183",
            latitude: 50.0837,
            longitude: 8.2400,
            phone: "+49 611 308080",
            email: nil,
            website: "https://parkcafe-wiesbaden.de",
            instagram: nil,
            coverImageURL: "https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?w=800",
            logoURL: nil,
            galleryURLs: [],
            dressCode: "Strict dress code",
            ageRequirement: "21+",
            capacity: 300,
            avgSpend: 60.00,
            bestNights: ["Thursday", "Friday", "Saturday"],
            openingHours: [
                "monday": "closed",
                "tuesday": "closed",
                "wednesday": "closed",
                "thursday": "22:00-04:00",
                "friday": "22:00-04:00",
                "saturday": "22:00-04:00",
                "sunday": "closed"
            ],
            memberCount: 1247,
            rating: 4.7,
            totalEvents: 18,
            totalPosts: 89
        )
    }

    /// Harput Restaurant - Turkish Grill & Steakhouse
    static func mockHarput() -> Venue {
        return Venue(
            name: "Harput Restaurant",
            slug: "harput",
            type: .restaurant,
            description: "Renowned Turkish restaurant and grill house serving authentic Anatolian cuisine",
            address: "Wellritzstraße 9",
            city: "Wiesbaden",
            postalCode: "65183",
            latitude: 50.0817,
            longitude: 8.2425,
            phone: "+49 611 406196",
            email: nil,
            website: "https://harputrestaurant.de",
            instagram: nil,
            coverImageURL: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800",
            logoURL: nil,
            galleryURLs: [],
            dressCode: "Casual",
            ageRequirement: "All ages",
            capacity: 120,
            avgSpend: 28.00,
            bestNights: ["Friday", "Saturday", "Sunday"],
            openingHours: [
                "monday": "07:00-01:00",
                "tuesday": "07:00-01:00",
                "wednesday": "07:00-01:00",
                "thursday": "07:00-01:00",
                "friday": "07:00-01:00",
                "saturday": "07:00-01:00",
                "sunday": "07:00-01:00"
            ],
            memberCount: 892,
            rating: 4.3,
            totalEvents: 12,
            totalPosts: 67
        )
    }

    /// Ente - Michelin Star Fine Dining
    static func mockEnte() -> Venue {
        return Venue(
            name: "Ente",
            slug: "ente",
            type: .restaurant,
            description: "Michelin-starred restaurant at Nassauer Hof offering exquisite French-inspired cuisine",
            address: "Kaiser-Friedrich-Platz 3-4",
            city: "Wiesbaden",
            postalCode: "65183",
            latitude: 50.0834,
            longitude: 8.2434,
            phone: "+49 611 133666",
            email: nil,
            website: "https://www.hommage-hotels.com/nassauer-hof-wiesbaden/dining/ente-restaurant",
            instagram: nil,
            coverImageURL: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800",
            logoURL: nil,
            galleryURLs: [],
            dressCode: "Formal dress code",
            ageRequirement: "All ages",
            capacity: 50,
            avgSpend: 150.00,
            bestNights: ["Wednesday", "Friday", "Saturday"],
            openingHours: [
                "monday": "closed",
                "tuesday": "closed",
                "wednesday": "18:30-22:00",
                "thursday": "18:30-22:00",
                "friday": "18:30-22:00",
                "saturday": "18:30-22:00",
                "sunday": "closed"
            ],
            memberCount: 456,
            rating: 4.9,
            totalEvents: 8,
            totalPosts: 34
        )
    }

    /// Hotel am Kochbrunnen - Boutique Hotel
    static func mockHotelKochbrunnen() -> Venue {
        return Venue(
            name: "Hotel am Kochbrunnen",
            slug: "hotel-kochbrunnen",
            type: .hotel,
            description: "Charming 3-star boutique hotel in the heart of Wiesbaden with Middle Eastern restaurant",
            address: "Taunusstraße 15",
            city: "Wiesbaden",
            postalCode: "65183",
            latitude: 50.0849,
            longitude: 8.2445,
            phone: "+49 611 98828300",
            email: nil,
            website: "https://hotelamkochbrunnen.de",
            instagram: nil,
            coverImageURL: "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800",
            logoURL: nil,
            galleryURLs: [],
            dressCode: "Casual",
            ageRequirement: "All ages",
            capacity: 80,
            avgSpend: 40.00,
            bestNights: ["Friday", "Saturday"],
            openingHours: [
                "monday": "00:00-23:59",
                "tuesday": "00:00-23:59",
                "wednesday": "00:00-23:59",
                "thursday": "00:00-23:59",
                "friday": "00:00-23:59",
                "saturday": "00:00-23:59",
                "sunday": "00:00-23:59"
            ],
            memberCount: 334,
            rating: 4.1,
            totalEvents: 6,
            totalPosts: 23
        )
    }

    /// Euro Palace - Mega Nightclub
    static func mockEuroPalace() -> Venue {
        return Venue(
            name: "Euro Palace",
            slug: "euro-palace",
            type: .club,
            description: "Wiesbaden's largest nightclub with multiple dance floors featuring techno, hip-hop, and more",
            address: "Mainz-Kastel Area",
            city: "Wiesbaden",
            postalCode: "65203",
            latitude: 50.0121,
            longitude: 8.2756,
            phone: "+49 611 7777777",
            email: nil,
            website: "https://europalace-wiesbaden.de",
            instagram: nil,
            coverImageURL: "https://images.unsplash.com/photo-1571266028243-d220c2925d90?w=800",
            logoURL: nil,
            galleryURLs: [],
            dressCode: "Smart casual",
            ageRequirement: "18+",
            capacity: 800,
            avgSpend: 45.00,
            bestNights: ["Friday", "Saturday"],
            openingHours: [
                "monday": "closed",
                "tuesday": "closed",
                "wednesday": "closed",
                "thursday": "closed",
                "friday": "23:00-06:00",
                "saturday": "23:00-06:00",
                "sunday": "closed"
            ],
            memberCount: 2156,
            rating: 4.4,
            totalEvents: 32,
            totalPosts: 198
        )
    }

    /// Villa im Tal - Fine Dining Villa
    static func mockVillaImTal() -> Venue {
        return Venue(
            name: "Villa im Tal",
            slug: "villa-im-tal",
            type: .restaurant,
            description: "Romantic fine dining in a historic half-timbered villa surrounded by woodlands",
            address: "Rambacher Straße 200",
            city: "Wiesbaden",
            postalCode: "65193",
            latitude: 50.0456,
            longitude: 8.2789,
            phone: "+49 611 400680",
            email: nil,
            website: "https://villaimtal.de",
            instagram: nil,
            coverImageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
            logoURL: nil,
            galleryURLs: [],
            dressCode: "Smart casual",
            ageRequirement: "All ages",
            capacity: 60,
            avgSpend: 85.00,
            bestNights: ["Friday", "Saturday"],
            openingHours: [
                "monday": "closed",
                "tuesday": "18:00-23:00",
                "wednesday": "18:00-23:00",
                "thursday": "18:00-23:00",
                "friday": "18:00-23:00",
                "saturday": "18:00-23:00",
                "sunday": "closed"
            ],
            memberCount: 523,
            rating: 4.8,
            totalEvents: 10,
            totalPosts: 45
        )
    }

    /// Kulturpalast - Cultural Venue & Events
    static func mockKulturpalast() -> Venue {
        return Venue(
            name: "Kulturpalast",
            slug: "kulturpalast",
            type: .bar,
            description: "Multi-purpose cultural venue hosting concerts, events, and nightlife entertainment",
            address: "Friedrichstraße 16",
            city: "Wiesbaden",
            postalCode: "65185",
            latitude: 50.0812,
            longitude: 8.2398,
            phone: "+49 611 9887766",
            email: nil,
            website: "https://kulturpalast-wiesbaden.de",
            instagram: nil,
            coverImageURL: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800",
            logoURL: nil,
            galleryURLs: [],
            dressCode: "Casual",
            ageRequirement: "18+",
            capacity: 400,
            avgSpend: 30.00,
            bestNights: ["Friday", "Saturday"],
            openingHours: [
                "monday": "closed",
                "tuesday": "closed",
                "wednesday": "19:00-02:00",
                "thursday": "19:00-02:00",
                "friday": "19:00-04:00",
                "saturday": "19:00-04:00",
                "sunday": "closed"
            ],
            memberCount: 1089,
            rating: 4.6,
            totalEvents: 26,
            totalPosts: 112
        )
    }
}
