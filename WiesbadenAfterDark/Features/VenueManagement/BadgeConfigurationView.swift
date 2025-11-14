//
//  BadgeConfigurationView.swift
//  WiesbadenAfterDark
//
//  Configure custom badges and achievements for the venue
//

import SwiftUI
import SwiftData

/// View for configuring custom achievement badges
struct BadgeConfigurationView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Query private var badges: [BadgeConfig]

    let venueId: UUID

    @State private var showingAddBadge = false
    @State private var editingBadge: BadgeConfig?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Header
            headerSection

            // Badges List
            if venueBadges.isEmpty {
                emptyStateView
            } else {
                badgesListSection
            }

            // Add Badge Button
            addBadgeButton
        }
        .sheet(isPresented: $showingAddBadge) {
            BadgeEditorSheet(venueId: venueId, badge: nil)
        }
        .sheet(item: $editingBadge) { badge in
            BadgeEditorSheet(venueId: venueId, badge: badge)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Badges & Achievements")
                .font(Typography.titleLarge)
                .foregroundColor(.textPrimary)

            Text("Create custom badges to reward members for visits, spending, referrals, and more.")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "rosette")
                .font(.system(size: 64))
                .foregroundColor(.textSecondary)

            VStack(spacing: Theme.Spacing.sm) {
                Text("No Badges Yet")
                    .font(Typography.headlineLarge)
                    .foregroundColor(.textPrimary)

                Text("Create achievement badges to motivate and reward your loyal customers")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }

    // MARK: - Badges List

    private var badgesListSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(venueBadges) { badge in
                badgeCard(badge)
            }
        }
    }

    private func badgeCard(_ badge: BadgeConfig) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                // Badge Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: badge.color).opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: badge.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: badge.color))
                }

                // Badge Info
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack {
                        Text(badge.name)
                            .font(Typography.headlineLarge)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { badge.isActive },
                            set: { newValue in
                                badge.isActive = newValue
                                try? modelContext.save()
                            }
                        ))
                        .labelsHidden()
                    }

                    Text(badge.badgeDescription)
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }

            Divider()

            // Requirements
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Requirements")
                    .font(Typography.captionMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textSecondary)

                requirementsList(for: badge)
            }

            // Rewards
            HStack(spacing: Theme.Spacing.lg) {
                if badge.pointsReward > 0 {
                    rewardItem(
                        icon: "star.fill",
                        text: "\(badge.pointsReward) pts",
                        color: .yellow
                    )
                }

                if let multiplier = badge.bonusMultiplier {
                    rewardItem(
                        icon: "arrow.up.circle.fill",
                        text: "\(formatMultiplier(multiplier)) bonus",
                        color: .green
                    )
                }
            }

            // Actions
            HStack(spacing: Theme.Spacing.md) {
                Button(action: {
                    editingBadge = badge
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(Typography.captionMedium)
                    .foregroundColor(.primary)
                }

                Spacer()

                Button(action: {
                    deleteBadge(badge)
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(Typography.captionMedium)
                    .foregroundColor(.red)
                }
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

    private func requirementsList(for badge: BadgeConfig) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            if let visits = badge.requiredVisits {
                requirementRow(
                    icon: "calendar.badge.checkmark",
                    text: "Visit \(visits) times"
                )
            }

            if let spending = badge.requiredSpending {
                requirementRow(
                    icon: "dollarsign.circle.fill",
                    text: "Spend €\(NSDecimalNumber(decimal: spending).intValue)"
                )
            }

            if let referrals = badge.requiredReferrals {
                requirementRow(
                    icon: "person.2.fill",
                    text: "Refer \(referrals) friends"
                )
            }

            if let days = badge.requiredDays, let visits = badge.requiredVisits {
                requirementRow(
                    icon: "clock.fill",
                    text: "Within \(days) days"
                )
            }
        }
    }

    private func requirementRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .frame(width: 20)

            Text(text)
                .font(Typography.captionMedium)
                .foregroundColor(.textSecondary)
        }
    }

    private func rewardItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)

            Text(text)
                .font(Typography.captionMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.sm)
    }

    // MARK: - Add Badge Button

    private var addBadgeButton: some View {
        Button(action: {
            showingAddBadge = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Create Badge")
            }
            .font(Typography.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.primaryGradient)
            .cornerRadius(Theme.CornerRadius.md)
        }
    }

    // MARK: - Helpers

    private var venueBadges: [BadgeConfig] {
        badges.filter { $0.venueId == venueId }
    }

    private func deleteBadge(_ badge: BadgeConfig) {
        modelContext.delete(badge)
        try? modelContext.save()
    }

    private func formatMultiplier(_ multiplier: Decimal) -> String {
        let value = NSDecimalNumber(decimal: multiplier).doubleValue
        return String(format: "%.1fx", value)
    }
}

