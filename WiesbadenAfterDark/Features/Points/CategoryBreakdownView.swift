//
//  CategoryBreakdownView.swift
//  WiesbadenAfterDark
//
//  Created by Claude Code on 2025-11-13.
//

import SwiftUI
import Charts

// MARK: - Earning Category Data Models

struct EarningCategory: Identifiable {
    let id = UUID()
    let name: String
    let rate: Double // Percentage rate (e.g., 0.10 = 10%)
    let level: EarningLevel
    let icon: String
    let description: String
    let examples: [String]

    enum EarningLevel {
        case high, medium, low

        var displayName: String {
            switch self {
            case .high: return "High Earning"
            case .medium: return "Medium Earning"
            case .low: return "Low Earning"
            }
        }

        var color: Color {
            switch self {
            case .high: return .success
            case .medium: return .warning
            case .low: return .info
            }
        }

        var badgeColor: Color {
            switch self {
            case .high: return Color(hex: "#10B981")
            case .medium: return Color(hex: "#F59E0B")
            case .low: return Color(hex: "#3B82F6")
            }
        }

        var iconName: String {
            switch self {
            case .high: return "arrow.up.circle.fill"
            case .medium: return "arrow.right.circle.fill"
            case .low: return "arrow.down.circle.fill"
            }
        }
    }

    var ratePercent: Int {
        Int(rate * 100)
    }

    var rateText: String {
        "\(ratePercent)%"
    }

    // Calculate points for a given amount
    func calculatePoints(for amount: Decimal) -> Int {
        let points = amount * Decimal(rate)
        return Int(truncating: points as NSNumber)
    }
}

struct CategoryComparison: Identifiable {
    let id = UUID()
    let category: String
    let points: Int
}

// MARK: - Category Breakdown View Model
@Observable @MainActor
final class CategoryBreakdownViewModel {
    var selectedAmount: Decimal = 100.0
    var expandedCategoryId: UUID?

    // All earning categories
    var categories: [EarningCategory] {
        [
            EarningCategory(
                name: "Beverages",
                rate: 0.10,
                level: .high,
                icon: "wineglass.fill",
                description: "Highest earning rate for all drink purchases",
                examples: ["Cocktails", "Beer", "Wine", "Spirits", "Non-alcoholic drinks"]
            ),
            EarningCategory(
                name: "Food",
                rate: 0.08,
                level: .medium,
                icon: "fork.knife",
                description: "Medium earning rate for food orders",
                examples: ["Appetizers", "Main courses", "Desserts", "Snacks", "Shared platters"]
            ),
            EarningCategory(
                name: "Table Service",
                rate: 0.06,
                level: .medium,
                icon: "table.furniture.fill",
                description: "Earn points on table bookings and service fees",
                examples: ["VIP tables", "Booth reservations", "Table service", "Cover charges"]
            ),
            EarningCategory(
                name: "Merchandise",
                rate: 0.05,
                level: .low,
                icon: "tshirt.fill",
                description: "Lower rate for venue merchandise",
                examples: ["T-shirts", "Hats", "Accessories", "Branded items", "Collectibles"]
            ),
            EarningCategory(
                name: "Other Purchases",
                rate: 0.05,
                level: .low,
                icon: "cart.fill",
                description: "Standard rate for miscellaneous items",
                examples: ["Gift cards", "Event tickets", "Special packages", "Promotions"]
            )
        ]
    }

    var categoryComparisons: [CategoryComparison] {
        categories.map { category in
            CategoryComparison(
                category: category.name,
                points: category.calculatePoints(for: selectedAmount)
            )
        }
        .sorted { $0.points > $1.points }
    }

    var highestEarningCategory: EarningCategory? {
        categories.max(by: { $0.rate < $1.rate })
    }

    var lowestEarningCategory: EarningCategory? {
        categories.min(by: { $0.rate < $1.rate })
    }

    func toggleExpanded(categoryId: UUID) {
        if expandedCategoryId == categoryId {
            expandedCategoryId = nil
        } else {
            expandedCategoryId = categoryId
        }
    }
}

// MARK: - Category Breakdown View
struct CategoryBreakdownView: View {
    @State private var viewModel = CategoryBreakdownViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Header
                headerSection

                // Quick Comparison Card
                comparisonCard

                // Amount Selector for Comparison
                amountSelectorCard

                // Comparison Chart
                comparisonChartCard

                // Categories List
                categoriesListSection

                // Tips Section
                tipsSection

