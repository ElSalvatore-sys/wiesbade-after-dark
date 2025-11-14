//
//  View+Shimmer.swift
//  WiesbadenAfterDark
//
//  Shimmer loading effect for image placeholders
//

import SwiftUI

extension View {
    /// Adds an animated shimmer effect to the view
    /// Perfect for loading states and skeleton screens
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 400
                }
            }
    }
}

// MARK: - Preview
#Preview("Shimmer Effect") {
    VStack(spacing: Theme.Spacing.lg) {
        Rectangle()
            .fill(Color.cardBackground)
            .frame(height: 200)
            .cornerRadius(Theme.CornerRadius.lg)
            .shimmer()

        Rectangle()
            .fill(Color.inputBackground)
            .frame(height: 100)
            .cornerRadius(Theme.CornerRadius.md)
            .shimmer()
    }
    .padding()
    .background(Color.appBackground)
}
