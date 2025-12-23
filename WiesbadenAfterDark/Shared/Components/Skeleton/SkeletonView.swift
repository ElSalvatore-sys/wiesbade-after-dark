//
//  SkeletonView.swift
//  WiesbadenAfterDark
//
//  Configurable skeleton placeholder shapes for loading states
//

import SwiftUI

/// A configurable skeleton shape with shimmer effect
struct SkeletonView: View {
    enum Shape {
        case rectangle
        case roundedRectangle(cornerRadius: CGFloat)
        case circle
        case capsule
    }

    let shape: Shape
    var width: CGFloat? = nil
    var height: CGFloat? = nil

    var body: some View {
        Group {
            switch shape {
            case .rectangle:
                Rectangle()
                    .fill(Color.skeletonBackground)
            case .roundedRectangle(let cornerRadius):
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.skeletonBackground)
            case .circle:
                Circle()
                    .fill(Color.skeletonBackground)
            case .capsule:
                Capsule()
                    .fill(Color.skeletonBackground)
            }
        }
        .frame(width: width, height: height)
        .shimmer()
    }
}

/// Text-line skeleton placeholder
struct SkeletonText: View {
    var width: CGFloat = 100
    var height: CGFloat = 14

    var body: some View {
        SkeletonView(
            shape: .roundedRectangle(cornerRadius: 4),
            width: width,
            height: height
        )
    }
}

/// Image skeleton placeholder
struct SkeletonImage: View {
    var width: CGFloat? = nil
    var height: CGFloat = 200
    var cornerRadius: CGFloat = Theme.CornerRadius.lg

    var body: some View {
        SkeletonView(
            shape: .roundedRectangle(cornerRadius: cornerRadius),
            width: width,
            height: height
        )
    }
}

/// Circle skeleton for avatars/icons
struct SkeletonCircle: View {
    var size: CGFloat = 44

    var body: some View {
        SkeletonView(
            shape: .circle,
            width: size,
            height: size
        )
    }
}

// MARK: - Skeleton Background Color Extension

extension Color {
    static let skeletonBackground = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.15, alpha: 1.0)
            : UIColor(white: 0.9, alpha: 1.0)
    })
}

// MARK: - Preview

#Preview("Skeleton Views") {
    VStack(spacing: Theme.Spacing.lg) {
        // Text lines
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            SkeletonText(width: 200, height: 20)
            SkeletonText(width: 150, height: 14)
            SkeletonText(width: 100, height: 12)
        }

        // Image
        SkeletonImage(height: 180)

        // Circles
        HStack(spacing: Theme.Spacing.md) {
            SkeletonCircle(size: 60)
            SkeletonCircle(size: 44)
            SkeletonCircle(size: 32)
        }

        // Rectangle
        SkeletonView(shape: .rectangle, height: 100)
    }
    .padding()
    .background(Color.appBackground)
}
