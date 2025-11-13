//
//  TierProgressionIntegrationExample.swift
//  WiesbadenAfterDark
//
//  Example integration of tier progression system
//  This file demonstrates how to use the tier progression features
//

import SwiftUI
import SwiftData

// MARK: - Example: Customer-Facing Tier View

/// Example of integrating tier progress into a user profile
struct ExampleProfileTierSection: View {
    let membership: VenueMembership
    let venueName: String

    @State private var tierProgress: TierProgress?
    @State private var showCelebration = false
    @State private var tierUpgrade: (from: MembershipTier, to: MembershipTier)?

    private let tierService = TierProgressionService()

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            if let progress = tierProgress {
                // Display tier progress
                TierProgressView(
                    progress: progress,
                    venueName: venueName
                )
            } else {
                ProgressView("Loading tier progress...")
            }
        }
        .onAppear {
            loadTierProgress()
        }
        .sheet(isPresented: $showCelebration) {
            if let upgrade = tierUpgrade {
                TierUpgradeCelebrationView(
                    fromTier: upgrade.from,
                    toTier: upgrade.to,
                    venueName: venueName,
                    onDismiss: {
                        showCelebration = false
                    },
                    onShare: {
                        shareAchievement()
                    }
                )
            }
        }
    }

    private func loadTierProgress() {
        // Get venue tier configuration
        let config = tierService.getOrCreateDefaultConfig(venueId: membership.venueId)

        // Calculate progress
        let progress = tierService.calculateProgress(
            membership: membership,
            config: config
        )

        tierProgress = progress
    }

    private func shareAchievement() {
        // Implement share functionality
        // Example: Share to social media or copy link
        print("Sharing tier achievement...")
    }
}

// MARK: - Example: Check Tier After Purchase

/// Example of checking and updating tier after a purchase
struct ExamplePurchaseHandler {
    let tierService = TierProgressionService()

    func handlePurchase(
        membership: VenueMembership,
        purchaseAmount: Decimal,
        config: VenueTierConfig
    ) async throws {
        // Update spending
        membership.totalSpent += purchaseAmount

        // Check for tier upgrade
        let result = try await tierService.checkAndUpdateTier(
            membership: membership,
            config: config
        )

        if result.updated, let oldTier = result.oldTier {
            // Show celebration if upgraded
            if result.newTier.order > oldTier.order {
                await showTierUpgradeCelebration(from: oldTier, to: result.newTier)
            }
        }

        // Apply tier benefits to points earned
        let basePoints = calculateBasePoints(amount: purchaseAmount)
        let bonusPoints = tierService.applyTierBenefits(
            basePoints: basePoints,
            tier: membership.tier,
            config: config
        )

        membership.pointsBalance += bonusPoints
        membership.totalPointsEarned += bonusPoints
    }

    private func calculateBasePoints(amount: Decimal) -> Int {
        // Example: 1 point per euro spent
        return NSDecimalNumber(decimal: amount).intValue
    }

    private func showTierUpgradeCelebration(from: MembershipTier, to: MembershipTier) async {
        // Trigger celebration animation
        await MainActor.run {
            // Present celebration view
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowTierUpgrade"),
                object: nil,
                userInfo: ["from": from, "to": to]
            )
        }
    }
}

// MARK: - Example: Venue Owner Dashboard Access

/// Example of presenting tier configuration for venue owners
struct ExampleVenueManagementView: View {
    let venue: Venue
    let isOwner: Bool

    @State private var showingTierConfig = false

