//
//  CommunityViewModel.swift
//  WiesbadenAfterDark
//
//  Purpose: Manages community feed data
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CommunityViewModel {
    var posts: [Post] = []
    var isLoading = false
    var error: Error?

    // Filter state
    var selectedFilter: PostFilter = .all
    var selectedVenueFilter: String? = nil

    // Filtered posts based on current filter
    var filteredPosts: [Post] {
        var result = posts

        // Apply venue filter first (from Live Activity tap)
        if let venueName = selectedVenueFilter {
            result = result.filter { $0.venueName == venueName }
        }

        // Then apply type filter
        switch selectedFilter {
        case .all:
            return result
        case .checkIns:
            return result.filter { $0.type == .checkIn }
        case .photos:
            return result.filter { $0.type == .photo }
        case .achievements:
            return result.filter { $0.type == .achievement }
        }
    }

    func loadPosts() async {
        isLoading = true
        defer { isLoading = false }

        // Mock data for now (reduced delay for faster demo)
        try? await Task.sleep(for: .milliseconds(300))

        posts = [
            Post(
                userId: UUID(),
                type: .checkIn,
                content: "Amazing night at Das Wohnzimmer! 🍻 The DJ is killing it!",
                imageURL: "https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=800&q=80",
                venueId: UUID(),
                venueName: "Das Wohnzimmer",
                userName: "Alex M.",
                reactionCounts: ["love": 12, "fire": 8, "wow": 3],
                commentCount: 8,
                previewComments: [
                    PreviewComment(userName: "Sarah K.", content: "Love this place! 🔥"),
                    PreviewComment(userName: "Mike R.", content: "The DJ was amazing tonight!")
                ]
            ),
            Post(
                userId: UUID(),
                type: .achievement,
                content: "Just reached Gold tier! 🎉 Thanks WiesbadenAfterDark!",
                userName: "Sarah K.",
                reactionCounts: ["love": 24, "fire": 15, "laugh": 2],
                commentCount: 5,
                previewComments: [
                    PreviewComment(userName: "Tom B.", content: "Congrats! 🎊 You're crushing it!"),
                    PreviewComment(userName: "Emma L.", content: "Well deserved! See you at the next event")
                ]
            ),
            Post(
                userId: UUID(),
                type: .photo,
                content: "Best cocktails in town! 🍹",
                imageURL: "https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&q=80",
                venueId: UUID(),
                venueName: "Park Café",
                userName: "Mike R.",
                reactionCounts: ["love": 18, "wow": 7],
                commentCount: 2,
                previewComments: [
                    PreviewComment(userName: "Lisa T.", content: "Those cocktails look incredible! What's the one on the left?")
                ]
            ),
            Post(
                userId: UUID(),
                type: .checkIn,
                content: "Great vibes tonight! Love this place ❤️",
                imageURL: "https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=800&q=80",
                venueId: UUID(),
                venueName: "Harput Restaurant",
                userName: "Lisa T.",
                reactionCounts: ["fire": 9, "love": 6],
                commentCount: 0,
                previewComments: []
            ),
            Post(
                userId: UUID(),
                type: .photo,
                content: "Saturday night done right! 📸",
                imageURL: "https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?w=800&q=80",
                venueId: UUID(),
                venueName: "Das Wohnzimmer",
                userName: "Tom B.",
                reactionCounts: ["love": 31, "fire": 12, "wow": 5, "laugh": 2],
                commentCount: 12,
                previewComments: [
                    PreviewComment(userName: "Alex M.", content: "Great shot! What camera do you use?"),
                    PreviewComment(userName: "Sarah K.", content: "This is SO good 📸")
                ]
            ),
            Post(
                userId: UUID(),
                type: .checkIn,
                content: "First time here and already in love! 🥰",
                imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80",
                venueId: UUID(),
                venueName: "Park Café",
                userName: "Emma L.",
                reactionCounts: ["love": 14, "wow": 8],
                commentCount: 1,
                previewComments: [
                    PreviewComment(userName: "Mike R.", content: "Welcome! You'll love it here")
                ]
            )
        ]
    }

    /// Add or change reaction on a post
    func addReaction(postId: UUID, type: ReactionType) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[index].toggleReaction(type)
    }

    /// Remove user's reaction from a post
    func removeReaction(postId: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[index].removeReaction()
    }

    /// Clear venue filter
    func clearVenueFilter() {
        selectedVenueFilter = nil
    }

    /// Set venue filter (from Live Activity tap)
    func filterByVenue(_ venueName: String) {
        selectedVenueFilter = venueName
        HapticManager.shared.medium()
    }
}

// MARK: - Post Filter Enum

enum PostFilter: String, CaseIterable {
    case all = "All"
    case checkIns = "Check-ins"
    case photos = "Photos"
    case achievements = "Achievements"
}
