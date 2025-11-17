//
//  Post.swift
//  WiesbadenAfterDark
//
//  Purpose: Social feed post model
//  Supports: Check-in posts, status updates, photos, comments
//

import Foundation
import SwiftData

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

    /// Number of likes
    var likeCount: Int

    /// Number of comments
    var commentCount: Int

    /// Has current user liked this?
    var isLikedByCurrentUser: Bool

    /// Creation timestamp
    var createdAt: Date

    /// User's display name
    var userName: String

    /// User's profile photo URL
    var userPhotoURL: String?

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
        userPhotoURL: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.content = content
        self.imageURL = imageURL
        self.venueId = venueId
        self.venueName = venueName
        self.likeCount = 0
        self.commentCount = 0
        self.isLikedByCurrentUser = false
        self.createdAt = Date()
        self.userName = userName
        self.userPhotoURL = userPhotoURL
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
