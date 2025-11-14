//
//  CheckInLoadingView.swift
//  WiesbadenAfterDark
//
//  Loading overlay shown during check-in processing
//

import SwiftUI

/// Loading view shown during check-in processing
struct CheckInLoadingView: View {
    // MARK: - Properties

    let message: String

    // MARK: - Animation State

    @State private var isAnimating = false
    @State private var pulseAnimation = false

    // MARK: - Initialization

    init(message: String = "Processing check-in...") {
        self.message = message
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black
                .opacity(0.4)
                .ignoresSafeArea()

            // Loading card
            VStack(spacing: 24) {
                // Animated loading icon
                ZStack {
                    // Pulsing circle background
                    Circle()
                        .fill(Color.primaryGradient)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .opacity(pulseAnimation ? 0.8 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: pulseAnimation
                        )

                    // Rotating progress indicator
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(
                                lineWidth: 4,
                                lineCap: .round
                            )
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            .linear(duration: 1.0).repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }

                // Loading text
                VStack(spacing: 8) {
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)

                    Text("Please wait...")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding(32)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Theme.Shadow.lg.color, radius: Theme.Shadow.lg.radius, x: Theme.Shadow.lg.x, y: Theme.Shadow.lg.y)
            .padding(40)
        }
        .onAppear {
            isAnimating = true
            pulseAnimation = true
        }
    }
}

// MARK: - Preview

#Preview {
    CheckInLoadingView()
}

#Preview("Custom Message") {
    CheckInLoadingView(message: "Validating NFC tag...")
}
