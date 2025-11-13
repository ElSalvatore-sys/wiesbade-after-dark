//
//  CommunityPost.swift
//  WiesbadenAfterDark
//
//  SwiftData model for community posts
//

import Foundation
import SwiftData

/// Membership tier for user badges
enum MembershipTier: String, Codable, CaseIterable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"

    var displayName: String { rawValue }

    var color: String {
        switch self {
        case .bronze: return "#CD7F32"
        case .silver: return "#C0C0C0"
        case .gold: return "#FFD700"
        case .platinum: return "#E5E4E2"
        }
    }

    /// Default spending threshold to reach this tier (can be customized per venue)
    var defaultRequiredSpending: Decimal {
        switch self {
        case .bronze: return 0
        case .silver: return 500
        case .gold: return 2000
        case .platinum: return 5000
        }
    }

    /// Default points multiplier for this tier
    var defaultMultiplier: Decimal {
        switch self {
        case .bronze: return 1.0
        case .silver: return 1.2
        case .gold: return 1.5
        case .platinum: return 2.0
        }
    }

    /// Icon for tier badge
    var icon: String {
        switch self {
        case .bronze: return "shield.fill"
        case .silver: return "shield.lefthalf.filled"
        case .gold: return "crown.fill"
        case .platinum: return "star.fill"
        }
    }

    /// Next tier in progression (if any)
    var nextTier: MembershipTier? {
        switch self {
        case .bronze: return .silver
        case .silver: return .gold
        case .gold: return .platinum
        case .platinum: return nil
        }
    }

    /// Order for sorting (higher is better)
    var order: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 1
        case .gold: return 2
        case .platinum: return 3
        }
    }
}

/// Represents a community post at a venue
@Model
final class CommunityPost: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID
    var userId: UUID
    var venueId: UUID

    var userName: String
    var userTier: MembershipTier
    var userAvatarURL: String?

    var content: String
    var imageURL: String?

    var likesCount: Int
    var commentsCount: Int
    var isLikedByCurrentUser: Bool

    var timestamp: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        venueId: UUID,
        userName: String,
        userTier: MembershipTier,
        userAvatarURL: String? = nil,
        content: String,
        imageURL: String? = nil,
        likesCount: Int = 0,
        commentsCount: Int = 0,
        isLikedByCurrentUser: Bool = false,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.userName = userName
        self.userTier = userTier
        self.userAvatarURL = userAvatarURL
        self.content = content
        self.imageURL = imageURL
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLikedByCurrentUser = isLikedByCurrentUser
        self.timestamp = timestamp
    }
}

// MARK: - Computed Properties
extension CommunityPost {
    /// Time ago display (e.g., "45 minutes ago")
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    /// User initials for avatar
    var userInitials: String {
        let components = userName.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }
}

// MARK: - Mock Data
extension CommunityPost {
    /// Mock posts for Das Wohnzimmer
    static func mockPostsForVenue(_ venueId: UUID) -> [CommunityPost] {
        let now = Date()

        return [
            CommunityPost(
                userId: UUID(),
                venueId: venueId,
                userName: "Sarah M.",
                userTier: .gold,
                content: "Who's going tonight? Looking for a group to party with! 🎉",
                likesCount: 12,
                commentsCount: 3,
                timestamp: now.addingTimeInterval(-45 * 60) // 45 minutes ago
            ),
            CommunityPost(
                userId: UUID(),
                venueId: venueId,
                userName: "Mike R.",
                userTier: .silver,
                content: "Amazing night last week! DJ was incredible 🔥",
                likesCount: 8,
                commentsCount: 1,
                timestamp: now.addingTimeInterval(-2 * 60 * 60) // 2 hours ago
            )
        ]
    }
}
