//
//  ProfileView.swift
//  WiesbadenAfterDark
//
//  Ultra-minimal profile with only 4 essential sections
//

import SwiftUI

/// Main profile view - Drastically simplified to 4 sections
struct ProfileView: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel

    @State private var showingSignOutAlert = false

    private var user: User? {
        authViewModel.authState.user
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // SECTION 1: USER HEADER
                    VStack(spacing: 16) {
                        // Avatar with gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 4)
                            .overlay(
                                Text(userInitials)
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )

                        VStack(spacing: 4) {
                            if let user = user {
                                Text(user.formattedPhoneNumber)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textPrimary)

                                Text("Member since \(memberSince)")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .padding(.top, 20)

                    // SECTION 2: REFERRAL CARD (Compact)
                    if let user = user {
                        ReferralCardCompact(
                            code: user.referralCode,
                            totalEarned: Int(user.totalPointsEarned * 0.25)
                        )
                        .padding(.horizontal, Theme.Spacing.lg)
                    }

                    // SECTION 3: MAIN ACTIONS (4 items max)
                    VStack(spacing: 0) {
                        if let user = user {
                            ProfileActionButton(
                                icon: "star.circle.fill",
                                title: "My Points",
                                subtitle: "\(user.totalPointsAvailable) points available",
                                color: .orange
                            ) {
                                // Navigate to points detail
                            }

                            Divider().padding(.leading, 60)
                        }

                        ProfileActionButton(
                            icon: "building.2.fill",
                            title: "Venue Memberships",
                            subtitle: "View your memberships",
                            color: .blue
                        ) {
                            // Navigate to memberships
                        }

                        Divider().padding(.leading, 60)

                        NavigationLink(destination: NotificationSettingsView()) {
                            ProfileActionButton(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Manage preferences",
                                color: .purple
                            )
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 60)

                        NavigationLink(destination: HelpSupportView()) {
                            ProfileActionButton(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                subtitle: "Get assistance",
                                color: .green
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color.cardBackground)
                    .cornerRadius(Theme.CornerRadius.lg)
                    .padding(.horizontal, Theme.Spacing.lg)

                    // SECTION 4: SIGN OUT
                    Button {
                        showingSignOutAlert = true
                    } label: {
                        Text("Sign Out")
                            .font(.headline)
                            .foregroundColor(.error)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.error.opacity(0.1))
                            .cornerRadius(Theme.CornerRadius.lg)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
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

    // MARK: - Computed Properties

    private var userInitials: String {
        guard let user = user else { return "?" }
        let digits = user.phoneNumber.filter { $0.isNumber }
        if digits.count >= 2 {
            return String(digits.suffix(2))
        } else if digits.count == 1 {
            return String(digits)
        }
        return "WL"
    }

    private var memberSince: String {
        guard let user = user else { return "..." }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: user.createdAt)
    }
}

// MARK: - Compact Referral Card
private struct ReferralCardCompact: View {
    let code: String
    let totalEarned: Int

    @State private var showCopied = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Referral Code")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Text(code)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }

                Spacer()

                Button {
                    UIPasteboard.general.string = code
                    showCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCopied = false
                    }
                } label: {
                    Image(systemName: showCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Earned from Referrals")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Text("\(totalEarned) points")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.success)
                }

                Spacer()

                ShareLink(item: "Join Wiesbaden After Dark with code: \(code)") {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }

            // Compact benefit note
            Text("Earn 25% when friends check in!")
                .font(.caption2)
                .foregroundColor(.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Action Button
private struct ProfileActionButton: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Typography.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.textTertiary)
            }
            .padding(Theme.Spacing.md)
        }
    }
}

// MARK: - Preview
#Preview("Profile View - Minimal") {
    ProfileView()
        .environment(AuthenticationViewModel())
}
