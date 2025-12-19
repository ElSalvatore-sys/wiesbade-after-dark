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
    var onReaction: ((ReactionType) -> Void)? = nil
    var onRemoveReaction: (() -> Void)? = nil
    var onCommentTap: (() -> Void)? = nil
    var onUsernameTap: ((String) -> Void)? = nil
    @State private var showComments = false
    @State private var showReactionPicker = false
    @State private var selectedReactionScale: [ReactionType: CGFloat] = [:]
    @State private var reactionButtonScale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User header
            userHeader

            // Post content
            postContent

            // Post image (if exists) - supports any post type with an image
            if let imageURL = post.imageURL, !imageURL.isEmpty {
                postImage(url: imageURL)
                    .onTapGesture(count: 2) {
                        // Double-tap to love (Instagram-style)
                        if !post.hasUserReacted {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                reactionButtonScale = 1.5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    reactionButtonScale = 1.0
                                }
                            }
                            onReaction?(.love)
                            HapticManager.shared.medium()
                        }
                    }
            }

            // Venue tag (for check-ins)
            if let venueName = post.venueName {
                venueTag(venueName)
            }

            // Interaction bar (likes, comments)
            interactionBar

            // Comments preview section
            if post.commentCount > 0 || !post.previewComments.isEmpty {
                commentsPreviewSection
            }

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
            // Profile photo - using cached loading
            if let photoURL = post.userPhotoURL {
                CachedAsyncImage(
                    url: URL(string: photoURL),
                    targetSize: CGSize(width: 88, height: 88)
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .shimmer()
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

    /// Post image with improved loading state - using cached loading
    /// Supports http/https URLs and adapts to different image sizes
    private func postImage(url: String) -> some View {
        // Ensure URL is valid (supports both http and https)
        let validURL = url.hasPrefix("http") ? URL(string: url) : URL(string: "https://\(url)")

        return CachedAsyncImage(
            url: validURL,
            targetSize: CGSize(width: 400, height: 200)
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
        } placeholder: {
            ZStack {
                Rectangle()
                    .fill(Color.cardBackground)

                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .shimmer()
        }
        .cornerRadius(Theme.CornerRadius.md)
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

    /// Reactions and comments bar
    private var interactionBar: some View {
        HStack(spacing: 16) {
            // Reaction button with long-press picker
            reactionButton

            // Reaction counts display
            if post.totalReactionCount > 0 {
                reactionCountsView
            }

            Spacer()

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

            // Share button
            ShareLink(item: shareText) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.gray)
            }
        }
        .overlay(alignment: .bottomLeading) {
            if showReactionPicker {
                reactionPickerOverlay
                    .transition(.scale(scale: 0.8, anchor: .bottomLeading).combined(with: .opacity))
            }
        }
    }

    /// Text to share when user taps share button
    private var shareText: String {
        var text = "\(post.userName) on WiesbadenAfterDark: \(post.content)"

        if let imageURL = post.imageURL, !imageURL.isEmpty {
            text += "\n\n\(imageURL)"
        }

        text += "\n\nCheck it out on WiesbadenAfterDark!"

        return text
    }

    // MARK: - Reaction Button

    private var reactionButton: some View {
        Button {
            // Quick tap: toggle love reaction
            if post.hasUserReacted {
                onRemoveReaction?()
            } else {
                onReaction?(.love)
            }
            HapticManager.shared.light()
        } label: {
            HStack(spacing: 6) {
                if let userReaction = post.userReactionType {
                    Text(userReaction.emoji)
                        .font(.title3)
                        .scaleEffect(reactionButtonScale)
                } else {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                        .scaleEffect(reactionButtonScale)
                }
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.3)
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showReactionPicker = true
                    }
                    HapticManager.shared.medium()
                }
        )
    }

    // MARK: - Reaction Picker Overlay

    private var reactionPickerOverlay: some View {
        HStack(spacing: 8) {
            ForEach(ReactionType.allCases, id: \.self) { reaction in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        showReactionPicker = false
                    }
                    onReaction?(reaction)
                    HapticManager.shared.medium()
                } label: {
                    Text(reaction.emoji)
                        .font(.title)
                        .scaleEffect(selectedReactionScale[reaction] ?? 1.0)
                        .padding(6)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                selectedReactionScale[reaction] = 1.4
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                selectedReactionScale[reaction] = 1.0
                            }
                        }
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        )
        .offset(y: -50)
        .onTapGesture {} // Prevent dismiss on picker tap
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showReactionPicker = false
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        )
    }

    // MARK: - Reaction Counts View

    private var reactionCountsView: some View {
        HStack(spacing: 4) {
            // Show top 3 reactions with counts
            ForEach(topReactions, id: \.type) { reaction in
                HStack(spacing: 2) {
                    Text(reaction.type.emoji)
                        .font(.caption)
                    Text("\(reaction.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    /// Get top 3 reactions sorted by count
    private var topReactions: [(type: ReactionType, count: Int)] {
        post.reactionCounts
            .compactMap { key, count -> (type: ReactionType, count: Int)? in
                guard let type = ReactionType(rawValue: key), count > 0 else { return nil }
                return (type, count)
            }
            .sorted { $0.count > $1.count }
            .prefix(3)
            .map { $0 }
    }

    // MARK: - Comments Preview Section

    private var commentsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // "View all X comments" link (if more than 2 comments)
            if post.commentCount > 2 {
                Button {
                    if let onCommentTap = onCommentTap {
                        onCommentTap()
                    } else {
                        showComments = true
                    }
                    HapticManager.shared.light()
                } label: {
                    Text("View all \(post.commentCount) comments")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Preview comments (1-2 most recent)
            ForEach(post.previewComments.prefix(2)) { comment in
                commentPreviewRow(comment)
            }
        }
    }

    /// Single comment preview row
    private func commentPreviewRow(_ comment: PreviewComment) -> some View {
        HStack(alignment: .top, spacing: 4) {
            // Tappable username
            Button {
                onUsernameTap?(comment.userName)
                HapticManager.shared.light()
            } label: {
                Text(comment.userName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
            }

            // Comment text (truncated)
            Text(comment.content)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(2)
                .truncationMode(.tail)

            Spacer(minLength: 0)
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
