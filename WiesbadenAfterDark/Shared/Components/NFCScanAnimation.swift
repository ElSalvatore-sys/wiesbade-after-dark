//
//  NFCScanAnimation.swift
//  WiesbadenAfterDark
//
//  Animated NFC scanning indicator
//

import SwiftUI

/// NFC scan animation states
enum NFCScanState {
    case idle
    case scanning
    case validating
    case success
    case error
}

/// NFC scanning animation component
struct NFCScanAnimation: View {
    // MARK: - Properties

    var state: NFCScanState = .scanning
    var message: String?

    // MARK: - Animation State

    @State private var outerRingScale: CGFloat = 0.8
    @State private var middleRingScale: CGFloat = 0.6
    @State private var innerRingScale: CGFloat = 0.4
    @State private var rotation: Double = 0
    @State private var iconScale: CGFloat = 1.0
    @State private var showCheckmark = false

    // MARK: - Computed Properties

    private var displayMessage: String {
        if let message = message {
            return message
        }

        switch state {
        case .idle:
            return "Ready to scan"
        case .scanning:
            return "Hold your device near the NFC tag"
        case .validating:
            return "Validating..."
        case .success:
            return "Success!"
        case .error:
            return "Scan failed. Please try again."
        }
    }

    private var iconName: String {
        switch state {
        case .idle, .scanning, .validating:
            return "wave.3.right"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch state {
        case .idle, .scanning, .validating:
            return Color.primary
        case .success:
            return .green
        case .error:
            return .red
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 32) {
            // Animation Container
            ZStack {
                // Outer Ring
                Circle()
                    .stroke(iconColor.opacity(0.2), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(outerRingScale)
                    .opacity(state == .scanning || state == .validating ? 1 : 0)

                // Middle Ring
                Circle()
                    .stroke(iconColor.opacity(0.4), lineWidth: 2)
                    .frame(width: 160, height: 160)
                    .scaleEffect(middleRingScale)
                    .opacity(state == .scanning || state == .validating ? 1 : 0)

                // Inner Ring
                Circle()
                    .stroke(iconColor.opacity(0.6), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(innerRingScale)
                    .opacity(state == .scanning || state == .validating ? 1 : 0)

                // Center Circle Background
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(iconScale)

                // NFC Icon
                Image(systemName: iconName)
                    .font(.system(size: 50))
                    .foregroundStyle(iconColor)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(iconScale)
            }
            .frame(height: 250)

            // Message
            VStack(spacing: 8) {
                Text(displayMessage)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)

                if state == .scanning {
                    Text("This may take a few seconds")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .padding(.horizontal)

            // Loading Indicator (for scanning/validating states)
            if state == .scanning || state == .validating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: iconColor))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onChange(of: state) { _, newState in
            updateAnimation(for: newState)
        }
        .onAppear {
            updateAnimation(for: state)
        }
    }

    // MARK: - Animation Logic

    private func updateAnimation(for state: NFCScanState) {
        switch state {
        case .idle:
            stopScanAnimation()

        case .scanning:
            startScanAnimation()

        case .validating:
            startValidatingAnimation()

        case .success:
            stopScanAnimation()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                iconScale = 1.2
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                iconScale = 1.0
            }

        case .error:
            stopScanAnimation()
            // Shake animation for error
            withAnimation(.default.repeatCount(3, autoreverses: true).speed(3)) {
                iconScale = 1.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                iconScale = 1.0
            }
        }
    }

    private func startScanAnimation() {
        // Pulsing ring animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
            outerRingScale = 1.2
        }

        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.2)) {
            middleRingScale = 1.15
        }

        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.4)) {
            innerRingScale = 1.1
        }

        // Rotating icon
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        // Gentle icon pulse
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            iconScale = 1.1
        }
    }

    private func startValidatingAnimation() {
        // Faster animation for validating
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: false)) {
            outerRingScale = 1.3
        }

        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: false).delay(0.1)) {
            middleRingScale = 1.2
        }

        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: false).delay(0.2)) {
            innerRingScale = 1.15
        }

        // Faster rotation
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }

    private func stopScanAnimation() {
        // Reset all animations
        withAnimation(.easeOut(duration: 0.3)) {
            outerRingScale = 1.0
            middleRingScale = 1.0
            innerRingScale = 1.0
            rotation = 0
            iconScale = 1.0
        }
    }
}

// MARK: - Preview

#Preview("Scanning") {
    VStack {
        NFCScanAnimation(state: .scanning)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}

#Preview("Validating") {
    VStack {
        NFCScanAnimation(
            state: .validating,
            message: "Validating NFC tag..."
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}

#Preview("Success") {
    VStack {
        NFCScanAnimation(state: .success)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}

#Preview("Error") {
    VStack {
        NFCScanAnimation(
            state: .error,
            message: "Invalid NFC tag. Please try again."
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}

#Preview("Idle") {
    VStack {
        NFCScanAnimation(state: .idle)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}

#Preview("All States") {
    ScrollView {
        VStack(spacing: 40) {
            VStack {
                Text("Idle")
                    .font(.headline)
                NFCScanAnimation(state: .idle)
            }

            Divider()

            VStack {
                Text("Scanning")
                    .font(.headline)
                NFCScanAnimation(state: .scanning)
            }

            Divider()

            VStack {
                Text("Validating")
                    .font(.headline)
                NFCScanAnimation(state: .validating)
            }

            Divider()

            VStack {
                Text("Success")
                    .font(.headline)
                NFCScanAnimation(state: .success)
            }

            Divider()

            VStack {
                Text("Error")
                    .font(.headline)
                NFCScanAnimation(state: .error)
            }
        }
        .padding()
    }
    .background(Color.appBackground)
}
