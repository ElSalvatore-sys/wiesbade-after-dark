//
//  OnboardingPageView.swift
//  WiesbadenAfterDark
//
//  Single page for the intro onboarding flow with animations
//

import SwiftUI

/// A single onboarding page with animated icon, title, and description
struct OnboardingPageView: View {
    // MARK: - Properties

    let page: OnboardingPageData
    let isActive: Bool

    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: CGFloat = 0
    @State private var textOpacity: CGFloat = 0
    @State private var floatingOffset: CGFloat = 0

    // MARK: - Body

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            // Animated Icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color.primary.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .blur(radius: 40)
                    .scaleEffect(iconScale * 1.2)

                // Icon container with gradient background
                ZStack {
                    Circle()
                        .fill(Color.cardBackground)
                        .frame(width: 140, height: 140)
                        .overlay(
                            Circle()
                                .stroke(Color.primaryGradient, lineWidth: 3)
                        )
                        .shadow(color: Color.primary.opacity(0.3), radius: 20)

                    Image(systemName: page.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(Color.primaryGradient)
                }
                .scaleEffect(iconScale)
                .offset(y: floatingOffset)
            }
            .opacity(iconOpacity)

            Spacer()
                .frame(height: Theme.Spacing.lg)

            // Text Content
            VStack(spacing: Theme.Spacing.md) {
                Text(page.title)
                    .font(Typography.titleLarge)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(Typography.bodyLarge)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, Theme.Spacing.lg)
            }
            .opacity(textOpacity)

            Spacer()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                animateIn()
            } else {
                resetAnimation()
            }
        }
        .onAppear {
            if isActive {
                animateIn()
            }
        }
    }

    // MARK: - Animation Methods

    private func animateIn() {
        // Reset first
        iconScale = 0.5
        iconOpacity = 0
        textOpacity = 0
        floatingOffset = 0

        // Animate icon
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }

        // Animate text
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            textOpacity = 1.0
        }

        // Start floating animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
            floatingOffset = -10
        }
    }

    private func resetAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            iconOpacity = 0
            textOpacity = 0
            floatingOffset = 0
        }
    }
}

// MARK: - Page Data Model

struct OnboardingPageData: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String

    static let pages: [OnboardingPageData] = [
        OnboardingPageData(
            icon: "moon.stars.fill",
            title: "Discover Wiesbaden's Nightlife",
            description: "Find the best bars, clubs, and restaurants in your city. Get exclusive access to events."
        ),
        OnboardingPageData(
            icon: "checkmark.seal.fill",
            title: "Check In & Earn Points",
            description: "Scan NFC tags at venues to check in. Collect loyalty points for drinks, VIP access, and more."
        ),
        OnboardingPageData(
            icon: "bell.badge.fill",
            title: "Never Miss an Event",
            description: "Get notified about upcoming events at your favorite venues. RSVP with one tap."
        )
    ]
}

// MARK: - Preview

#Preview("Page 1 - Discover") {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        OnboardingPageView(page: OnboardingPageData.pages[0], isActive: true)
    }
}

#Preview("Page 2 - Check In") {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        OnboardingPageView(page: OnboardingPageData.pages[1], isActive: true)
    }
}

#Preview("Page 3 - Events") {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        OnboardingPageView(page: OnboardingPageData.pages[2], isActive: true)
    }
}
