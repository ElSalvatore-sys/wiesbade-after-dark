//
//  ProfileView.swift
//  WiesbadenAfterDark
//
//  User profile with memberships and settings
//

import SwiftUI

/// Main profile view
struct ProfileView: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel

    @State private var showingSignOutAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Profile header
                    ProfileHeader(user: authViewModel.authState.user)

                    Divider()
                        .background(Color.textTertiary.opacity(0.2))
                        .padding(.horizontal, Theme.Spacing.lg)

                    // Account section
                    AccountSection(user: authViewModel.authState.user)

                    Divider()
                        .background(Color.textTertiary.opacity(0.2))
                        .padding(.horizontal, Theme.Spacing.lg)

                    // Memberships section
                    MembershipsSection()

                    Divider()
                        .background(Color.textTertiary.opacity(0.2))
                        .padding(.horizontal, Theme.Spacing.lg)

                    // Settings section
                    SettingsSection()

                    // Sign out button
                    Button(action: {
                        showingSignOutAlert = true
                    }) {
                        Text("Sign Out")
                            .font(Typography.button)
                            .fontWeight(.semibold)
                            .foregroundColor(.error)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.error.opacity(0.1))
                            .cornerRadius(Theme.CornerRadius.lg)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                }
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Color.appBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

// MARK: - Profile Header
private struct ProfileHeader: View {
    let user: User?

    private var initials: String {
        guard let user = user else { return "?" }
        // Use first letter of phone number as placeholder
        return String(user.phoneNumber.prefix(1))
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 100, height: 100)

                Text(initials)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }

            // Phone number
            if let user = user {
                Text(user.formattedPhoneNumber)
                    .font(Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
        }
    }
}

// MARK: - Account Section
private struct AccountSection: View {
    let user: User?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Account")
                .font(Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Theme.Spacing.lg)

            VStack(spacing: 0) {
                // Phone number
                if let user = user {
                    InfoRow(
                        icon: "phone.fill",
                        label: "Phone Number",
                        value: user.formattedPhoneNumber
                    )

                    Divider()
                        .padding(.leading, 56)
                        .background(Color.textTertiary.opacity(0.2))

                    // Referral code
                    InfoRow(
                        icon: "gift.fill",
                        label: "Referral Code",
                        value: user.referralCode
                    )

                    Divider()
                        .padding(.leading, 56)
                        .background(Color.textTertiary.opacity(0.2))

                    // Member since
                    InfoRow(
                        icon: "calendar",
                        label: "Member Since",
                        value: user.memberSinceFormatted
                    )
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(Theme.CornerRadius.lg)
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(Typography.captionMedium)
                    .foregroundColor(.textSecondary)

                Text(value)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)
            }

            Spacer()
        }
        .padding(Theme.Spacing.md)
    }
}

// MARK: - Memberships Section
private struct MembershipsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Venue Memberships")
                .font(Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Theme.Spacing.lg)

            // Placeholder for memberships
            VStack(spacing: Theme.Spacing.lg) {
                Image(systemName: "building.2")
                    .font(.system(size: 40))
                    .foregroundColor(.textTertiary)

                Text("No Memberships Yet")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textSecondary)

                Text("Join venues to start earning points and rewards!")
                    .font(Typography.captionMedium)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.xl)
            .background(Color.cardBackground)
            .cornerRadius(Theme.CornerRadius.lg)
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }
}

// MARK: - Settings Section
private struct SettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Settings")
                .font(Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Theme.Spacing.lg)

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    label: "Notifications",
                    showChevron: true,
                    action: {
                        // TODO: Navigate to notifications settings
                        print("Navigate to notifications")
                    }
                )

                Divider()
                    .padding(.leading, 56)
                    .background(Color.textTertiary.opacity(0.2))

                SettingsRow(
                    icon: "lock.fill",
                    label: "Privacy & Security",
                    showChevron: true,
                    action: {
                        // TODO: Navigate to privacy settings
                        print("Navigate to privacy")
                    }
                )

                Divider()
                    .padding(.leading, 56)
                    .background(Color.textTertiary.opacity(0.2))

                SettingsRow(
                    icon: "questionmark.circle.fill",
                    label: "Help & Support",
                    showChevron: true,
                    action: {
                        // TODO: Navigate to help
                        print("Navigate to help")
                    }
                )

                Divider()
                    .padding(.leading, 56)
                    .background(Color.textTertiary.opacity(0.2))

                SettingsRow(
                    icon: "doc.text.fill",
                    label: "Terms & Privacy Policy",
                    showChevron: true,
                    action: {
                        // TODO: Navigate to legal
                        print("Navigate to legal")
                    }
                )
            }
            .background(Color.cardBackground)
            .cornerRadius(Theme.CornerRadius.lg)
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }
}

private struct SettingsRow: View {
    let icon: String
    let label: String
    let showChevron: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .frame(width: 24)

                Text(label)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)

                Spacer()

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(Theme.Spacing.md)
        }
    }
}

// MARK: - User Extension
private extension User {
    var memberSinceFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
}

// MARK: - Preview
#Preview("Profile View") {
    ProfileView()
        .environment(AuthenticationViewModel())
}
