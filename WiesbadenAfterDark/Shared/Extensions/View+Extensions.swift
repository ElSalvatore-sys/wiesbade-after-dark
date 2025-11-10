//
//  View+Extensions.swift
//  WiesbadenAfterDark
//
//  Custom view modifiers and helpers
//

import SwiftUI

extension View {
    // MARK: - Background Modifiers

    /// Applies the app's gradient background
    func gradientBackground() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primaryGradient.ignoresSafeArea())
    }

    /// Applies the app's dark background
    func darkBackground() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: - Keyboard Handling

    /// Hides the keyboard when the view is tapped
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }

    // MARK: - Conditional Modifiers

    /// Applies a modifier conditionally
    /// - Parameters:
    ///   - condition: Whether to apply the modifier
    ///   - transform: The modifier to apply
    /// - Returns: Modified view
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Loading State

    /// Overlays a loading spinner
    func loading(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }
    }

    // MARK: - Navigation

    /// Hides the navigation bar
    func hideNavigationBar() -> some View {
        self
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
    }

    // MARK: - Shake Animation

    /// Applies a shake animation (useful for errors)
    func shake(_ isShaking: Bool) -> some View {
        self.modifier(ShakeEffect(shakes: isShaking ? 3 : 0))
    }
}

// MARK: - Shake Effect Modifier

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 10 * sin(animatableData * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - Placeholder Modifier for TextField

extension View {
    /// Adds a placeholder to a TextField when it's empty
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - 2025 Modern Design Modifiers

extension View {
    /// Applies 2025 glassmorphism effect with ultra-thin material
    func glassCard() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    /// Applies modern card styling with soft shadows
    func modernCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
    }

    /// Applies elevated card styling for modals and floating elements
    func elevatedCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 8)
            )
    }

    /// Applies subtle card styling for less prominent elements
    func subtleCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
    }

    /// Adds modern micro-interaction with spring animation
    func modernTapAnimation(isPressed: Binding<Bool>) -> some View {
        self
            .scaleEffect(isPressed.wrappedValue ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed.wrappedValue)
    }
}
