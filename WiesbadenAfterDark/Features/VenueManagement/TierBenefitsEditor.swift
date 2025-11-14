//
//  TierBenefitsEditor.swift
//  WiesbadenAfterDark
//
//  Editor for configuring benefits per tier
//

import SwiftUI

/// Editor for configuring tier benefits and perks
struct TierBenefitsEditor: View {
    @Binding var config: VenueTierConfig

    @State private var selectedTier: MembershipTier = .bronze
    @State private var showingAddPerk = false
    @State private var newPerkName = ""
    @State private var newPerkDescription = ""
    @State private var newPerkIcon = "star.fill"

    // Computed property to help compiler with type inference
    private var selectedTierColor: Color {
        Color(hex: selectedTier.color)
    }

    // Available perk templates
    private let perkTemplates: [TierPerk] = [
        TierPerk(name: "Early Event Access", description: "Book events before general release", icon: "calendar.badge.clock"),
        TierPerk(name: "Reserved Seating", description: "Priority table reservations", icon: "chair.fill"),
        TierPerk(name: "Birthday Bonus", description: "Special birthday reward", icon: "gift.fill"),
        TierPerk(name: "Skip-the-Line", description: "Fast-track venue entry", icon: "figure.walk.motion"),
        TierPerk(name: "Free Drinks", description: "Complimentary beverages", icon: "cup.and.saucer.fill"),
        TierPerk(name: "VIP Lounge Access", description: "Exclusive lounge area", icon: "star.circle.fill"),
        TierPerk(name: "Discount on Food", description: "10% off food orders", icon: "percent"),
        TierPerk(name: "Free Merchandise", description: "Venue branded items", icon: "tshirt.fill")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Header
            headerSection

            // Tier Selector
            tierSelector

            // Points Multiplier
            multiplierSection

            // Perks List
            perksSection

            // Add Perk Button
            addPerkButton
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Tier Benefits")
                .font(Typography.titleLarge)
                .foregroundColor(.textPrimary)

            Text("Configure points multipliers and exclusive perks for each membership tier.")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Tier Selector

    private var tierSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.md) {
                ForEach(MembershipTier.allCases, id: \.self) { tier in
                    tierSelectorButton(tier)
                }
            }
        }
    }

    private func tierSelectorButton(_ tier: MembershipTier) -> some View {
        Button(action: {
            withAnimation(Theme.Animation.quick) {
                selectedTier = tier
            }
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: tier.icon)
                    .font(.system(size: 18))

                Text(tier.displayName)
                    .font(Typography.headlineMedium)
            }
            .foregroundColor(selectedTier == tier ? .white : Color(hex: tier.color))
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
            .background(
                selectedTier == tier ?
                    Color(hex: tier.color) :
                    Color(hex: tier.color).opacity(0.1)
            )
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(Color(hex: tier.color), lineWidth: selectedTier == tier ? 0 : 1)
            )
        }
    }

    // MARK: - Multiplier Section

    private var multiplierSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Points Multiplier")
                .font(Typography.headlineLarge)
                .foregroundColor(.textPrimary)

            Text("Members earn \(formatMultiplier(currentMultiplier)) points for every €1 spent")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)

            HStack {
                Text("1.0x")
                    .font(Typography.captionMedium)
                    .foregroundColor(.textSecondary)

                Slider(value: multiplierBinding, in: 1.0...3.0, step: 0.1)
                    .accentColor(Color(hex: selectedTier.color))

                Text("3.0x")
                    .font(Typography.captionMedium)
                    .foregroundColor(.textSecondary)
            }

            // Multiplier Display
            HStack {
                Spacer()
                VStack(spacing: Theme.Spacing.xs) {
                    Text(formatMultiplier(currentMultiplier))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: selectedTier.color))

                    Text("Points Multiplier")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(Color(hex: selectedTier.color).opacity(0.1))
            .cornerRadius(Theme.CornerRadius.md)
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }

    // MARK: - Perks Section

    private var perksSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Exclusive Perks")
                .font(Typography.headlineLarge)
                .foregroundColor(.textPrimary)

            if currentPerks.isEmpty {
                emptyPerksView
            } else {
                ForEach(currentPerks) { perk in
                    perkCard(perk)
                }
            }
        }
    }

    private var emptyPerksView: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "gift.slash")
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)

            Text("No perks configured for \(selectedTier.displayName) tier")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)

            Text("Add exclusive perks to make this tier more attractive")
                .font(Typography.captionMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }

    private func perkCard(_ perk: TierPerk) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: selectedTier.color).opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: perk.icon)
                    .foregroundColor(Color(hex: selectedTier.color))
                    .font(.system(size: 18))
            }

            // Content
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(perk.name)
                    .font(Typography.headlineMedium)
                    .foregroundColor(.textPrimary)

                Text(perk.description)
                    .font(Typography.captionMedium)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Delete Button
            Button(action: {
                removePerk(perk)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 16))
            }
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(Color(hex: selectedTier.color).opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Add Perk Button

    private var addPerkButton: some View {
        Menu {
            Section("Quick Add Templates") {
                ForEach(perkTemplates) { template in
                    Button(action: {
                        addPerk(template)
                    }) {
                        Label(template.name, systemImage: template.icon)
                    }
                }
            }

            Divider()

            Button(action: {
                showingAddPerk = true
            }) {
                Label("Create Custom Perk", systemImage: "plus.circle")
            }
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Perk")
            }
            .font(Typography.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color(hex: selectedTier.color))
            .cornerRadius(Theme.CornerRadius.md)
        }
        .sheet(isPresented: $showingAddPerk) {
            customPerkSheet
        }
    }

    // MARK: - Custom Perk Sheet

    private var customPerkSheet: some View {
        NavigationView {
            Form {
                Section("Perk Details") {
                    TextField("Perk Name", text: $newPerkName)
                    TextField("Description", text: $newPerkDescription)
                }

                Section("Icon") {
                    // In production, you'd have an icon picker
                    TextField("SF Symbol Name", text: $newPerkIcon)

                    HStack {
                        Spacer()
                        Image(systemName: newPerkIcon)
                            .font(.system(size: 48))
                            .foregroundColor(selectedTierColor)
                        Spacer()
                    }
                }
            }
            .navigationTitle("New Perk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddPerk = false
                        resetPerkForm()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let perk = TierPerk(
                            name: newPerkName,
                            description: newPerkDescription,
                            icon: newPerkIcon
                        )
                        addPerk(perk)
                        showingAddPerk = false
                        resetPerkForm()
                    }
                    .disabled(newPerkName.isEmpty)
                }
            }
        }
    }

    // MARK: - Helpers

    private var multiplierBinding: Binding<Double> {
        Binding(
            get: {
                NSDecimalNumber(decimal: currentMultiplier).doubleValue
            },
            set: { newValue in
                setMultiplier(Decimal(newValue))
            }
        )
    }

    private var currentMultiplier: Decimal {
        switch selectedTier {
        case .bronze: return config.bronzeMultiplier
        case .silver: return config.silverMultiplier
        case .gold: return config.goldMultiplier
        case .platinum: return config.platinumMultiplier
        }
    }

    private func setMultiplier(_ value: Decimal) {
        switch selectedTier {
        case .bronze: config.bronzeMultiplier = value
        case .silver: config.silverMultiplier = value
        case .gold: config.goldMultiplier = value
        case .platinum: config.platinumMultiplier = value
        }
    }

    private var currentPerks: [TierPerk] {
        switch selectedTier {
        case .bronze: return config.bronzePerks
        case .silver: return config.silverPerks
        case .gold: return config.goldPerks
        case .platinum: return config.platinumPerks
        }
    }

    private func addPerk(_ perk: TierPerk) {
        var perks = currentPerks
        perks.append(perk)
        updatePerks(perks)
    }

    private func removePerk(_ perk: TierPerk) {
        var perks = currentPerks
        perks.removeAll { $0.id == perk.id }
        updatePerks(perks)
    }

    private func updatePerks(_ perks: [TierPerk]) {
        switch selectedTier {
        case .bronze:
            config.bronzePerksJSON = encodePerks(perks)
        case .silver:
            config.silverPerksJSON = encodePerks(perks)
        case .gold:
            config.goldPerksJSON = encodePerks(perks)
        case .platinum:
            config.platinumPerksJSON = encodePerks(perks)
        }
    }

    private func encodePerks(_ perks: [TierPerk]) -> String {
        if let data = try? JSONEncoder().encode(perks),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "[]"
    }

    private func formatMultiplier(_ multiplier: Decimal) -> String {
        let value = NSDecimalNumber(decimal: multiplier).doubleValue
        return String(format: "%.1fx", value)
    }

    private func resetPerkForm() {
        newPerkName = ""
        newPerkDescription = ""
        newPerkIcon = "star.fill"
    }
}

// MARK: - Preview

#Preview("Tier Benefits Editor") {
    ScrollView {
        TierBenefitsEditor(config: .constant(VenueTierConfig.mock(venueId: UUID())))
            .padding()
    }
    .background(Color.appBackground)
}
