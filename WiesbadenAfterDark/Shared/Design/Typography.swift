//
//  Typography.swift
//  WiesbadenAfterDark
//
//  Typography system for consistent font styles
//

import SwiftUI

/// Typography system for WiesbadenAfterDark
/// Provides consistent font styles throughout the app
enum Typography {
    // MARK: - Display Styles (for hero sections)
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)

    // MARK: - Title Styles
    static let titleLarge = Font.system(size: 28, weight: .bold, design: .rounded)
    static let titleMedium = Font.system(size: 24, weight: .bold, design: .rounded)
    static let titleSmall = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Headline Styles
    static let headlineLarge = Font.system(size: 18, weight: .semibold, design: .default)
    static let headlineMedium = Font.system(size: 16, weight: .semibold, design: .default)
    static let headlineSmall = Font.system(size: 14, weight: .semibold, design: .default)

    // MARK: - Body Styles
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Label Styles
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Caption Styles
    static let captionLarge = Font.system(size: 13, weight: .regular, design: .default)
    static let captionMedium = Font.system(size: 12, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: - Special Styles
    static let button = Font.system(size: 17, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 15, weight: .semibold, design: .default)
    static let code = Font.system(size: 15, weight: .regular, design: .monospaced)
}

// MARK: - View Extensions for Typography
extension View {
    /// Applies display large style
    func displayLarge() -> some View {
        self.font(Typography.displayLarge)
    }

    /// Applies title large style
    func titleLarge() -> some View {
        self.font(Typography.titleLarge)
    }

    /// Applies title medium style
    func titleMedium() -> some View {
        self.font(Typography.titleMedium)
    }

    /// Applies headline style
    func headline() -> some View {
        self.font(Typography.headlineMedium)
    }

    /// Applies body style
    func body() -> some View {
        self.font(Typography.bodyMedium)
    }

    /// Applies caption style
    func caption() -> some View {
        self.font(Typography.captionMedium)
    }
}
