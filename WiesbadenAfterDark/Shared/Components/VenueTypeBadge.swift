//
//  VenueTypeBadge.swift
//  WiesbadenAfterDark
//
//  Badge component for displaying venue type
//

import SwiftUI

/// Small pill badge displaying venue type
struct VenueTypeBadge: View {
    let type: VenueType
    var size: BadgeSize = .small

    enum BadgeSize {
        case small
        case medium

        var fontSize: Font {
            switch self {
            case .small: return Typography.captionSmall
            case .medium: return Typography.labelMedium
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }

    var body: some View {
        Text(type.displayName)
            .font(size.fontSize)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(size.padding)
            .background(Color(hex: type.badgeColor))
            .cornerRadius(Theme.CornerRadius.pill)
    }
}

// MARK: - Preview
#Preview("Venue Type Badges") {
    VStack(spacing: Theme.Spacing.md) {
        VenueTypeBadge(type: .club)
        VenueTypeBadge(type: .bar)
        VenueTypeBadge(type: .restaurant)
        VenueTypeBadge(type: .barRestaurantClub, size: .medium)
        VenueTypeBadge(type: .lounge)
    }
    .padding()
    .background(Color.appBackground)
}
