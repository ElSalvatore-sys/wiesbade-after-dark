//
//  IntroOnboardingView.swift
//  WiesbadenAfterDark
//
//  3-screen animated intro onboarding for first-time users
//

import SwiftUI

/// Intro onboarding with 3 animated screens shown to first-time users
struct IntroOnboardingView: View {
    // MARK: - Properties

    var onComplete: () -> Void

    @State private var currentPage = 0
    @State private var showGetStarted = false

    private let pages = OnboardingPageData.pages

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()

            // Animated background particles
            ParticleBackground()
                .opacity(0.4)

            VStack(spacing: 0) {
                // Skip button (hidden on last page)
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation(.spring()) {
                                currentPage = pages.count - 1
                            }
                        } label: {
                            Text("Skip")
                                .font(Typography.labelLarge)
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal, Theme.Spacing.md)
                                .padding(.vertical, Theme.Spacing.sm)
                        }
                    }
                }
                .frame(height: 44)
                .padding(.horizontal, Theme.Spacing.md)

                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page Indicator & Buttons
                VStack(spacing: Theme.Spacing.lg) {
                    // Custom page dots
                    HStack(spacing: Theme.Spacing.sm) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.primary : Color.textTertiary)
                                .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Action Button
                    if currentPage == pages.count - 1 {
                        // Get Started Button (last page)
                        Button {
                            onComplete()
                        } label: {
                            HStack(spacing: Theme.Spacing.sm) {
                                Text("Get Started")
                                    .font(Typography.button)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.primaryGradient)
                            .cornerRadius(Theme.CornerRadius.lg)
                            .shadow(color: Color.primary.opacity(0.4), radius: 12, y: 4)
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Next Button
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } label: {
                            HStack(spacing: Theme.Spacing.sm) {
                                Text("Next")
                                    .font(Typography.button)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                                    .stroke(Color.cardBorder, lineWidth: 1)
                            )
                            .cornerRadius(Theme.CornerRadius.lg)
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                    }
                }
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}

// MARK: - Particle Background

private struct ParticleBackground: View {
    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .blur(radius: particle.size / 3)
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
            }
        }
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<15).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                color: [Color.primary, Color.primaryGradientEnd, Color.gold].randomElement()!.opacity(0.3),
                size: CGFloat.random(in: 20...60)
            )
        }
    }
}

private struct Particle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let color: Color
    let size: CGFloat
}

// MARK: - Preview

#Preview("Intro Onboarding") {
    IntroOnboardingView {
        print("Onboarding complete")
    }
}
