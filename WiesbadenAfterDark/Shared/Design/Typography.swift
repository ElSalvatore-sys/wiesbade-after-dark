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

    // MARK: - Headline Styles (2025 Modern - Rounded Design)
    static let headlineLarge = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 14, weight: .semibold, design: .rounded)

    // MARK: - Body Styles (2025 Modern - Rounded Design)
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .rounded)

    // MARK: - Label Styles (2025 Modern - Rounded Design)
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .rounded)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .rounded)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .rounded)

    // MARK: - Caption Styles (2025 Modern - Rounded Design)
    static let captionLarge = Font.system(size: 13, weight: .regular, design: .rounded)
    static let captionMedium = Font.system(size: 12, weight: .regular, design: .rounded)
    static let captionSmall = Font.system(size: 11, weight: .regular, design: .rounded)

    // MARK: - Special Styles
    static let button = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let buttonSmall = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let buttonMedium = Font.system(size: 16, weight: .semibold, design: .rounded)
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
