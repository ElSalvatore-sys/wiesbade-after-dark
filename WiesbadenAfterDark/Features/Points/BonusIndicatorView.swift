//
//  BonusIndicatorView.swift
//  WiesbadenAfterDark
//
//  Created by Claude Code on 2025-11-13.
//

import SwiftUI

// MARK: - Bonus Data Models

struct ActiveBonus: Identifiable {
    let id = UUID()
    let name: String
    let multiplier: Double
    let type: BonusType
    let expiresAt: Date
    let description: String
    let venueName: String?

    enum BonusType {
        case happyHour
        case streak
        case event
        case promotional
        case firstVisit
        case membershipTier

        var icon: String {
            switch self {
            case .happyHour: return "clock.fill"
            case .streak: return "flame.fill"
            case .event: return "star.fill"
            case .promotional: return "gift.fill"
            case .firstVisit: return "sparkles"
            case .membershipTier: return "crown.fill"
            }
        }

        var color: Color {
            switch self {
            case .happyHour: return .warning
            case .streak: return Color(hex: "#FF6B35") // Orange-red
            case .event: return .gold
            case .promotional: return .primary
            case .firstVisit: return .success
            case .membershipTier: return Color(hex: "#FFD700") // Gold
            }
        }

        var gradientColors: [Color] {
            switch self {
            case .happyHour: return [.warning, Color.warning.opacity(0.7)]
            case .streak: return [Color(hex: "#FF6B35"), Color(hex: "#FF8C42")]
            case .event: return [.gold, Color.gold.opacity(0.8)]
            case .promotional: return [.primaryGradientStart, .primaryGradientEnd]
            case .firstVisit: return [.success, Color.success.opacity(0.7)]
            case .membershipTier: return [Color(hex: "#FFD700"), Color(hex: "#FFA500")]
            }
        }
    }

    var timeRemaining: TimeInterval {
        expiresAt.timeIntervalSinceNow
    }

    var isExpired: Bool {
        timeRemaining <= 0
    }

    var formattedTimeRemaining: String {
        guard !isExpired else { return "Expired" }

        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var multiplierText: String {
        if multiplier == floor(multiplier) {
            return "\(Int(multiplier))×"
        } else {
            return String(format: "%.1f×", multiplier)
        }
    }
}

// MARK: - Bonus Indicator View Model
@Observable @MainActor
final class BonusIndicatorViewModel {
    var currentTime = Date()
    var selectedVenue: String = "Apollo Club"

    // Mock active bonuses - In production, fetch from API/CheckIn service
    var activeBonuses: [ActiveBonus] {
        let now = Date()
        return [
            ActiveBonus(
                name: "Happy Hour",
                multiplier: 2.0,
                type: .happyHour,
                expiresAt: now.addingTimeInterval(3600 * 2), // 2 hours
                description: "Double points on all beverages",
                venueName: "Apollo Club"
            ),
            ActiveBonus(
                name: "5-Day Streak",
                multiplier: 2.5,
                type: .streak,
                expiresAt: now.addingTimeInterval(86400), // 24 hours
                description: "Maintain your check-in streak",
                venueName: nil
            ),
            ActiveBonus(
                name: "Special Event",
                multiplier: 1.5,
                type: .event,
                expiresAt: now.addingTimeInterval(7200), // 2 hours
                description: "Live DJ performance tonight",
                venueName: "Apollo Club"
            ),
            ActiveBonus(
                name: "Gold Member",
                multiplier: 1.2,
                type: .membershipTier,
                expiresAt: now.addingTimeInterval(86400 * 30), // 30 days
                description: "Permanent bonus for Gold tier",
                venueName: "Apollo Club"
            )
        ].filter { !$0.isExpired }
    }

    var venueSpecificBonuses: [ActiveBonus] {
        activeBonuses.filter { $0.venueName == selectedVenue }
    }

    var globalBonuses: [ActiveBonus] {
        activeBonuses.filter { $0.venueName == nil }
    }

    var totalMultiplier: Double {
        activeBonuses.reduce(1.0) { $0 * $1.multiplier }
    }

    var hasActiveBonuses: Bool {
        !activeBonuses.isEmpty
    }

    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
        }
    }
}