                Spacer(minLength: Theme.Spacing.xl)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.lg)
        }
        .darkBackground()
        .navigationTitle("Earning Categories")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Points by Category")
                .typography(.titleMedium)
                .foregroundStyle(.textPrimary)

            Text("Different purchases earn points at different rates")
                .typography(.bodyMedium)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Comparison Card
    private var comparisonCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best Rate")
                        .typography(.bodySmall)
                        .foregroundStyle(.textSecondary)

                    if let highest = viewModel.highestEarningCategory {
                        Text(highest.name)
                            .typography(.headlineMedium)
                            .foregroundStyle(.success)

                        Text(highest.rateText)
                            .typography(.titleLarge)
                            .foregroundStyle(.success)
                    }
                }

                Spacer()

                Divider()
                    .frame(height: 50)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Standard Rate")
                        .typography(.bodySmall)
                        .foregroundStyle(.textSecondary)

                    if let lowest = viewModel.lowestEarningCategory {
                        Text(lowest.name)
                            .typography(.headlineMedium)
                            .foregroundStyle(.info)

                        Text(lowest.rateText)
                            .typography(.titleLarge)
                            .foregroundStyle(.info)
                    }
                }
            }

            // Difference Indicator
            if let highest = viewModel.highestEarningCategory,
               let lowest = viewModel.lowestEarningCategory {
                let difference = highest.rate - lowest.rate
                let percentDifference = (difference / lowest.rate) * 100

                Text("Beverages earn \(Int(percentDifference))% more points than standard purchases")
                    .typography(.bodySmall)
                    .foregroundStyle(.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Theme.Spacing.lg)
        .cardStyle()
    }

    // MARK: - Amount Selector Card
    private var amountSelectorCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Compare Earnings", systemImage: "chart.bar.xaxis")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            VStack(spacing: Theme.Spacing.sm) {
                Text("For €\(String(format: "%.0f", NSDecimalNumber(decimal: viewModel.selectedAmount).doubleValue)) purchase")
                    .typography(.bodyMedium)
                    .foregroundStyle(.textSecondary)

                // Amount Slider
                HStack(spacing: Theme.Spacing.md) {
                    Text("€10")
                        .typography(.bodySmall)
                        .foregroundStyle(.textTertiary)

                    Slider(
                        value: Binding(
                            get: { Double(truncating: viewModel.selectedAmount as NSNumber) },
                            set: { viewModel.selectedAmount = Decimal($0) }
                        ),
                        in: 10...500,
                        step: 10
                    )
                    .tint(.primary)

                    Text("€500")
                        .typography(.bodySmall)
                        .foregroundStyle(.textTertiary)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Comparison Chart Card
    private var comparisonChartCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Points Comparison", systemImage: "chart.bar.fill")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            // Bar Chart
            Chart(viewModel.categoryComparisons) { item in
                BarMark(
                    x: .value("Points", item.points),
                    y: .value("Category", item.category)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primaryGradientStart, .primaryGradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(4)
                .annotation(position: .trailing, spacing: 8) {
                    Text("\(item.points) pts")
                        .typography(.bodySmall)
                        .foregroundStyle(.textPrimary)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.textSecondary)
                }
            }
            .frame(height: CGFloat(viewModel.categories.count * 50))
        }
        .cardStyle()
    }

    // MARK: - Categories List Section
    private var categoriesListSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("All Categories", systemImage: "list.bullet.rectangle.fill")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            VStack(spacing: Theme.Spacing.sm) {
                ForEach(viewModel.categories) { category in
                    categoryCard(category)
                }
            }
        }
    }

    // MARK: - Category Card
    private func categoryCard(_ category: EarningCategory) -> some View {
        let isExpanded = viewModel.expandedCategoryId == category.id

        return VStack(alignment: .leading, spacing: 0) {
            // Main Content
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.toggleExpanded(categoryId: category.id)
                }
            } label: {
                HStack(spacing: Theme.Spacing.md) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(category.level.color.opacity(0.2))
                            .frame(width: 48, height: 48)

                        Image(systemName: category.icon)
                            .font(.title3)
                            .foregroundStyle(category.level.color)
                    }

                    // Category Info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Text(category.name)
                                .typography(.bodyLarge)
                                .foregroundStyle(.textPrimary)

                            // Level Badge
                            HStack(spacing: 4) {
                                Image(systemName: category.level.iconName)
                                    .font(.caption2)

                                Text(category.level.displayName)
                                    .typography(.bodySmall)
                            }
                            .foregroundStyle(category.level.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(category.level.color.opacity(0.15))
                            .cornerRadius(Theme.CornerRadius.sm)
                        }

                        Text(category.description)
                            .typography(.bodySmall)
                            .foregroundStyle(.textSecondary)
                            .lineLimit(isExpanded ? nil : 1)
                    }

                    Spacer()

                    // Rate and Expand Icon
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(category.rateText)
                            .typography(.titleMedium)
                            .foregroundStyle(category.level.color)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.textTertiary)
                            .font(.caption)
                    }
                }
                .padding(Theme.Spacing.md)
            }
            .buttonStyle(.plain)

            // Expanded Content
            if isExpanded {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Divider()

                    // Examples
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Examples:")
                            .typography(.bodySmall)
                            .foregroundStyle(.textSecondary)

                        ForEach(category.examples, id: \.self) { example in
                            HStack(spacing: Theme.Spacing.sm) {
                                Circle()
                                    .fill(category.level.color)
                                    .frame(width: 6, height: 6)

                                Text(example)
                                    .typography(.bodySmall)
                                    .foregroundStyle(.textPrimary)
                            }
                        }
                    }

                    // Calculation Example
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Earnings Calculator:")
                            .typography(.bodySmall)
                            .foregroundStyle(.textSecondary)

                        HStack(spacing: Theme.Spacing.md) {
                            ForEach([50, 100, 200], id: \.self) { amount in
                                let points = category.calculatePoints(for: Decimal(amount))
                                VStack(spacing: 4) {
                                    Text("€\(amount)")
                                        .typography(.bodySmall)
                                        .foregroundStyle(.textSecondary)

                                    Text("\(points) pts")
                                        .typography(.bodyMedium)
                                        .foregroundStyle(category.level.color)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.sm)
                                .background(category.level.color.opacity(0.1))
                                .cornerRadius(Theme.CornerRadius.sm)
                            }
                        }
                    }
                }
                .padding([.horizontal, .bottom], Theme.Spacing.md)
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .strokeBorder(category.level.color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Earning Tips", systemImage: "lightbulb.fill")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            VStack(spacing: Theme.Spacing.md) {
                tipCard(
                    icon: "wineglass.fill",
                    color: .success,
                    title: "Focus on Beverages",
                    description: "Drink purchases earn the highest points rate at 10%. Order cocktails and premium drinks to maximize earnings."
                )

                tipCard(
                    icon: "flame.fill",
                    color: Color(hex: "#FF6B35"),
                    title: "Stack with Bonuses",
                    description: "Combine high-earning categories with active bonuses. Happy Hour + Beverages = maximum points!"
                )

                tipCard(
                    icon: "star.fill",
                    color: .gold,
                    title: "Check-in First",
                    description: "Always check in before making purchases. You'll earn check-in points plus purchase points on the same visit."
                )

                tipCard(
                    icon: "arrow.triangle.2.circlepath",
                    color: .info,
                    title: "Mix Categories",
                    description: "Combine different categories in one visit. Food + beverages adds up to substantial points earnings."
                )
            }
        }
        .cardStyle()
    }

    private func tipCard(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.body)
            }

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

