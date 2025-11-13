//
//  RealVenueService.swift
//  WiesbadenAfterDark
//
//  Production venue service that connects to the backend API
//  Replaces MockVenueService with real API calls and caching
//

import Foundation

/// Production venue service with 5-minute caching strategy
final class RealVenueService: VenueServiceProtocol {
    // MARK: - Properties

    private let apiClient = APIClient.shared

    // Cache properties
    private var cachedVenues: [Venue] = []
    private var cacheTimestamp: Date?
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes

    // Actor for thread-safe cache access
    private let cacheQueue = DispatchQueue(label: "com.wiesbaden.realvenueservice.cache")

    // MARK: - Singleton

    static let shared = RealVenueService()

    private init() {
        #if DEBUG
        print("🏢 [RealVenueService] Initialized with production backend")
        #endif
    }

    // MARK: - VenueServiceProtocol Implementation

    /// Fetches all venues with 5-minute caching
    func fetchVenues() async throws -> [Venue] {
        #if DEBUG
        SecureLogger.shared.info("Fetching all venues", category: "RealVenueService")
        #endif

        // Check cache validity
        if let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheValidityDuration,
           !cachedVenues.isEmpty {
            #if DEBUG
            SecureLogger.shared.info("Returning \(cachedVenues.count) cached venues", category: "RealVenueService")
            #endif
            return cachedVenues
        }

        do {
            // Fetch from backend
            let venueDTOs: [VenueDTO] = try await apiClient.get(
                APIConfig.Endpoints.venues,
                requiresAuth: false
            )

            #if DEBUG
            print("✅ [RealVenueService] Fetched \(venueDTOs.count) venues from backend")
            #endif

            // Convert DTOs to Venue models
            let venues = venueDTOs.compactMap { convertToVenue(from: $0) }

            // Update cache
            cacheQueue.sync {
                self.cachedVenues = venues
                self.cacheTimestamp = Date()
            }

            #if DEBUG
            SecureLogger.shared.success("Cached \(venues.count) venues", category: "RealVenueService")
            #endif

            return venues

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to fetch venues", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    /// Fetches a specific venue by ID
    func fetchVenue(id: UUID) async throws -> Venue {
        #if DEBUG
        SecureLogger.shared.info("Fetching venue: \(id)", category: "RealVenueService")
        #endif

        // Check cache first
        if let cachedVenue = cachedVenues.first(where: { $0.id == id }),
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheValidityDuration {
            #if DEBUG
            SecureLogger.shared.info("Returning cached venue: \(cachedVenue.name)", category: "RealVenueService")
            #endif
            return cachedVenue
        }

        do {
            // Fetch from backend
            let venueDTO: VenueDTO = try await apiClient.get(
                APIConfig.Endpoints.venueDetail(id: id.uuidString),
                requiresAuth: false
            )

            #if DEBUG
            print("✅ [RealVenueService] Fetched venue: \(venueDTO.name)")
            #endif

            // Convert DTO to Venue model
            guard let venue = convertToVenue(from: venueDTO) else {
                throw VenueError.venueNotFound
            }

            // Update cache if this venue exists in cache
            cacheQueue.sync {
                if let index = cachedVenues.firstIndex(where: { $0.id == id }) {
                    cachedVenues[index] = venue
                }
            }

            return venue

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to fetch venue", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    /// Fetches events for a specific venue
    func fetchEvents(venueId: UUID) async throws -> [Event] {
        #if DEBUG
        SecureLogger.shared.info("Fetching events for venue: \(venueId)", category: "RealVenueService")
        #endif

        do {
            let eventDTOs: [EventDTO] = try await apiClient.get(
                APIConfig.Endpoints.venueEvents(id: venueId.uuidString),
                requiresAuth: false
            )

            #if DEBUG
            print("✅ [RealVenueService] Fetched \(eventDTOs.count) events")
            #endif

            // Convert DTOs to Event models
            let events = eventDTOs.compactMap { convertToEvent(from: $0) }
            return events

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to fetch events", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    /// Fetches all events from all venues
    func fetchAllEvents() async throws -> [Event] {
        #if DEBUG
        SecureLogger.shared.info("Fetching all events across all venues", category: "RealVenueService")
        #endif

        do {
            let eventDTOs: [EventDTO] = try await apiClient.get(
                "/api/v1/events",
                requiresAuth: false
            )

            #if DEBUG
            print("✅ [RealVenueService] Fetched \(eventDTOs.count) events")
            #endif

            // Convert DTOs to Event models
            let events = eventDTOs.compactMap { convertToEvent(from: $0) }
            return events

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to fetch all events", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    /// Fetches rewards for a specific venue
    func fetchRewards(venueId: UUID) async throws -> [Reward] {
        #if DEBUG
        SecureLogger.shared.info("Fetching rewards for venue: \(venueId)", category: "RealVenueService")
        #endif

        do {
            let rewardDTOs: [RewardDTO] = try await apiClient.get(
                APIConfig.Endpoints.venueRewards(id: venueId.uuidString),
                requiresAuth: true
            )

            #if DEBUG
            print("✅ [RealVenueService] Fetched \(rewardDTOs.count) rewards")
            #endif

            // Convert DTOs to Reward models
            let rewards = rewardDTOs.compactMap { convertToReward(from: $0) }
            return rewards

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to fetch rewards", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    /// Fetches community posts for a specific venue
    func fetchCommunityPosts(venueId: UUID) async throws -> [CommunityPost] {
        #if DEBUG
        SecureLogger.shared.info("Fetching community posts for venue: \(venueId)", category: "RealVenueService")
        #endif

        do {
            let postDTOs: [CommunityPostDTO] = try await apiClient.get(
                APIConfig.Endpoints.venueCommunity(id: venueId.uuidString),
                requiresAuth: false
            )

            #if DEBUG
            print("✅ [RealVenueService] Fetched \(postDTOs.count) community posts")
            #endif

            // Convert DTOs to CommunityPost models
            let posts = postDTOs.compactMap { convertToCommunityPost(from: $0) }
            return posts

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to fetch community posts", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    /// Joins a venue (creates membership)
    @MainActor
    func joinVenue(venueId: UUID, userId: UUID) async throws -> VenueMembership {
        #if DEBUG
        SecureLogger.shared.info("Joining venue: \(venueId) for user: \(userId)", category: "RealVenueService")
        #endif

        struct JoinRequest: Encodable {
            let userId: UUID
        }

        do {
            let membershipDTO: VenueMembershipDTO = try await apiClient.post(
                APIConfig.Endpoints.joinVenue(id: venueId.uuidString),
                body: JoinRequest(userId: userId),
                requiresAuth: true
            )

            #if DEBUG
            print("✅ [RealVenueService] Membership created")
            #endif

            // Convert DTO to VenueMembership model
            guard let membership = convertToVenueMembership(from: membershipDTO) else {
                throw VenueError.unknownError
            }

            return membership

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to join venue", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    /// RSVPs to an event
    func rsvpEvent(eventId: UUID, status: RSVPStatus) async throws {
        #if DEBUG
        SecureLogger.shared.info("RSVP to event: \(eventId) with status: \(status.rawValue)", category: "RealVenueService")
        #endif

        struct RSVPRequest: Encodable {
            let status: String
        }

        do {
            try await apiClient.post(
                APIConfig.Endpoints.rsvpEvent(id: eventId.uuidString),
                body: RSVPRequest(status: status.rawValue),
                requiresAuth: true
            )

            #if DEBUG
            SecureLogger.shared.success("RSVP successful", category: "RealVenueService")
            #endif

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to RSVP event", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    /// Fetches user's membership for a venue
    func fetchMembership(userId: UUID, venueId: UUID) async throws -> VenueMembership? {
        #if DEBUG
        SecureLogger.shared.info("Fetching membership for user: \(userId) at venue: \(venueId)", category: "RealVenueService")
        #endif

        do {
            let membershipDTO: VenueMembershipDTO = try await apiClient.get(
                APIConfig.Endpoints.venueMembership(venueId: venueId.uuidString, userId: userId.uuidString),
                requiresAuth: true
            )

            #if DEBUG
            print("✅ [RealVenueService] Membership found")
            #endif

            // Convert DTO to VenueMembership model
            return convertToVenueMembership(from: membershipDTO)

        } catch let error as APIError {
            if case .httpError(let statusCode, _) = error, statusCode == 404 {
                // Membership not found - return nil
                return nil
            }
            #if DEBUG
            SecureLogger.shared.error("Failed to fetch membership", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    /// Redeems a reward
    func redeemReward(rewardId: UUID, membershipId: UUID) async throws {
        #if DEBUG
        SecureLogger.shared.info("Redeeming reward: \(rewardId)", category: "RealVenueService")
        #endif

        struct RedeemRequest: Encodable {
            let membershipId: UUID
        }

        do {
            try await apiClient.post(
                APIConfig.Endpoints.redeemReward(id: rewardId.uuidString),
                body: RedeemRequest(membershipId: membershipId),
                requiresAuth: true
            )

            #if DEBUG
            SecureLogger.shared.success("Reward redeemed successfully", category: "RealVenueService")
            #endif

        } catch let error as APIError {
            #if DEBUG
            SecureLogger.shared.error("Failed to redeem reward", error: error, category: "RealVenueService")
            #endif
            throw mapAPIError(error)
        } catch {
            throw VenueError.networkError(error)
        }
    }

    // MARK: - Helper Methods

    /// Invalidates the venue cache
    func invalidateCache() {
        cacheQueue.sync {
            cachedVenues.removeAll()
            cacheTimestamp = nil
        }
        #if DEBUG
        print("🗑️ [RealVenueService] Cache invalidated")
        #endif
    }

    /// Maps APIError to VenueError
    private func mapAPIError(_ error: APIError) -> VenueError {
        switch error {
        case .httpError(let statusCode, let message):
            switch statusCode {
            case 404:
                return .venueNotFound
            case 400:
                if let message = message, message.lowercased().contains("points") {
                    return .insufficientPoints
                } else if let message = message, message.lowercased().contains("unavailable") {
                    return .rewardUnavailable
                }
                return .serverError(message ?? "Bad request")
            case 409:
                return .alreadyMember
            default:
                return .serverError(message ?? "Server error")
            }
        case .networkError(let underlyingError):
            return .networkError(underlyingError)
        default:
            return .unknownError
        }
    }

    /// Converts VenueDTO to Venue model
    private func convertToVenue(from dto: VenueDTO) -> Venue? {
        // Note: Backend may send margin fields (foodMarginPercent, beverageMarginPercent, defaultMarginPercent)
        // but they are not part of the Venue model, so we ignore them during conversion

        return Venue(
            id: dto.id,
            name: dto.name,
            slug: dto.slug ?? dto.name.lowercased().replacingOccurrences(of: " ", with: "-"),
            type: VenueType(rawValue: dto.type ?? "Bar") ?? .bar,
            description: dto.description ?? "",
            address: dto.address,
            city: dto.city,
            postalCode: dto.postalCode ?? "",
            latitude: dto.latitude,
            longitude: dto.longitude,
            phone: dto.phone,
            email: dto.email,
            website: dto.website,
            instagram: dto.instagram,
            coverImageURL: dto.imageUrl,
            logoURL: dto.logoUrl,
            galleryURLs: dto.galleryUrls ?? [],
            dressCode: dto.dressCode,
            ageRequirement: dto.ageRequirement,
            capacity: dto.capacity,
            avgSpend: Decimal(dto.avgSpend ?? 0.0),
            bestNights: dto.bestNights ?? [],
            openingHours: dto.openingHours ?? [:],
            memberCount: dto.memberCount ?? 0,
            rating: Decimal(dto.rating ?? 0.0),
            totalEvents: dto.totalEvents ?? 0,
            totalPosts: dto.totalPosts ?? 0,
            createdAt: dto.createdAt ?? Date(),
            updatedAt: dto.updatedAt ?? Date()
        )
    }

    /// Converts EventDTO to Event model (placeholder - needs Event model details)
    private func convertToEvent(from dto: EventDTO) -> Event? {
        // Implementation depends on Event model structure
        // This is a placeholder that should be implemented based on actual Event model
        return nil
    }

    /// Converts RewardDTO to Reward model (placeholder - needs Reward model details)
    private func convertToReward(from dto: RewardDTO) -> Reward? {
        // Implementation depends on Reward model structure
        // This is a placeholder that should be implemented based on actual Reward model
        return nil
    }

    /// Converts CommunityPostDTO to CommunityPost model (placeholder - needs CommunityPost model details)
    private func convertToCommunityPost(from dto: CommunityPostDTO) -> CommunityPost? {
        // Implementation depends on CommunityPost model structure
        // This is a placeholder that should be implemented based on actual CommunityPost model
        return nil
    }

    /// Converts VenueMembershipDTO to VenueMembership model (placeholder - needs VenueMembership model details)
    private func convertToVenueMembership(from dto: VenueMembershipDTO) -> VenueMembership? {
        // Implementation depends on VenueMembership model structure
        // This is a placeholder that should be implemented based on actual VenueMembership model
        return nil
    }
}

// MARK: - DTO Models

/// Data Transfer Object for Venue API responses
private struct VenueDTO: Decodable {
    let id: UUID
    let name: String
    let slug: String?
    let type: String?
    let description: String?
    let address: String
    let city: String
    let postalCode: String?
    let latitude: Double?
    let longitude: Double?
    let phone: String?
    let email: String?
    let website: String?
    let instagram: String?
    let imageUrl: String?
    let logoUrl: String?
    let galleryUrls: [String]?
    let dressCode: String?
    let ageRequirement: String?
    let capacity: Int?
    let avgSpend: Double?
    let bestNights: [String]?
    let openingHours: [String: String]?
    let memberCount: Int?
    let rating: Double?
    let totalEvents: Int?
    let totalPosts: Int?
    let createdAt: Date?
    let updatedAt: Date?

    // Margin fields from backend (not used in Venue model)
    let foodMarginPercent: Double?
    let beverageMarginPercent: Double?
    let defaultMarginPercent: Double?
}

/// Data Transfer Object for Event API responses
private struct EventDTO: Decodable {
    let id: UUID
    let venueId: UUID
    let name: String
    let description: String?
    let startTime: Date
    let endTime: Date?
    let imageUrl: String?
    let attendingCount: Int?
    let interestedCount: Int?
}

/// Data Transfer Object for Reward API responses
private struct RewardDTO: Decodable {
    let id: UUID
    let venueId: UUID
    let name: String
    let description: String?
    let pointsCost: Int
    let isAvailable: Bool
    let imageUrl: String?
}

/// Data Transfer Object for CommunityPost API responses
private struct CommunityPostDTO: Decodable {
    let id: UUID
    let venueId: UUID
    let userId: UUID
    let content: String
    let imageUrl: String?
    let likesCount: Int
    let commentsCount: Int
    let createdAt: Date
}

/// Data Transfer Object for VenueMembership API responses
private struct VenueMembershipDTO: Decodable {
    let id: UUID
    let userId: UUID
    let venueId: UUID
    let pointsBalance: Double
    let tier: String
    let joinedAt: Date
}
