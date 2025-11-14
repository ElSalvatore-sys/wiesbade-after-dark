import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    // Points & Rewards
    @AppStorage("notifications.pointsExpiring") private var pointsExpiring = true
    @AppStorage("notifications.tierUpgrades") private var tierUpgrades = true
    @AppStorage("notifications.referralEarnings") private var referralEarnings = false
    @AppStorage("notifications.specialOffers") private var specialOffers = true

    // Events
    @AppStorage("notifications.newEvents") private var newEvents = true
    @AppStorage("notifications.eventReminders") private var eventReminders = true

    // Venues
    @AppStorage("notifications.venueUpdates") private var venueUpdates = false

    @State private var notificationsEnabled = false
    @State private var showPermissionAlert = false

    var body: some View {
        List {
            // System notification status banner
            if !notificationsEnabled {
                Section {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Label {
                            Text("Notifications Disabled")
                                .font(Typography.bodyMedium)
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "bell.slash.fill")
                                .foregroundColor(.orange)
                        }

                        Text("Enable notifications in Settings to receive updates about points, events, and special offers")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)

                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("Open Settings")
                                .font(Typography.bodyMedium)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    .padding(.vertical, Theme.Spacing.sm)
                }
                .listRowBackground(Color.orange.opacity(0.1))
            }

            // Points & Rewards Section
            Section {
                NotificationToggleRow(
                    isOn: $pointsExpiring,
                    title: "Points Expiring Soon",
                    description: "Get notified 30 days before points expire",
                    isEnabled: notificationsEnabled
                )

                NotificationToggleRow(
                    isOn: $tierUpgrades,
                    title: "Tier Upgrades",
                    description: "Celebrate when you reach a new tier",
                    isEnabled: notificationsEnabled
                )

                NotificationToggleRow(
                    isOn: $referralEarnings,
                    title: "Referral Earnings",
                    description: "See when your referrals earn you points",
                    isEnabled: notificationsEnabled
                )

                NotificationToggleRow(
                    isOn: $specialOffers,
                    title: "Special Offers",
                    description: "Exclusive deals and bonus point opportunities",
                    isEnabled: notificationsEnabled
                )
            } header: {
                Text("Points & Rewards")
            }

            // Events Section
            Section {
                NotificationToggleRow(
                    isOn: $newEvents,
                    title: "New Events Nearby",
                    description: "Discover upcoming events in Wiesbaden",
                    isEnabled: notificationsEnabled
                )

                NotificationToggleRow(
                    isOn: $eventReminders,
                    title: "Event Reminders",
                    description: "Get reminded about events you RSVP'd to",
                    isEnabled: notificationsEnabled
                )
            } header: {
                Text("Events")
            }

            // Venues Section
            Section {
                NotificationToggleRow(
                    isOn: $venueUpdates,
                    title: "Venue Updates",
                    description: "News from your favorite venues",
                    isEnabled: notificationsEnabled
                )
            } header: {
                Text("Venues")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await checkNotificationStatus()
        }
    }

    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            notificationsEnabled = settings.authorizationStatus == .authorized
        }
    }
}

// MARK: - Notification Toggle Row Component
private struct NotificationToggleRow: View {
    @Binding var isOn: Bool
    let title: String
    let description: String
    let isEnabled: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(Typography.captionMedium)
                    .foregroundColor(.textSecondary)
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
