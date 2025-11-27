//
//  Color+Theme.swift
//  WiesbadenAfterDark
//
//  Color palette and theme colors for the app
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors (Purple to Pink Gradient)

    /// Start color for primary gradient (#8B5CF6 - Purple)
    static let primaryGradientStart = Color(hex: "#8B5CF6")

    /// End color for primary gradient (#EC4899 - Pink)
    static let primaryGradientEnd = Color(hex: "#EC4899")

    /// Solid primary color (purple)
    static let primary = Color(hex: "#8B5CF6")

    // MARK: - Background Colors

    /// Main app background (#0F172A - Dark Navy Blue)
    static let appBackground = Color(hex: "#0F172A")

    /// Card and surface background (#1E293B - Lighter Dark)
    static let cardBackground = Color(hex: "#1E293B")

    /// Input field background (#334155 - Even Lighter Dark)
    static let inputBackground = Color(hex: "#334155")

    // MARK: - Text Colors

    /// Primary text color (white)
    static let textPrimary = Color.white

    /// Secondary text color (#94A3B8 - Light Gray)
    static let textSecondary = Color(hex: "#94A3B8")

    /// Tertiary text color (#64748B - Medium Gray)
    static let textTertiary = Color(hex: "#64748B")

    /// Disabled text color (#475569 - Darker Gray)
    static let textDisabled = Color(hex: "#475569")

    // MARK: - State Colors

    /// Success color (#10B981 - Green)
    static let success = Color(hex: "#10B981")

    /// Error color (#EF4444 - Red)
    static let error = Color(hex: "#EF4444")

    /// Warning color (#F59E0B - Orange)
    static let warning = Color(hex: "#F59E0B")

    /// Info color (#3B82F6 - Blue)
    static let info = Color(hex: "#3B82F6")

    // MARK: - Accent Colors

    /// Gold color for premium features (#FCD34D)
    static let gold = Color(hex: "#FCD34D")

    /// Silver color (#E5E7EB)
    static let silver = Color(hex: "#E5E7EB")

    // MARK: - Tier Colors

    /// Bronze tier color (#CD7F32)
    static let tierBronze = Color(hex: "CD7F32")

    /// Silver tier color (#C0C0C0)
    static let tierSilver = Color(hex: "C0C0C0")

    /// Gold tier color (#FFD700)
    static let tierGold = Color(hex: "FFD700")

    /// Platinum tier color (#E5E4E2)
    static let tierPlatinum = Color(hex: "E5E4E2")

    /// Diamond tier color (#B9F2FF)
    static let tierDiamond = Color(hex: "B9F2FF")

    // MARK: - Gradient Helpers

    /// Primary gradient (purple to pink)
    static let primaryGradient = LinearGradient(
        colors: [primaryGradientStart, primaryGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Dark gradient for backgrounds
    static let darkGradient = LinearGradient(
        colors: [appBackground, cardBackground],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - 2025 Futuristic Gradients

    /// Neon gradient (purple → pink → cyan)
    static let neonGradient = LinearGradient(
        colors: [
            Color(hex: "#7c3aed"),  // Primary purple
            Color(hex: "#ec4899"),  // Pink accent
            Color(hex: "#06b6d4")   // Cyan accent
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Cyber gradient (light purple → cyan → green)
    static let cyberGradient = LinearGradient(
        colors: [
            Color(hex: "#8b5cf6"),  // Light purple
            Color(hex: "#06b6d4"),  // Cyan
            Color(hex: "#10b981")   // Green
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Sunset gradient (orange → pink → purple)
    static let sunsetGradient = LinearGradient(
        colors: [
            Color(hex: "#f59e0b"),  // Orange
            Color(hex: "#ec4899"),  // Pink
            Color(hex: "#8b5cf6")   // Purple
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Hex Initializer

    /// Creates a Color from a hex string
    /// - Parameter hex: Hex color string (e.g., "#8B5CF6" or "8B5CF6")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
