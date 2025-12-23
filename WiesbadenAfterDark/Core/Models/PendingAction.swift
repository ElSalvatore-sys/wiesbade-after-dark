//
//  PendingAction.swift
//  WiesbadenAfterDark
//
//  SwiftData model for storing offline actions to be synced when back online
//

import Foundation
import SwiftData

/// Types of actions that can be queued for offline sync
enum PendingActionType: String, Codable {
    case checkIn = "check_in"
    case rsvp = "rsvp"
    case joinVenue = "join_venue"
    case redeemReward = "redeem_reward"
    case createPost = "create_post"
    case likePost = "like_post"
    case addComment = "add_comment"
    case updateProfile = "update_profile"
}

/// Status of a pending action
enum PendingActionStatus: String, Codable {
    case pending = "pending"
    case syncing = "syncing"
    case completed = "completed"
    case failed = "failed"
}

/// Represents an action that was performed offline and needs to be synced
@Model
final class PendingAction {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID

    /// The type of action
    var actionType: PendingActionType

    /// Current status of the action
    var status: PendingActionStatus

    /// JSON-encoded payload containing action-specific data
    var payloadJSON: String

    /// When the action was created
    var createdAt: Date

    /// When the action was last attempted
    var lastAttemptAt: Date?

    /// Number of sync attempts
    var attemptCount: Int

    /// Error message from last failed attempt
    var lastError: String?

    /// Priority (higher = sync first)
    var priority: Int

    /// User ID associated with this action
    var userId: UUID?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        actionType: PendingActionType,
        payload: [String: Any],
        priority: Int = 0,
        userId: UUID? = nil
    ) {
        self.id = id
        self.actionType = actionType
        self.status = .pending
        self.createdAt = Date()
        self.attemptCount = 0
        self.priority = priority
        self.userId = userId

        // Encode payload to JSON
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            self.payloadJSON = jsonString
        } else {
            self.payloadJSON = "{}"
        }
    }
}

// MARK: - Computed Properties

extension PendingAction {
    /// Decoded payload dictionary
    var payload: [String: Any] {
        guard let data = payloadJSON.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return dict
    }

    /// Whether this action can be retried
    var canRetry: Bool {
        return attemptCount < 3 && status != .completed
    }

    /// Time since action was created
    var age: TimeInterval {
        return Date().timeIntervalSince(createdAt)
    }

    /// Human-readable description of the action
    var actionDescription: String {
        switch actionType {
        case .checkIn:
            return "Check-in"
        case .rsvp:
            return "RSVP für Event"
        case .joinVenue:
            return "Venue beitreten"
        case .redeemReward:
            return "Belohnung einlösen"
        case .createPost:
            return "Beitrag erstellen"
        case .likePost:
            return "Beitrag liken"
        case .addComment:
            return "Kommentar hinzufügen"
        case .updateProfile:
            return "Profil aktualisieren"
        }
    }
}

// MARK: - Convenience Methods

extension PendingAction {
    /// Mark this action as syncing
    func markSyncing() {
        status = .syncing
        lastAttemptAt = Date()
        attemptCount += 1
    }

    /// Mark this action as completed
    func markCompleted() {
        status = .completed
        lastError = nil
    }

    /// Mark this action as failed
    func markFailed(error: String) {
        status = .failed
        lastError = error
    }

    /// Reset to pending for retry
    func resetForRetry() {
        status = .pending
        lastError = nil
    }
}
