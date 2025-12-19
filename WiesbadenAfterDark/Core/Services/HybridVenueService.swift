//
//  HybridVenueService.swift
//  WiesbadenAfterDark
//
//  Hybrid venue service that tries real backend first, falls back to mock data
//  This ensures the app always has data to display even when offline
//

import Foundation

/// Hybrid venue service with automatic fallback to mock data
/// Tries RealVenueService first, falls back to MockVenueService on failure
final class HybridVenueService: VenueServiceProtocol {
    // MARK: - Properties

    private let realService = RealVenueService.shared
    private let mockService = MockVenueService.shared

    /// Tracks if we're currently using mock data
    private(set) var isUsingMockData = false

    /// Last error from real service (for debugging)
    private(set) var lastRealServiceError: Error?

    // MARK: - Singleton

    static let shared = HybridVenueService()

    private init() {
        #if DEBUG
        print("🔄 [HybridVenueService] Initialized with fallback support")
        #endif
    }

    // MARK: - VenueServiceProtocol Implementation

    /// Fetches all venues - tries real backend first, falls back to mock
    func fetchVenues() async throws -> [Venue] {
        #if DEBUG
        print("🔄 [HybridVenueService] Fetching venues (trying real backend first)")
        #endif

        do {
            let venues = try await realService.fetchVenues()
            isUsingMockData = false
            lastRealServiceError = nil

            #if DEBUG
            print("✅ [HybridVenueService] Got \(venues.count) venues from real backend")
            #endif

            return venues

        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Real backend failed: \(error.localizedDescription)")
            print("🔄 [HybridVenueService] Falling back to mock data...")
            #endif

            lastRealServiceError = error
            isUsingMockData = true

            let venues = try await mockService.fetchVenues()

            #if DEBUG
            print("✅ [HybridVenueService] Got \(venues.count) venues from mock data")
            #endif

            return venues
        }
    }

    /// Fetches a specific venue by ID
    func fetchVenue(id: UUID) async throws -> Venue {
        do {
            let venue = try await realService.fetchVenue(id: id)
            isUsingMockData = false
            return venue
        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Falling back to mock for venue: \(id)")
            #endif
            isUsingMockData = true
            return try await mockService.fetchVenue(id: id)
        }
    }

    /// Fetches events for a venue
    func fetchEvents(venueId: UUID) async throws -> [Event] {
        do {
            let events = try await realService.fetchEvents(venueId: venueId)
            isUsingMockData = false
            return events
        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Falling back to mock for events: \(venueId)")
            #endif
            isUsingMockData = true
            return try await mockService.fetchEvents(venueId: venueId)
        }
    }

    /// Fetches all events
    func fetchAllEvents() async throws -> [Event] {
        do {
            let events = try await realService.fetchAllEvents()
            isUsingMockData = false
            return events
        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Falling back to mock for all events")
            #endif
            isUsingMockData = true
            return try await mockService.fetchAllEvents()
        }
    }

    /// Fetches rewards for a venue
    func fetchRewards(venueId: UUID) async throws -> [Reward] {
        do {
            let rewards = try await realService.fetchRewards(venueId: venueId)
            isUsingMockData = false
            return rewards
        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Falling back to mock for rewards: \(venueId)")
            #endif
            isUsingMockData = true
            return try await mockService.fetchRewards(venueId: venueId)
        }
    }

    /// Fetches community posts for a venue
    func fetchCommunityPosts(venueId: UUID) async throws -> [CommunityPost] {
        do {
            let posts = try await realService.fetchCommunityPosts(venueId: venueId)
            isUsingMockData = false
            return posts
        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Falling back to mock for community: \(venueId)")
            #endif
            isUsingMockData = true
            return try await mockService.fetchCommunityPosts(venueId: venueId)
        }
    }

    /// Joins a venue
    @MainActor
    func joinVenue(venueId: UUID, userId: UUID) async throws -> VenueMembership {
        do {
            let membership = try await realService.joinVenue(venueId: venueId, userId: userId)
            isUsingMockData = false
            return membership
        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Falling back to mock for join venue")
            #endif
            isUsingMockData = true
            return try await mockService.joinVenue(venueId: venueId, userId: userId)
        }
    }

    /// Fetches membership for a user at a venue
    func fetchMembership(userId: UUID, venueId: UUID) async throws -> VenueMembership? {
        do {
            let membership = try await realService.fetchMembership(userId: userId, venueId: venueId)
            isUsingMockData = false
            return membership
        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Falling back to mock for membership")
            #endif
            isUsingMockData = true
            return try await mockService.fetchMembership(userId: userId, venueId: venueId)
        }
    }

    /// RSVPs to an event
    func rsvpEvent(eventId: UUID, status: RSVPStatus) async throws {
        do {
            try await realService.rsvpEvent(eventId: eventId, status: status)
            isUsingMockData = false
        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Falling back to mock for RSVP")
            #endif
            isUsingMockData = true
            try await mockService.rsvpEvent(eventId: eventId, status: status)
        }
    }

    /// Redeems a reward
    func redeemReward(rewardId: UUID, membershipId: UUID) async throws {
        do {
            try await realService.redeemReward(rewardId: rewardId, membershipId: membershipId)
            isUsingMockData = false
        } catch {
            #if DEBUG
            print("⚠️ [HybridVenueService] Falling back to mock for redeem reward")
            #endif
            isUsingMockData = true
            try await mockService.redeemReward(rewardId: rewardId, membershipId: membershipId)
        }
    }
}
