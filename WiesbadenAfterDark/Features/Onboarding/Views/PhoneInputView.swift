//
//  PhoneInputView.swift
//  WiesbadenAfterDark
//
//  Phone number input screen
//

import SwiftUI

/// Phone number input screen
struct PhoneInputView: View {
    // MARK: - Properties

    @Environment(AuthenticationViewModel.self) private var viewModel
    @State private var phoneNumber: String = ""
    @State private var showError: Bool = false

    var onContinue: () -> Void

    // MARK: - Computed Properties

    private var isPhoneValid: Bool {
        phoneNumber.isValidGermanPhoneNumber
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: Theme.Spacing.md) {
                Text("Enter Your Phone Number")
                    .font(Typography.titleLarge)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text("We'll send you a verification code")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.Spacing.xxl)
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()
                .frame(height: Theme.Spacing.xxl)

            // Phone Input
            VStack(spacing: Theme.Spacing.md) {
                PhoneTextField(phoneNumber: $phoneNumber)
                    .shake(showError)

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

            // Continue Button
            PrimaryButton(
                title: "Continue",
                action: handleContinue,
                isEnabled: isPhoneValid,
                isLoading: viewModel.isLoading
            )
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
            await viewModel.sendVerificationCode(to: phoneNumber)

            // Navigate to verification if no error
            if viewModel.errorMessage == nil {
                onContinue()
            }
        }
    }
}

// MARK: - Preview

#Preview("Phone Input View") {
    PhoneInputView {
        print("Continue tapped")
    }
    .environment(AuthenticationViewModel())
}
