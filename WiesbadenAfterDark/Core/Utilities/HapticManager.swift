//
//  HapticManager.swift
//  WiesbadenAfterDark
//
//  Centralized haptic feedback manager for consistent tactile responses
//

import UIKit

/// Manages haptic feedback throughout the app
final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // MARK: - Impact Feedback

    /// Light impact - for subtle interactions (taps, selections)
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact - for standard interactions (button presses, swipes)
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact - for important interactions (confirmations, completions)
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success feedback - for successful operations (check-in, points earned)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning feedback - for warning messages
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error feedback - for errors and failures
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed - for picker wheels, segmented controls
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Custom Patterns

    /// Points earned pattern - success with a light follow-up
    func pointsEarned() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.light()
        }
    }

    /// Check-in success pattern - heavy impact followed by success
    func checkInSuccess() {
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.success()
        }
    }

    /// Navigation pattern - light tap for transitions
    func navigate() {
        light()
    }

    /// Referral code copied - medium impact for clipboard action
    func copied() {
        medium()
    }
}

// MARK: - Convenience Extensions

extension UIImpactFeedbackGenerator {
    /// Prepare and trigger impact in one call
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
