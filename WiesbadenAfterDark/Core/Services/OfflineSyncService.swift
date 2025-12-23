//
//  OfflineSyncService.swift
//  WiesbadenAfterDark
//
//  Manages offline caching and synchronization of pending actions
//

import Foundation
import SwiftData
import Observation

/// Service for managing offline data caching and sync
@Observable
@MainActor
final class OfflineSyncService {
    // MARK: - Singleton

    static let shared = OfflineSyncService()

    // MARK: - Properties

    /// Number of pending actions waiting to sync
    private(set) var pendingActionsCount: Int = 0

    /// Whether a sync is currently in progress
    private(set) var isSyncing: Bool = false

    /// Last successful sync time
    private(set) var lastSyncTime: Date?

    /// Model context for SwiftData operations
    private var modelContext: ModelContext?

    /// Last cache update time for venues
    private(set) var lastVenueCacheUpdate: Date?

    /// Last cache update time for user profile
    private(set) var lastProfileCacheUpdate: Date?

    // MARK: - Initialization

    private init() {
        // Listen for network becoming available
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkBecameAvailable),
            name: .networkBecameAvailable,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Configuration

    /// Configure the service with a model context
    func configure(with context: ModelContext) {
        self.modelContext = context
        refreshPendingCount()

        #if DEBUG
        print("💾 [OfflineSyncService] Configured with model context")
        #endif
    }

    // MARK: - Caching

    /// Cache venues locally in SwiftData
    func cacheVenues(_ venues: [Venue]) {
        guard let context = modelContext else {
            #if DEBUG
            print("⚠️ [OfflineSyncService] No model context available for caching venues")
            #endif
            return
        }

        do {
            // Insert or update venues
            for venue in venues {
                context.insert(venue)
            }

            try context.save()
            lastVenueCacheUpdate = Date()

            #if DEBUG
            print("💾 [OfflineSyncService] Cached \(venues.count) venues locally")
            #endif
        } catch {
            #if DEBUG
            print("❌ [OfflineSyncService] Failed to cache venues: \(error)")
            #endif
        }
    }

    /// Cache user profile locally
    func cacheUserProfile(_ user: User) {
        guard let context = modelContext else {
            #if DEBUG
            print("⚠️ [OfflineSyncService] No model context available for caching user")
            #endif
            return
        }

        do {
            context.insert(user)
            try context.save()
            lastProfileCacheUpdate = Date()

            #if DEBUG
            print("💾 [OfflineSyncService] Cached user profile locally")
            #endif
        } catch {
            #if DEBUG
            print("❌ [OfflineSyncService] Failed to cache user profile: \(error)")
            #endif
        }
    }

    /// Load cached venues from SwiftData
    func loadCachedVenues() -> [Venue] {
        guard let context = modelContext else { return [] }

        do {
            let descriptor = FetchDescriptor<Venue>(
                sortBy: [SortDescriptor(\.name)]
            )
            let venues = try context.fetch(descriptor)

            #if DEBUG
            print("💾 [OfflineSyncService] Loaded \(venues.count) cached venues")
            #endif

            return venues
        } catch {
            #if DEBUG
            print("❌ [OfflineSyncService] Failed to load cached venues: \(error)")
            #endif
            return []
        }
    }

