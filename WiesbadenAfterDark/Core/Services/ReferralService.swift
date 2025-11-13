//
//  ReferralService.swift
//  WiesbadenAfterDark
//
//  Service for managing referral chains and processing 25% reward distribution
//

import Foundation

/// Production implementation of ReferralServiceProtocol
final class ReferralService: ReferralServiceProtocol {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = ReferralService()

    /// API client for backend communication
    private let apiClient: APIClient

    /// Reward percentage per level (25%)
    private let rewardPercentage: Decimal = 0.25

    // MARK: - Initialization

    private init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Protocol Implementation

    /// Fetches the referral chain for a specific user from the backend
    /// GET /api/v1/users/{userId}/referrals
    func fetchReferralChain(for userId: UUID) async throws -> ReferralChain {
        #if DEBUG
        print("🔗 [ReferralService] Fetching referral chain for user: \(userId)")
        #endif

        let endpoint = "/api/v1/users/\(userId.uuidString)/referrals"

        do {
            let response: FetchReferralChainResponse = try await apiClient.get(
                endpoint,
                requiresAuth: true
            )

            #if DEBUG
            print("✅ [ReferralService] Successfully fetched referral chain")
            print("   Level 1: \(response.level1?.uuidString ?? "nil")")
            print("   Level 2: \(response.level2?.uuidString ?? "nil")")
            print("   Level 3: \(response.level3?.uuidString ?? "nil")")
            print("   Level 4: \(response.level4?.uuidString ?? "nil")")
            print("   Level 5: \(response.level5?.uuidString ?? "nil")")
            #endif

            // Convert backend response to ReferralChain model
            return ReferralChain(
                userId: response.userId,
                level1ReferrerId: response.level1,
                level2ReferrerId: response.level2,
                level3ReferrerId: response.level3,
                level4ReferrerId: response.level4,
                level5ReferrerId: response.level5
            )
        } catch {
            #if DEBUG
            print("❌ [ReferralService] Failed to fetch referral chain: \(error)")
            #endif
            throw error
        }
    }

    /// Processes rewards for all referrers in the chain when a user earns points
    /// POST /api/v1/referrals/process-rewards
    func processReferralRewards(
        for userId: UUID,
        pointsEarned: Decimal
    ) async throws -> [UUID: Decimal] {
        #if DEBUG
        print("💰 [ReferralService] Processing referral rewards")
        print("   User ID: \(userId)")
        print("   Points Earned: \(pointsEarned)")
        #endif

        let endpoint = "/api/v1/referrals/process-rewards"
        let request = ProcessReferralRewardsRequest(
            userId: userId,
            pointsEarned: pointsEarned
        )

        do {
            let response: ProcessReferralRewardsResponse = try await apiClient.post(
                endpoint,
                body: request,
                requiresAuth: true
            )

            #if DEBUG
            print("✅ [ReferralService] Successfully processed rewards")
            print("   Total Distributed: \(response.totalDistributed)")
            print("   Levels Rewarded: \(response.levelsRewarded)")
            #endif

            // Convert string keys to UUIDs
            var rewardsMap: [UUID: Decimal] = [:]
            for (userIdString, amount) in response.rewards {
                if let uuid = UUID(uuidString: userIdString) {
                    rewardsMap[uuid] = amount
                }
            }

            return rewardsMap
        } catch {
            #if DEBUG
            print("❌ [ReferralService] Failed to process rewards: \(error)")
            #endif
            throw error
        }
    }

    /// Calculates the 25% reward distribution for each level in the referral chain
    /// Algorithm: Each active level receives 25% of the base points earned
    func calculateRewardDistribution(
        pointsEarned: Decimal,
        referralChain: ReferralChain
    ) -> [Int: RewardDistribution] {
        var distributions: [Int: RewardDistribution] = [:]

        // Calculate 25% of points earned
        let rewardAmount = pointsEarned * rewardPercentage

        #if DEBUG
        print("📊 [ReferralService] Calculating reward distribution")
        print("   Base Points: \(pointsEarned)")
        print("   Reward Per Level: \(rewardAmount) (25%)")
        #endif

        // Process each level (1-5)
        for level in 1...5 {
            if let referrerId = referralChain.getReferrerId(forLevel: level) {
                distributions[level] = RewardDistribution(
                    referrerId: referrerId,
                    level: level,
                    rewardAmount: rewardAmount,
                    basePointsEarned: pointsEarned
                )

                #if DEBUG
                print("   Level \(level): \(rewardAmount) → \(referrerId)")
                #endif
            }
        }

        // Calculate total distributed
        let totalDistributed = Decimal(distributions.count) * rewardAmount

        #if DEBUG
        print("   Total Distributed: \(totalDistributed)")
        print("   Levels Rewarded: \(distributions.count)")
        #endif

        return distributions
    }

    /// Updates the local referral chain earnings after successful reward processing
    func updateLocalEarnings(
        referralChain: inout ReferralChain,
        distributions: [Int: RewardDistribution]
    ) {
        #if DEBUG
        print("💾 [ReferralService] Updating local earnings")
        #endif

        for (level, distribution) in distributions {
            referralChain.addEarnings(distribution.rewardAmount, toLevel: level)

            #if DEBUG
            print("   Level \(level): +\(distribution.rewardAmount)")
            #endif
        }

        #if DEBUG
        print("   Total Earnings: \(referralChain.totalEarnings)")
        #endif
    }
}

// MARK: - Mock Service for Testing

/// Mock implementation of ReferralServiceProtocol for testing and previews
final class MockReferralService: ReferralServiceProtocol {
    // MARK: - Mock Data

    var mockReferralChain: ReferralChain?
    var mockRewardsMap: [UUID: Decimal] = [:]
    var shouldThrowError = false
    var mockError: Error?

    // MARK: - Protocol Implementation

    func fetchReferralChain(for userId: UUID) async throws -> ReferralChain {
        if shouldThrowError {
            throw mockError ?? APIError.serverError
        }

        if let mock = mockReferralChain {
            return mock
        }

        // Return a default mock chain
        return ReferralChain(
            userId: userId,
            level1ReferrerId: UUID(),
            level2ReferrerId: UUID(),
            level3ReferrerId: UUID()
        )
    }

    func processReferralRewards(
        for userId: UUID,
        pointsEarned: Decimal
    ) async throws -> [UUID: Decimal] {
        if shouldThrowError {
            throw mockError ?? APIError.serverError
        }

        return mockRewardsMap
    }

    func calculateRewardDistribution(
        pointsEarned: Decimal,
        referralChain: ReferralChain
    ) -> [Int: RewardDistribution] {
        var distributions: [Int: RewardDistribution] = [:]
        let rewardAmount = pointsEarned * 0.25

        for level in 1...5 {
            if let referrerId = referralChain.getReferrerId(forLevel: level) {
                distributions[level] = RewardDistribution(
                    referrerId: referrerId,
                    level: level,
                    rewardAmount: rewardAmount,
                    basePointsEarned: pointsEarned
                )
            }
        }

        return distributions
    }

    func updateLocalEarnings(
        referralChain: inout ReferralChain,
        distributions: [Int: RewardDistribution]
    ) {
        for (level, distribution) in distributions {
            referralChain.addEarnings(distribution.rewardAmount, toLevel: level)
        }
    }
}