// MARK: - Category Level Badge Component
struct CategoryLevelBadge: View {
    let level: EarningCategory.EarningLevel
    let compact: Bool

    init(level: EarningCategory.EarningLevel, compact: Bool = false) {
        self.level = level
        self.compact = compact
    }

    var body: some View {
        HStack(spacing: compact ? 4 : 6) {
            Image(systemName: level.iconName)
                .font(compact ? .caption2 : .caption)

            if !compact {
                Text(level.displayName)
                    .typography(.bodySmall)
            }
        }
        .foregroundStyle(level.color)
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 3 : 4)
        .background(level.color.opacity(0.15))
        .cornerRadius(Theme.CornerRadius.sm)
    }
}

// MARK: - Preview
#Preview("Category Breakdown View") {
    NavigationStack {
        CategoryBreakdownView()
    }
}

#Preview("Category Level Badges") {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            CategoryLevelBadge(level: .high, compact: false)
            CategoryLevelBadge(level: .medium, compact: false)
            CategoryLevelBadge(level: .low, compact: false)
        }

        HStack(spacing: 8) {
            CategoryLevelBadge(level: .high, compact: true)
            CategoryLevelBadge(level: .medium, compact: true)
            CategoryLevelBadge(level: .low, compact: true)
        }
    }
    .padding()
    .darkBackground()
}
