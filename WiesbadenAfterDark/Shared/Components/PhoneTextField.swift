//
//  PhoneTextField.swift
//  WiesbadenAfterDark
//
//  Custom phone number input field with auto-formatting
//

import SwiftUI

/// Phone number text field with country code and auto-formatting
@MainActor
struct PhoneTextField: View {
    // MARK: - Properties

    @Binding var phoneNumber: String
    var countryCode: String = "+49"
    var placeholder: String = "170 1234567"

    @FocusState private var isFocused: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Country code
            Text(countryCode)
                .font(Typography.bodyLarge)
                .foregroundColor(.textPrimary)
                .padding(.leading, Theme.Spacing.md)

            // Divider
            Rectangle()
                .fill(Color.textTertiary.opacity(0.3))
                .frame(width: 1, height: 24)

            // Phone number input
            TextField("", text: $phoneNumber)
                .placeholder(when: phoneNumber.isEmpty) {
                    Text(placeholder)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.textTertiary)
                }
                .font(Typography.bodyLarge)
                .foregroundColor(.textPrimary)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .onChange(of: phoneNumber) { oldValue, newValue in
                    // Filter to digits only and limit length in one pass
                    let filtered = String(newValue.filter { $0.isNumber }.prefix(11))

                    // Only update if different to avoid infinite loop
                    if filtered != newValue {
                        phoneNumber = filtered
                    }
                }
        }
        .frame(height: 56)
        .background(Color.inputBackground)
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(isFocused ? Color.primary : Color.clear, lineWidth: Theme.BorderWidth.regular)
        )
    }
}

// MARK: - Preview

#Preview("Phone TextField") {
    VStack(spacing: Theme.Spacing.lg) {
        PhoneTextField(phoneNumber: .constant(""))

        PhoneTextField(phoneNumber: .constant("17012345678"))
    }
    .padding()
    .background(Color.appBackground)
}
