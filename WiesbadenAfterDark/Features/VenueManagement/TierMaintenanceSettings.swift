//
//  TierMaintenanceSettings.swift
//  WiesbadenAfterDark
//
//  Configure tier retention and maintenance rules
//

import SwiftUI

/// Settings for tier maintenance and retention policies
struct TierMaintenanceSettings: View {
    @Binding var config: VenueTierConfig

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Header
            headerSection

            // Tier Reset Policy
            resetPolicySection

            // Inactivity Downgrade
            inactivitySection

            // Monthly Spending Requirement
            monthlySpendingSection

            // Grace Period
            gracePeriodSection

            // Info Box
            infoSection
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Tier Maintenance")
                .font(Typography.h2)
                .foregroundColor(.textPrimary)

            Text("Configure how members maintain their tier status and when tiers reset or downgrade.")
                .font(Typography.body)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Reset Policy Section

    private var resetPolicySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(.primary)
                    .font(.system(size: 20))

                Text("Tier Reset Policy")
                    .font(Typography.h3)
                    .foregroundColor(.textPrimary)
            }

            Text("Determine if and when member tiers reset to the starting level")
                .font(Typography.caption)
                .foregroundColor(.textSecondary)

            Picker("Reset Policy", selection: $config.tierResetPolicy) {
                ForEach(TierResetPolicy.allCases, id: \.self) { policy in
                    Text(policy.displayName).tag(policy)
                }
            }
            .pickerStyle(.segmented)

            // Policy Description
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))

                Text(config.tierResetPolicy.description)
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(Theme.Spacing.md)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.md)
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }

    // MARK: - Inactivity Section

    private var inactivitySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 20))

                Text("Inactivity Downgrade")
                    .font(Typography.h3)
                    .foregroundColor(.textPrimary)
            }

            Text("Automatically downgrade tier after period of inactivity")
                .font(Typography.caption)
                .foregroundColor(.textSecondary)

            Toggle("Enable Inactivity Downgrade", isOn: Binding(
                get: { config.inactivityDowngradeAfterDays != nil },
                set: { enabled in
                    config.inactivityDowngradeAfterDays = enabled ? 90 : nil
                }
            ))

            if config.inactivityDowngradeAfterDays != nil {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Days of Inactivity: \(config.inactivityDowngradeAfterDays ?? 0)")
                        .font(Typography.bodyBold)
                        .foregroundColor(.textPrimary)

                    Slider(
                        value: Binding(
                            get: { Double(config.inactivityDowngradeAfterDays ?? 90) },
                            set: { config.inactivityDowngradeAfterDays = Int($0) }
                        ),
                        in: 30...365,
                        step: 15
                    )
                    .accentColor(.orange)

                    HStack {
                        Text("30 days")
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)

                        Spacer()

                        Text("365 days")
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)
                    }
                }

                // Example Message
                Text("Members will be downgraded one tier if inactive for \(config.inactivityDowngradeAfterDays ?? 0) days")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                    .padding(Theme.Spacing.md)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.sm)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }

    // MARK: - Monthly Spending Section

    private var monthlySpendingSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 20))

                Text("Monthly Spending Requirement")
                    .font(Typography.h3)
                    .foregroundColor(.textPrimary)
            }

            Text("Require minimum monthly spending to maintain current tier")
                .font(Typography.caption)
                .foregroundColor(.textSecondary)

            Toggle("Require Monthly Spending", isOn: Binding(
                get: { config.monthlySpendingRequired != nil },
                set: { enabled in
                    config.monthlySpendingRequired = enabled ? 100 : nil
                }
            ))

            if config.monthlySpendingRequired != nil {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack {
                        Text("Required Amount:")
                            .font(Typography.bodyBold)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Text("€\(NSDecimalNumber(decimal: config.monthlySpendingRequired ?? 0).intValue)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                    }

                    TextField("Amount", value: Binding(
                        get: { config.monthlySpendingRequired ?? 0 },
                        set: { config.monthlySpendingRequired = $0 }
                    ), format: .currency(code: "EUR"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                }

                // Tier Levels Suggestion
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Suggested by Tier:")
                        .font(Typography.caption)
                        .foregroundColor(.textSecondary)

                    HStack(spacing: Theme.Spacing.md) {
                        tierSuggestionButton(.bronze, amount: 50)
                        tierSuggestionButton(.silver, amount: 100)
                        tierSuggestionButton(.gold, amount: 200)
                        tierSuggestionButton(.platinum, amount: 500)
                    }
                }
                .padding(.top, Theme.Spacing.sm)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }

    private func tierSuggestionButton(_ tier: MembershipTier, amount: Int) -> some View {
        Button(action: {
            config.monthlySpendingRequired = Decimal(amount)
        }) {
            VStack(spacing: Theme.Spacing.xs) {
                Text(tier.displayName)
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)

                Text("€\(amount)")
                    .font(Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: tier.color))
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Color(hex: tier.color).opacity(0.1))
            .cornerRadius(Theme.CornerRadius.sm)
        }
    }

    // MARK: - Grace Period Section

    private var gracePeriodSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "hourglass.circle.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 20))

                Text("Grace Period")
                    .font(Typography.h3)
                    .foregroundColor(.textPrimary)
            }

            Text("Give members extra time before downgrading or resetting their tier")
                .font(Typography.caption)
                .foregroundColor(.textSecondary)

            Toggle("Enable Grace Period", isOn: $config.hasGracePeriod)

            if config.hasGracePeriod {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Grace Period: \(config.gracePeriodDays) days")
                        .font(Typography.bodyBold)
                        .foregroundColor(.textPrimary)

                    Slider(
                        value: Binding(
                            get: { Double(config.gracePeriodDays) },
                            set: { config.gracePeriodDays = Int($0) }
                        ),
                        in: 7...90,
                        step: 7
                    )
                    .accentColor(.purple)

                    HStack {
                        Text("1 week")
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)

                        Spacer()

                        Text("3 months")
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)
                    }
                }

                // Example Message
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 16))

                    Text("Members get \(config.gracePeriodDays) extra days to meet requirements before tier changes")
                        .font(Typography.caption)
                        .foregroundColor(.textSecondary)
                }
                .padding(Theme.Spacing.md)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.sm)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Best Practices")
                        .font(Typography.bodyBold)
                        .foregroundColor(.textPrimary)

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        bestPracticeItem("Set reasonable inactivity periods (90-180 days recommended)")
                        bestPracticeItem("Use grace periods to retain loyal members temporarily away")
                        bestPracticeItem("Consider your venue type when setting monthly requirements")
                        bestPracticeItem("Communicate tier changes clearly to avoid member confusion")
                    }
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }

    private func bestPracticeItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: "checkmark")
                .font(.system(size: 12))
                .foregroundColor(.green)
                .frame(width: 16)

            Text(text)
                .font(Typography.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview("Tier Maintenance Settings") {
    ScrollView {
        TierMaintenanceSettings(config: .constant(VenueTierConfig.mock(venueId: UUID())))
            .padding()
    }
    .background(Color.appBackground)
}
