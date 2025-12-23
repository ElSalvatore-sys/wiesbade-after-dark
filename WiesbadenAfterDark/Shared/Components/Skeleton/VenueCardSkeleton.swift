//
//  VenueCardSkeleton.swift
//  WiesbadenAfterDark
//
//  Skeleton loading placeholder for VenueCard
//

import SwiftUI

/// Skeleton placeholder matching VenueCard layout
struct VenueCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero Image Skeleton
            ZStack(alignment: .topTrailing) {
                SkeletonView(
                    shape: .rectangle,
                    height: 180
                )

                // Badge skeleton
                SkeletonView(
                    shape: .roundedRectangle(cornerRadius: 8),
                    width: 60,
                    height: 24
                )
                .padding(Theme.Spacing.sm)
            }
            .frame(height: 180)

            // Content Section
            VStack(alignment: .leading, spacing: Theme.Spacing.cardGap) {
                // Title & Rating Row
                HStack(alignment: .top) {
                    SkeletonText(width: 160, height: 18)

                    Spacer()

                    // Rating skeleton
                    HStack(spacing: Theme.Spacing.xs) {
                        SkeletonCircle(size: 14)
                        SkeletonText(width: 30, height: 12)
                    }
                }

                // Member Count Row
                HStack(spacing: Theme.Spacing.sm) {
                    SkeletonText(width: 100, height: 12)
                    SkeletonText(width: 50, height: 12)
                }

                // Description (2 lines)
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonText(width: .infinity, height: 12)
                    SkeletonText(width: 200, height: 12)
                }

                // Points Rate Badge
                SkeletonText(width: 140, height: 14)
                    .padding(.top, Theme.Spacing.xs)
            }
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .shadow(
            color: Theme.Shadow.md.color,
            radius: Theme.Shadow.md.radius,
            x: Theme.Shadow.md.x,
            y: Theme.Shadow.md.y
        )
    }
}

// MARK: - Preview

#Preview("Venue Card Skeleton") {
    VStack(spacing: Theme.Spacing.lg) {
        VenueCardSkeleton()
        VenueCardSkeleton()
    }
    .padding()
    .background(Color.appBackground)
}