    /// Load cached user profile from SwiftData
    func loadCachedUser(userId: UUID) -> User? {
        guard let context = modelContext else { return nil }

        do {
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate { $0.id == userId }
            )
            let users = try context.fetch(descriptor)
            return users.first
        } catch {
            #if DEBUG
            print("❌ [OfflineSyncService] Failed to load cached user: \(error)")
            #endif
            return nil
        }
    }

    // MARK: - Action Queuing

    /// Queue an action to be synced when online
    func queueAction(
        type: PendingActionType,
        payload: [String: Any],
        priority: Int = 0,
        userId: UUID? = nil
    ) {
        guard let context = modelContext else {
            #if DEBUG
            print("⚠️ [OfflineSyncService] No model context for queueing action")
            #endif
            return
        }

        let action = PendingAction(
            actionType: type,
            payload: payload,
            priority: priority,
            userId: userId
        )

        context.insert(action)

        do {
            try context.save()
            refreshPendingCount()

            #if DEBUG
            print("📤 [OfflineSyncService] Queued action: \(type.rawValue)")
            #endif

            // Trigger haptic feedback
            HapticManager.shared.warning()

        } catch {
            #if DEBUG
            print("❌ [OfflineSyncService] Failed to queue action: \(error)")
            #endif
        }
    }

    /// Get all pending actions
    func getPendingActions() -> [PendingAction] {
        guard let context = modelContext else { return [] }

        do {
            // Fetch all pending actions and filter in memory
            // (SwiftData predicates don't support direct enum case comparison)
            let descriptor = FetchDescriptor<PendingAction>(
                sortBy: [
                    SortDescriptor(\.priority, order: .reverse),
                    SortDescriptor(\.createdAt)
                ]
            )
            let allActions = try context.fetch(descriptor)

            // Filter to only pending or failed actions
            return allActions.filter { action in
                action.status == .pending || action.status == .failed
            }
        } catch {
            #if DEBUG
            print("❌ [OfflineSyncService] Failed to fetch pending actions: \(error)")
            #endif
            return []
        }
    }

    // MARK: - Synchronization

    /// Sync all pending actions when back online
    func syncPendingActions() async {
        guard !isSyncing else {
            #if DEBUG
            print("⏳ [OfflineSyncService] Sync already in progress")
            #endif
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            #if DEBUG
            print("📴 [OfflineSyncService] Cannot sync - offline")
            #endif
            return
        }

        isSyncing = true

        #if DEBUG
        print("🔄 [OfflineSyncService] Starting sync of pending actions...")
        #endif

        let actions = getPendingActions()

        for action in actions {
            guard action.canRetry else {
                #if DEBUG
                print("⚠️ [OfflineSyncService] Action \(action.id) exceeded retry limit")
                #endif
                continue
            }

            action.markSyncing()

            do {
                try await performAction(action)
                action.markCompleted()

                // Remove completed action
                modelContext?.delete(action)

                #if DEBUG
                print("✅ [OfflineSyncService] Synced action: \(action.actionType.rawValue)")
                #endif

            } catch {
                action.markFailed(error: error.localizedDescription)

                #if DEBUG
                print("❌ [OfflineSyncService] Failed to sync action: \(error)")
                #endif
            }
        }

        // Save changes
        try? modelContext?.save()

        isSyncing = false
        lastSyncTime = Date()
        refreshPendingCount()

        // Play success sound if all synced
        if pendingActionsCount == 0 {
            SoundManager.shared.playCheckInSuccess(withHaptic: true)
        }

        #if DEBUG
        print("✅ [OfflineSyncService] Sync complete. Pending: \(pendingActionsCount)")
        #endif
    }

    // MARK: - Private Methods

    private func refreshPendingCount() {
        pendingActionsCount = getPendingActions().count
    }

    @objc private func networkBecameAvailable() {
        Task { @MainActor in
            await syncPendingActions()
        }
    }

    /// Perform the actual sync of a pending action
    private func performAction(_ action: PendingAction) async throws {
        let payload = action.payload

        switch action.actionType {
        case .checkIn:
            // Sync check-in
            guard let venueIdString = payload["venueId"] as? String,
                  let venueId = UUID(uuidString: venueIdString),
                  let userIdString = payload["userId"] as? String,
                  let userId = UUID(uuidString: userIdString) else {
                throw SyncError.invalidPayload
            }

            // Get venue name from payload or use default
            let venueName = payload["venueName"] as? String ?? "Venue"

            // Determine check-in method from payload
            let methodString = payload["method"] as? String ?? "QR Code"
            let method = CheckInMethod(rawValue: methodString) ?? CheckInMethod.qr

            // Call the real check-in service
            _ = try await RealCheckInService.shared.performCheckIn(
                userId: userId,
                venueId: venueId,
                venueName: venueName,
                method: method
            )

        case .rsvp:
            // Sync RSVP
            guard let eventIdString = payload["eventId"] as? String,
                  let eventId = UUID(uuidString: eventIdString),
                  let statusString = payload["status"] as? String,
                  let status = RSVPStatus(rawValue: statusString) else {
                throw SyncError.invalidPayload
            }

            try await HybridVenueService.shared.rsvpEvent(eventId: eventId, status: status)

        case .joinVenue:
            // Sync join venue
            guard let venueIdString = payload["venueId"] as? String,
                  let venueId = UUID(uuidString: venueIdString),
                  let userIdString = payload["userId"] as? String,
                  let userId = UUID(uuidString: userIdString) else {
                throw SyncError.invalidPayload
            }

            _ = try await HybridVenueService.shared.joinVenue(venueId: venueId, userId: userId)

        case .redeemReward:
            // Sync reward redemption
            guard let rewardIdString = payload["rewardId"] as? String,
                  let rewardId = UUID(uuidString: rewardIdString),
                  let membershipIdString = payload["membershipId"] as? String,
                  let membershipId = UUID(uuidString: membershipIdString) else {
                throw SyncError.invalidPayload
            }

            try await HybridVenueService.shared.redeemReward(rewardId: rewardId, membershipId: membershipId)

        case .createPost, .likePost, .addComment:
            // Community actions - implement when community service is ready
            #if DEBUG
            print("📝 [OfflineSyncService] Community action sync not yet implemented")
            #endif

        case .updateProfile:
            // Profile update sync
            #if DEBUG
            print("📝 [OfflineSyncService] Profile update sync not yet implemented")
            #endif
        }
    }
}

// MARK: - Sync Errors

enum SyncError: Error, LocalizedError {
    case invalidPayload
    case networkError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidPayload:
            return "Ungültige Daten für Synchronisation"
        case .networkError:
            return "Netzwerkfehler bei der Synchronisation"
        case .serverError(let message):
            return "Serverfehler: \(message)"
        }
    }
}
