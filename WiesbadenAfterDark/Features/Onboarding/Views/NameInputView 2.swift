//
//  NameInputView.swift
//  WiesbadenAfterDark
//
//  Name input screen for new user registration
//

import SwiftUI

/// Name input screen for new user onboarding
struct NameInputView: View {
    // MARK: - Properties

    @Environment(AuthenticationViewModel.self) private var viewModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @FocusState private var focusedField: Field?

    var onContinue: () -> Void

    // MARK: - Field Enum

    private enum Field {
        case firstName
        case lastName
    }

    // MARK: - Computed Properties

    private var isNameValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: Theme.Spacing.md) {
                Text("What's your name?")
                    .font(Typography.displayMedium)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text("This is how you'll appear to others")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.Spacing.xxl)
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()
                .frame(height: Theme.Spacing.xxl)

            // Name Input Fields
            VStack(spacing: Theme.Spacing.md) {
                // First Name
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("First Name")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)

                    TextField("", text: $firstName)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.textPrimary)
                        .padding(Theme.Spacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                .stroke(
                                    focusedField == .firstName ? Color.primary : Color.cardBorder,
                                    lineWidth: focusedField == .firstName ? 2 : 1
                                )
                        )
                        .focused($focusedField, equals: .firstName)
                        .textContentType(.givenName)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .lastName
                        }
                }

                // Last Name (Optional)
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack {
                        Text("Last Name")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)

                        Text("(optional)")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textTertiary)
                    }

                    TextField("", text: $lastName)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.textPrimary)
                        .padding(Theme.Spacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                .stroke(
                                    focusedField == .lastName ? Color.primary : Color.cardBorder,
                                    lineWidth: focusedField == .lastName ? 2 : 1
                                )
                        )
                        .focused($focusedField, equals: .lastName)
                        .textContentType(.familyName)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                            if isNameValid {
                                handleContinue()
                            }
                        }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()

            // Bottom Buttons
            VStack(spacing: Theme.Spacing.md) {
                // Continue Button
                PrimaryButton(
                    title: "Continue",
                    action: handleContinue,
                    isEnabled: isNameValid,
                    isLoading: false
                )

                // Skip Button
                Button(action: handleSkip) {
                    Text("Skip for now")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                .padding(.vertical, Theme.Spacing.sm)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .hideKeyboardOnTap()
        .onAppear {
            // Auto-focus first name field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .firstName
            }
        }
    }

    // MARK: - Actions

    private func handleContinue() {
        let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        // Store name in view model for account creation
        viewModel.pendingFirstName = trimmedFirst.isEmpty ? nil : trimmedFirst
        viewModel.pendingLastName = trimmedLast.isEmpty ? nil : trimmedLast

        onContinue()
    }

    private func handleSkip() {
        // Clear any pending name
        viewModel.pendingFirstName = nil
        viewModel.pendingLastName = nil

        onContinue()
    }
}

// MARK: - Preview

#Preview("Name Input View") {
    NameInputView {
        print("Continue tapped")
    }
    .environment(AuthenticationViewModel())
}
