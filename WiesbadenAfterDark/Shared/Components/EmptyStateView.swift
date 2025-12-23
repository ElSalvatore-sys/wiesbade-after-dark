//
//  EmptyStateView.swift
//  WiesbadenAfterDark
//
//  Reusable empty state component for consistent UI across the app
//

import SwiftUI

// MARK: - Empty State Configuration

/// Configuration for empty state display
struct EmptyStateConfig {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    let style: EmptyStateStyle

    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        style: EmptyStateStyle = .standard
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
        self.style = style
    }
}

/// Visual style for empty states
enum EmptyStateStyle {
    case standard      // Default gray icon
    case accent        // Purple gradient icon
    case success       // Green icon (for "all clear" states)
    case warning       // Orange icon (for alerts)
    case error         // Red icon (for error states)
    case network       // Special network error style
}

// MARK: - Empty State Presets

extension EmptyStateConfig {
    // MARK: - Content Empty States

    static var noVenues: EmptyStateConfig {
        EmptyStateConfig(
            icon: "map",
            title: "No Venues Yet",
            subtitle: "Check back soon for exciting venues!"
        )
    }

    static var noEvents: EmptyStateConfig {
        EmptyStateConfig(
            icon: "calendar.badge.clock",
            title: "No Events Yet",
            subtitle: "Check back soon for exciting events"
        )
    }

    static var noEventsThisWeek: EmptyStateConfig {
        EmptyStateConfig(
            icon: "calendar.badge.clock",
            title: "No Events This Week",
            subtitle: "No events scheduled for the next 7 days"
        )
    }

    static var noEventsThisWeekend: EmptyStateConfig {
        EmptyStateConfig(
            icon: "calendar.badge.clock",
            title: "No Events This Weekend",
            subtitle: "No events scheduled for this weekend"
        )
    }

    static var noBookings: EmptyStateConfig {
        EmptyStateConfig(
            icon: "calendar.badge.plus",
            title: "No Bookings Yet",
            subtitle: "Your upcoming reservations will appear here"
        )
    }

    static var noPastBookings: EmptyStateConfig {
        EmptyStateConfig(
            icon: "clock.badge.checkmark",
            title: "No Past Bookings",
            subtitle: "Your booking history will appear here"
        )
    }

    static var noCheckIns: EmptyStateConfig {
        EmptyStateConfig(
            icon: "clock.badge.checkmark",
            title: "No Check-Ins Yet",
            subtitle: "Your check-in history will appear here"
        )
    }

    static var noCheckInPosts: EmptyStateConfig {
        EmptyStateConfig(
            icon: "location.circle",
            title: "No Check-ins Yet",
            subtitle: "Check in at a venue to see posts here"
        )
    }

    static var noPosts: EmptyStateConfig {
        EmptyStateConfig(
            icon: "bubble.left.and.bubble.right",
            title: "No Posts Yet",
            subtitle: "Be the first to share something!"
        )
    }

    static var noPhotos: EmptyStateConfig {
        EmptyStateConfig(
            icon: "photo",
            title: "No Photos Yet",
            subtitle: "Share a photo to see posts here"
        )
    }

    static var noAchievements: EmptyStateConfig {
        EmptyStateConfig(
            icon: "star.circle",
            title: "No Achievements Yet",
            subtitle: "Earn achievements to see posts here"
        )
    }

    static func noPostsFromVenue(_ venueName: String) -> EmptyStateConfig {
        EmptyStateConfig(
            icon: "mappin.circle",
            title: "No Posts from This Venue",
            subtitle: "Be the first to post from \(venueName)!"
        )
    }

    static var noRewards: EmptyStateConfig {
        EmptyStateConfig(
            icon: "gift",
            title: "No Rewards Available",
            subtitle: "Check back later for new rewards"
        )
    }

    static var noPasses: EmptyStateConfig {
        EmptyStateConfig(
            icon: "wallet.pass",
            title: "No Passes Yet",
            subtitle: "Check in at venues to earn passes"
        )
    }

    static var noPayments: EmptyStateConfig {
        EmptyStateConfig(
            icon: "creditcard",
            title: "No Payments Yet",
            subtitle: "Your payment history will appear here"
        )
    }

    static var noBadges: EmptyStateConfig {
        EmptyStateConfig(
            icon: "rosette",
            title: "No Badges Yet",
            subtitle: "Create custom badges for your venue"
        )
    }

    static var noBonuses: EmptyStateConfig {
        EmptyStateConfig(
            icon: "star.slash",
            title: "No Active Bonuses",
            subtitle: "Check back later for bonus point opportunities"
        )
    }

    static var noTransactions: EmptyStateConfig {
        EmptyStateConfig(
            icon: "clock",
            title: "No Transactions Yet",
            subtitle: "Your points activity will appear here"
        )
    }

