//
//  TierProgressionService.swift
//  WiesbadenAfterDark
//
//  Service for managing tier progression, upgrades, and benefits
//

import Foundation
import SwiftData

// MARK: - Tier Progression Event

/// Events emitted by the tier progression service
enum TierProgressionEvent {
    case tierUpgraded(from: MembershipTier, to: MembershipTier, venueId: UUID)
    case tierDowngraded(from: MembershipTier, to: MembershipTier, venueId: UUID)
    case tierMaintained(tier: MembershipTier, venueId: UUID)
    case progressUpdated(progress: TierProgress, venueId: UUID)
}

// MARK: - Tier Progression Error

enum TierProgressionError: Error, LocalizedError {
    case membershipNotFound
    case configNotFound
    case invalidSpending
    case calculationFailed

    var errorDescription: String? {
        switch self {
        case .membershipNotFound:
            return "Membership not found for this venue"
        case .configNotFound:
            return "Tier configuration not found for this venue"
        case .invalidSpending:
            return "Invalid spending amount"
        case .calculationFailed:
            return "Failed to calculate tier progression"
        }
    }
}

// MARK: - Tier Progression Service

@Observable
class TierProgressionService {

    // MARK: - Properties

    private let modelContext: ModelContext?
    private var eventHandler: ((TierProgressionEvent) -> Void)?

    // MARK: - Initialization

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    // MARK: - Event Handling

    /// Register a handler for tier progression events
    func onEvent(_ handler: @escaping (TierProgressionEvent) -> Void) {
        self.eventHandler = handler
    }

    // MARK: - Tier Calculation

    /// Calculate the appropriate tier based on spending and configuration
    func calculateTier(
        spending: Decimal,
        config: VenueTierConfig
    ) -> MembershipTier {
        return config.tier(for: spending)
    }

    /// Calculate tier progress for a membership
    func calculateProgress(
        membership: VenueMembership,
        config: VenueTierConfig
    ) -> TierProgress {
        let currentTier = membership.tier
        let currentSpending = membership.totalSpent
        let nextTier = currentTier.nextTier

        let perks = config.perks(for: currentTier)
        let multiplier = config.multiplier(for: currentTier)

        // Calculate days at current tier
        let daysAtTier = calculateDaysAtTier(membership: membership)

        // If at maximum tier
        guard let nextTier = nextTier else {
            return TierProgress(
                currentTier: currentTier,
                nextTier: nil,
                currentSpending: currentSpending,
                nextTierThreshold: nil,
                progressPercentage: 100.0,
                amountToNextTier: nil,
                daysAtCurrentTier: daysAtTier,
                perks: perks,
                multiplier: multiplier
            )
        }

        // Calculate progress to next tier
        let nextTierThreshold = config.minimum(for: nextTier)
        let currentTierMin = config.minimum(for: currentTier)
        let tierRange = nextTierThreshold - currentTierMin
        let progress = currentSpending - currentTierMin
        let progressPercentage = tierRange > 0 ?
            min(100.0, (NSDecimalNumber(decimal: progress).doubleValue / NSDecimalNumber(decimal: tierRange).doubleValue) * 100.0) : 0.0

        let amountNeeded = max(0, nextTierThreshold - currentSpending)

        return TierProgress(
            currentTier: currentTier,
            nextTier: nextTier,
            currentSpending: currentSpending,
            nextTierThreshold: nextTierThreshold,
            progressPercentage: progressPercentage,
            amountToNextTier: amountNeeded,
            daysAtCurrentTier: daysAtTier,
            perks: perks,
            multiplier: multiplier
        )
    }

