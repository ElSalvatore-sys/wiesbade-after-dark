//
//  CountdownButton.swift
//  WiesbadenAfterDark
//
//  Button with countdown timer (for "Resend code")
//

import SwiftUI

/// Button with countdown timer functionality
struct CountdownButton: View {
    // MARK: - Properties

    let title: String
    let countdownTitle: String
    let countdownDuration: Int
    let action: () -> Void

    @State private var remainingTime: Int = 0
    @State private var timer: Timer?

    // MARK: - Computed Properties

    private var isCountingDown: Bool {
        remainingTime > 0
    }

    private var displayTitle: String {
        if isCountingDown {
            return "\(countdownTitle) (\(remainingTime)s)"
        }
        return title
    }

    // MARK: - Body

    var body: some View {
        Button(action: handleAction) {
            Text(displayTitle)
                .font(Typography.labelMedium)
                .foregroundColor(isCountingDown ? .textTertiary : .primary)
        }
        .disabled(isCountingDown)
        .animation(Theme.Animation.quick, value: isCountingDown)
    }

    // MARK: - Actions

    private func handleAction() {
        // Execute the action
        action()

        // Start countdown
        startCountdown()
    }

    private func startCountdown() {
        remainingTime = countdownDuration

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
}

// MARK: - Preview

#Preview("Countdown Button") {
    VStack(spacing: Theme.Spacing.lg) {
        CountdownButton(
            title: "Resend Code",
            countdownTitle: "Resend Code",
            countdownDuration: 30,
            action: {
                print("Resend code tapped")
            }
        )

        CountdownButton(
            title: "Try Again",
            countdownTitle: "Wait",
            countdownDuration: 10,
            action: {
                print("Try again tapped")
            }
        )
    }
    .padding()
    .background(Color.appBackground)
}
