//
//  VenueCommunityTab.swift
//  WiesbadenAfterDark
//
//  Community tab with posts and social feed
//

import SwiftUI

/// Community tab with social posts
struct VenueCommunityTab: View {
    @Environment(VenueViewModel.self) private var viewModel
    @Environment(AuthenticationViewModel.self) private var authViewModel

    let venue: Venue

    @State private var newPostText = ""
    @State private var showingPostInput = false
    @State private var showingReplySheet = false
    @State private var replyToPost: CommunityPost?
    @State private var replyText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Header with create post button
                HStack {
                    Text("Community")
                        .font(Typography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Button(action: {
                        showingPostInput.toggle()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                            Text("Post")
                                .font(Typography.labelMedium)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, 8)
                        .background(Color.primaryGradient)
                        .cornerRadius(Theme.CornerRadius.pill)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.md)

                // Post input (if showing)
                if showingPostInput {
                    PostInputView(
                        text: $newPostText,
                        onCancel: {
                            showingPostInput = false
                            newPostText = ""
                        },
                        onPost: {
                            submitPost()
                        }
                    )
                    .padding(.horizontal, Theme.Spacing.lg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Posts feed
                if viewModel.communityPosts.isEmpty {
                    EmptyCommunityState()
                } else {
                    VStack(spacing: Theme.Spacing.md) {
                        ForEach(viewModel.communityPosts, id: \.id) { post in
                            CommunityPostCard(
                                post: post,
                                onLike: {
                                    viewModel.likePost(post)
                                },
                                onReply: {
                                    replyToPost = post
                                    showingReplySheet = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                }
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Color.appBackground)
        .animation(Theme.Animation.quick, value: showingPostInput)
        .sheet(isPresented: $showingReplySheet) {
            ReplySheetView(
                post: replyToPost,
                replyText: $replyText,
                onSubmit: submitReply,
                onCancel: {
                    showingReplySheet = false
                    replyText = ""
                    replyToPost = nil
                }
            )
            .presentationDetents([.medium])
        }
    }

    private func submitPost() {
        guard !newPostText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Get current user
        guard case .authenticated(let user) = authViewModel.authState else {
            print("❌ User not authenticated")
            return
        }

        viewModel.createPost(content: newPostText, user: user)

        // Clear input
        newPostText = ""
        showingPostInput = false
    }

    private func submitReply() {
        guard !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let post = replyToPost else { return }

        // Get current user
        guard case .authenticated(let user) = authViewModel.authState else {
            print("❌ User not authenticated")
            return
        }

        viewModel.replyToPost(post, comment: replyText, user: user)

        // Clear and dismiss
        replyText = ""
        replyToPost = nil
        showingReplySheet = false
    }
}

// MARK: - Reply Sheet View
private struct ReplySheetView: View {
    let post: CommunityPost?
    @Binding var replyText: String
    let onSubmit: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                // Original post preview
                if let post = post {
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        HStack {
                            Text(post.userName)
                                .font(Typography.labelMedium)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                            Text("·")
                                .foregroundColor(.textTertiary)
                            Text(post.timeAgo)
                                .font(Typography.captionMedium)
                                .foregroundColor(.textSecondary)
                        }
                        Text(post.content)
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Color.inputBackground)
                    .cornerRadius(Theme.CornerRadius.md)
                }

                // Reply input
                TextField("Write a reply...", text: $replyText, axis: .vertical)
                    .lineLimit(3...6)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)
                    .padding(Theme.Spacing.md)
                    .background(Color.inputBackground)
                    .cornerRadius(Theme.CornerRadius.md)

                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(Color.appBackground)
            .navigationTitle("Reply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Reply", action: onSubmit)
                        .fontWeight(.semibold)
                        .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Post Input View
private struct PostInputView: View {
    @Binding var text: String
    let onCancel: () -> Void
    let onPost: () -> Void

    private var canPost: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Input area
            TextField("What's happening at \(venue)?", text: $text, axis: .vertical)
                .lineLimit(3...8)
                .font(Typography.bodyMedium)
                .foregroundColor(.textPrimary)
                .padding(Theme.Spacing.md)
                .background(Color.inputBackground)
                .cornerRadius(Theme.CornerRadius.md)

            // Actions
            HStack {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(Typography.labelMedium)
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, 8)
                        .background(Color.inputBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                }

                Spacer()

                Button(action: onPost) {
                    Text("Post")
                        .font(Typography.labelMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, 8)
                        .background(canPost ? Color.primaryGradientStart : Color.textTertiary.opacity(0.3))
                        .cornerRadius(Theme.CornerRadius.md)
                }
                .disabled(!canPost)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
        .shadow(
            color: Theme.Shadow.sm.color,
            radius: Theme.Shadow.sm.radius,
            x: Theme.Shadow.sm.x,
            y: Theme.Shadow.sm.y
        )
    }

    private var venue: String {
        "this venue"
    }
}

// MARK: - Empty State
private struct EmptyCommunityState: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50))
                .foregroundColor(.textTertiary)

            Text("No Posts Yet")
                .font(Typography.titleMedium)
                .foregroundColor(.textPrimary)

            Text("Be the first to share something with the community!")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal, Theme.Spacing.xl)
    }
}

// MARK: - Preview
#Preview("Venue Community Tab") {
    VenueCommunityTab(venue: Venue.mockDasWohnzimmer())
        .environment(VenueViewModel())
        .environment(AuthenticationViewModel())
}
