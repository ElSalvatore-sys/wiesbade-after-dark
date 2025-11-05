//
//  SplashView.swift
//  WiesbadenAfterDark
//
//  Splash screen with auto-login check
//

import SwiftUI

/// Splash screen shown on app launch
/// Checks for existing session and auto-logs in if valid token exists
struct SplashView: View {
    // MARK: - Properties

    @Environment(AuthenticationViewModel.self) private var viewModel
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8

    // MARK: - Body

    var body: some View {
        ZStack {
            // Gradient Background
            Color.primaryGradient
                .ignoresSafeArea()

            // Content
            VStack(spacing: Theme.Spacing.lg) {
                // Logo Icon
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)

                // App Name
                VStack(spacing: 4) {
                    Text("Wiesbaden")
                        .font(Typography.displayMedium)
                        .foregroundColor(.white)
                        .fontWeight(.bold)

                    Text("After Dark")
                        .font(Typography.displayMedium)
                        .foregroundColor(.white.opacity(0.9))
                        .fontWeight(.bold)
                }
                .opacity(opacity)

                // Loading Indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.top, Theme.Spacing.xl)
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Animate logo entrance
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1
                scale = 1.0
            }

            // Check for existing session
            Task {
                await viewModel.checkExistingSession()
            }
        }
    }
}

// MARK: - Preview

#Preview("Splash View") {
    SplashView()
        .environment(AuthenticationViewModel())
}
