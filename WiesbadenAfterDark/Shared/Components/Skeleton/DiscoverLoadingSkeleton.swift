//
//  DiscoverLoadingSkeleton.swift
//  WiesbadenAfterDark
//
//  Skeleton loading state for DiscoverView
//

import SwiftUI

/// Skeleton loading state for the discover/venues screen
struct DiscoverLoadingSkeleton: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Header skeleton
                SkeletonText(width: 200, height: 32)
                    .padding(.horizontal)
                    .padding(.top, Theme.Spacing.md)

                // Active Deals Section skeleton
                DealsSectionSkeleton()
                    .padding(.vertical, Theme.Spacing.sm)

                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, Theme.Spacing.sm)

                // Venue cards list skeleton
                LazyVStack(spacing: Theme.Spacing.cardPadding) {
                    ForEach(0..<4, id: \.self) { _ in
                        VenueCardSkeleton()
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
    }
}

// MARK: - Deals Section Skeleton

private struct DealsSectionSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.cardGap) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    SkeletonText(width: 100, height: 20)
                    SkeletonText(width: 160, height: 12)
                }

                Spacer()

                HStack(spacing: Theme.Spacing.xs) {
                    SkeletonCircle(size: 12)
                    SkeletonText(width: 50, height: 14)
                }
            }
            .padding(.horizontal)

            // Deals horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.cardGap) {
                    ForEach(0..<3, id: \.self) { _ in
                        DealCardSkeleton()
                            .frame(width: 320)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct DealCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Product image
            SkeletonImage(height: 120, cornerRadius: Theme.CornerRadius.md)

            // Product info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonText(width: 150, height: 16)
                    SkeletonText(width: 100, height: 12)
                }

                Spacer()

                // Multiplier badge
                SkeletonView(
                    shape: .roundedRectangle(cornerRadius: Theme.CornerRadius.sm),
                    width: 50,
                    height: 24
                )
            }

            // Timer
            SkeletonText(width: 120, height: 12)
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

// MARK: - Preview

#Preview("Discover Loading Skeleton") {
    DiscoverLoadingSkeleton()
        .background(Color.appBackground)
}