// MARK: - Badge Editor Sheet

struct BadgeEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let venueId: UUID
    let badge: BadgeConfig?

    @State private var name: String
    @State private var description: String
    @State private var iconName: String
    @State private var color: String
    @State private var requiredVisits: Int?
    @State private var requiredSpending: Decimal?
    @State private var requiredReferrals: Int?
    @State private var requiredDays: Int?
    @State private var pointsReward: Int
    @State private var bonusMultiplier: Decimal?

    // Common icon options
    private let iconOptions = [
        "calendar.badge.checkmark", "dollarsign.circle.fill", "person.2.fill",
        "flame.fill", "star.fill", "crown.fill", "trophy.fill", "rosette",
        "heart.fill", "bolt.fill", "sparkles", "moon.stars.fill"
    ]

    // Color options
    private let colorOptions = [
        "#3B82F6", "#10B981", "#F59E0B", "#EF4444", "#8B5CF6",
        "#EC4899", "#06B6D4", "#14B8A6", "#F97316"
    ]

    init(venueId: UUID, badge: BadgeConfig?) {
        self.venueId = venueId
        self.badge = badge

        _name = State(initialValue: badge?.name ?? "")
        _description = State(initialValue: badge?.badgeDescription ?? "")
        _iconName = State(initialValue: badge?.iconName ?? "star.fill")
        _color = State(initialValue: badge?.color ?? "#3B82F6")
        _requiredVisits = State(initialValue: badge?.requiredVisits)
        _requiredSpending = State(initialValue: badge?.requiredSpending)
        _requiredReferrals = State(initialValue: badge?.requiredReferrals)
        _requiredDays = State(initialValue: badge?.requiredDays)
        _pointsReward = State(initialValue: badge?.pointsReward ?? 0)
        _bonusMultiplier = State(initialValue: badge?.bonusMultiplier)
    }

    var body: some View {
        NavigationView {
            Form {
                // Basic Info
                Section("Badge Details") {
                    TextField("Badge Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                // Icon & Color
                Section("Appearance") {
                    // Icon Picker
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Icon")
                            .font(Typography.headlineMedium)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: Theme.Spacing.md) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Button(action: {
                                    iconName = icon
                                }) {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(iconName == icon ? .white : Color(hex: color))
                                        .frame(width: 50, height: 50)
                                        .background(iconName == icon ? Color(hex: color) : Color.gray.opacity(0.1))
                                        .cornerRadius(Theme.CornerRadius.sm)
                                }
                            }
                        }
                    }

                    // Color Picker
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Color")
                            .font(Typography.headlineMedium)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: Theme.Spacing.md) {
                            ForEach(colorOptions, id: \.self) { colorHex in
                                Button(action: {
                                    color = colorHex
                                }) {
                                    Circle()
                                        .fill(Color(hex: colorHex))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: color == colorHex ? 3 : 0)
                                        )
                                        .shadow(radius: color == colorHex ? 4 : 0)
                                }
                            }
                        }
                    }
                }

                // Requirements
                Section("Requirements") {
                    Toggle("Require Visits", isOn: Binding(
                        get: { requiredVisits != nil },
                        set: { requiredVisits = $0 ? 5 : nil }
                    ))

                    if requiredVisits != nil {
                        Stepper("Visits: \(requiredVisits ?? 0)", value: Binding(
                            get: { requiredVisits ?? 0 },
                            set: { requiredVisits = $0 }
                        ), in: 1...100)
                    }

                    Toggle("Require Spending", isOn: Binding(
                        get: { requiredSpending != nil },
                        set: { requiredSpending = $0 ? 100 : nil }
                    ))

                    if requiredSpending != nil {
                        TextField("Amount (€)", value: Binding(
                            get: { requiredSpending ?? 0 },
                            set: { requiredSpending = $0 }
                        ), format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
                    }

                    Toggle("Require Referrals", isOn: Binding(
                        get: { requiredReferrals != nil },
                        set: { requiredReferrals = $0 ? 3 : nil }
                    ))

                    if requiredReferrals != nil {
                        Stepper("Referrals: \(requiredReferrals ?? 0)", value: Binding(
                            get: { requiredReferrals ?? 0 },
                            set: { requiredReferrals = $0 }
                        ), in: 1...50)
                    }

                    Toggle("Time Limit", isOn: Binding(
                        get: { requiredDays != nil },
                        set: { requiredDays = $0 ? 30 : nil }
                    ))

                    if requiredDays != nil {
                        Stepper("Within \(requiredDays ?? 0) days", value: Binding(
                            get: { requiredDays ?? 0 },
                            set: { requiredDays = $0 }
                        ), in: 1...365)
                    }
                }

                // Rewards
                Section("Rewards") {
                    Stepper("Points: \(pointsReward)", value: $pointsReward, in: 0...10000, step: 50)

                    Toggle("Bonus Multiplier", isOn: Binding(
                        get: { bonusMultiplier != nil },
                        set: { bonusMultiplier = $0 ? 1.1 : nil }
                    ))

                    if bonusMultiplier != nil {
                        Slider(value: Binding(
                            get: { NSDecimalNumber(decimal: bonusMultiplier ?? 1.0).doubleValue },
                            set: { bonusMultiplier = Decimal($0) }
                        ), in: 1.0...2.0, step: 0.1)

                        Text("Multiplier: \(formatMultiplier(bonusMultiplier ?? 1.0))")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .navigationTitle(badge == nil ? "New Badge" : "Edit Badge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBadge()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveBadge() {
        if let badge = badge {
            // Update existing badge
            badge.name = name
            badge.badgeDescription = description
            badge.iconName = iconName
            badge.color = color
            badge.requiredVisits = requiredVisits
            badge.requiredSpending = requiredSpending
            badge.requiredReferrals = requiredReferrals
            badge.requiredDays = requiredDays
            badge.pointsReward = pointsReward
            badge.bonusMultiplier = bonusMultiplier
            badge.updatedAt = Date()
        } else {
            // Create new badge
            let newBadge = BadgeConfig(
                venueId: venueId,
                name: name,
                description: description,
                iconName: iconName,
                color: color,
                requiredVisits: requiredVisits,
                requiredSpending: requiredSpending,
                requiredReferrals: requiredReferrals,
                requiredDays: requiredDays,
                pointsReward: pointsReward,
                bonusMultiplier: bonusMultiplier
            )
            modelContext.insert(newBadge)
        }

        try? modelContext.save()
        dismiss()
    }

    private func formatMultiplier(_ multiplier: Decimal) -> String {
        let value = NSDecimalNumber(decimal: multiplier).doubleValue
        return String(format: "%.1fx", value)
    }
}

// MARK: - Preview

#Preview("Badge Configuration") {
    BadgeConfigurationView(venueId: UUID())
        .modelContainer(for: [BadgeConfig.self], inMemory: true)
        .padding()
        .background(Color.appBackground)
}
