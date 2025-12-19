//
//  CommunityPostCard.swift
//  WiesbadenAfterDark
//
//  Community post card component for displaying social posts
//

import SwiftUI

/// Displays community post in a card format
struct CommunityPostCard: View {
    let post: CommunityPost
    var onLike: (() -> Void)?
    var onReply: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // User info row
            HStack(spacing: Theme.Spacing.md) {
                // Avatar (user initials)
                ZStack {
                    Circle()
                        .fill(Color(hex: post.userTier.color))
                        .frame(width: 44, height: 44)

                    Text(post.userInitials)
                        .font(Typography.headlineMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    // Username + tier badge
                    HStack(spacing: 6) {
                        Text(post.userName)
                            .font(Typography.headlineMedium)
                            .foregroundColor(.textPrimary)

                        // Tier badge
                        Text(post.userTier.displayName)
                            .font(Typography.captionSmall)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: post.userTier.color))
                            .cornerRadius(4)
                    }

                    // Timestamp
                    Text(post.timeAgo)
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            // Post content
            Text(post.content)
                .font(Typography.bodyMedium)
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // Post image (if available) - using cached loading
            if let imageURL = post.imageURL {
                CachedAsyncImage(
                    url: URL(string: imageURL),
                    targetSize: CGSize(width: 400, height: 200)
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 200)
                        .clipped()
                        .cornerRadius(Theme.CornerRadius.md)
                } placeholder: {
                    Rectangle()
                        .fill(Color.inputBackground)
                        .frame(height: 200)
                        .cornerRadius(Theme.CornerRadius.md)
                        .shimmer()
                }
            }

            Divider()
                .background(Color.textTertiary.opacity(0.2))

            // Actions row
            HStack(spacing: Theme.Spacing.xl) {
                // Like button
                Button(action: { onLike?() }) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLikedByCurrentUser ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(post.isLikedByCurrentUser ? .error : .textSecondary)

                        Text("\(post.likesCount)")
                            .font(Typography.labelMedium)
                            .foregroundColor(.textSecondary)
                    }
                }

                // Reply button
                Button(action: { onReply?() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondary)

                        if post.commentsCount > 0 {
                            Text("\(post.commentsCount)")
                                .font(Typography.labelMedium)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }

                Spacer()
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
}

// MARK: - Preview
#Preview("Community Posts") {
    ScrollView {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(CommunityPost.mockPostsForVenue(UUID()), id: \.id) { post in
                CommunityPostCard(post: post) {
                    print("Liked post")
                } onReply: {
                    print("Reply to post")
                }
            }
        }
        .padding()
    }
    .background(Color.appBackground)
}