    var body: some View {
        VStack {
            if isOwner {
                Button(action: {
                    showingTierConfig = true
                }) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text("Configure Tier System")
                    }
                }
                .sheet(isPresented: $showingTierConfig) {
                    TierConfigurationView(
                        venueId: venue.id,
                        venueName: venue.name
                    )
                }
            } else {
                Text("Owner-only feature")
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Example: Automatic Tier Maintenance Check

/// Example background task to check tier maintenance
class ExampleTierMaintenanceTask {
    let tierService = TierProgressionService()

    /// Run daily to check for tier downgrades
    func checkAllMemberships(memberships: [VenueMembership], configs: [UUID: VenueTierConfig]) async {
        for membership in memberships {
            guard let config = configs[membership.venueId] else { continue }

            // Check if tier should be downgraded
            let result = tierService.checkTierMaintenance(
                membership: membership,
                config: config
            )

            if result.shouldDowngrade {
                await handleTierDowngrade(
                    membership: membership,
                    reason: result.reason ?? "Tier maintenance check failed"
                )
            }

            // Check if tier should be reset
            if tierService.shouldResetTier(membership: membership, config: config) {
                await handleTierReset(membership: membership)
            }
        }
    }

    private func handleTierDowngrade(membership: VenueMembership, reason: String) async {
        // Downgrade tier by one level
        let currentOrder = membership.tier.order
        if currentOrder > 0 {
            let newTier = MembershipTier.allCases.first { $0.order == currentOrder - 1 }
            if let newTier = newTier {
                membership.tier = newTier
                membership.updatedAt = Date()

                // Send notification to user
                await notifyUserOfDowngrade(membership: membership, reason: reason)
            }
        }
    }

    private func handleTierReset(membership: VenueMembership) async {
        // Reset to bronze tier
        membership.tier = .bronze
        membership.totalSpent = 0
        membership.updatedAt = Date()

        // Send notification to user
        await notifyUserOfReset(membership: membership)
    }

    private func notifyUserOfDowngrade(membership: VenueMembership, reason: String) async {
        // Send push notification or email
        print("Tier downgraded for user \(membership.userId): \(reason)")
    }

    private func notifyUserOfReset(membership: VenueMembership) async {
        // Send push notification or email
        print("Tier reset for user \(membership.userId)")
    }
}

// MARK: - Example: Badge Checking

/// Example of checking badge achievements after actions
struct ExampleBadgeChecker {
    let tierService = TierProgressionService()

    func checkBadgesAfterAction(
        membership: VenueMembership,
        badges: [BadgeConfig]
    ) -> [BadgeConfig] {
        var earnedBadges: [BadgeConfig] = []

        for badge in badges where badge.isActive {
            let result = tierService.checkBadgeEarned(
                membership: membership,
                badge: badge
            )

            if result.earned {
                earnedBadges.append(badge)

                // Award badge rewards
                if badge.pointsReward > 0 {
                    membership.pointsBalance += badge.pointsReward
                    membership.totalPointsEarned += badge.pointsReward
                }
            }
        }

        return earnedBadges
    }

    func showBadgeToast(badge: BadgeConfig) {
        // Show toast notification
        // This would typically be shown in the UI layer
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowBadgeToast"),
            object: nil,
            userInfo: ["badge": badge]
        )
    }
}

// MARK: - Example: API Integration Points

/*
 BACKEND API ENDPOINTS TO IMPLEMENT:

 1. GET /api/v1/venues/:id/tier-config
    - Fetch venue's tier configuration
    - Returns: VenueTierConfig

 2. PUT /api/v1/venues/:id/tier-config
    - Update venue's tier configuration (owner only)
    - Body: VenueTierConfig
    - Returns: Updated VenueTierConfig

 3. GET /api/v1/users/:id/tier-progress?venueId=:venueId
    - Fetch user's tier progress at a venue
    - Returns: TierProgress

 4. POST /api/v1/tiers/upgrade
    - Trigger tier upgrade check after purchase
    - Body: { userId, venueId, purchaseAmount }
    - Returns: { upgraded: Bool, oldTier?, newTier, bonusPoints }

 5. GET /api/v1/venues/:id/badges
    - Fetch all badges for a venue
    - Returns: [BadgeConfig]

 6. POST /api/v1/venues/:id/badges
    - Create new badge (owner only)
    - Body: BadgeConfig
    - Returns: Created BadgeConfig

 7. PUT /api/v1/venues/:id/badges/:badgeId
    - Update badge (owner only)
    - Body: BadgeConfig
    - Returns: Updated BadgeConfig

 8. DELETE /api/v1/venues/:id/badges/:badgeId
    - Delete badge (owner only)
    - Returns: Success status

 9. GET /api/v1/users/:id/badges-earned?venueId=:venueId
    - Fetch badges earned by user at venue
    - Returns: [BadgeConfig]

 10. POST /api/v1/badges/check
     - Check badge achievement after action
     - Body: { userId, venueId, badgeId }
     - Returns: { earned: Bool, progress: Double }
*/

// MARK: - Example: SwiftData Schema

/*
 SWIFTDATA MODELS TO ADD TO SCHEMA:

 @Model
 final class Schema {
     static var models: [any PersistentModel.Type] {
         [
             User.self,
             Venue.self,
             VenueMembership.self,
             VenueTierConfig.self,    // ← Add this
             BadgeConfig.self,         // ← Add this
             // ... other models
         ]
     }
 }
*/

// MARK: - Preview

#Preview("Integration Example") {
    ExampleProfileTierSection(
        membership: VenueMembership.mockMembership(userId: UUID(), venueId: UUID()),
        venueName: "Das Wohnzimmer"
    )
    .padding()
    .background(Color.appBackground)
}
