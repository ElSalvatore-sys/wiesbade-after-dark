//
//  CommentsViewModel.swift
//  WiesbadenAfterDark
//
//  Purpose: Manages comments for a post
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CommentsViewModel {
    var comments: [Comment] = []
    var isLoading = false

    func loadComments(for postId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        // Mock data
        try? await Task.sleep(for: .milliseconds(500))

        comments = [
            Comment(
                postId: postId,
                userId: UUID(),
                content: "Looks amazing! 🔥",
                userName: "Tom"
            ),
            Comment(
                postId: postId,
                userId: UUID(),
                content: "Wish I was there!",
                userName: "Emma"
            ),
            Comment(
                postId: postId,
                userId: UUID(),
                content: "Best place in Wiesbaden!",
                userName: "David"
            )
        ]
    }

    func postComment(_ text: String, on postId: UUID) async {
        let newComment = Comment(
            postId: postId,
            userId: UUID(),
            content: text,
            userName: "You"
        )

        comments.append(newComment)
    }
}
