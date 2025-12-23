//
//  AnimationModifiers.swift
//  WiesbadenAfterDark
//
//  Reusable animation modifiers for polished UI transitions
//

import SwiftUI

// MARK: - Card Appear Animation (Scale + Fade)

/// Animates a card appearing with scale and fade effect
struct CardAppearModifier: ViewModifier {
    @State private var isVisible = false
    let delay: Double

    init(delay: Double = 0) {
        self.delay = delay
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.92)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(
                    .spring(response: 0.5, dampingFraction: 0.8)
                    .delay(delay)
                ) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Adds a card appear animation with scale, fade, and slide-up
    func cardAppear(delay: Double = 0) -> some View {
        modifier(CardAppearModifier(delay: delay))
    }
}

// MARK: - Stagger Animation for Lists

/// Animates list items with staggered delays
struct StaggeredAppearModifier: ViewModifier {
    @State private var isVisible = false
    let index: Int
    let baseDelay: Double
    let staggerDelay: Double

    init(index: Int, baseDelay: Double = 0.1, staggerDelay: Double = 0.05) {
        self.index = index
        self.baseDelay = baseDelay
        self.staggerDelay = staggerDelay
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 15)
            .onAppear {
                let delay = baseDelay + (Double(index) * staggerDelay)
                withAnimation(
                    .spring(response: 0.4, dampingFraction: 0.75)
                    .delay(delay)
                ) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Staggered animation for list items based on index
    func staggeredAppear(index: Int, baseDelay: Double = 0.1, staggerDelay: Double = 0.05) -> some View {
        modifier(StaggeredAppearModifier(index: index, baseDelay: baseDelay, staggerDelay: staggerDelay))
    }
}

// MARK: - Modal Spring Animation

/// Spring animation for modals and sheets
struct ModalSpringModifier: ViewModifier {
    @State private var isVisible = false
    let fromEdge: Edge

    init(fromEdge: Edge = .bottom) {
        self.fromEdge = fromEdge
    }

    private var offset: CGSize {
        guard !isVisible else { return .zero }
        switch fromEdge {
        case .top:
            return CGSize(width: 0, height: -100)
        case .bottom:
            return CGSize(width: 0, height: 100)
        case .leading:
            return CGSize(width: -100, height: 0)
        case .trailing:
            return CGSize(width: 100, height: 0)
        }
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(offset)
            .scaleEffect(isVisible ? 1 : 0.95)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Modal spring animation from specified edge
    func modalSpring(from edge: Edge = .bottom) -> some View {
        modifier(ModalSpringModifier(fromEdge: edge))
    }
}

// MARK: - Bounce Animation

/// Adds a bounce effect on tap or appear
struct BounceModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    let trigger: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        scale = 1.15
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.15)) {
                        scale = 1.0
                    }
                }
            }
    }
}

extension View {
    /// Bounce animation triggered by a boolean
    func bounce(on trigger: Bool) -> some View {
        modifier(BounceModifier(trigger: trigger))
    }
}

// MARK: - Press Effect

/// Adds a subtle press-down effect for buttons
struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    /// Adds a press-down effect for interactive elements
    func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }
}

// MARK: - Pulse Animation

/// Continuous pulse animation for attention-grabbing elements
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    let speed: Double

    init(speed: Double = 1.2) {
        self.speed = speed
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.9 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: speed)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    /// Adds a continuous pulse animation
    func pulse(speed: Double = 1.2) -> some View {
        modifier(PulseModifier(speed: speed))
    }
}

// MARK: - Fade Slide Animation

/// Fade with directional slide
struct FadeSlideModifier: ViewModifier {
    @State private var isVisible = false
    let direction: SlideDirection
    let distance: CGFloat
    let delay: Double

    enum SlideDirection {
        case up, down, left, right
    }

    init(direction: SlideDirection = .up, distance: CGFloat = 20, delay: Double = 0) {
        self.direction = direction
        self.distance = distance
        self.delay = delay
    }

    private var offset: CGSize {
        guard !isVisible else { return .zero }
        switch direction {
        case .up:
            return CGSize(width: 0, height: distance)
        case .down:
            return CGSize(width: 0, height: -distance)
        case .left:
            return CGSize(width: distance, height: 0)
        case .right:
            return CGSize(width: -distance, height: 0)
        }
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(offset)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 0.4)
                    .delay(delay)
                ) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Fade in with directional slide
    func fadeSlide(
        direction: FadeSlideModifier.SlideDirection = .up,
        distance: CGFloat = 20,
        delay: Double = 0
    ) -> some View {
        modifier(FadeSlideModifier(direction: direction, distance: distance, delay: delay))
    }
}

