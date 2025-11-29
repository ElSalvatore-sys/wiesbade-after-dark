//
//  ProfileView.swift
//  WiesbadenAfterDark
//
//  Profile view with user info, actions, and recent activity
//

import SwiftUI
import SwiftData

/// Main profile view with user info and recent activity
struct ProfileView: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var showingSignOutAlert = false
    @State private var recentTransactions: [PointTransaction] = []
    @State private var isLoadingTransactions = false

    private var user: User? {
        authViewModel.authState.user
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // SECTION 1: USER HEADER (Compact)
                    VStack(spacing: 12) {
                        // Avatar with gradient - smaller size
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Color(hex: "#8B5CF6").opacity(0.3), radius: 10, x: 0, y: 4)
                            .overlay(
                                Text(userInitials)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )

                        VStack(spacing: 2) {
                            if let user = user {
                                // Check if user has a name
                                if let fullName = user.fullName, !fullName.isEmpty {
                                    // Has name: Show name as title, phone smaller
                                    Text(fullName)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.textPrimary)

                                    Text(user.formattedPhoneNumber)
                                        .font(.system(size: 13))
                                        .foregroundColor(.textSecondary)
                                } else {
                                    // No name: Show phone number medium-sized
                                    Text(user.formattedPhoneNumber)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.textPrimary)
                                }

                                Text("Member since \(memberSince)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textTertiary)
                                    .padding(.top, 2)
                            }
                        }
                    }
                    .padding(.top, 16)

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

                    // SECTION 4: RECENT ACTIVITY
                    if !recentTransactions.isEmpty {
                        RecentActivitySection(transactions: recentTransactions)
                            .padding(.horizontal, Theme.Spacing.lg)
                    }

                    // SECTION 5: SIGN OUT
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
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .task {
                await loadRecentTransactions()
            }
        }
    }

    // MARK: - Data Loading

    private func loadRecentTransactions() async {
        guard let user = user else { return }

        isLoadingTransactions = true

        // Load transactions from mock data
        // In production, this would fetch from the backend via a service
        recentTransactions = PointTransaction.mockHistory(
            userId: user.id,
            venueId: UUID(), // Mock venue ID
            venueName: "Das Wohnzimmer",
            count: 8
        )

        isLoadingTransactions = false
    }

    // MARK: - Computed Properties

    private var userInitials: String {
        guard let user = user else { return "?" }

        // Use name initials if available
        if let firstName = user.firstName, !firstName.isEmpty {
            let firstInitial = String(firstName.prefix(1)).uppercased()
            if let lastName = user.lastName, !lastName.isEmpty {
                let lastInitial = String(lastName.prefix(1)).uppercased()
                return "\(firstInitial)\(lastInitial)"
            }
            return firstInitial
        }

        // Fallback to last 2 digits of phone number
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

// MARK: - Recent Activity Section
private struct RecentActivitySection: View {
    let transactions: [PointTransaction]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            if transactions.isEmpty {
                // Empty state
                VStack(spacing: Theme.Spacing.cardGap) {
                    Image(systemName: "clock")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.textTertiary)

                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.lg)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                        HStack(spacing: Theme.Spacing.cardGap) {
                            // Icon
                            Image(systemName: transaction.source.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(transactionColor(for: transaction))
                                .frame(width: 40, height: 40)
                                .background(transactionColor(for: transaction).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))

                            // Description and date
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text(transaction.shortDescription)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.textPrimary)
                                    .lineLimit(1)

                                Text(transaction.timeAgo)
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }

                            Spacer()

                            // Amount
                            Text(transaction.formattedAmount)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(transaction.amount > 0 ? Color.success : Color.error)
                        }
                        .padding(.vertical, Theme.Spacing.cardGap)

                        // Divider (except for last item)
                        if index < min(4, transactions.count - 1) {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(Theme.Spacing.cardPadding)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .shadow(
            color: Theme.Shadow.md.color,
            radius: Theme.Shadow.md.radius,
            x: Theme.Shadow.md.x,
            y: Theme.Shadow.md.y
        )
    }

    private func transactionColor(for transaction: PointTransaction) -> Color {
        switch transaction.type {
        case .earn: return .blue
        case .redeem: return .red
        case .bonus: return .green
        case .refund: return .orange
        }
    }
}

// MARK: - Preview
#Preview("Profile View") {
    ProfileView()
        .environment(AuthenticationViewModel())
}
