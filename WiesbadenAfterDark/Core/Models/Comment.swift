//
//  Comment.swift
//  WiesbadenAfterDark
//
//  Purpose: Comments on social posts
//

import Foundation
import SwiftData

/// Comment on a social post
@Model
final class Comment: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID

    /// Post this comment belongs to
    var postId: UUID

    /// User who wrote the comment
    var userId: UUID

    /// Comment text
    var content: String

    /// Number of likes on this comment
    var likeCount: Int

    /// Creation timestamp
    var createdAt: Date

    /// User's display name
    var userName: String

    /// User's profile photo URL
    var userPhotoURL: String?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        postId: UUID,
        userId: UUID,
        content: String,
        userName: String,
        userPhotoURL: String? = nil
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.content = content
        self.likeCount = 0
        self.createdAt = Date()
        self.userName = userName
        self.userPhotoURL = userPhotoURL
    }
}

// MARK: - Mock Data

extension Comment {
    static func mock(
        content: String = "Looks amazing!",
        userName: String = "Sarah"
    ) -> Comment {
        Comment(
            postId: UUID(),
            userId: UUID(),
            content: content,
            userName: userName
        )
    }
}