// MARK: - Shake Animation

/// Shake animation for error states
struct ShakeModifier: ViewModifier {
    @State private var shakeOffset: CGFloat = 0
    let trigger: Bool

    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.default.speed(2)) {
                        shakeOffset = 10
                    }
                    withAnimation(.default.speed(2).delay(0.1)) {
                        shakeOffset = -8
                    }
                    withAnimation(.default.speed(2).delay(0.2)) {
                        shakeOffset = 6
                    }
                    withAnimation(.default.speed(2).delay(0.3)) {
                        shakeOffset = -4
                    }
                    withAnimation(.default.speed(2).delay(0.4)) {
                        shakeOffset = 0
                    }
                }
            }
    }
}

extension View {
    /// Shake animation triggered by a boolean (for errors)
    func shake(on trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

// MARK: - Points Counter Animation

/// Animated counter for points/numbers
struct AnimatedCounter: View {
    let value: Int
    let font: Font
    let color: Color

    @State private var displayedValue: Int = 0

    init(value: Int, font: Font = .title, color: Color = .primary) {
        self.value = value
        self.font = font
        self.color = color
    }

    var body: some View {
        Text("\(displayedValue)")
            .font(font)
            .foregroundColor(color)
            .contentTransition(.numericText())
            .onChange(of: value) { oldValue, newValue in
                animateValue(from: oldValue, to: newValue)
            }
            .onAppear {
                animateValue(from: 0, to: value)
            }
    }

    private func animateValue(from: Int, to: Int) {
        let steps = 20
        let difference = to - from
        let stepValue = difference / steps

        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                if i == steps {
                    withAnimation(.easeOut(duration: 0.1)) {
                        displayedValue = to
                    }
                } else {
                    displayedValue = from + (stepValue * i)
                }
            }
        }
    }
}

// MARK: - Glow Animation

/// Adds a subtle glow effect to views
struct GlowModifier: ViewModifier {
    @State private var isGlowing = false
    let color: Color
    let radius: CGFloat

    init(color: Color = .purple, radius: CGFloat = 10) {
        self.color = color
        self.radius = radius
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(isGlowing ? 0.6 : 0.3), radius: isGlowing ? radius : radius / 2)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    isGlowing = true
                }
            }
    }
}

extension View {
    /// Adds a pulsing glow effect
    func glow(color: Color = .purple, radius: CGFloat = 10) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
}

// MARK: - Preview

#Preview("Card Appear") {
    VStack(spacing: 16) {
        ForEach(0..<4) { index in
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.3))
                .frame(height: 80)
                .cardAppear(delay: Double(index) * 0.1)
        }
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Staggered List") {
    ScrollView {
        LazyVStack(spacing: 12) {
            ForEach(0..<10, id: \.self) { index in
                HStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 40, height: 40)
                    Text("Item \(index + 1)")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .staggeredAppear(index: index)
            }
        }
        .padding()
    }
    .background(Color.appBackground)
}

#Preview("Press Effect") {
    Button(action: {}) {
        Text("Press Me")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.purple)
            .cornerRadius(12)
    }
    .pressEffect()
    .padding()
    .background(Color.appBackground)
}

#Preview("Animated Counter") {
    struct CounterPreview: View {
        @State private var points = 0

        var body: some View {
            VStack(spacing: 20) {
                AnimatedCounter(value: points, font: .system(size: 48, weight: .bold), color: .purple)

                Button("Add Points") {
                    points += Int.random(in: 50...200)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
            }
            .padding()
            .background(Color.appBackground)
        }
    }

    return CounterPreview()
}

#Preview("Glow Effect") {
    VStack(spacing: 20) {
        Circle()
            .fill(Color.purple)
            .frame(width: 100, height: 100)
            .glow(color: .purple, radius: 20)

        RoundedRectangle(cornerRadius: 12)
            .fill(Color.orange)
            .frame(width: 200, height: 60)
            .glow(color: .orange, radius: 15)
    }
    .padding()
    .background(Color.appBackground)
}