    // MARK: - Success States

    static var allPointsSafe: EmptyStateConfig {
        EmptyStateConfig(
            icon: "checkmark.circle.fill",
            title: "All Points Safe",
            subtitle: "No points expiring soon",
            style: .success
        )
    }

    // MARK: - Network States

    static var noNetwork: EmptyStateConfig {
        EmptyStateConfig(
            icon: "wifi.slash",
            title: "No Connection",
            subtitle: "Check your internet connection and try again",
            actionTitle: "Retry",
            style: .network
        )
    }

    static func loadError(message: String, retryAction: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            icon: "exclamationmark.triangle",
            title: "Unable to Load",
            subtitle: message,
            actionTitle: "Retry",
            action: retryAction,
            style: .error
        )
    }

    // MARK: - Search States

    static var noSearchResults: EmptyStateConfig {
        EmptyStateConfig(
            icon: "magnifyingglass",
            title: "No Results Found",
            subtitle: "Try adjusting your search or filters"
        )
    }
}

// MARK: - Empty State View

/// A reusable empty state view for displaying when content is unavailable
struct EmptyStateView: View {
    let config: EmptyStateConfig

    /// Create an empty state view with full configuration
    init(_ config: EmptyStateConfig) {
        self.config = config
    }

    /// Create an empty state view with individual parameters
    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        style: EmptyStateStyle = .standard
    ) {
        self.config = EmptyStateConfig(
            icon: icon,
            title: title,
            subtitle: subtitle,
            actionTitle: actionTitle,
            action: action,
            style: style
        )
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Icon
            iconView
                .cardAppear(delay: 0.1)

            // Text content
            VStack(spacing: Theme.Spacing.sm) {
                Text(config.title)
                    .font(Typography.titleMedium)
                    .foregroundColor(.textPrimary)

                Text(config.subtitle)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .fadeSlide(direction: .up, delay: 0.2)

            // Action button (if provided)
            if let actionTitle = config.actionTitle, let action = config.action {
                Button(action: {
                    HapticManager.shared.light()
                    action()
                }) {
                    HStack(spacing: Theme.Spacing.sm) {
                        if config.style == .network || config.style == .error {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text(actionTitle)
                    }
                    .font(Typography.buttonMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(buttonBackground)
                    .cornerRadius(Theme.CornerRadius.md)
                }
                .pressEffect()
                .fadeSlide(direction: .up, delay: 0.3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
    }

    // MARK: - Icon View

    @ViewBuilder
    private var iconView: some View {
        Image(systemName: config.icon)
            .font(.system(size: 60))
            .foregroundStyle(iconColor)
    }

    // MARK: - Colors

    private var iconColor: Color {
        switch config.style {
        case .standard:
            return .textTertiary
        case .accent:
            return .primary
        case .success:
            return .success
        case .warning:
            return .warning
        case .error:
            return .error
        case .network:
            return .textTertiary
        }
    }

    private var buttonBackground: Color {
        switch config.style {
        case .standard, .accent:
            return .primary
        case .success:
            return .success
        case .warning:
            return .warning
        case .error, .network:
            return .primary
        }
    }
}

// MARK: - Convenience Extensions

extension View {
    /// Shows an empty state overlay when a condition is true
    @ViewBuilder
    func emptyState(
        _ config: EmptyStateConfig,
        when isEmpty: Bool
    ) -> some View {
        if isEmpty {
            EmptyStateView(config)
        } else {
            self
        }
    }
}

// MARK: - Previews

#Preview("Standard Empty States") {
    ScrollView {
        VStack(spacing: 40) {
            EmptyStateView(.noVenues)

            Divider()

            EmptyStateView(.noEvents)

            Divider()

            EmptyStateView(.noBookings)
        }
    }
    .background(Color.appBackground)
}

#Preview("Success State") {
    EmptyStateView(.allPointsSafe)
        .background(Color.appBackground)
}

#Preview("Error State") {
    EmptyStateView(
        .loadError(message: "Could not load venues. Please check your connection.") {
            print("Retry tapped")
        }
    )
    .background(Color.appBackground)
}

#Preview("Network Error") {
    EmptyStateView(
        icon: "wifi.slash",
        title: "No Connection",
        subtitle: "Check your internet connection and try again",
        actionTitle: "Retry",
        action: { print("Retry") },
        style: .network
    )
    .background(Color.appBackground)
}

#Preview("Custom Empty State") {
    EmptyStateView(
        icon: "star.circle",
        title: "Custom Title",
        subtitle: "This is a custom subtitle message",
        actionTitle: "Take Action",
        action: { print("Action tapped") },
        style: .accent
    )
    .background(Color.appBackground)
}
