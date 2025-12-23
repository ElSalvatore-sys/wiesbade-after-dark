//
//  HomeLoadingSkeleton.swift
//  WiesbadenAfterDark
//
//  Full skeleton loading state for HomeView
//

import SwiftUI

/// Complete skeleton loading state for the home screen
/// Matches the actual HomeView structure: Points Balance, Quick Actions, Event Highlights
struct HomeLoadingSkeleton: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Theme.Spacing.lg) {
                // Points Balance Card Skeleton
                PointsBalanceCardSkeleton()
                    .padding(.horizontal)

                // Quick Actions Skeleton
                QuickActionsSkeleton()
                    .padding(.horizontal)

                // Event Highlights Skeleton
                EventHighlightsSkeleton()

                Spacer()
                    .frame(height: Theme.Spacing.xl)
            }
            .padding(.top)
        }
    }
}

// MARK: - Points Balance Card Skeleton

private struct PointsBalanceCardSkeleton: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.cardGap) {
            // "Your Points" label
            SkeletonText(width: 80, height: 14)

            // Points balance number
            SkeletonText(width: 150, height: 60)

            // Euro value
            SkeletonText(width: 100, height: 20)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    Color.skeletonBackground.opacity(0.5),
                    Color.skeletonBackground.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Quick Actions Skeleton

private struct QuickActionsSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section title
            SkeletonText(width: 120, height: 18)

            // 2x2 grid of action buttons
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.Spacing.cardGap) {
                ForEach(0..<4, id: \.self) { _ in
                    QuickActionButtonSkeleton()
                }
            }

            // Sign out button skeleton
            SkeletonView(
                shape: .roundedRectangle(cornerRadius: Theme.CornerRadius.sm),
                height: 48
            )
            .padding(.top, Theme.Spacing.sm)
        }
    }
}

private struct QuickActionButtonSkeleton: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.cardGap) {
            SkeletonCircle(size: 28)
            SkeletonText(width: 60, height: 14)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.cardPadding)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
    }
}

// MARK: - Event Highlights Skeleton

private struct EventHighlightsSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    SkeletonText(width: 160, height: 24)
                    SkeletonText(width: 100, height: 12)
                }

                Spacer()

                SkeletonText(width: 50, height: 14)
            }
            .padding(.horizontal)

            // Horizontal scroll of event cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    ForEach(0..<2, id: \.self) { _ in
                        EventHighlightCardSkeleton()
                            .frame(width: 320)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct EventHighlightCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Event image
            SkeletonImage(height: 160, cornerRadius: Theme.CornerRadius.md)

            // Event title
            SkeletonText(width: 200, height: 18)

            // Venue name
            SkeletonText(width: 120, height: 14)

            // Date & time
            HStack(spacing: 4) {
                SkeletonCircle(size: 14)
                SkeletonText(width: 140, height: 12)
            }

            // Points multiplier badge
            SkeletonView(
                shape: .roundedRectangle(cornerRadius: Theme.CornerRadius.sm),
                width: 80,
                height: 24
            )
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

// MARK: - Generic List Skeleton

/// A reusable list skeleton for any repeated content
struct SkeletonList<Content: View>: View {
    let count: Int
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(count: Int = 3, spacing: CGFloat = Theme.Spacing.md, @ViewBuilder content: @escaping () -> Content) {
        self.count = count
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<count, id: \.self) { _ in
                content()
            }
        }
    }
}

// MARK: - Preview

#Preview("Home Loading Skeleton") {
    HomeLoadingSkeleton()
        .background(Color.appBackground)
}

#Preview("Skeleton List - Venues") {
    ScrollView {
        SkeletonList(count: 3) {
            VenueCardSkeleton()
        }
        .padding()
    }
    .background(Color.appBackground)
}

#Preview("Skeleton List - Events") {
    ScrollView {
        SkeletonList(count: 4) {
            EventCardSkeleton()
        }
        .padding()
    }
    .background(Color.appBackground)
}
