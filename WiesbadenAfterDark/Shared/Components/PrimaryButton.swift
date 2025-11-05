//
//  PrimaryButton.swift
//  WiesbadenAfterDark
//
//  Primary action button with gradient background
//

import SwiftUI

/// Primary button component with gradient background and loading state
struct PrimaryButton: View {
    // MARK: - Properties

    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var style: ButtonStyle = .primary

    // MARK: - Button Styles

    enum ButtonStyle {
        case primary
        case secondary
        case text

        var backgroundColor: LinearGradient? {
            switch self {
            case .primary:
                return Color.primaryGradient
            case .secondary, .text:
                return nil
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return .primary
            case .text:
                return .textSecondary
            }
        }

        var borderColor: Color? {
            switch self {
            case .secondary:
                return .primary
            default:
                return nil
            }
        }
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.9)
                }

                Text(title)
                    .font(Typography.button)
                    .foregroundColor(style.foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if let background = style.backgroundColor {
                        background
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(style.borderColor ?? Color.clear, lineWidth: Theme.BorderWidth.regular)
            )
            .cornerRadius(Theme.CornerRadius.lg)
            .opacity(isEnabled && !isLoading ? 1.0 : 0.5)
        }
        .disabled(!isEnabled || isLoading)
        .animation(Theme.Animation.standard, value: isEnabled)
        .animation(Theme.Animation.standard, value: isLoading)
    }
}

// MARK: - Preview

#Preview("Primary Button States") {
    VStack(spacing: Theme.Spacing.lg) {
        PrimaryButton(title: "Continue", action: {})

        PrimaryButton(title: "Continue", action: {}, isEnabled: false)

        PrimaryButton(title: "Loading...", action: {}, isLoading: true)

        PrimaryButton(title: "Secondary", action: {}, style: .secondary)

        PrimaryButton(title: "Text Button", action: {}, style: .text)
    }
    .padding()
    .background(Color.appBackground)
}
