//
//  ReferralServiceProtocol.swift
//  WiesbadenAfterDark
//
//  Protocol defining referral chain and reward distribution functionality
//

import Foundation

/// Protocol for managing referral chains and reward distribution
protocol ReferralServiceProtocol {
    /// Fetches the referral chain for a specific user from the backend
    /// - Parameter userId: The user ID to fetch the referral chain for
    /// - Returns: A ReferralChain object with all referrer levels populated
    /// - Throws: APIError if the request fails
    func fetchReferralChain(for userId: UUID) async throws -> ReferralChain

    /// Processes rewards for all referrers in the chain when a user earns points
    /// - Parameters:
    ///   - userId: The user ID who earned the points
    ///   - pointsEarned: The amount of points earned by the user
    /// - Returns: Dictionary mapping referrer IDs to the reward amount they received
    /// - Throws: APIError if the request fails
    func processReferralRewards(
        for userId: UUID,
        pointsEarned: Decimal
    ) async throws -> [UUID: Decimal]

    /// Calculates the reward distribution for a given point amount
    /// - Parameters:
    ///   - pointsEarned: The base points earned
    ///   - referralChain: The referral chain with up to 5 levels
    /// - Returns: Dictionary mapping level (1-5) to reward amount
    func calculateRewardDistribution(
        pointsEarned: Decimal,
        referralChain: ReferralChain
    ) -> [Int: RewardDistribution]

    /// Updates the local referral chain earnings after successful reward processing
    /// - Parameters:
    ///   - referralChain: The referral chain to update
    ///   - distributions: The reward distributions that were processed
    func updateLocalEarnings(
        referralChain: inout ReferralChain,
        distributions: [Int: RewardDistribution]
    )
}

/// Represents a reward distribution for a single referrer level
struct RewardDistribution: Codable, Sendable {
    /// The referrer ID receiving the reward
    let referrerId: UUID

    /// The level in the referral chain (1-5)
    let level: Int

    /// The reward amount (25% of points earned)
    let rewardAmount: Decimal

    /// The original points earned that triggered this reward
    let basePointsEarned: Decimal
}

// MARK: - Backend Request/Response Models

/// Request model for processing referral rewards
struct ProcessReferralRewardsRequest: Codable, Sendable {
    let userId: UUID
    let pointsEarned: Decimal
}

/// Response model for processing referral rewards
struct ProcessReferralRewardsResponse: Codable, Sendable {
    /// Dictionary mapping referrer user IDs to reward amounts
    let rewards: [String: Decimal]

    /// Total rewards distributed across all levels
    let totalDistributed: Decimal

    /// Number of levels that received rewards
    let levelsRewarded: Int
}

/// Response model for fetching a user's referral chain
struct FetchReferralChainResponse: Codable, Sendable {
    let userId: UUID
    let level1: UUID?
    let level2: UUID?
    let level3: UUID?
    let level4: UUID?
    let level5: UUID?
}
