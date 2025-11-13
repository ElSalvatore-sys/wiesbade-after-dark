//
//  PointsExpirationService.swift
//  WiesbadenAfterDark
//
//  Service for managing points expiration, warnings, and background processing
//

import Foundation
import SwiftData
import BackgroundTasks
import UserNotifications

@MainActor
final class PointsExpirationService: @unchecked Sendable {
    // MARK: - Singleton

    static let shared = PointsExpirationService()

    // MARK: - Constants

    private let expirationDays = 180 // Points expire after 180 days of inactivity
    private let warningDays = 30 // Show warning 30 days before expiration
    private let backgroundTaskIdentifier = "com.wad.points-expiration-check"

    // MARK: - Properties

    private var modelContext: ModelContext?
    private let apiClient = APIClient.shared

    // MARK: - Initialization

    private init() {}

    /// Configure the service with a model context
    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Background Task Registration

    /// Register background task for points expiration checks
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let self = self else {
                task.setTaskCompleted(success: false)
                return
            }

            Task {
                await self.handleBackgroundTask(task as! BGProcessingTask)
            }
        }
    }

    /// Schedule the next background task
    func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date())

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ [PointsExpiration] Background task scheduled successfully")
        } catch {
            print("❌ [PointsExpiration] Failed to schedule background task: \(error)")
        }
    }

    // MARK: - Background Task Handler

    private func handleBackgroundTask(_ task: BGProcessingTask) async {
        // Set expiration handler
        task.expirationHandler = {
            print("⏰ [PointsExpiration] Background task expired")
            task.setTaskCompleted(success: false)
        }

        do {
            // Perform expiration check
            let result = try await performExpirationCheck()

            // Send notifications if needed
            if result.expiringCount > 0 {
                await sendExpirationNotifications(for: result.expiringMemberships)
            }

            // Schedule next task
            scheduleBackgroundTask()

            task.setTaskCompleted(success: true)
            print("✅ [PointsExpiration] Background task completed successfully")
        } catch {
            print("❌ [PointsExpiration] Background task failed: \(error)")
            task.setTaskCompleted(success: false)
        }
    }

    // MARK: - Expiration Check

    /// Perform full expiration check for all memberships
    func performExpirationCheck() async throws -> ExpirationCheckResult {
        guard let context = modelContext else {
            throw ExpirationError.contextNotConfigured
        }

        // Fetch all active venue memberships
        let fetchDescriptor = FetchDescriptor<VenueMembership>(
            predicate: #Predicate { $0.isActive && $0.pointsBalance > 0 }
        )

        let memberships = try context.fetch(fetchDescriptor)

        var expiredMemberships: [VenueMembership] = []
        var expiringMemberships: [VenueMembership] = []
        var totalPointsExpired = 0

        for membership in memberships {
            // Update expiration date if not set
            if membership.nextExpirationDate == nil {
                membership.nextExpirationDate = calculateExpirationDate(from: membership.lastActivityDate)
            }

            // Check if points have expired
            if membership.hasExpiredPoints {
                expiredMemberships.append(membership)
                totalPointsExpired += membership.pointsBalance
            }
            // Check if points are expiring soon
            else if membership.hasExpiringPoints {
                expiringMemberships.append(membership)
            }
        }

        // Execute expiration for expired points
        if !expiredMemberships.isEmpty {
            try await executeExpiration(for: expiredMemberships)
        }

        // Update expiration tracking
        try await updateExpirationTracking(for: expiringMemberships)

        try context.save()

        return ExpirationCheckResult(
            totalChecked: memberships.count,
            expiredCount: expiredMemberships.count,
            expiringCount: expiringMemberships.count,
            totalPointsExpired: totalPointsExpired,
            expiredMemberships: expiredMemberships,
            expiringMemberships: expiringMemberships
        )
    }

    // MARK: - Expiration Calculation

    /// Calculate expiration date from last activity date
    func calculateExpirationDate(from lastActivityDate: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: expirationDays, to: lastActivityDate) ?? lastActivityDate
    }

    /// Check if points are expiring soon (within warning period)
    func isExpiringSoon(expirationDate: Date) -> Bool {
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return daysUntilExpiry <= warningDays && daysUntilExpiry > 0
    }

    // MARK: - Execute Expiration

    /// Execute expiration for memberships with expired points
    private func executeExpiration(for memberships: [VenueMembership]) async throws {
        guard let context = modelContext else { return }

        for membership in memberships {
            let pointsToExpire = membership.pointsBalance

            // Create expiration record
            let expiration = PointExpiration(
                membershipId: membership.id,
                userId: membership.userId,
                venueId: membership.venueId,
                venueName: "", // Will be fetched from venue
                pointsAtRisk: pointsToExpire,
                lastActivityDate: membership.lastActivityDate,
                expirationDate: membership.calculatedExpirationDate,
                isExpired: true,
                expirationExecutedAt: Date()
            )

            context.insert(expiration)

            // Update membership
            membership.pointsBalance = 0
            membership.lastActivityDate = Date()
            membership.nextExpirationDate = calculateExpirationDate(from: Date())

            print("⏰ [PointsExpiration] Expired \(pointsToExpire) points for membership \(membership.id)")
        }

        try context.save()

        // Notify backend
        do {
            try await notifyBackendExpiration(for: memberships)
        } catch {
            print("⚠️ [PointsExpiration] Failed to notify backend: \(error)")
        }
    }

    // MARK: - Update Expiration Tracking

    /// Update or create expiration tracking records
    private func updateExpirationTracking(for memberships: [VenueMembership]) async throws {
        guard let context = modelContext else { return }

        for membership in memberships {
            // Check if tracking record exists
            let fetchDescriptor = FetchDescriptor<PointExpiration>(
                predicate: #Predicate<PointExpiration> {
                    $0.membershipId == membership.id && !$0.isExpired
                }
            )

            let existingRecords = try context.fetch(fetchDescriptor)

            if let existingRecord = existingRecords.first {
                // Update existing record
                existingRecord.pointsAtRisk = membership.pointsBalance
                existingRecord.lastActivityDate = membership.lastActivityDate
                existingRecord.expirationDate = membership.calculatedExpirationDate
                existingRecord.updateDaysUntilExpiry()
                existingRecord.updatedAt = Date()
            } else {
                // Create new tracking record
                let expiration = PointExpiration(
                    membershipId: membership.id,
                    userId: membership.userId,
                    venueId: membership.venueId,
                    venueName: "", // Will be fetched from venue
                    pointsAtRisk: membership.pointsBalance,
                    lastActivityDate: membership.lastActivityDate,
                    expirationDate: membership.calculatedExpirationDate
                )

                context.insert(expiration)
            }
        }

        try context.save()
    }

    // MARK: - Fetch Expiring Points

    /// Fetch all expiring points for a user
    func fetchExpiringPoints(for userId: UUID) async throws -> [PointExpiration] {
        guard let context = modelContext else {
            throw ExpirationError.contextNotConfigured
        }

        let fetchDescriptor = FetchDescriptor<PointExpiration>(
            predicate: #Predicate<PointExpiration> {
                $0.userId == userId && !$0.isExpired && $0.daysUntilExpiry <= 30
            },
            sortBy: [SortDescriptor(\PointExpiration.daysUntilExpiry)]
        )

        let expirations = try context.fetch(fetchDescriptor)

        // Update days until expiry for each
        for expiration in expirations {
            expiration.updateDaysUntilExpiry()
        }

        return expirations
    }

    /// Fetch expiring memberships for a user
    func fetchExpiringMemberships(for userId: UUID) async throws -> [VenueMembership] {
        guard let context = modelContext else {
            throw ExpirationError.contextNotConfigured
        }

        let fetchDescriptor = FetchDescriptor<VenueMembership>(
            predicate: #Predicate<VenueMembership> {
                $0.userId == userId && $0.isActive && $0.pointsBalance > 0
            }
        )

        let memberships = try context.fetch(fetchDescriptor)

        // Filter to only those expiring soon
        return memberships.filter { $0.hasExpiringPoints }
    }

    // MARK: - Update Activity

    /// Update last activity date for a membership (called on check-in, redemption, etc.)
    func updateLastActivity(for membershipId: UUID) async throws {
        guard let context = modelContext else {
            throw ExpirationError.contextNotConfigured
        }

        let fetchDescriptor = FetchDescriptor<VenueMembership>(
            predicate: #Predicate<VenueMembership> { $0.id == membershipId }
        )

        guard let membership = try context.fetch(fetchDescriptor).first else {
            throw ExpirationError.membershipNotFound
        }

        // Update activity date and recalculate expiration
        membership.lastActivityDate = Date()
        membership.nextExpirationDate = calculateExpirationDate(from: Date())

        try context.save()

        // Notify backend
        do {
            try await notifyBackendActivity(for: membership)
        } catch {
            print("⚠️ [PointsExpiration] Failed to notify backend of activity: \(error)")
        }
    }

    // MARK: - User Actions

    /// Mark warning as dismissed by user
    func dismissWarning(for expirationId: UUID) async throws {
        guard let context = modelContext else {
            throw ExpirationError.contextNotConfigured
        }

        let fetchDescriptor = FetchDescriptor<PointExpiration>(
            predicate: #Predicate<PointExpiration> { $0.id == expirationId }
        )

        guard let expiration = try context.fetch(fetchDescriptor).first else {
            throw ExpirationError.expirationNotFound
        }

        expiration.userDismissedWarning = true
        expiration.updatedAt = Date()

        try context.save()
    }

    /// Set remind later date for a warning
    func remindLater(for expirationId: UUID, remindInDays: Int = 7) async throws {
        guard let context = modelContext else {
            throw ExpirationError.contextNotConfigured
        }

        let fetchDescriptor = FetchDescriptor<PointExpiration>(
            predicate: #Predicate<PointExpiration> { $0.id == expirationId }
        )

        guard let expiration = try context.fetch(fetchDescriptor).first else {
            throw ExpirationError.expirationNotFound
        }

        expiration.remindLaterDate = Calendar.current.date(byAdding: .day, value: remindInDays, to: Date())
        expiration.updatedAt = Date()

        try context.save()
    }

    // MARK: - Push Notifications

    /// Send push notifications for expiring points
    private func sendExpirationNotifications(for memberships: [VenueMembership]) async {
        let center = UNUserNotificationCenter.current()

        // Check notification authorization
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            print("⚠️ [PointsExpiration] Notifications not authorized")
            return
        }

        for membership in memberships {
            await sendNotification(for: membership)
        }
    }

    /// Send notification for a specific membership
    private func sendNotification(for membership: VenueMembership) async {
        let content = UNMutableNotificationContent()
        content.title = "Your points are expiring soon!"
        content.body = "\(membership.pointsBalance) points expire in \(membership.daysUntilExpiry) days"
        content.sound = .default
        content.badge = 1

        // Add venue ID for deep linking
        content.userInfo = [
            "type": "points_expiration",
            "venueId": membership.venueId.uuidString,
            "membershipId": membership.id.uuidString
        ]

        // Create trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: "expiration_\(membership.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ [PointsExpiration] Notification sent for membership \(membership.id)")
        } catch {
            print("❌ [PointsExpiration] Failed to send notification: \(error)")
        }
    }

    // MARK: - Backend Integration

    /// Notify backend of expired points
    private func notifyBackendExpiration(for memberships: [VenueMembership]) async throws {
        for membership in memberships {
            let endpoint = "/api/v1/points/expire"
            let body: [String: Any] = [
                "userId": membership.userId.uuidString,
                "venueId": membership.venueId.uuidString,
                "membershipId": membership.id.uuidString,
                "pointsExpired": membership.expiringPoints,
                "expirationDate": ISO8601DateFormatter().string(from: Date())
            ]

            _ = try await apiClient.request(
                endpoint: endpoint,
                method: "POST",
                body: body
            )
        }
    }

    /// Notify backend of activity update
    private func notifyBackendActivity(for membership: VenueMembership) async throws {
        let endpoint = "/api/v1/users/\(membership.userId.uuidString)/activity"
        let body: [String: Any] = [
            "venueId": membership.venueId.uuidString,
            "lastActivityDate": ISO8601DateFormatter().string(from: membership.lastActivityDate)
        ]

        _ = try await apiClient.request(
            endpoint: endpoint,
            method: "PUT",
            body: body
        )
    }

    /// Fetch expiring points from backend
    func fetchExpiringPointsFromBackend(for userId: UUID) async throws -> [PointExpiration] {
        let endpoint = "/api/v1/users/\(userId.uuidString)/expiring-points"

        let response: [String: Any] = try await apiClient.request(
            endpoint: endpoint,
            method: "GET"
        )

        // Parse response (implementation depends on backend structure)
        // For now, return local data
        return try await fetchExpiringPoints(for: userId)
    }
}

// MARK: - Supporting Types

struct ExpirationCheckResult {
    let totalChecked: Int
    let expiredCount: Int
    let expiringCount: Int
    let totalPointsExpired: Int
    let expiredMemberships: [VenueMembership]
    let expiringMemberships: [VenueMembership]
}

enum ExpirationError: LocalizedError {
    case contextNotConfigured
    case membershipNotFound
    case expirationNotFound

    var errorDescription: String? {
        switch self {
        case .contextNotConfigured:
            return "Model context not configured"
        case .membershipNotFound:
            return "Venue membership not found"
        case .expirationNotFound:
            return "Expiration record not found"
        }
    }
}
