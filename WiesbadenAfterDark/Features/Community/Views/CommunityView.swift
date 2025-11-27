//
//  CommunityView.swift
//  WiesbadenAfterDark
//
//  Purpose: Main community/social feed tab
//  Shows: User posts, check-ins, activity feed
//

import SwiftUI

/// Main community feed view
/// Instagram/Twitter-style social feed
struct CommunityView: View {
    @State private var viewModel = CommunityViewModel()
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Activity header (tappable to filter by venue)
                        ActivityHeaderSection(
                            onVenueTap: { venueName in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.filterByVenue(venueName)
                                }
                            }
                        )
                        .padding(.horizontal)

                        // Filter chips
                        filterChipsView
                            .padding(.top, Theme.Spacing.xs)

                        // Venue filter indicator (when active)
                        if let venueName = viewModel.selectedVenueFilter {
                            venueFilterBadge(venueName)
                                .padding(.horizontal)
                        }

                        // Posts feed
                        if viewModel.filteredPosts.isEmpty && !viewModel.isLoading {
                            emptyStateView
                                .padding(.top, Theme.Spacing.xl)
                        } else {
                            ForEach(viewModel.filteredPosts, id: \.id) { post in
                                PostCard(
                                    post: post,
                                    onReaction: { reactionType in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            viewModel.addReaction(postId: post.id, type: reactionType)
                                        }
                                    },
                                    onRemoveReaction: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            viewModel.removeReaction(postId: post.id)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color.appBackground.ignoresSafeArea())

                // Loading overlay
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                            .scaleEffect(1.5)

                        Text("Loading community...")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.appBackground)
                }
            }
            .navigationTitle("Community")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreatePost = true
                        HapticManager.shared.medium()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
            .refreshable {
                await viewModel.loadPosts()
            }
            .task {
                await viewModel.loadPosts()
            }
        }
    }

    // MARK: - Filter Chips

    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(PostFilter.allCases, id: \.self) { filter in
                    CommunityFilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
    }

    // MARK: - Venue Filter Badge

    private func venueFilterBadge(_ venueName: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.red)

            Text("Showing posts from \(venueName)")
                .font(Typography.captionMedium)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.clearVenueFilter()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Color.red.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.md)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)

            Text(emptyStateTitle)
                .font(Typography.titleSmall)
                .foregroundStyle(Color.textPrimary)

            Text(emptyStateMessage)
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            if viewModel.selectedFilter != .all || viewModel.selectedVenueFilter != nil {
                Button {
                    withAnimation {
                        viewModel.selectedFilter = .all
                        viewModel.clearVenueFilter()
                    }
                } label: {
                    Text("Show All Posts")
                        .font(Typography.buttonMedium)
                        .foregroundColor(.primary)
                }
                .padding(.top, Theme.Spacing.sm)
            }
        }
        .padding(Theme.Spacing.xl)
    }

    private var emptyStateIcon: String {
        switch viewModel.selectedFilter {
        case .all: return "bubble.left.and.bubble.right"
        case .checkIns: return "location.circle"
        case .photos: return "photo"
        case .achievements: return "star.circle"
        }
    }

    private var emptyStateTitle: String {
        if viewModel.selectedVenueFilter != nil {
            return "No Posts from This Venue"
        }
        switch viewModel.selectedFilter {
        case .all: return "No Posts Yet"
        case .checkIns: return "No Check-ins Yet"
        case .photos: return "No Photos Yet"
        case .achievements: return "No Achievements Yet"
        }
    }

    private var emptyStateMessage: String {
        if viewModel.selectedVenueFilter != nil {
            return "Be the first to post from here!"
        }
        switch viewModel.selectedFilter {
        case .all: return "Be the first to share something!"
        case .checkIns: return "Check in at a venue to see posts here"
        case .photos: return "Share a photo to see posts here"
        case .achievements: return "Earn achievements to see posts here"
        }
    }
}

// MARK: - Community Filter Chip

private struct CommunityFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.captionMedium)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    Group {
                        if isSelected {
                            Color.primaryGradient
                        } else {
                            Color.cardBackground
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.cardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CommunityView()
}
