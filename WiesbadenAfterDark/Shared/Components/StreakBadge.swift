//
//  StreakBadge.swift
//  WiesbadenAfterDark
//
//  Reusable streak indicator badge component
//

import SwiftUI

/// Streak badge display size
enum StreakBadgeSize {
    case small
    case medium
    case large

    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 24
        }
    }

    var fontSize: Font {
        switch self {
        case .small: return .caption2
        case .medium: return .subheadline
        case .large: return .headline
        }
    }

    var padding: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 10
        case .large: return 14
        }
    }
}

/// Streak badge style
enum StreakBadgeStyle {
    case filled // Solid background
    case outlined // Border only
    case minimal // No background, just icon and text
}

/// Streak indicator badge component
struct StreakBadge: View {
    // MARK: - Properties

    let streakDay: Int
    let multiplier: Decimal?
    var size: StreakBadgeSize = .medium
    var style: StreakBadgeStyle = .filled
    var showMultiplier: Bool = true

    // MARK: - Computed Properties

    private var streakColor: Color {
        switch streakDay {
        case 1:
            return .orange.opacity(0.7)
        case 2:
            return .orange
        case 3:
            return .orange.mix(with: .red, by: 0.3)
        case 4:
            return .red
        default: // 5+
            return .red.mix(with: .pink, by: 0.3)
        }
    }

    private var displayMultiplier: String {
        guard let multiplier = multiplier else { return "×1.0" }
        return "×\(String(format: "%.1f", NSDecimalNumber(decimal: multiplier).doubleValue))"
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: size == .small ? 4 : 6) {
            // Flame icon
            Image(systemName: streakDay >= 3 ? "flame.fill" : "flame")
                .font(.system(size: size.iconSize))
                .foregroundStyle(streakColor)

            // Streak day
            Text("Day \(streakDay)")
                .font(size.fontSize)
                .fontWeight(.semibold)
                .foregroundStyle(style == .minimal ? streakColor : .primary)

            // Multiplier
            if showMultiplier, let _ = multiplier {
                Text(displayMultiplier)
                    .font(size.fontSize)
                    .fontWeight(.bold)
                    .foregroundStyle(streakColor)
            }
        }
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding * 0.6)
        .background(backgroundView)
        .clipShape(Capsule())
    }

    // MARK: - Background View

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            streakColor.opacity(0.15)

        case .outlined:
            Capsule()
                .strokeBorder(streakColor.opacity(0.5), lineWidth: 1.5)

        case .minimal:
            Color.clear
        }
    }
}

// MARK: - Color Extension

extension Color {
    func mix(with color: Color, by percentage: Double) -> Color {
        // Simple color mixing (this is a simplified version)
        return self.opacity(1 - percentage)
    }
}

// MARK: - Preview

#Preview("Sizes - Filled") {
    VStack(spacing: 20) {
        // Small
        HStack {
            Text("Small:")
            StreakBadge(
                streakDay: 3,
                multiplier: 1.5,
                size: .small,
                style: .filled
            )
        }

        // Medium
        HStack {
            Text("Medium:")
            StreakBadge(
                streakDay: 3,
                multiplier: 1.5,
                size: .medium,
                style: .filled
            )
        }

        // Large
        HStack {
            Text("Large:")
            StreakBadge(
                streakDay: 3,
                multiplier: 1.5,
                size: .large,
                style: .filled
            )
        }
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Styles") {
    VStack(spacing: 20) {
        // Filled
        HStack {
            Text("Filled:")
            StreakBadge(
                streakDay: 4,
                multiplier: 2.0,
                size: .medium,
                style: .filled
            )
        }

        // Outlined
        HStack {
            Text("Outlined:")
            StreakBadge(
                streakDay: 4,
                multiplier: 2.0,
                size: .medium,
                style: .outlined
            )
        }

        // Minimal
        HStack {
            Text("Minimal:")
            StreakBadge(
                streakDay: 4,
                multiplier: 2.0,
                size: .medium,
                style: .minimal
            )
        }
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Streak Progression") {
    VStack(spacing: 16) {
        Text("Streak Progression")
            .font(.headline)

        // Day 1
        HStack {
            Text("Day 1:")
            StreakBadge(
                streakDay: 1,
                multiplier: 1.0,
                size: .medium
            )
        }

        // Day 2
        HStack {
            Text("Day 2:")
            StreakBadge(
                streakDay: 2,
                multiplier: 1.2,
                size: .medium
            )
        }

        // Day 3
        HStack {
            Text("Day 3:")
            StreakBadge(
                streakDay: 3,
                multiplier: 1.5,
                size: .medium
            )
        }

        // Day 4
        HStack {
            Text("Day 4:")
            StreakBadge(
                streakDay: 4,
                multiplier: 2.0,
                size: .medium
            )
        }

        // Day 5+
        HStack {
            Text("Day 5+:")
            StreakBadge(
                streakDay: 7,
                multiplier: 2.5,
                size: .medium
            )
        }
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Without Multiplier") {
    VStack(spacing: 16) {
        StreakBadge(
            streakDay: 3,
            multiplier: 1.5,
            size: .small,
            showMultiplier: false
        )

        StreakBadge(
            streakDay: 5,
            multiplier: 2.5,
            size: .medium,
            showMultiplier: false
        )

        StreakBadge(
            streakDay: 10,
            multiplier: 2.5,
            size: .large,
            showMultiplier: false
        )
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("All Combinations") {
    ScrollView {
        VStack(spacing: 24) {
            ForEach(1...7, id: \.self) { day in
                VStack(alignment: .leading, spacing: 12) {
                    Text("Day \(day)")
                        .font(.headline)

                    HStack(spacing: 16) {
                        StreakBadge(
                            streakDay: day,
                            multiplier: calculateMultiplier(for: day),
                            size: .small,
                            style: .filled
                        )

                        StreakBadge(
                            streakDay: day,
                            multiplier: calculateMultiplier(for: day),
                            size: .medium,
                            style: .outlined
                        )

                        StreakBadge(
                            streakDay: day,
                            multiplier: calculateMultiplier(for: day),
                            size: .large,
                            style: .minimal
                        )
                    }
                }

                if day < 7 {
                    Divider()
                }
            }
        }
        .padding()
    }
    .background(Color.appBackground)
}

// MARK: - Preview Helper

private func calculateMultiplier(for day: Int) -> Decimal {
    switch day {
    case 1: return 1.0
    case 2: return 1.2
    case 3: return 1.5
    case 4: return 2.0
    default: return 2.5
    }
}
