//
//  WiesbadenAPIService.swift
//  WiesbadenAfterDark
//
//  Comprehensive API service for backend integration
//  Created: December 26, 2025
//

import Foundation
import UIKit

/// Comprehensive API service for WiesbadenAfterDark backend
/// Handles venues, posts, bookings, check-ins, and image uploads
@MainActor
final class WiesbadenAPIService {

    // MARK: - Singleton
    static let shared = WiesbadenAPIService()

    // MARK: - Configuration

    private let baseURL = "https://yyplbhrqtaeyzmcxpfli.supabase.co"
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5cGxiaHJxdGFleXptY3hwZmxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwMjMxNTQsImV4cCI6MjA0OTU5OTE1NH0.8S5r4kcXAeBjRs9_lz_7kRxtdBjpTbwFiJWl5SDJbdg"

    // MARK: - Properties

    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    // MARK: - Initialization

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        // Configure decoder
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.jsonDecoder.dateDecodingStrategy = .iso8601

        // Configure encoder
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        self.jsonEncoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Venues API

    func fetchVenues() async throws -> [WiesbadenVenueDTO] {
        guard let url = URL(string: "\(baseURL)/rest/v1/venues?select=*") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            print("❌ [API] Venues fetch failed: \(httpResponse.statusCode)")
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: "Failed to fetch venues")
        }

        let venues = try jsonDecoder.decode([WiesbadenVenueDTO].self, from: data)
        print("✅ [API] Fetched \(venues.count) venues")

        return venues
    }

    func fetchVenue(id: UUID) async throws -> WiesbadenVenueDTO {
        guard let url = URL(string: "\(baseURL)/rest/v1/venues?id=eq.\(id.uuidString)&select=*") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: 404, message: "Venue not found")
        }

        let venues = try jsonDecoder.decode([WiesbadenVenueDTO].self, from: data)

        guard let venue = venues.first else {
            throw APIError.httpError(statusCode: 404, message: "Venue not found")
        }

        return venue
    }

    // MARK: - Posts API

    func createPost(content: String, type: String, venueId: UUID?, imageURL: String?) async throws -> WiesbadenPostDTO {
        guard let url = URL(string: "\(baseURL)/rest/v1/posts") else {
            throw APIError.invalidURL
        }

        let postData: [String: Any?] = [
            "content": content,
            "type": type,
            "venue_id": venueId?.uuidString,
            "image_url": imageURL
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")

        let jsonData = try JSONSerialization.data(withJSONObject: postData.compactMapValues { $0 })
        request.httpBody = jsonData

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.httpError(statusCode: 500, message: "Failed to create post")
        }

        let posts = try jsonDecoder.decode([WiesbadenPostDTO].self, from: data)

        guard let post = posts.first else {
            throw APIError.invalidResponse
        }

        print("✅ [API] Post created: \(post.id)")

        return post
    }

    // MARK: - Image Upload

    func uploadImage(_ image: UIImage, bucket: String = "posts") async throws -> String {
        // Compress image to JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidResponse
        }

        // Generate unique filename
        let filename = "\(UUID().uuidString).jpg"
        let path = "\(bucket)/\(filename)"

        guard let url = URL(string: "\(baseURL)/storage/v1/object/\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            print("❌ [API] Image upload failed: \(httpResponse.statusCode)")
            if let errorMessage = String(data: data, encoding: .utf8) {
                print("Error: \(errorMessage)")
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: "Image upload failed")
        }

        // Construct public URL
        let publicURL = "\(baseURL)/storage/v1/object/public/\(path)"

        print("✅ [API] Image uploaded: \(publicURL)")

        return publicURL
    }

    // MARK: - Check-ins API

    func createCheckIn(venueId: UUID, userId: UUID) async throws -> WiesbadenCheckInDTO {
        guard let url = URL(string: "\(baseURL)/rest/v1/check_ins") else {
            throw APIError.invalidURL
        }

        let checkInData: [String: Any] = [
            "venue_id": venueId.uuidString,
            "user_id": userId.uuidString
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")

        request.httpBody = try JSONSerialization.data(withJSONObject: checkInData)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.httpError(statusCode: 500, message: "Failed to create check-in")
        }

        let checkIns = try jsonDecoder.decode([WiesbadenCheckInDTO].self, from: data)

        guard let checkIn = checkIns.first else {
            throw APIError.invalidResponse
        }

        print("✅ [API] Check-in created: \(checkIn.id)")

        return checkIn
    }

    // MARK: - Bookings API

    func fetchBookings(userId: UUID) async throws -> [WiesbadenBookingDTO] {
        guard let url = URL(string: "\(baseURL)/rest/v1/bookings?user_id=eq.\(userId.uuidString)&select=*") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: 500, message: "Failed to fetch bookings")
        }

        let bookings = try jsonDecoder.decode([WiesbadenBookingDTO].self, from: data)
        print("✅ [API] Fetched \(bookings.count) bookings")

        return bookings
    }

    func createBooking(
        venueId: UUID,
        userId: UUID,
        partySize: Int,
        date: Date,
        notes: String?
    ) async throws -> WiesbadenBookingDTO {
        guard let url = URL(string: "\(baseURL)/rest/v1/bookings") else {
            throw APIError.invalidURL
        }

        let bookingData: [String: Any?] = [
            "venue_id": venueId.uuidString,
            "user_id": userId.uuidString,
            "party_size": partySize,
            "booking_date": ISO8601DateFormatter().string(from: date),
            "notes": notes,
            "status": "pending"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")

        let jsonData = try JSONSerialization.data(withJSONObject: bookingData.compactMapValues { $0 })
        request.httpBody = jsonData

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.httpError(statusCode: 500, message: "Failed to create booking")
        }

        let bookings = try jsonDecoder.decode([WiesbadenBookingDTO].self, from: data)

        guard let booking = bookings.first else {
            throw APIError.invalidResponse
        }

        print("✅ [API] Booking created: \(booking.id)")

        return booking
    }
}

// MARK: - DTOs (Data Transfer Objects)

struct WiesbadenVenueDTO: Codable {
    let id: UUID
    let name: String
    let description: String?
    let imageUrl: String?
    let category: String?
    let address: String?
    let rating: Double?
    let priceLevel: Int?
    let isOpen: Bool?
}

struct WiesbadenPostDTO: Codable {
    let id: UUID
    let content: String
    let type: String
    let venueId: UUID?
    let imageUrl: String?
    let createdAt: Date
}

struct WiesbadenCheckInDTO: Codable {
    let id: UUID
    let venueId: UUID
    let userId: UUID
    let createdAt: Date
}

struct WiesbadenBookingDTO: Codable {
    let id: UUID
    let venueId: UUID
    let userId: UUID
    let partySize: Int
    let bookingDate: Date
    let status: String
    let notes: String?
    let createdAt: Date
}

// Note: Using existing APIError from APIClient.swift
