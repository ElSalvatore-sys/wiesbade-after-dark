//
//  TierConfigurationView.swift
//  WiesbadenAfterDark
//
//  Venue owner dashboard for configuring tier system
//

import SwiftUI
import SwiftData

/// Main configuration view for venue owners to customize their tier system
struct TierConfigurationView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let venueId: UUID
    let venueName: String

    @State private var config: VenueTierConfig
    @State private var selectedTab: ConfigTab = .thresholds
    @State private var showingSaveConfirmation = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    // MARK: - Tabs

    enum ConfigTab: String, CaseIterable {
        case thresholds = "Thresholds"
        case benefits = "Benefits"
        case badges = "Badges"
        case maintenance = "Maintenance"

        var icon: String {
            switch self {
            case .thresholds: return "chart.bar.fill"
            case .benefits: return "gift.fill"
            case .badges: return "rosette"
            case .maintenance: return "gear"
            }
        }
    }

    // MARK: - Initialization

    init(venueId: UUID, venueName: String, config: VenueTierConfig? = nil) {
        self.venueId = venueId
        self.venueName = venueName
        self._config = State(initialValue: config ?? VenueTierConfig.defaultConfig(venueId: venueId))
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                tabSelector

                // Content
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Header
                        headerSection

                        // Tab Content
                        switch selectedTab {
                        case .thresholds:
                            TierThresholdsEditor(config: $config)
                        case .benefits:
                            TierBenefitsEditor(config: $config)
                        case .badges:
                            BadgeConfigurationView(venueId: venueId)
                        case .maintenance:
                            TierMaintenanceSettings(config: $config)
                        }
                    }
                    .padding(Theme.Spacing.lg)
                }

                // Save Button
                saveButton
            }
            .background(Color.appBackground)
            .navigationTitle("Tier Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Configuration Saved", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your tier configuration has been saved successfully.")
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(venueName)
                        .font(Typography.titleLarge)
                        .foregroundColor(.textPrimary)

                    Text("Configure your membership tier system")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "building.2.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.primary)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
        .shadow(
            color: Theme.Shadow.sm.color,
            radius: Theme.Shadow.sm.radius,
            x: Theme.Shadow.sm.x,
            y: Theme.Shadow.sm.y
        )
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.md) {
                ForEach(ConfigTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
        }
        .background(Color.cardBackground)
        .shadow(
            color: Theme.Shadow.sm.color,
            radius: Theme.Shadow.sm.radius,
            x: Theme.Shadow.sm.x,
            y: Theme.Shadow.sm.y
        )
    }

    private func tabButton(for tab: ConfigTab) -> some View {
        Button(action: {
            withAnimation(Theme.Animation.quick) {
                selectedTab = tab
            }
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16))

                Text(tab.rawValue)
                    .font(Typography.headlineMedium)
            }
            .foregroundColor(selectedTab == tab ? .white : .textSecondary)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
            .background(
                selectedTab == tab ?
                    Color.primaryGradient :
                    LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(Theme.CornerRadius.md)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        VStack(spacing: 0) {
            Divider()

            PrimaryButton(
                title: "Save Configuration",
                action: saveConfiguration,
                isLoading: isSaving
            )
            .padding(Theme.Spacing.lg)
        }
        .background(Color.cardBackground)
    }

    // MARK: - Actions

    private func saveConfiguration() {
        isSaving = true

        // In production, this would save to the backend API
        // For now, we'll simulate a save with SwiftData
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_000_000_000)

                // Save to model context
                modelContext.insert(config)
                try modelContext.save()

                await MainActor.run {
                    isSaving = false
                    showingSaveConfirmation = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "Failed to save configuration: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Tier Thresholds Editor

struct TierThresholdsEditor: View {
    @Binding var config: VenueTierConfig

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("Spending Thresholds")
                .font(Typography.titleLarge)
                .foregroundColor(.textPrimary)

            Text("Set the minimum spending required to reach each tier. Based on total lifetime spending at your venue.")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)

            // Bronze Tier
            tierThresholdCard(
                tier: .bronze,
                min: $config.bronzeMin,
                max: $config.bronzeMax,
                multiplier: config.bronzeMultiplier
            )

            // Silver Tier
            tierThresholdCard(
                tier: .silver,
                min: $config.silverMin,
                max: $config.silverMax,
                multiplier: config.silverMultiplier
            )

            // Gold Tier
            tierThresholdCard(
                tier: .gold,
                min: $config.goldMin,
                max: $config.goldMax,
                multiplier: config.goldMultiplier
            )

            // Platinum Tier
            tierThresholdCard(
                tier: .platinum,
                min: $config.platinumMin,
                max: .constant(999999), // No max for platinum
                multiplier: config.platinumMultiplier,
                isMaxTier: true
            )
        }
    }

    private func tierThresholdCard(
        tier: MembershipTier,
        min: Binding<Decimal>,
        max: Binding<Decimal>,
        multiplier: Decimal,
        isMaxTier: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: tier.icon)
                    .foregroundColor(Color(hex: tier.color))
                    .font(.system(size: 24))

                Text(tier.displayName)
                    .font(Typography.headlineLarge)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(formatMultiplier(multiplier)) pts")
                    .font(Typography.captionMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Color(hex: tier.color))
                    .cornerRadius(Theme.CornerRadius.sm)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Spending Range")
                    .font(Typography.headlineMedium)
                    .foregroundColor(.textSecondary)

                HStack(spacing: Theme.Spacing.md) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("From")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)

                        TextField("Min", value: min, format: .currency(code: "EUR"))
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .disabled(tier == .bronze) // Bronze always starts at 0
                    }

                    if !isMaxTier {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("To")
                                .font(Typography.captionMedium)
                                .foregroundColor(.textSecondary)

                            TextField("Max", value: max, format: .currency(code: "EUR"))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("To")
                                .font(Typography.captionMedium)
                                .foregroundColor(.textSecondary)

                            Text("No Limit")
                                .font(Typography.bodyMedium)
                                .foregroundColor(.textSecondary)
                                .frame(height: 36)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(Theme.CornerRadius.sm)
                        }
                    }
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(Color(hex: tier.color).opacity(0.3), lineWidth: 2)
        )
    }

    private func formatMultiplier(_ multiplier: Decimal) -> String {
        let value = NSDecimalNumber(decimal: multiplier).doubleValue
        return String(format: "%.1fx", value)
    }
}

// MARK: - Preview

#Preview("Tier Configuration") {
    TierConfigurationView(
        venueId: UUID(),
        venueName: "Das Wohnzimmer",
        config: VenueTierConfig.mock(venueId: UUID())
    )
    .modelContainer(for: [VenueTierConfig.self], inMemory: true)
}
