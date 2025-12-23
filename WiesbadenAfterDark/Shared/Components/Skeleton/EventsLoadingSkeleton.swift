//
//  EventsLoadingSkeleton.swift
//  WiesbadenAfterDark
//
//  Skeleton loading state for EventsView
//

import SwiftUI

/// Skeleton loading state for the events screen
struct EventsLoadingSkeleton: View {
    var body: some View {
        VStack(spacing: 0) {
            // Filter chips skeleton
            filterChipsSkeleton
                .padding(.top, Theme.Spacing.sm)

            // Events list skeleton
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: Theme.Spacing.md) {
                    ForEach(0..<5, id: \.self) { _ in
                        EventCardSkeleton()
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.md)
            }
        }
    }

    private var filterChipsSkeleton: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(0..<3, id: \.self) { index in
                    SkeletonView(
                        shape: .capsule,
                        width: index == 0 ? 90 : (index == 1 ? 100 : 120),
                        height: 32
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
        }
    }
}

// MARK: - Preview

#Preview("Events Loading Skeleton") {
    NavigationStack {
        EventsLoadingSkeleton()
            .background(Color.appBackground)
            .navigationTitle("Events")
    }
}
