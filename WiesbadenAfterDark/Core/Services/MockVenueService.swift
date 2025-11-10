//
//  MockVenueService.swift
//  WiesbadenAfterDark
//
//  Mock implementation of VenueServiceProtocol for testing
//  This will be replaced with real API calls once backend is deployed
//

import Foundation

/// Mock venue service for development and testing
/// Always returns successful responses with simulated delays
final class MockVenueService: VenueServiceProtocol {
    // MARK: - Properties

    /// Simulated network delay in seconds
    private let networkDelay: TimeInterval = 1.0

    /// All cached venues
    private lazy var allVenues: [Venue] = [
        Venue.mockDasWohnzimmer(),
        Venue.mockParkCafe(),
        Venue.mockHarput(),
        Venue.mockEnte(),
        Venue.mockHotelKochbrunnen(),
        Venue.mockEuroPalace(),
        Venue.mockVillaImTal(),
        Venue.mockKulturpalast()
    ]

    /// Cached Das Wohnzimmer venue for backward compatibility
    private var dasWohnzimmer: Venue { allVenues[0] }

    /// All events across all venues
    private lazy var allEvents: [Event] = {
        let venueMap = Dictionary(uniqueKeysWithValues: allVenues.map { ($0.id, $0.name) })
        return Event.mockAllEvents(venues: venueMap)
    }()

    /// Cached events for Das Wohnzimmer (backward compatibility)
    private lazy var events: [Event] = Event.mockEventsForVenue(dasWohnzimmer.id)

    /// Cached rewards
    private lazy var rewards: [Reward] = Reward.mockRewardsForVenue(dasWohnzimmer.id)

    /// Cached community posts
    private lazy var posts: [CommunityPost] = CommunityPost.mockPostsForVenue(dasWohnzimmer.id)

    // MARK: - Singleton
    static let shared = MockVenueService()

    private init() {}

    // MARK: - VenueServiceProtocol Implementation

    /// Fetches all venues
    func fetchVenues() async throws -> [Venue] {
        print("🏢 [MockVenueService] Fetching all venues")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        print("✅ [MockVenueService] Returned \(allVenues.count) venues")
        return allVenues
    }

    /// Fetches a specific venue by ID
    func fetchVenue(id: UUID) async throws -> Venue {
        print("🏢 [MockVenueService] Fetching venue: \(id)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        guard let venue = allVenues.first(where: { $0.id == id }) else {
            print("❌ [MockVenueService] Venue not found")
            throw VenueError.venueNotFound
        }

        print("✅ [MockVenueService] Returned \(venue.name)")
        return venue
    }

    /// Fetches events for a venue
    func fetchEvents(venueId: UUID) async throws -> [Event] {
        print("🎉 [MockVenueService] Fetching events for venue: \(venueId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Check if venue exists
        guard allVenues.contains(where: { $0.id == venueId }) else {
            print("❌ [MockVenueService] Venue not found")
            throw VenueError.venueNotFound
        }

        // Filter events for this specific venue
        let venueEvents = allEvents.filter { $0.venueId == venueId }
        print("✅ [MockVenueService] Returned \(venueEvents.count) events")
        return venueEvents
    }

    /// Fetches all events from all venues
    func fetchAllEvents() async throws -> [Event] {
        print("🎉 [MockVenueService] Fetching all events across all venues")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        print("✅ [MockVenueService] Returned \(allEvents.count) events")
        return allEvents
    }

    /// Fetches rewards for a venue
    func fetchRewards(venueId: UUID) async throws -> [Reward] {
        print("🎁 [MockVenueService] Fetching rewards for venue: \(venueId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        guard venueId == dasWohnzimmer.id else {
            print("❌ [MockVenueService] Venue not found")
            throw VenueError.venueNotFound
        }

        print("✅ [MockVenueService] Returned \(rewards.count) rewards")
        return rewards
    }

    /// Fetches community posts for a venue
    func fetchCommunityPosts(venueId: UUID) async throws -> [CommunityPost] {
        print("💬 [MockVenueService] Fetching posts for venue: \(venueId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        guard venueId == dasWohnzimmer.id else {
            print("❌ [MockVenueService] Venue not found")
            throw VenueError.venueNotFound
        }

        print("✅ [MockVenueService] Returned \(posts.count) posts")
        return posts
    }

    /// Joins a venue (creates membership)
    @MainActor
    func joinVenue(venueId: UUID, userId: UUID) async throws -> VenueMembership {
        print("👤 [MockVenueService] Joining venue: \(venueId) for user: \(userId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        guard venueId == dasWohnzimmer.id else {
            print("❌ [MockVenueService] Venue not found")
            throw VenueError.venueNotFound
        }

        // Create new membership
        let membership = VenueMembership.mockMembership(userId: userId, venueId: venueId)
        print("✅ [MockVenueService] Membership created with \(membership.pointsBalance) points")

        return membership
    }

    /// RSVPs to an event
    func rsvpEvent(eventId: UUID, status: RSVPStatus) async throws {
        print("🎫 [MockVenueService] RSVP to event: \(eventId) with status: \(status.rawValue)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Find the event
        guard let eventIndex = events.firstIndex(where: { $0.id == eventId }) else {
            print("❌ [MockVenueService] Event not found")
            throw VenueError.eventNotFound
        }

        // Update attendance count (mock)
        var event = events[eventIndex]
        switch status {
        case .going:
            event.attendingCount += 1
            print("✅ [MockVenueService] Marked as going. New count: \(event.attendingCount)")
        case .interested:
            event.interestedCount += 1
            print("✅ [MockVenueService] Marked as interested. New count: \(event.interestedCount)")
        case .notGoing:
            print("✅ [MockVenueService] Removed RSVP")
        }

        events[eventIndex] = event
    }

    /// Fetches user's membership for a venue
    func fetchMembership(userId: UUID, venueId: UUID) async throws -> VenueMembership? {
        print("👤 [MockVenueService] Fetching membership for user: \(userId) at venue: \(venueId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        guard venueId == dasWohnzimmer.id else {
            print("❌ [MockVenueService] Venue not found")
            throw VenueError.venueNotFound
        }

        // For mock purposes, return a membership if user is authenticated
        // In real app, this would query the database
        let membership = VenueMembership.mockMembership(userId: userId, venueId: venueId)
        print("✅ [MockVenueService] Membership found: \(membership.tier.displayName) tier")

        return membership
    }

    /// Redeems a reward
    func redeemReward(rewardId: UUID, membershipId: UUID) async throws {
        print("🎁 [MockVenueService] Redeeming reward: \(rewardId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        guard let reward = rewards.first(where: { $0.id == rewardId }) else {
            print("❌ [MockVenueService] Reward not found")
            throw VenueError.venueNotFound
        }

        // Check availability
        guard reward.isAvailable else {
            print("❌ [MockVenueService] Reward unavailable")
            throw VenueError.rewardUnavailable
        }

        // In real app, would check user's points balance
        print("✅ [MockVenueService] Reward redeemed: \(reward.name)")
    }
}
