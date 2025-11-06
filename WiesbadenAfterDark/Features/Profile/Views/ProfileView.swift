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

                    // Payments section
                    if let userId = authViewModel.authState.user?.id {
                        PaymentsSection(userId: userId)

                        Divider()
                            .background(Color.textTertiary.opacity(0.2))
                            .padding(.horizontal, Theme.Spacing.lg)
                    }

                    // Wallet Passes section
                    if let userId = authViewModel.authState.user?.id {
                        WalletPassesSection(userId: userId)

                        Divider()
                            .background(Color.textTertiary.opacity(0.2))
                            .padding(.horizontal, Theme.Spacing.lg)

                        // Check-In History section
                        CheckInHistorySection(userId: userId)

                        Divider()
                            .background(Color.textTertiary.opacity(0.2))
                            .padding(.horizontal, Theme.Spacing.lg)
                    }

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

// MARK: - Wallet Passes Section
private struct WalletPassesSection: View {
    let userId: UUID

    @State private var viewModel: CheckInViewModel
    @State private var showAllPasses = false

    init(userId: UUID) {
        self.userId = userId
        self._viewModel = State(initialValue: CheckInViewModel(
            checkInService: MockCheckInService.shared,
            walletPassService: MockWalletPassService.shared
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Wallet Passes")
                    .font(Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Spacer()

                if !viewModel.walletPasses.isEmpty {
                    NavigationLink(destination: MyPassesView(userId: userId)) {
                        Text("See All")
                            .font(Typography.captionMedium)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)

            if viewModel.walletPasses.isEmpty {
                // Empty state
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "wallet.pass")
                        .font(.system(size: 32))
                        .foregroundColor(.textTertiary)

                    Text("No Wallet Passes")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)

                    Text("Generate passes from venue rewards tabs")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.xl)
                .background(Color.cardBackground)
                .cornerRadius(Theme.CornerRadius.lg)
                .padding(.horizontal, Theme.Spacing.lg)
            } else {
                // Show first 2 passes
                VStack(spacing: Theme.Spacing.md) {
                    ForEach(viewModel.walletPasses.prefix(2)) { pass in
                        NavigationLink(destination: WalletPassDetailView(pass: pass)) {
                            WalletPassCard(pass: pass, mode: .compact)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
        .task {
            await viewModel.fetchWalletPasses(userId: userId)
        }
    }
}

// MARK: - Check-In History Section
private struct CheckInHistorySection: View {
    let userId: UUID

    @State private var viewModel: CheckInViewModel

    init(userId: UUID) {
        self.userId = userId
        self._viewModel = State(initialValue: CheckInViewModel(
            checkInService: MockCheckInService.shared,
            walletPassService: MockWalletPassService.shared
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Recent Check-Ins")
                    .font(Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Spacer()

                if !viewModel.checkIns.isEmpty {
                    NavigationLink(destination: CheckInHistoryView(userId: userId)) {
                        Text("See All")
                            .font(Typography.captionMedium)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)

            if viewModel.checkIns.isEmpty {
                // Empty state
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 32))
                        .foregroundColor(.textTertiary)

                    Text("No Check-Ins Yet")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)

                    Text("Visit venues and check in to earn points")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.xl)
                .background(Color.cardBackground)
                .cornerRadius(Theme.CornerRadius.lg)
                .padding(.horizontal, Theme.Spacing.lg)
            } else {
                // Show first 3 check-ins
                VStack(spacing: Theme.Spacing.md) {
                    ForEach(viewModel.checkIns.prefix(3)) { checkIn in
                        CheckInCard(checkIn: checkIn, mode: .compact)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
        .task {
            await viewModel.fetchCheckInHistory(userId: userId)
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

// MARK: - Payments Section
private struct PaymentsSection: View {
    let userId: UUID

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section Header
            HStack {
                Text("Payments & Bookings")
                    .font(Typography.headlineLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)

            // Buy Points Button
            NavigationLink(destination: BuyPointsView(userId: userId)) {
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Buy Points")
                            .font(Typography.bodyLarge)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        Text("Get bonus points on larger packages")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.textTertiary)
                }
                .padding(Theme.Spacing.md)
                .background(Color.cardBackground)
                .cornerRadius(Theme.CornerRadius.md)
            }
            .padding(.horizontal, Theme.Spacing.lg)

            // My Bookings Button
            NavigationLink(destination: MyBookingsView()) {
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Bookings")
                            .font(Typography.bodyLarge)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        Text("View upcoming and past bookings")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.textTertiary)
                }
                .padding(Theme.Spacing.md)
                .background(Color.cardBackground)
                .cornerRadius(Theme.CornerRadius.md)
            }
            .padding(.horizontal, Theme.Spacing.lg)

            // Payment History Button
            NavigationLink(destination: PaymentHistoryView(userId: userId)) {
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "creditcard")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Payment History")
                            .font(Typography.bodyLarge)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        Text("View all transactions")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.textTertiary)
                }
                .padding(Theme.Spacing.md)
                .background(Color.cardBackground)
                .cornerRadius(Theme.CornerRadius.md)
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }
}

// MARK: - Preview
#Preview("Profile View") {
    ProfileView()
        .environment(AuthenticationViewModel())
}
