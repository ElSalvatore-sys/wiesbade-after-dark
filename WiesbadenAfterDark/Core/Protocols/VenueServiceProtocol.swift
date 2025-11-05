//
//  VenueServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Core protocol for venue operations
//  Enables dependency injection and easy testing
//

import Foundation

/// RSVP status for events
enum RSVPStatus: String, Codable {
    case going = "Going"
    case interested = "Interested"
    case notGoing = "Not Going"
}

/// Defines the contract for venue services
/// This protocol allows us to swap between mock and real implementations
protocol VenueServiceProtocol {
    /// Fetches all venues
    /// - Returns: Array of venues
    /// - Throws: VenueError if the request fails
    func fetchVenues() async throws -> [Venue]

    /// Fetches a specific venue by ID
    /// - Parameter id: Venue UUID
    /// - Returns: Venue object
    /// - Throws: VenueError if venue not found
    func fetchVenue(id: UUID) async throws -> Venue

    /// Fetches events for a specific venue
    /// - Parameter venueId: Venue UUID
    /// - Returns: Array of events
    /// - Throws: VenueError if the request fails
    func fetchEvents(venueId: UUID) async throws -> [Event]

    /// Fetches rewards for a specific venue
    /// - Parameter venueId: Venue UUID
    /// - Returns: Array of rewards
    /// - Throws: VenueError if the request fails
    func fetchRewards(venueId: UUID) async throws -> [Reward]

    /// Fetches community posts for a specific venue
    /// - Parameter venueId: Venue UUID
    /// - Returns: Array of community posts
    /// - Throws: VenueError if the request fails
    func fetchCommunityPosts(venueId: UUID) async throws -> [CommunityPost]

    /// Joins a venue (creates membership)
    /// - Parameter venueId: Venue UUID
    /// - Returns: VenueMembership object
    /// - Throws: VenueError if join fails
    @MainActor func joinVenue(venueId: UUID, userId: UUID) async throws -> VenueMembership

    /// RSVPs to an event
    /// - Parameters:
    ///   - eventId: Event UUID
    ///   - status: RSVP status (going/interested/not going)
    /// - Throws: VenueError if RSVP fails
    func rsvpEvent(eventId: UUID, status: RSVPStatus) async throws

    /// Fetches user's membership for a venue
    /// - Parameters:
    ///   - userId: User UUID
    ///   - venueId: Venue UUID
    /// - Returns: VenueMembership if exists, nil otherwise
    /// - Throws: VenueError if the request fails
    func fetchMembership(userId: UUID, venueId: UUID) async throws -> VenueMembership?

    /// Redeems a reward
    /// - Parameters:
    ///   - rewardId: Reward UUID
    ///   - membershipId: VenueMembership UUID
    /// - Throws: VenueError if redemption fails
    func redeemReward(rewardId: UUID, membershipId: UUID) async throws
}

/// Custom errors for venue operations
enum VenueError: LocalizedError {
    case venueNotFound
    case eventNotFound
    case insufficientPoints
    case rewardUnavailable
    case alreadyMember
    case networkError(Error)
    case serverError(String)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .venueNotFound:
            return "Venue not found"
        case .eventNotFound:
            return "Event not found"
        case .insufficientPoints:
            return "Insufficient points for this reward"
        case .rewardUnavailable:
            return "This reward is currently unavailable"
        case .alreadyMember:
            return "You're already a member of this venue"
        case .networkError:
            return "Connection error. Please check your internet."
        case .serverError(let message):
            return message
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
}
