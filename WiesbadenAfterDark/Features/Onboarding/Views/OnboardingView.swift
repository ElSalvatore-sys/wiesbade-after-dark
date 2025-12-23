//
//  OnboardingView.swift
//  WiesbadenAfterDark
//
//  German-language intro onboarding with gradient backgrounds
//

import SwiftUI

struct OnboardingPageModel: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let gradient: [Color]
}

/// German-language intro onboarding with colorful gradient backgrounds
struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0
    @State private var isAnimating = false

    private let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            icon: "moon.stars.fill",
            title: "Willkommen bei",
            subtitle: "WiesbadenAfterDark",
            description: "Entdecke die besten Bars, Clubs und Events in Wiesbaden. Dein ultimativer Nachtleben-Guide.",
            gradient: [Color.purple, Color.purple.opacity(0.6)]
        ),
        OnboardingPageModel(
            icon: "checkmark.circle.fill",
            title: "Check In &",
            subtitle: "Sammle Punkte",
            description: "Checke bei deinen Lieblingslocations ein und sammle Treuepunkte. Steige von Bronze zu Platin auf!",
            gradient: [Color.green, Color.teal]
        ),
        OnboardingPageModel(
            icon: "calendar.badge.clock",
            title: "Verpasse",
            subtitle: "Kein Event",
            description: "Erhalte Benachrichtigungen über kommende Events, exklusive Angebote und besondere Aktionen.",
            gradient: [Color.orange, Color.pink]
        )
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: pages[currentPage].gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Überspringen") {
                            withAnimation {
                                currentPage = pages.count - 1
                            }
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                    }
                }

                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingContentView(page: page, isAnimating: isAnimating)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                            .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 30)

                // Action button
                Button(action: {
                    HapticManager.shared.medium()
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    HStack {
                        Text(currentPage < pages.count - 1 ? "Weiter" : "Los geht's!")
                            .fontWeight(.semibold)

                        Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "sparkles")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .foregroundColor(pages[currentPage].gradient.first ?? .purple)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                isAnimating = true
            }
        }
    }

    private func completeOnboarding() {
        HapticManager.shared.success()
        onComplete()
    }
}

// MARK: - Onboarding Content View

private struct OnboardingContentView: View {
    let page: OnboardingPageModel
    let isAnimating: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Icon with animation
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 160, height: 160)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .opacity(isAnimating ? 1 : 0)

                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1 : 0.3)
                    .opacity(isAnimating ? 1 : 0)

                Image(systemName: page.icon)
                    .font(.system(size: 70))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isAnimating)

            VStack(spacing: 8) {
                Text(page.title)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))

                Text(page.subtitle)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(y: isAnimating ? 0 : 30)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isAnimating)

            Text(page.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .offset(y: isAnimating ? 0 : 20)
                .opacity(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isAnimating)
        }
        .padding(.top, 60)
    }
}

#Preview {
    OnboardingView {
        print("Onboarding complete")
    }
}