// MARK: - Bonus Indicator View
struct BonusIndicatorView: View {
    @State private var viewModel = BonusIndicatorViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Header
                headerSection

                // Summary Card with Total Multiplier
                if viewModel.hasActiveBonuses {
                    totalMultiplierCard
                }

                // Active Bonuses List
                if !viewModel.venueSpecificBonuses.isEmpty {
                    venueBonusesSection
                }

                if !viewModel.globalBonuses.isEmpty {
                    globalBonusesSection
                }

                // Empty State
                if !viewModel.hasActiveBonuses {
                    emptyStateSection
                }

                // Info Section
                infoSection

                Spacer(minLength: Theme.Spacing.xl)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.lg)
        }
        .darkBackground()
        .navigationTitle("Active Bonuses")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.startTimer()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Bonus Multipliers")
                .typography(.titleMedium)
                .foregroundStyle(.textPrimary)

            Text("Active bonuses boost your points earnings")
                .typography(.bodyMedium)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Total Multiplier Card
    private var totalMultiplierCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Badge Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.gold.opacity(0.3), .gold.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "star.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.gold, .warning],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Total Multiplier Display
            VStack(spacing: Theme.Spacing.xs) {
                Text("Total Multiplier")
                    .typography(.bodyMedium)
                    .foregroundStyle(.textSecondary)

                Text(String(format: "%.1f×", viewModel.totalMultiplier))
                    .typography(.displayLarge)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.gold, .warning],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            // Explanation
            Text("All active bonuses multiply together")
                .typography(.bodySmall)
                .foregroundStyle(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    Color.gold.opacity(0.15),
                    Color.gold.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .strokeBorder(
                    LinearGradient(
                        colors: [.gold.opacity(0.4), .gold.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }

    // MARK: - Venue Bonuses Section
    private var venueBonusesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("At \(viewModel.selectedVenue)", systemImage: "building.2.fill")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            VStack(spacing: Theme.Spacing.sm) {
                ForEach(viewModel.venueSpecificBonuses) { bonus in
                    bonusCard(bonus)
                }
            }
        }
    }

    // MARK: - Global Bonuses Section
    private var globalBonusesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Global Bonuses", systemImage: "globe")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            VStack(spacing: Theme.Spacing.sm) {
                ForEach(viewModel.globalBonuses) { bonus in
                    bonusCard(bonus)
                }
            }
        }
    }

    // MARK: - Bonus Card
    private func bonusCard(_ bonus: ActiveBonus) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: bonus.type.gradientColors.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: bonus.type.icon)
                        .font(.title3)
                        .foregroundStyle(bonus.type.color)
                }

                // Bonus Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Text(bonus.name)
                            .typography(.headlineMedium)
                            .foregroundStyle(.textPrimary)

                        // Multiplier Badge
                        Text(bonus.multiplierText)
                            .typography(.bodySmall)
                            .foregroundStyle(bonus.type.color)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, 4)
                            .background(bonus.type.color.opacity(0.15))
                            .cornerRadius(Theme.CornerRadius.sm)
                    }

                    Text(bonus.description)
                        .typography(.bodySmall)
                        .foregroundStyle(.textSecondary)
                }

                Spacer()
            }

            // Countdown Timer
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "timer")
                    .foregroundStyle(bonus.timeRemaining < 3600 ? .error : .warning)
                    .font(.body)

                Text("Expires in:")
                    .typography(.bodySmall)
                    .foregroundStyle(.textSecondary)

                Text(bonus.formattedTimeRemaining)
                    .typography(.bodySmall)
                    .foregroundStyle(bonus.timeRemaining < 3600 ? .error : .textPrimary)
                    .monospacedDigit()

                Spacer()

                // Progress Bar
                if bonus.timeRemaining < 3600 {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.error)
                        .font(.caption)
                }
            }
            .padding(Theme.Spacing.sm)
            .background(Color.inputBackground)
            .cornerRadius(Theme.CornerRadius.sm)
        }
        .padding(Theme.Spacing.md)
        .background(
            LinearGradient(
                colors: [
                    bonus.type.color.opacity(0.1),
                    bonus.type.color.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .strokeBorder(bonus.type.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Empty State
    private var emptyStateSection: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "star.slash")
                .font(.system(size: 64))
                .foregroundStyle(.textTertiary)

            VStack(spacing: Theme.Spacing.sm) {
                Text("No Active Bonuses")
                    .typography(.titleMedium)
                    .foregroundStyle(.textPrimary)

                Text("Check in during happy hours or special events to earn bonus multipliers")
                    .typography(.bodyMedium)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xxl)
        .cardStyle()
    }

    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("How Bonuses Work", systemImage: "info.circle.fill")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                infoRow(
                    icon: "multiply.circle.fill",
                    color: .info,
                    title: "Multiplicative Stacking",
                    description: "All active bonuses multiply together. Example: 2× Happy Hour × 1.5× Event = 3× total multiplier"
                )

                infoRow(
                    icon: "clock.arrow.circlepath",
                    color: .warning,
                    title: "Time Limited",
                    description: "Most bonuses expire after a set time. Check back during happy hours and events for the best multipliers"
                )

                infoRow(
                    icon: "star.circle.fill",
                    color: .gold,
                    title: "Streak Bonuses",
                    description: "Check in daily to build streaks. Day 5+ gives you a permanent 2.5× multiplier until the streak breaks"
                )

                infoRow(
                    icon: "crown.fill",
                    color: Color(hex: "#FFD700"),
                    title: "Membership Tiers",
                    description: "Higher tiers provide permanent bonuses at specific venues. Reach Gold or Platinum for the best rewards"
                )
            }
        }
        .cardStyle()
    }

    private func infoRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .typography(.bodyLarge)
                    .foregroundStyle(.textPrimary)

                Text(description)
                    .typography(.bodySmall)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Bonus Badge Component