    /// Calculate how many days the user has been at their current tier
    private func calculateDaysAtTier(membership: VenueMembership) -> Int {
        // For now, calculate from join date (in production, track tier change dates)
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: membership.joinedAt, to: now)
        return components.day ?? 0
    }

    // MARK: - Tier Updates

    /// Check and update tier if spending threshold is crossed
    func checkAndUpdateTier(
        membership: VenueMembership,
        config: VenueTierConfig
    ) async throws -> (updated: Bool, oldTier: MembershipTier?, newTier: MembershipTier) {
        let currentTier = membership.tier
        let calculatedTier = calculateTier(spending: membership.totalSpent, config: config)

        // No change needed
        if currentTier == calculatedTier {
            return (updated: false, oldTier: nil, newTier: currentTier)
        }

        // Update the tier
        let oldTier = currentTier
        membership.tier = calculatedTier
        membership.updatedAt = Date()

        // Emit event
        if calculatedTier.order > currentTier.order {
            eventHandler?(.tierUpgraded(from: oldTier, to: calculatedTier, venueId: membership.venueId))
        } else {
            eventHandler?(.tierDowngraded(from: oldTier, to: calculatedTier, venueId: membership.venueId))
        }

        return (updated: true, oldTier: oldTier, newTier: calculatedTier)
    }

    /// Apply tier benefits to a purchase (points multiplier)
    func applyTierBenefits(
        basePoints: Int,
        tier: MembershipTier,
        config: VenueTierConfig
    ) -> Int {
        let multiplier = config.multiplier(for: tier)
        let multipliedPoints = Decimal(basePoints) * multiplier
        return NSDecimalNumber(decimal: multipliedPoints).intValue
    }

    // MARK: - Tier Maintenance

    /// Check if a tier should be downgraded due to inactivity
    func checkTierMaintenance(
        membership: VenueMembership,
        config: VenueTierConfig
    ) -> (shouldDowngrade: Bool, reason: String?) {
        // Check inactivity downgrade
        if let inactivityDays = config.inactivityDowngradeAfterDays,
           let lastVisit = membership.lastVisitAt {
            let daysSinceLastVisit = Calendar.current.dateComponents(
                [.day],
                from: lastVisit,
                to: Date()
            ).day ?? 0

            // Apply grace period if configured
            let threshold = config.hasGracePeriod ?
                inactivityDays + config.gracePeriodDays :
                inactivityDays

            if daysSinceLastVisit > threshold {
                return (true, "Inactive for \(daysSinceLastVisit) days")
            }
        }

        // Check monthly spending requirement
        if let requiredSpending = config.monthlySpendingRequired {
            // This would require tracking monthly spending separately
            // For now, we'll skip this check
            // In production, you'd track spending per month
        }

        return (false, nil)
    }

    /// Apply tier reset policy (e.g., annual reset)
    func shouldResetTier(
        membership: VenueMembership,
        config: VenueTierConfig
    ) -> Bool {
        switch config.tierResetPolicy {
        case .never:
            return false

        case .annually:
            // Check if a year has passed since join date
            let calendar = Calendar.current
            if let yearAgo = calendar.date(byAdding: .year, value: -1, to: Date()),
               membership.joinedAt < yearAgo {
                // Check if we're at the start of a new year
                let currentYear = calendar.component(.year, from: Date())
                let joinYear = calendar.component(.year, from: membership.joinedAt)
                return currentYear > joinYear
            }
            return false

        case .quarterly:
            // Reset every 3 months
            let calendar = Calendar.current
            if let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date()) {
                return membership.joinedAt < threeMonthsAgo
            }
            return false

        case .monthly:
            // Reset every month
            let calendar = Calendar.current
            if let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) {
                return membership.joinedAt < monthAgo
            }
            return false
        }
    }

    // MARK: - Badge Checking

    /// Check if a user has earned a badge
    func checkBadgeEarned(
        membership: VenueMembership,
        badge: BadgeConfig
    ) -> (earned: Bool, progress: Double) {
        var criteriaMetCount = 0
        var totalCriteria = 0
        var progressSum = 0.0

        // Check visits requirement
        if let requiredVisits = badge.requiredVisits {
            totalCriteria += 1
            let progress = Double(membership.totalVisits) / Double(requiredVisits)
            progressSum += min(1.0, progress)
            if membership.totalVisits >= requiredVisits {
                criteriaMetCount += 1
            }
        }

        // Check spending requirement
        if let requiredSpending = badge.requiredSpending {
            totalCriteria += 1
            let spendingDouble = NSDecimalNumber(decimal: membership.totalSpent).doubleValue
            let requiredDouble = NSDecimalNumber(decimal: requiredSpending).doubleValue
            let progress = spendingDouble / requiredDouble
            progressSum += min(1.0, progress)
            if membership.totalSpent >= requiredSpending {
                criteriaMetCount += 1
            }
        }

        // Check referrals requirement (would need referral data from User model)
        if let requiredReferrals = badge.requiredReferrals {
            totalCriteria += 1
            // This would require access to user referral data
            // For now, we'll skip this check
        }

        // Check time-based requirements
        if let requiredDays = badge.requiredDays,
           let requiredVisits = badge.requiredVisits {
            // Check if visits happened within the time window
            // This would require visit timestamps
            // For now, we'll use a simplified check
            totalCriteria += 1
        }

        let overallProgress = totalCriteria > 0 ? progressSum / Double(totalCriteria) : 0.0
        let earned = totalCriteria > 0 && criteriaMetCount == totalCriteria

        return (earned, overallProgress)
    }
}

// MARK: - Default Configuration

extension TierProgressionService {
    /// Get or create default tier configuration for a venue
    func getOrCreateDefaultConfig(venueId: UUID) -> VenueTierConfig {
        // In a real implementation, this would fetch from the database
        // or create a new config if it doesn't exist
        return VenueTierConfig.defaultConfig(venueId: venueId)
    }
}

// MARK: - Mock Service

class MockTierProgressionService: TierProgressionService {
    var mockConfig: VenueTierConfig?
    var mockProgress: TierProgress?

    override func calculateTier(spending: Decimal, config: VenueTierConfig) -> MembershipTier {
        return super.calculateTier(spending: spending, config: config)
    }

    override func calculateProgress(membership: VenueMembership, config: VenueTierConfig) -> TierProgress {
        return mockProgress ?? super.calculateProgress(membership: membership, config: config)
    }
}
