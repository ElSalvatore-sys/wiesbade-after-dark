//
//  VenueViewModel.swift
//  WiesbadenAfterDark
//
//  ViewModel for managing venue discovery and details
//

import Foundation
import SwiftUI
import SwiftData

/// Main venue view model
/// Manages venue discovery, details, events, rewards, and community
@MainActor
@Observable
final class VenueViewModel {
    // MARK: - Dependencies

    private let venueService: VenueServiceProtocol
    private let modelContext: ModelContext?

    // MARK: - Published State

    // Venues
    var venues: [Venue] = []
    var selectedVenue: Venue?

    // Venue details
    var events: [Event] = []
    var rewards: [Reward] = []
    var communityPosts: [CommunityPost] = []
    var membership: VenueMembership?

    // UI State
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Initialization

    init(
        venueService: VenueServiceProtocol = MockVenueService.shared,
        modelContext: ModelContext? = nil
    ) {
        self.venueService = venueService
        self.modelContext = modelContext

        print("🏢 [VenueViewModel] Initialized")
    }

    // MARK: - Venue Discovery Methods

    /// Fetches all venues
    func fetchVenues() async {
        print("🏢 [VenueViewModel] Fetching venues")

        isLoading = true
        errorMessage = nil

        do {
            venues = try await venueService.fetchVenues()
            print("✅ [VenueViewModel] Fetched \(venues.count) venues")

            // Save to SwiftData for offline access
            if let context = modelContext {
                for venue in venues {
                    context.insert(venue)
                }
                try? context.save()
            }

            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            print("❌ [VenueViewModel] Failed to fetch venues: \(error)")
            isLoading = false
        }
    }

    /// Selects a venue and loads its details
    func selectVenue(_ venue: Venue) async {
        print("🏢 [VenueViewModel] Selecting venue: \(venue.name)")

        selectedVenue = venue

        // Load venue details concurrently
        await loadVenueDetails(venueId: venue.id)
    }

    /// Loads all details for a venue (events, rewards, posts, membership)
    private func loadVenueDetails(venueId: UUID) async {
        isLoading = true

        // Load all venue details concurrently
        async let eventsTask = venueService.fetchEvents(venueId: venueId)
        async let rewardsTask = venueService.fetchRewards(venueId: venueId)
        async let postsTask = venueService.fetchCommunityPosts(venueId: venueId)

        do {
            events = try await eventsTask
            rewards = try await rewardsTask
            communityPosts = try await postsTask

            print("✅ [VenueViewModel] Loaded venue details")
            print("   Events: \(events.count)")
            print("   Rewards: \(rewards.count)")
            print("   Posts: \(communityPosts.count)")

            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            print("❌ [VenueViewModel] Failed to load venue details: \(error)")
            isLoading = false
        }
    }

    // MARK: - Membership Methods

    /// Joins a venue (creates membership)
    func joinVenue(userId: UUID) async {
        guard let venue = selectedVenue else {
            print("❌ [VenueViewModel] No venue selected")
            return
        }

        print("🏢 [VenueViewModel] Joining venue: \(venue.name)")

        isLoading = true
        errorMessage = nil

        do {
            membership = try await venueService.joinVenue(venueId: venue.id, userId: userId)
            print("✅ [VenueViewModel] Joined venue successfully")

            // Save to SwiftData
            if let context = modelContext, let membership = membership {
                context.insert(membership)
                try? context.save()
            }

            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            print("❌ [VenueViewModel] Failed to join venue: \(error)")
            isLoading = false
        }
    }

    /// Fetches membership for current user
    func fetchMembership(userId: UUID, venueId: UUID) async {
        do {
            membership = try await venueService.fetchMembership(userId: userId, venueId: venueId)
            if let membership = membership {
                print("✅ [VenueViewModel] Membership found: \(membership.pointsBalance) points")
            }
        } catch {
            print("ℹ️ [VenueViewModel] No membership found")
        }
    }

    // MARK: - Event Methods

    /// RSVPs to an event
    func rsvpEvent(_ event: Event, status: RSVPStatus) async {
        print("🎫 [VenueViewModel] RSVP to event: \(event.title) with status: \(status.rawValue)")

        do {
            try await venueService.rsvpEvent(eventId: event.id, status: status)
            print("✅ [VenueViewModel] RSVP successful")

            // Reload events to get updated counts
            if let venue = selectedVenue {
                events = try await venueService.fetchEvents(venueId: venue.id)
            }

        } catch {
            errorMessage = error.localizedDescription
            print("❌ [VenueViewModel] RSVP failed: \(error)")
        }
    }

    // MARK: - Reward Methods

    /// Redeems a reward
    func redeemReward(_ reward: Reward) async {
        guard let membership = membership else {
            errorMessage = "You must join this venue first"
            print("❌ [VenueViewModel] No membership found")
            return
        }

        guard membership.pointsBalance >= reward.pointsCost else {
            errorMessage = "Insufficient points"
            print("❌ [VenueViewModel] Insufficient points")
            return
        }

        print("🎁 [VenueViewModel] Redeeming reward: \(reward.name)")

        isLoading = true
        errorMessage = nil

        do {
            try await venueService.redeemReward(rewardId: reward.id, membershipId: membership.id)
            print("✅ [VenueViewModel] Reward redeemed successfully")

            // Update membership points (mock)
            var updatedMembership = membership
            updatedMembership.pointsBalance -= reward.pointsCost
            updatedMembership.totalPointsRedeemed += reward.pointsCost
            self.membership = updatedMembership

            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            print("❌ [VenueViewModel] Failed to redeem reward: \(error)")
            isLoading = false
        }
    }

    // MARK: - Community Methods

    /// Likes a community post
    func likePost(_ post: CommunityPost) {
        print("💬 [VenueViewModel] Liking post: \(post.id)")

        // Update post locally (mock)
        if let index = communityPosts.firstIndex(where: { $0.id == post.id }) {
            var updatedPost = communityPosts[index]
            updatedPost.isLikedByCurrentUser.toggle()
            updatedPost.likesCount += updatedPost.isLikedByCurrentUser ? 1 : -1
            communityPosts[index] = updatedPost
        }
    }

    // MARK: - Helper Methods

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }

    /// Reloads venue details
    func refreshVenueDetails() async {
        guard let venue = selectedVenue else { return }
        await loadVenueDetails(venueId: venue.id)
    }
}
