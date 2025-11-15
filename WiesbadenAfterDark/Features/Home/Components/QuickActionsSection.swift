//
//  QuickActionsSection.swift
//  WiesbadenAfterDark
//
//  Purpose: Grid of quick action buttons for common tasks
//  Used in: Home screen for quick access to features
//

import SwiftUI

/// Section with grid of quick action buttons
/// - Check-in, My Passes, History, Refer Friend
/// - Sign Out button at bottom
struct QuickActionsSection: View {
    // MARK: - Properties

    let onCheckIn: () -> Void
    let onMyPasses: () -> Void
    let onHistory: () -> Void
    let onShareReferral: () -> Void
    let onSignOut: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Check-In
                quickActionButton(
                    icon: "wave.3.right.circle.fill",
                    title: "Check In",
                    color: .purple,
                    action: onCheckIn
                )

                // My Passes
                quickActionButton(
                    icon: "wallet.pass.fill",
                    title: "My Passes",
                    color: .blue,
                    action: onMyPasses
                )

                // History
                quickActionButton(
                    icon: "clock.fill",
                    title: "History",
                    color: .green,
                    action: onHistory
                )

                // Share Referral
                quickActionButton(
                    icon: "gift.fill",
                    title: "Refer Friend",
                    color: .orange,
                    action: onShareReferral
                )
            }

            // Sign Out Button
            Button(action: onSignOut) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Helper Views

    private func quickActionButton(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Preview

#Preview("Quick Actions Section") {
    QuickActionsSection(
        onCheckIn: { print("Check In") },
        onMyPasses: { print("My Passes") },
        onHistory: { print("History") },
        onShareReferral: { print("Share Referral") },
        onSignOut: { print("Sign Out") }
    )
    .padding()
}
