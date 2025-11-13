//
//  ReferralServiceTests.swift
//  WiesbadenAfterDarkTests
//
//  Unit tests for ReferralService reward calculation algorithms
//

import XCTest
import Foundation
@testable import WiesbadenAfterDark

final class ReferralServiceTests: XCTestCase {
    // MARK: - Properties

    var sut: MockReferralService!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = MockReferralService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Reward Distribution Tests

    /// Test that 25% reward is calculated correctly for a single level
    func testRewardDistribution_SingleLevel() {
        // Given
        let userId = UUID()
        let referrerId = UUID()
        let pointsEarned: Decimal = 10.0
        let expectedReward: Decimal = 2.5 // 25% of 10

        let referralChain = ReferralChain(
            userId: userId,
            level1ReferrerId: referrerId
        )

        // When
        let distributions = sut.calculateRewardDistribution(
            pointsEarned: pointsEarned,
            referralChain: referralChain
        )

        // Then
        XCTAssertEqual(distributions.count, 1, "Should have 1 distribution")
        XCTAssertNotNil(distributions[1], "Level 1 should have a distribution")
        XCTAssertEqual(distributions[1]?.rewardAmount, expectedReward)
        XCTAssertEqual(distributions[1]?.referrerId, referrerId)
        XCTAssertEqual(distributions[1]?.level, 1)
    }

    /// Test that 25% reward is distributed to all 5 levels
    func testRewardDistribution_AllFiveLevels() {
        // Given
        let userId = UUID()
        let level1Id = UUID()
        let level2Id = UUID()
        let level3Id = UUID()
        let level4Id = UUID()
        let level5Id = UUID()
        let pointsEarned: Decimal = 10.0
        let expectedRewardPerLevel: Decimal = 2.5 // 25% of 10

        let referralChain = ReferralChain(
            userId: userId,
            level1ReferrerId: level1Id,
            level2ReferrerId: level2Id,
            level3ReferrerId: level3Id,
            level4ReferrerId: level4Id,
            level5ReferrerId: level5Id
        )

        // When
        let distributions = sut.calculateRewardDistribution(
            pointsEarned: pointsEarned,
            referralChain: referralChain
        )

        // Then
        XCTAssertEqual(distributions.count, 5, "Should have 5 distributions")

        // Verify each level gets exactly 25%
        for level in 1...5 {
            XCTAssertNotNil(distributions[level], "Level \(level) should have a distribution")
            XCTAssertEqual(
                distributions[level]?.rewardAmount,
                expectedRewardPerLevel,
                "Level \(level) should receive 2.5 points (25% of 10)"
            )
            XCTAssertEqual(distributions[level]?.level, level)
            XCTAssertEqual(distributions[level]?.basePointsEarned, pointsEarned)
        }

        // Verify referrer IDs
        XCTAssertEqual(distributions[1]?.referrerId, level1Id)
        XCTAssertEqual(distributions[2]?.referrerId, level2Id)
        XCTAssertEqual(distributions[3]?.referrerId, level3Id)
        XCTAssertEqual(distributions[4]?.referrerId, level4Id)
        XCTAssertEqual(distributions[5]?.referrerId, level5Id)

        // Total distributed: 5 levels × 2.5 = 12.5 points
        let totalDistributed = distributions.values.reduce(Decimal(0)) { $0 + $1.rewardAmount }
        XCTAssertEqual(totalDistributed, 12.5, "Total distributed should be 12.5 points")
    }

    /// Test reward distribution with partial chain (3 levels)
    func testRewardDistribution_PartialChain() {
        // Given
        let userId = UUID()
        let level1Id = UUID()
        let level2Id = UUID()
        let level3Id = UUID()
        let pointsEarned: Decimal = 100.0
        let expectedRewardPerLevel: Decimal = 25.0 // 25% of 100

        let referralChain = ReferralChain(
            userId: userId,
            level1ReferrerId: level1Id,
            level2ReferrerId: level2Id,
            level3ReferrerId: level3Id,
            level4ReferrerId: nil,
            level5ReferrerId: nil
        )

        // When
        let distributions = sut.calculateRewardDistribution(
            pointsEarned: pointsEarned,
            referralChain: referralChain
        )

        // Then
        XCTAssertEqual(distributions.count, 3, "Should have 3 distributions")
        XCTAssertNotNil(distributions[1])
        XCTAssertNotNil(distributions[2])
        XCTAssertNotNil(distributions[3])
        XCTAssertNil(distributions[4])
        XCTAssertNil(distributions[5])

        // Each active level gets 25 points
        XCTAssertEqual(distributions[1]?.rewardAmount, expectedRewardPerLevel)
        XCTAssertEqual(distributions[2]?.rewardAmount, expectedRewardPerLevel)
        XCTAssertEqual(distributions[3]?.rewardAmount, expectedRewardPerLevel)

        // Total distributed: 3 levels × 25 = 75 points
        let totalDistributed = distributions.values.reduce(Decimal(0)) { $0 + $1.rewardAmount }
        XCTAssertEqual(totalDistributed, 75.0)
    }

