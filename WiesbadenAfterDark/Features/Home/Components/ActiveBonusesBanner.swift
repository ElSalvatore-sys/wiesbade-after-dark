//
//  ActiveBonusesBanner.swift
//  WiesbadenAfterDark
//
//  Purpose: Banner to highlight active bonus point offers
//  Used in: Home screen to promote active deals
//

import SwiftUI

/// Banner displaying active bonuses summary
/// - Shows flame icon for attention
/// - Displays bonus summary text
/// - Tappable for navigation to full list
struct ActiveBonusesBanner: View {
    // MARK: - Properties

    let hasActiveBonuses: Bool
    let bonusesSummary: String?

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(Color.gold)

            VStack(alignment: .leading, spacing: 2) {
                Text("Active Bonuses")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                if let summary = bonusesSummary {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.textTertiary)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color.gold.opacity(0.15),
                    Color.warning.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .strokeBorder(Color.gold.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("Active Bonuses Banner") {
    ActiveBonusesBanner(
        hasActiveBonuses: true,
        bonusesSummary: "15 products • 12 expiring soon"
    )
    .padding()
}
