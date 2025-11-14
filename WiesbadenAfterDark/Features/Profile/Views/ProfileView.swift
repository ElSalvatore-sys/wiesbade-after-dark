//
//  ProfileView.swift
//  WiesbadenAfterDark
//
//  User profile with memberships and settings
//

import SwiftUI

/// Main profile view - Simplified and minimalist
struct ProfileView: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel

    @State private var showingSignOutAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User Header - Minimal
                    if let user = authViewModel.authState.user {
                        VStack(spacing: 12) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(userInitials(for: user))
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                )

                            Text(user.formattedPhoneNumber)
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("Member since \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)

                        // Referral Card - Compact
                        ReferralCard(
                            referralCode: user.referralCode,
                            totalEarnings: Int(user.totalPointsEarned * 0.25)
                        )
                        .padding(.horizontal)

                        // Main Actions
                        VStack(spacing: 0) {
                            if let userId = user.id {
                                NavigationLink(destination: BuyPointsView(userId: userId)) {
                                    ProfileActionRow(
                                        icon: "star.circle.fill",
                                        title: "My Points",
                                        subtitle: "\(user.totalPointsAvailable) points available",
                                        color: .orange
                                    )
                                }
                                .buttonStyle(.plain)

                                Divider().padding(.leading, 60)
                            }

                            Button(action: {}) {
                                ProfileActionRow(
                                    icon: "building.2.fill",
                                    title: "Memberships",
                                    subtitle: "Venue subscriptions",
                                    color: .blue
                                )
                            }
                            .buttonStyle(.plain)

                            Divider().padding(.leading, 60)

                            if let userId = user.id {
                                NavigationLink(destination: CheckInHistoryView(userId: userId)) {
                                    ProfileActionRow(
                                        icon: "clock.fill",
                                        title: "Check-In History",
                                        subtitle: "View past visits",
                                        color: .green
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Settings - Minimal
                        VStack(spacing: 0) {
                            NavigationLink(destination: NotificationSettingsView()) {
                                ProfileActionRow(
                                    icon: "bell.fill",
                                    title: "Notifications",
                                    color: .purple
                                )
                            }
                            .buttonStyle(.plain)

                            Divider().padding(.leading, 60)

                            NavigationLink(destination: PrivacySecurityView()) {
                                ProfileActionRow(
                                    icon: "lock.fill",
                                    title: "Privacy & Security",
                                    color: .gray
                                )
                            }
                            .buttonStyle(.plain)

                            Divider().padding(.leading, 60)

                            NavigationLink(destination: HelpSupportView()) {
                                ProfileActionRow(
                                    icon: "questionmark.circle.fill",
                                    title: "Help & Support",
                                    color: .blue
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Sign Out
                        Button(action: {
                            showingSignOutAlert = true
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
                .padding(.vertical)
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

    private func userInitials(for user: User) -> String {
        let digits = user.phoneNumber.filter { $0.isNumber }
        if digits.count >= 2 {
            return String(digits.suffix(2))
        } else if digits.count == 1 {
            return String(digits)
        }
        return "WL" // Fallback: Wiesbaden Loyalty
    }
}

// MARK: - Profile Action Row
private struct ProfileActionRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}


// MARK: - Preview
#Preview("Profile View") {
    ProfileView()
        .environment(AuthenticationViewModel())
}