    /// Test reward distribution with decimal point precision
    func testRewardDistribution_DecimalPrecision() {
        // Given
        let userId = UUID()
        let referrerId = UUID()
        let pointsEarned: Decimal = 10.5
        let expectedReward: Decimal = 2.625 // 25% of 10.5

        let referralChain = ReferralChain(
            userId: userId,
            level1ReferrerId: referrerId
        )

        // When
        let distributions = sut.calculateRewardDistribution(
            pointsEarned: pointsEarned,
            referralChain: referralChain
        )

        // Then
        XCTAssertEqual(distributions[1]?.rewardAmount, expectedReward)
    }

    /// Test that empty chain returns no distributions
    func testRewardDistribution_EmptyChain() {
        // Given
        let userId = UUID()
        let pointsEarned: Decimal = 10.0

        let referralChain = ReferralChain(userId: userId)

        // When
        let distributions = sut.calculateRewardDistribution(
            pointsEarned: pointsEarned,
            referralChain: referralChain
        )

        // Then
        XCTAssertEqual(distributions.count, 0, "Empty chain should have no distributions")
    }

    /// Test zero points earned
    func testRewardDistribution_ZeroPoints() {
        // Given
        let userId = UUID()
        let referrerId = UUID()
        let pointsEarned: Decimal = 0.0

        let referralChain = ReferralChain(
            userId: userId,
            level1ReferrerId: referrerId
        )

        // When
        let distributions = sut.calculateRewardDistribution(
            pointsEarned: pointsEarned,
            referralChain: referralChain
        )

        // Then
        XCTAssertEqual(distributions.count, 1)
        XCTAssertEqual(distributions[1]?.rewardAmount, 0.0)
    }

    // MARK: - Local Earnings Update Tests

    /// Test updating local earnings for a single level
    func testUpdateLocalEarnings_SingleLevel() {
        // Given
        let userId = UUID()
        let referrerId = UUID()
        var referralChain = ReferralChain(
            userId: userId,
            level1ReferrerId: referrerId
        )

        let distribution = RewardDistribution(
            referrerId: referrerId,
            level: 1,
            rewardAmount: 2.5,
            basePointsEarned: 10.0
        )

        // When
        sut.updateLocalEarnings(
            referralChain: &referralChain,
            distributions: [1: distribution]
        )

        // Then
        XCTAssertEqual(referralChain.level1TotalEarnings, 2.5)
        XCTAssertEqual(referralChain.totalEarnings, 2.5)
    }

    /// Test updating local earnings for all 5 levels
    func testUpdateLocalEarnings_AllLevels() {
        // Given
        let userId = UUID()
        var referralChain = ReferralChain(
            userId: userId,
            level1ReferrerId: UUID(),
            level2ReferrerId: UUID(),
            level3ReferrerId: UUID(),
            level4ReferrerId: UUID(),
            level5ReferrerId: UUID()
        )

        let distributions: [Int: RewardDistribution] = [
            1: RewardDistribution(referrerId: UUID(), level: 1, rewardAmount: 2.5, basePointsEarned: 10),
            2: RewardDistribution(referrerId: UUID(), level: 2, rewardAmount: 2.5, basePointsEarned: 10),
            3: RewardDistribution(referrerId: UUID(), level: 3, rewardAmount: 2.5, basePointsEarned: 10),
            4: RewardDistribution(referrerId: UUID(), level: 4, rewardAmount: 2.5, basePointsEarned: 10),
            5: RewardDistribution(referrerId: UUID(), level: 5, rewardAmount: 2.5, basePointsEarned: 10)
        ]

        // When
        sut.updateLocalEarnings(
            referralChain: &referralChain,
            distributions: distributions
        )

        // Then
        XCTAssertEqual(referralChain.level1TotalEarnings, 2.5)
        XCTAssertEqual(referralChain.level2TotalEarnings, 2.5)
        XCTAssertEqual(referralChain.level3TotalEarnings, 2.5)
        XCTAssertEqual(referralChain.level4TotalEarnings, 2.5)
        XCTAssertEqual(referralChain.level5TotalEarnings, 2.5)
        XCTAssertEqual(referralChain.totalEarnings, 12.5) // 5 × 2.5
    }

    /// Test cumulative earnings over multiple updates
    func testUpdateLocalEarnings_Cumulative() {
        // Given
        let userId = UUID()
        let referrerId = UUID()
        var referralChain = ReferralChain(
            userId: userId,
            level1ReferrerId: referrerId,
            level1TotalEarnings: 10.0 // Already has 10 points
        )

        let distribution = RewardDistribution(
            referrerId: referrerId,
            level: 1,
            rewardAmount: 5.0,
            basePointsEarned: 20.0
        )

        // When
        sut.updateLocalEarnings(
            referralChain: &referralChain,
            distributions: [1: distribution]
        )

        // Then
        XCTAssertEqual(referralChain.level1TotalEarnings, 15.0) // 10 + 5
        XCTAssertEqual(referralChain.totalEarnings, 15.0)
    }

