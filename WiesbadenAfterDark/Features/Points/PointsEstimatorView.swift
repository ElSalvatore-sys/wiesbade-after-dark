//
//  PointsEstimatorView.swift
//  WiesbadenAfterDark
//
//  Created by Claude Code on 2025-11-13.
//

import SwiftUI

// MARK: - Points Estimator View Model
@Observable @MainActor
final class PointsEstimatorViewModel {
    var amountText: String = ""
    var selectedCategory: PurchaseCategory = .beverages

    var estimatedPoints: Int {
        guard let amount = Decimal(string: amountText), amount > 0 else {
            return 0
        }

        // Calculate points based on category earning rate
        let basePoints = amount * selectedCategory.pointsRate
        return Int(truncating: basePoints as NSNumber)
    }

    var formattedAmount: String {
        guard let amount = Decimal(string: amountText), amount > 0 else {
            return "€0.00"
        }
        return "€\(String(format: "%.2f", NSDecimalNumber(decimal: amount).doubleValue))"
    }

    var formulaText: String {
        guard estimatedPoints > 0 else {
            return "Enter amount to see calculation"
        }

        let ratePercent = Int(selectedCategory.pointsRate * 100)
        return "\(formattedAmount) \(selectedCategory.displayName.lowercased()) → ~\(estimatedPoints) points (\(ratePercent)% rate)"
    }
}

// MARK: - Purchase Category
enum PurchaseCategory: String, CaseIterable, Identifiable {
    case beverages
    case food
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beverages: return "Beverages"
        case .food: return "Food"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .beverages: return "wineglass.fill"
        case .food: return "fork.knife"
        case .other: return "cart.fill"
        }
    }

    // Points earning rate as decimal (percentage)
    var pointsRate: Decimal {
        switch self {
        case .beverages: return 0.10  // 10% - High earning
        case .food: return 0.08       // 8% - Medium earning
        case .other: return 0.05      // 5% - Low earning
        }
    }

    var earningLevel: String {
        switch self {
        case .beverages: return "High earning"
        case .food: return "Medium earning"
        case .other: return "Low earning"
        }
    }

    var accentColor: Color {
        switch self {
        case .beverages: return .success
        case .food: return .warning
        case .other: return .info
        }
    }
}

// MARK: - Points Estimator View
struct PointsEstimatorView: View {
    @State private var viewModel = PointsEstimatorViewModel()
    @FocusState private var isAmountFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Header
                headerSection

                // Amount Input
                amountInputCard

                // Category Selector
                categorySelectorCard

                // Estimated Points Display
                estimatedPointsCard

                // Formula Breakdown
                formulaCard

                // Disclaimer
                disclaimerCard

                Spacer(minLength: Theme.Spacing.xl)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.lg)
        }
        .darkBackground()
        .navigationTitle("Points Estimator")
        .navigationBarTitleDisplayMode(.large)
        .hideKeyboardOnTap()
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Calculate Estimated Points")
                .typography(.titleMedium)
                .foregroundStyle(.textPrimary)

            Text("Preview how many points you could earn on your next purchase")
                .typography(.bodyMedium)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Amount Input Card
    private var amountInputCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Purchase Amount", systemImage: "eurosign.circle.fill")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            HStack(spacing: Theme.Spacing.sm) {
                Text("€")
                    .typography(.titleLarge)
                    .foregroundStyle(.textSecondary)

                TextField("0.00", text: $viewModel.amountText)
                    .typography(.titleLarge)
                    .foregroundStyle(.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
                    .frame(maxWidth: .infinity)
            }
            .padding(Theme.Spacing.md)
            .background(Color.inputBackground)
            .cornerRadius(Theme.CornerRadius.md)
        }
        .cardStyle()
    }

    // MARK: - Category Selector Card
    private var categorySelectorCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Purchase Category", systemImage: "tag.fill")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            VStack(spacing: Theme.Spacing.sm) {
                ForEach(PurchaseCategory.allCases) { category in
                    categoryRow(category)
                }
            }
        }
        .cardStyle()
    }

    private func categoryRow(_ category: PurchaseCategory) -> some View {
        Button {
            viewModel.selectedCategory = category
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                // Icon
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(category.accentColor)
                    .frame(width: 32)

                // Category Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.displayName)
                        .typography(.bodyLarge)
                        .foregroundStyle(.textPrimary)

                    Text(category.earningLevel)
                        .typography(.bodySmall)
                        .foregroundStyle(.textSecondary)
                }

                Spacer()

                // Rate Badge
                Text("\(Int(category.pointsRate * 100))%")
                    .typography(.bodySmall)
                    .foregroundStyle(category.accentColor)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(category.accentColor.opacity(0.15))
                    .cornerRadius(Theme.CornerRadius.sm)

                // Selection Indicator
                Image(systemName: viewModel.selectedCategory == category ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(viewModel.selectedCategory == category ? .primary : .textTertiary)
                    .font(.title3)
            }
            .padding(Theme.Spacing.md)
            .background(
                viewModel.selectedCategory == category
                    ? Color.primary.opacity(0.1)
                    : Color.cardBackground
            )
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .strokeBorder(
                        viewModel.selectedCategory == category
                            ? Color.primary.opacity(0.3)
                            : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Estimated Points Card
    private var estimatedPointsCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            // "Estimated" Label
            Text("Estimated Points")
                .typography(.headlineMedium)
                .foregroundStyle(.textSecondary)

            // Large Points Display
            HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.sm) {
                Text("~")
                    .typography(.titleLarge)
                    .foregroundStyle(.textTertiary)

                Text("\(viewModel.estimatedPoints)")
                    .typography(.displayLarge)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primaryGradientStart, .primaryGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("points")
                    .typography(.titleMedium)
                    .foregroundStyle(.textSecondary)
            }

            // Points Value in Euro
            if viewModel.estimatedPoints > 0 {
                let euroValue = Decimal(viewModel.estimatedPoints) / 10
                Text("≈ €\(String(format: "%.2f", NSDecimalNumber(decimal: euroValue).doubleValue)) value")
                    .typography(.bodyMedium)
                    .foregroundStyle(.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    Color.primary.opacity(0.1),
                    Color.primaryGradientEnd.opacity(0.05)
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
                        colors: [.primary.opacity(0.3), .primaryGradientEnd.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Formula Card
    private var formulaCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Calculation Breakdown", systemImage: "function")
                .typography(.headlineMedium)
                .foregroundStyle(.textPrimary)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                // Formula Display
                Text(viewModel.formulaText)
                    .typography(.bodyMedium)
                    .foregroundStyle(.textSecondary)
                    .padding(Theme.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.inputBackground)
                    .cornerRadius(Theme.CornerRadius.md)

                // Explanation
                if viewModel.estimatedPoints > 0 {
                    HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.info)
                            .font(.body)

                        Text("Points are calculated based on purchase amount × category earning rate. Higher rates for beverages encourage in-venue spending.")
                            .typography(.bodySmall)
                            .foregroundStyle(.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Disclaimer Card
    private var disclaimerCard: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.warning)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text("Estimate Only")
                    .typography(.headlineSmall)
                    .foregroundStyle(.textPrimary)

                Text("Final points calculated at checkout based on actual purchase details, active bonuses, and venue-specific multipliers.")
                    .typography(.bodySmall)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Color.warning.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .strokeBorder(Color.warning.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PointsEstimatorView()
    }
}
