//
//  HomeView.swift
//  WiesbadenAfterDark
//
//  Home screen placeholder (temporary)
//

import SwiftUI

/// Home screen - main app view after authentication
/// This is a placeholder for now
struct HomeView: View {
    // MARK: - Properties

    @Environment(AuthenticationViewModel.self) private var viewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.success)

            // Welcome Message
            VStack(spacing: Theme.Spacing.md) {
                Text("Welcome to")
                    .font(Typography.titleLarge)
                    .foregroundColor(.textSecondary)

                Text("Wiesbaden After Dark!")
                    .font(Typography.displayMedium)
                    .foregroundStyle(Color.primaryGradient)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                if let user = viewModel.authState.user {
                    Text("Phone: \(user.formattedPhoneNumber)")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .padding(.top, Theme.Spacing.sm)

                    Text("Your Code: \(user.referralCode)")
                        .font(Typography.headlineMedium)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Color.inputBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                        .padding(.top, Theme.Spacing.sm)

                    if user.pointsBalance > 0 {
                        Text("\(user.pointsBalance) Points")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.gold)
                            .padding(.top, Theme.Spacing.xs)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()

            // Info Text
            Text("🎉 Authentication Complete!")
                .font(Typography.bodyLarge)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, Theme.Spacing.lg)
                .multilineTextAlignment(.center)

            Text("The home screen will be built next")
                .font(Typography.captionMedium)
                .foregroundColor(.textTertiary)
                .padding(.horizontal, Theme.Spacing.lg)

            // Sign Out Button
            PrimaryButton(
                title: "Sign Out",
                action: {
                    viewModel.signOut()
                },
                style: .secondary
            )
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// MARK: - Preview

#Preview("Home View") {
    HomeView()
        .environment(AuthenticationViewModel())
}
