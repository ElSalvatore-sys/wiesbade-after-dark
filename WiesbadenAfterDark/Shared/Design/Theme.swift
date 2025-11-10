//
//  Theme.swift
//  WiesbadenAfterDark
//
//  Design system constants for the app
//  Colors, spacing, corner radius, and other design tokens
//

import SwiftUI

/// Central design system for WiesbadenAfterDark
/// Contains all design tokens used throughout the app
enum Theme {
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius (2025 Modern - Softer Rounded Corners)
    enum CornerRadius {
        static let sm: CGFloat = 14        // ⬆️ Increased from 8
        static let md: CGFloat = 16        // ⬆️ Increased from 12
        static let lg: CGFloat = 20        // ⬆️ Increased from 16
        static let xl: CGFloat = 24        // Unchanged (already modern)
        static let pill: CGFloat = 999     // For fully rounded buttons
    }

    // MARK: - Border Width
    enum BorderWidth {
        static let thin: CGFloat = 1
        static let regular: CGFloat = 2
        static let thick: CGFloat = 3
    }

    // MARK: - Shadow (2025 Modern - Softer, More Depth)
    enum Shadow {
        static let sm = ShadowStyle(
            color: Color.black.opacity(0.05),  // ⬇️ More subtle
            radius: 8,                         // ⬆️ Increased spread
            x: 0,
            y: 2
        )

        static let md = ShadowStyle(
            color: Color.black.opacity(0.08),  // ⬇️ More subtle
            radius: 12,                        // ⬆️ Increased spread
            x: 0,
            y: 4
        )

        static let lg = ShadowStyle(
            color: Color.black.opacity(0.15),  // ⬇️ More subtle
            radius: 20,                        // ⬆️ Increased spread
            x: 0,
            y: 8
        )
    }

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    // MARK: - Animation
    enum Animation {
        static let quick: SwiftUI.Animation = .easeInOut(duration: 0.2)
        static let standard: SwiftUI.Animation = .easeInOut(duration: 0.3)
        static let slow: SwiftUI.Animation = .easeInOut(duration: 0.5)
    }
}

// MARK: - View Extensions for Theme
extension View {
    /// Applies a card style with background and shadow
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(Theme.CornerRadius.lg)
            .shadow(
                color: Theme.Shadow.md.color,
                radius: Theme.Shadow.md.radius,
                x: Theme.Shadow.md.x,
                y: Theme.Shadow.md.y
            )
    }

    /// Applies standard padding
    func standardPadding() -> some View {
        self.padding(Theme.Spacing.md)
    }

    /// Applies large padding
    func largePadding() -> some View {
        self.padding(Theme.Spacing.lg)
    }
}
