//
//  ReferralCodeInputView.swift
//  WiesbadenAfterDark
//
//  Optional referral code input screen
//

import SwiftUI

/// Referral code input screen (optional step)
struct ReferralCodeInputView: View {
    // MARK: - Properties

    @Environment(AuthenticationViewModel.self) private var viewModel
    @State private var referralCode: String = ""
    @State private var showError: Bool = false

    var onComplete: () -> Void

    // MARK: - Computed Properties

    private var isCodeValid: Bool {
        referralCode.isEmpty || referralCode.isValidReferralCode
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: Theme.Spacing.md) {
                // Gift Icon
                Image(systemName: "gift.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.primaryGradient)
                    .padding(.bottom, Theme.Spacing.md)

                Text("Have a Referral Code?")
                    .font(Typography.titleLarge)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Earn bonus points when you join")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.Spacing.xxl)
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()
                .frame(height: Theme.Spacing.xxl)

            // Referral Code Input
            VStack(spacing: Theme.Spacing.md) {
                TextField("", text: $referralCode)
                    .placeholder(when: referralCode.isEmpty) {
                        Text("Enter code")
                            .font(Typography.bodyLarge)
                            .foregroundColor(.textTertiary)
                    }
                    .font(Typography.bodyLarge)
                    .foregroundColor(.textPrimary)
                    .textCase(.uppercase)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                    .multilineTextAlignment(.center)
                    .frame(height: 56)
                    .background(Color.inputBackground)
                    .cornerRadius(Theme.CornerRadius.lg)
                    .shake(showError)
                    .onChange(of: referralCode) { oldValue, newValue in
                        // Limit to 10 characters
                        if newValue.count > 10 {
                            referralCode = String(newValue.prefix(10))
                        }
                    }

                // Hint Text
                Text("Example: WIESBADEN2024")
                    .font(Typography.captionSmall)
                    .foregroundColor(.textTertiary)

                // Error Message
                if let error = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.error)

                        Text(error)
                            .font(Typography.captionMedium)
                            .foregroundColor(.error)

                        Spacer()
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .animation(Theme.Animation.standard, value: viewModel.errorMessage)

            Spacer()

            // Action Buttons
            VStack(spacing: Theme.Spacing.md) {
                // Continue Button
                PrimaryButton(
                    title: referralCode.isEmpty ? "Continue" : "Apply Code",
                    action: handleContinue,
                    isEnabled: isCodeValid,
                    isLoading: viewModel.isLoading
                )

                // Skip Button
                if !referralCode.isEmpty {
                    PrimaryButton(
                        title: "Skip",
                        action: handleSkip,
                        style: .text
                    )
                } else {
                    PrimaryButton(
                        title: "Skip",
                        action: handleSkip,
                        style: .secondary
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .hideKeyboardOnTap()
        .onChange(of: viewModel.errorMessage) { oldValue, newValue in
            if newValue != nil {
                withAnimation {
                    showError = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showError = false
                }
            }
        }
    }

    // MARK: - Actions

    private func handleContinue() {
        Task {
            viewModel.clearError()

            // Validate code if entered
            if !referralCode.isEmpty {
                let isValid = await viewModel.validateReferralCode(referralCode)
                guard isValid else { return }
            }

            // Complete account creation
            let success = await viewModel.completeAccountCreation()

            if success {
                onComplete()
            }
        }
    }

    private func handleSkip() {
        Task {
            viewModel.clearError()

            // Complete account creation without referral code
            let success = await viewModel.completeAccountCreation()

            if success {
                onComplete()
            }
        }
    }
}

// MARK: - Preview

#Preview("Referral Code Input View") {
    ReferralCodeInputView {
        print("Complete tapped")
    }
    .environment(AuthenticationViewModel())
}
