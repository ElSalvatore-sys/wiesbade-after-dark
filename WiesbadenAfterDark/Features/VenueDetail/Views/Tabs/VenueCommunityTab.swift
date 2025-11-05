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
                                    // TODO: Implement reply
                                    print("Reply to post: \(post.id)")
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
    }

    private func submitPost() {
        guard !newPostText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // TODO: Implement post creation
        print("📝 Creating post: \(newPostText)")

        // Clear input
        newPostText = ""
        showingPostInput = false
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
