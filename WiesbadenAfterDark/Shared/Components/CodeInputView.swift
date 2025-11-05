//
//  CodeInputView.swift
//  WiesbadenAfterDark
//
//  6-digit verification code input with auto-advance
//

import SwiftUI

/// 6-digit code input view with individual boxes
struct CodeInputView: View {
    // MARK: - Properties

    @Binding var code: String
    var onComplete: ((String) -> Void)?

    @FocusState private var focusedField: Int?

    private let boxCount = 6

    // MARK: - Computed Properties

    /// Individual digits from the code string
    private var digits: [String] {
        let codeArray = Array(code)
        return (0..<boxCount).map { index in
            index < codeArray.count ? String(codeArray[index]) : ""
        }
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(0..<boxCount, id: \.self) { index in
                DigitBox(
                    digit: digits[index],
                    isFocused: focusedField == index
                )
                .onTapGesture {
                    focusedField = index
                }
            }
        }
        .background(
            // Hidden TextField for keyboard input
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focusedField, equals: 0)
                .opacity(0)
                .frame(width: 1, height: 1)
        )
        .onChange(of: code) { oldValue, newValue in
            // Filter to digits only
            let filtered = newValue.digitsOnly

            // Limit to 6 digits
            let limited = String(filtered.prefix(boxCount))

            if limited != code {
                code = limited
            }

            // Trigger completion when 6 digits entered
            if code.count == boxCount {
                onComplete?(code)
            }
        }
        .onAppear {
            // Auto-focus first field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = 0
            }
        }
    }
}

// MARK: - Digit Box

private struct DigitBox: View {
    let digit: String
    let isFocused: Bool

    var body: some View {
        Text(digit)
            .font(Typography.titleMedium)
            .foregroundColor(.textPrimary)
            .frame(width: 48, height: 56)
            .background(Color.inputBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(
                        isFocused ? Color.primary : (digit.isEmpty ? Color.clear : Color.textTertiary.opacity(0.3)),
                        lineWidth: Theme.BorderWidth.regular
                    )
            )
            .animation(Theme.Animation.quick, value: isFocused)
            .animation(Theme.Animation.quick, value: digit.isEmpty)
    }
}

// MARK: - Preview

#Preview("Code Input View") {
    VStack(spacing: Theme.Spacing.xl) {
        CodeInputView(code: .constant(""))

        CodeInputView(code: .constant("123"))

        CodeInputView(code: .constant("123456"))
    }
    .padding()
    .background(Color.appBackground)
}
