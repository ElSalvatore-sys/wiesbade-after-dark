//
//  EventCardSkeleton.swift
//  WiesbadenAfterDark
//
//  Skeleton loading placeholder for EventCard
//

import SwiftUI

/// Skeleton placeholder matching EventCard layout
struct EventCardSkeleton: View {
    /// Whether to show the image skeleton (matches EventCard's optional image)
    var showImage: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Event image skeleton
            if showImage {
                SkeletonImage(height: 150, cornerRadius: Theme.CornerRadius.md)
            }

            // Title & points multiplier
            HStack {
                SkeletonText(width: 200, height: 20)
                Spacer()
                SkeletonView(
                    shape: .roundedRectangle(cornerRadius: Theme.CornerRadius.sm),
                    width: 50,
                    height: 24
                )
            }

            // DJ Lineup skeleton
            HStack(spacing: 4) {
                SkeletonCircle(size: 12)
                SkeletonText(width: 150, height: 12)
            }

            // Date & Time skeleton
            HStack(spacing: Theme.Spacing.sm) {
                SkeletonCircle(size: 14)
                SkeletonText(width: 180, height: 14)
            }

            // Cover charge & attendance
            HStack {
                // Cover charge
                HStack(spacing: 4) {
                    SkeletonCircle(size: 14)
                    SkeletonText(width: 60, height: 12)
                }

                Spacer()

                // Attendance
                HStack(spacing: Theme.Spacing.md) {
                    SkeletonText(width: 60, height: 12)
                    SkeletonText(width: 80, height: 12)
                }
            }

            // Action buttons skeleton
            HStack(spacing: Theme.Spacing.md) {
                SkeletonView(
                    shape: .roundedRectangle(cornerRadius: Theme.CornerRadius.md),
                    height: 44
                )
                SkeletonView(
                    shape: .roundedRectangle(cornerRadius: Theme.CornerRadius.md),
                    height: 44
                )
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

#Preview("Event Card Skeleton") {
    ScrollView {
        VStack(spacing: Theme.Spacing.lg) {
            EventCardSkeleton()
            EventCardSkeleton(showImage: false)
        }
        .padding()
    }
    .background(Color.appBackground)
}
