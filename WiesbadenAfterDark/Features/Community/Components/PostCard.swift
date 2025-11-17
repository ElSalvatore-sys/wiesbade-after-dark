//
//  PostCard.swift
//  WiesbadenAfterDark
//
//  Purpose: Individual post card in social feed
//  Shows: User info, post content, likes, comments
//

import SwiftUI

/// Card displaying a single social post
/// Supports: Check-ins, status, photos, achievements
struct PostCard: View {
    let post: Post
    @State private var showComments = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User header
            userHeader

            // Post content
            postContent

            // Post image (if exists)
            if let imageURL = post.imageURL {
                postImage(url: imageURL)
            }

            // Venue tag (for check-ins)
            if let venueName = post.venueName {
                venueTag(venueName)
            }

            // Interaction bar (likes, comments)
            interactionBar

            Divider()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
        .sheet(isPresented: $showComments) {
            CommentsView(postId: post.id)
        }
    }

    // MARK: - Subviews

    /// User profile header
    private var userHeader: some View {
        HStack(spacing: 12) {
            // Profile photo
            if let photoURL = post.userPhotoURL {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                // Default avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(post.userName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(post.userName)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Text(post.createdAt.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Post type badge
            postTypeBadge
        }
    }

    /// Post type indicator
    private var postTypeBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: post.type.icon)
                .font(.caption)
            Text(post.type.displayName)
                .font(.caption)
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }

    /// Post text content
    private var postContent: some View {
        Text(post.content)
            .font(.body)
            .foregroundColor(.primary)
    }

    /// Post image
    private func postImage(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
        }
        .frame(height: 250)
        .clipped()
        .cornerRadius(12)
    }

    /// Venue location tag
    private func venueTag(_ name: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.red)
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }

    /// Likes and comments bar
    private var interactionBar: some View {
        HStack(spacing: 24) {
            // Like button
            Button {
                // TODO: Toggle like
                HapticManager.shared.light()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: post.isLikedByCurrentUser ? "heart.fill" : "heart")
                        .foregroundColor(post.isLikedByCurrentUser ? .red : .gray)
                    Text("\(post.likeCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Comment button
            Button {
                showComments = true
                HapticManager.shared.light()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                        .foregroundColor(.gray)
                    Text("\(post.commentCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Post Type Extensions

extension PostType {
    var icon: String {
        switch self {
        case .checkIn: return "location.circle.fill"
        case .status: return "text.bubble.fill"
        case .photo: return "photo.fill"
        case .achievement: return "star.circle.fill"
        }
    }

    var displayName: String {
        switch self {
        case .checkIn: return "Check-in"
        case .status: return "Status"
        case .photo: return "Photo"
        case .achievement: return "Achievement"
        }
    }
}

// MARK: - Date Extension

extension Date {
    var timeAgo: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: self, to: now)

        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        } else {
            return "Just now"
        }
    }
}

#Preview {
    PostCard(post: .mock())
        .background(Color.appBackground)
}
