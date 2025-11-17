//
//  CommentsView.swift
//  WiesbadenAfterDark
//
//  Purpose: Comments sheet for a post
//  Chat-like interface for discussions
//

import SwiftUI

/// Comments view with chat-like interface
struct CommentsView: View {
    let postId: UUID
    @State private var viewModel = CommentsViewModel()
    @State private var commentText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Comments list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.comments, id: \.id) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                    .padding()
                }

                // Input bar
                commentInputBar
            }
            .background(Color.appBackground)
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadComments(for: postId)
            }
        }
    }

    /// Comment input bar (chat-style)
    private var commentInputBar: some View {
        HStack(spacing: 12) {
            // Text field
            TextField("Add a comment...", text: $commentText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color.cardBackground)
                .cornerRadius(20)
                .lineLimit(1...4)

            // Send button
            Button {
                sendComment()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(commentText.isEmpty ? .gray : .blue)
            }
            .disabled(commentText.isEmpty)
        }
        .padding()
        .background(Color.appBackground)
    }

    private func sendComment() {
        guard !commentText.isEmpty else { return }

        Task {
            await viewModel.postComment(commentText, on: postId)
            commentText = ""
            HapticManager.shared.medium()
        }
    }
}

// MARK: - Comment Row

/// Single comment row
struct CommentRow: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // User avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(comment.userName.prefix(1)))
                        .font(.subheadline)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                // User name and time
                HStack {
                    Text(comment.userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)

                    Text(comment.createdAt.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Comment text
                Text(comment.content)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
            }

            Spacer()
        }
    }
}

#Preview {
    CommentsView(postId: UUID())
}
