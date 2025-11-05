//
//  WelcomeView.swift
//  WiesbadenAfterDark
//
//  Welcome screen with app branding and CTA
//

import SwiftUI

/// Welcome screen - first screen users see
struct WelcomeView: View {
    // MARK: - Properties

    var onGetStarted: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // App Logo and Branding
            VStack(spacing: Theme.Spacing.lg) {
                // Logo Icon
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.primaryGradient)
                    .shadow(
                        color: Color.primary.opacity(0.5),
                        radius: 20,
                        x: 0,
                        y: 10
                    )

                // App Name
                Text("Wiesbaden")
                    .font(Typography.displayMedium)
                    .foregroundColor(.textPrimary)
                    .fontWeight(.bold)

                Text("After Dark")
                    .font(Typography.displayMedium)
                    .foregroundStyle(Color.primaryGradient)
                    .fontWeight(.bold)

                // Tagline
                Text("Wiesbaden's Nightlife Network")
                    .font(Typography.bodyLarge)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, Theme.Spacing.sm)
            }

            Spacer()

            // Features List
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                FeatureRow(
                    icon: "calendar.badge.clock",
                    title: "Exclusive Events",
                    description: "RSVP to the hottest parties"
                )

                FeatureRow(
                    icon: "ticket.fill",
                    title: "Book Tables",
                    description: "Reserve your spot instantly"
                )

                FeatureRow(
                    icon: "gift.fill",
                    title: "Earn Rewards",
                    description: "Get points for drinks & VIP access"
                )

                FeatureRow(
                    icon: "person.2.fill",
                    title: "Invite Friends",
                    description: "Earn bonus points for referrals"
                )
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)

            // CTA Button
            PrimaryButton(title: "Get Started") {
                onGetStarted()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color.primaryGradient)
                .frame(width: 40, height: 40)
                .background(Color.inputBackground)
                .cornerRadius(Theme.CornerRadius.md)

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.headlineMedium)
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(Typography.bodySmall)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Welcome View") {
    WelcomeView {
        print("Get Started tapped")
    }
}