    // MARK: - ReferralChain Model Tests

    /// Test referral chain computed properties
    func testReferralChain_ComputedProperties() {
        // Given
        let chain = ReferralChain(
            userId: UUID(),
            level1ReferrerId: UUID(),
            level2ReferrerId: UUID(),
            level3ReferrerId: UUID(),
            level1TotalEarnings: 10.0,
            level2TotalEarnings: 5.0,
            level3TotalEarnings: 2.5
        )

        // Then
        XCTAssertEqual(chain.activeReferrerLevels, 3)
        XCTAssertEqual(chain.totalEarnings, 17.5) // 10 + 5 + 2.5
        XCTAssertEqual(chain.allReferrerIds.count, 3)
    }

    /// Test getReferrerId helper method
    func testReferralChain_GetReferrerId() {
        // Given
        let level1Id = UUID()
        let level3Id = UUID()
        let level5Id = UUID()

        let chain = ReferralChain(
            userId: UUID(),
            level1ReferrerId: level1Id,
            level2ReferrerId: nil,
            level3ReferrerId: level3Id,
            level4ReferrerId: nil,
            level5ReferrerId: level5Id
        )

        // Then
        XCTAssertEqual(chain.getReferrerId(forLevel: 1), level1Id)
        XCTAssertNil(chain.getReferrerId(forLevel: 2))
        XCTAssertEqual(chain.getReferrerId(forLevel: 3), level3Id)
        XCTAssertNil(chain.getReferrerId(forLevel: 4))
        XCTAssertEqual(chain.getReferrerId(forLevel: 5), level5Id)
        XCTAssertNil(chain.getReferrerId(forLevel: 0))
        XCTAssertNil(chain.getReferrerId(forLevel: 6))
    }

    /// Test getTotalEarnings helper method
    func testReferralChain_GetTotalEarnings() {
        // Given
        let chain = ReferralChain(
            userId: UUID(),
            level1TotalEarnings: 10.0,
            level2TotalEarnings: 5.0,
            level3TotalEarnings: 2.5,
            level4TotalEarnings: 1.25,
            level5TotalEarnings: 0.625
        )

        // Then
        XCTAssertEqual(chain.getTotalEarnings(forLevel: 1), 10.0)
        XCTAssertEqual(chain.getTotalEarnings(forLevel: 2), 5.0)
        XCTAssertEqual(chain.getTotalEarnings(forLevel: 3), 2.5)
        XCTAssertEqual(chain.getTotalEarnings(forLevel: 4), 1.25)
        XCTAssertEqual(chain.getTotalEarnings(forLevel: 5), 0.625)
        XCTAssertEqual(chain.getTotalEarnings(forLevel: 0), 0)
        XCTAssertEqual(chain.getTotalEarnings(forLevel: 6), 0)
    }

    // MARK: - Real-world Scenario Tests

    /// Test the complete example from the spec:
    /// When User D earns 10 points, levels 1-5 each get 2.50 points
    func testRealWorldScenario_UserDEarns10Points() {
        // Given: User A → User B → User C → User D (+ 2 more levels)
        let userA_Id = UUID() // Level 5
        let userB_Id = UUID() // Level 4
        let userC_Id = UUID() // Level 3
        let userD_directReferrer_Id = UUID() // Level 2
        let userD_immediateReferrer_Id = UUID() // Level 1
        let userD_Id = UUID()

        let referralChain = ReferralChain(
            userId: userD_Id,
            level1ReferrerId: userD_immediateReferrer_Id,
            level2ReferrerId: userD_directReferrer_Id,
            level3ReferrerId: userC_Id,
            level4ReferrerId: userB_Id,
            level5ReferrerId: userA_Id
        )

        let pointsEarned: Decimal = 10.0

        // When
        let distributions = sut.calculateRewardDistribution(
            pointsEarned: pointsEarned,
            referralChain: referralChain
        )

        // Then
        // Each level gets exactly 2.50 points (25%)
        XCTAssertEqual(distributions.count, 5, "All 5 levels should receive rewards")

        for level in 1...5 {
            XCTAssertEqual(
                distributions[level]?.rewardAmount,
                2.50,
                "Level \(level) should receive exactly 2.50 points"
            )
        }

        // Total distributed: 12.50 points (5 levels × 2.50)
        let totalDistributed = distributions.values.reduce(Decimal(0)) { $0 + $1.rewardAmount }
        XCTAssertEqual(totalDistributed, 12.50, "Total distributed should be 12.50 points")

        // Verify correct referrer IDs
        XCTAssertEqual(distributions[1]?.referrerId, userD_immediateReferrer_Id)
        XCTAssertEqual(distributions[2]?.referrerId, userD_directReferrer_Id)
        XCTAssertEqual(distributions[3]?.referrerId, userC_Id)
        XCTAssertEqual(distributions[4]?.referrerId, userB_Id)
        XCTAssertEqual(distributions[5]?.referrerId, userA_Id)
    }
}
