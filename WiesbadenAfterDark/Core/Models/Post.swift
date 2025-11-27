//
//  Post.swift
//  WiesbadenAfterDark
//
//  Purpose: Social feed post model
//  Supports: Check-in posts, status updates, photos, comments
//

import Foundation
import SwiftData

// MARK: - Preview Comment

/// Lightweight comment for preview display (not persisted)
struct PreviewComment: Identifiable {
    let id: UUID
    let userName: String
    let content: String

    init(id: UUID = UUID(), userName: String, content: String) {
        self.id = id
        self.userName = userName
        self.content = content
    }
}

// MARK: - Reaction Type

/// Available reaction types for posts
enum ReactionType: String, CaseIterable, Codable {
    case love = "love"
    case fire = "fire"
    case laugh = "laugh"
    case wow = "wow"

    var emoji: String {
        switch self {
        case .love: return "❤️"
        case .fire: return "🔥"
        case .laugh: return "😂"
        case .wow: return "😍"
        }
    }
}

/// Social feed post shared by users
/// Can be: check-in, status, photo, or achievement
@Model
final class Post: @unchecked Sendable {
    // MARK: - Properties

    /// Unique post identifier
    @Attribute(.unique) var id: UUID

    /// User who created the post
    var userId: UUID

    /// Post type (check-in, status, photo, achievement)
    var type: PostType

    /// Text content of the post
    var content: String

    /// Optional image URL
    var imageURL: String?

    /// Venue ID (for check-in posts)
    var venueId: UUID?

    /// Venue name (for display)
    var venueName: String?

    /// Number of likes (legacy - now use reactions)
    var likeCount: Int

    /// Number of comments
    var commentCount: Int

    /// Has current user liked this? (legacy - now use currentUserReaction)
    var isLikedByCurrentUser: Bool

    /// Reaction counts by type
    var reactionCounts: [String: Int]

    /// Current user's reaction (nil if no reaction)
    var currentUserReaction: String?

    /// Creation timestamp
    var createdAt: Date

    /// User's display name
    var userName: String

    /// User's profile photo URL
    var userPhotoURL: String?

    /// Preview of recent comments (1-2 most recent)
    @Transient var previewComments: [PreviewComment] = []

    // MARK: - Computed Properties

    /// Total reaction count across all types
    var totalReactionCount: Int {
        reactionCounts.values.reduce(0, +)
    }

    /// Get current user's reaction type
    var userReactionType: ReactionType? {
        guard let reaction = currentUserReaction else { return nil }
        return ReactionType(rawValue: reaction)
    }

    /// Check if user has reacted
    var hasUserReacted: Bool {
        currentUserReaction != nil
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        type: PostType,
        content: String,
        imageURL: String? = nil,
        venueId: UUID? = nil,
        venueName: String? = nil,
        userName: String,
        userPhotoURL: String? = nil,
        reactionCounts: [String: Int]? = nil,
        commentCount: Int = 0,
        previewComments: [PreviewComment] = []
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.content = content
        self.imageURL = imageURL
        self.venueId = venueId
        self.venueName = venueName
        self.likeCount = 0
        self.commentCount = commentCount
        self.isLikedByCurrentUser = false
        self.reactionCounts = reactionCounts ?? [:]
        self.currentUserReaction = nil
        self.createdAt = Date()
        self.userName = userName
        self.userPhotoURL = userPhotoURL
        self.previewComments = previewComments
    }

    // MARK: - Reaction Methods

    /// Add or change reaction
    func addReaction(_ type: ReactionType) {
        // Remove old reaction if exists
        if let oldReaction = currentUserReaction {
            reactionCounts[oldReaction, default: 0] -= 1
            if reactionCounts[oldReaction, default: 0] <= 0 {
                reactionCounts.removeValue(forKey: oldReaction)
            }
        }

        // Add new reaction
        currentUserReaction = type.rawValue
        reactionCounts[type.rawValue, default: 0] += 1

        // Update legacy fields for backward compatibility
        isLikedByCurrentUser = true
        likeCount = totalReactionCount
    }

    /// Remove user's reaction
    func removeReaction() {
        if let oldReaction = currentUserReaction {
            reactionCounts[oldReaction, default: 0] -= 1
            if reactionCounts[oldReaction, default: 0] <= 0 {
                reactionCounts.removeValue(forKey: oldReaction)
            }
        }
        currentUserReaction = nil

        // Update legacy fields
        isLikedByCurrentUser = false
        likeCount = totalReactionCount
    }

    /// Toggle reaction (add if not present, remove if same, change if different)
    func toggleReaction(_ type: ReactionType) {
        if currentUserReaction == type.rawValue {
            removeReaction()
        } else {
            addReaction(type)
        }
    }
}

// MARK: - Post Type

enum PostType: String, Codable {
    case checkIn = "check_in"      // "I'm at Das Wohnzimmer 🍻"
    case status = "status"          // "Great night out!"
    case photo = "photo"            // Photo with caption
    case achievement = "achievement" // "Reached Gold tier!"
}

// MARK: - Mock Data

extension Post {
    static func mock(
        type: PostType = .checkIn,
        content: String = "Having a great time! 🎉",
        venueName: String? = "Das Wohnzimmer",
        userName: String = "Alex"
    ) -> Post {
        Post(
            userId: UUID(),
            type: type,
            content: content,
            venueId: UUID(),
            venueName: venueName,
            userName: userName
        )
    }
}