struct BonusBadge: View {
    let bonus: ActiveBonus
    let compact: Bool

    init(bonus: ActiveBonus, compact: Bool = false) {
        self.bonus = bonus
        self.compact = compact
    }

    var body: some View {
        HStack(spacing: compact ? 4 : Theme.Spacing.sm) {
            Image(systemName: bonus.type.icon)
                .font(compact ? .caption : .body)

            if !compact {
                Text(bonus.name)
                    .typography(.bodySmall)
            }

            Text(bonus.multiplierText)
                .typography(compact ? .bodySmall : .bodyMedium)
                .bold()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, compact ? 8 : Theme.Spacing.sm)
        .padding(.vertical, compact ? 4 : 6)
        .background(
            LinearGradient(
                colors: bonus.type.gradientColors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(Theme.CornerRadius.sm)
        .shadow(color: bonus.type.color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Helper Extension
extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview("Bonus Indicator View") {
    NavigationStack {
        BonusIndicatorView()
    }
}

#Preview("Bonus Badge - Full") {
    VStack(spacing: 16) {
        let bonuses = [
            ActiveBonus(
                name: "Happy Hour",
                multiplier: 2.0,
                type: .happyHour,
                expiresAt: Date().addingTimeInterval(3600),
                description: "Double points",
                venueName: nil
            ),
            ActiveBonus(
                name: "5-Day Streak",
                multiplier: 2.5,
                type: .streak,
                expiresAt: Date().addingTimeInterval(86400),
                description: "Streak bonus",
                venueName: nil
            )
        ]

        ForEach(bonuses) { bonus in
            BonusBadge(bonus: bonus, compact: false)
        }
    }
    .padding()
    .darkBackground()
}

#Preview("Bonus Badge - Compact") {
    HStack(spacing: 8) {
        let bonuses = [
            ActiveBonus(
                name: "Happy Hour",
                multiplier: 2.0,
                type: .happyHour,
                expiresAt: Date().addingTimeInterval(3600),
                description: "Double points",
                venueName: nil
            ),
            ActiveBonus(
                name: "Streak",
                multiplier: 2.5,
                type: .streak,
                expiresAt: Date().addingTimeInterval(86400),
                description: "Streak bonus",
                venueName: nil
            )
        ]

        ForEach(bonuses) { bonus in
            BonusBadge(bonus: bonus, compact: true)
        }
    }
    .padding()
    .darkBackground()
}
