//
//  VerificationCodeView.swift
//  WiesbadenAfterDark
//
//  SMS verification code input screen
//

import SwiftUI

/// Verification code input screen
struct VerificationCodeView: View {
    // MARK: - Properties

    @Environment(AuthenticationViewModel.self) private var viewModel
    @State private var code: String = ""
    @State private var showError: Bool = false

    var phoneNumber: String
    var onSuccess: () -> Void

    // MARK: - Computed Properties

    private var formattedPhoneNumber: String {
        phoneNumber.formattedAsPhoneNumber()
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: Theme.Spacing.md) {
                Text("Enter Verification Code")
                    .font(Typography.titleLarge)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Sent to \(formattedPhoneNumber)")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.Spacing.xxl)
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()
                .frame(height: Theme.Spacing.xxl)

            // Code Input
            VStack(spacing: Theme.Spacing.lg) {
                CodeInputView(code: $code) { enteredCode in
                    handleCodeComplete(enteredCode)
                }
                .shake(showError)

                // Resend Button
                CountdownButton(
                    title: "Resend Code",
                    countdownTitle: "Resend in",
                    countdownDuration: 30
                ) {
                    handleResendCode()
                }

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
                    .padding(.horizontal, Theme.Spacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .animation(Theme.Animation.standard, value: viewModel.errorMessage)

            Spacer()

            // Loading Indicator
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .scaleEffect(1.2)
                    .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .hideKeyboardOnTap()
        .onChange(of: viewModel.errorMessage) { oldValue, newValue in
            if newValue != nil {
                withAnimation {
                    showError = true
                    // Clear code on error
                    code = ""
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showError = false
                }
            }
        }
    }

    // MARK: - Actions

    private func handleCodeComplete(_ enteredCode: String) {
        Task {
            viewModel.clearError()

            let success = await viewModel.verifyCode(enteredCode)

            if success {
                onSuccess()
            }
        }
    }

    private func handleResendCode() {
        Task {
            code = "" // Clear existing code
            viewModel.clearError()
            await viewModel.sendVerificationCode(to: phoneNumber)
        }
    }
}

// MARK: - Preview

#Preview("Verification Code View") {
    VerificationCodeView(phoneNumber: "+4917012345678") {
        print("Verification success")
    }
    .environment(AuthenticationViewModel())
}
