//
//  HomeView.swift
//  WiesbadenAfterDark
//
//  Home screen with check-in CTA
//

import SwiftUI

/// Home screen - main app view after authentication
struct HomeView: View {
    // MARK: - Properties

    @Environment(AuthenticationViewModel.self) private var viewModel

    // MARK: - UI State

    @State private var showMyPasses = false
    @State private var showCheckInHistory = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Check-In CTA Card
                    checkInCTACard
                        .padding(.horizontal)
                        .padding(.top)

                    // Welcome Section
                    welcomeSection
                        .padding(.horizontal)

                    // Quick Actions
                    quickActionsSection
                        .padding(.horizontal)

                    Spacer()
                        .frame(height: 40)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showMyPasses) {
                if let user = viewModel.authState.user {
                    NavigationStack {
                        MyPassesView(userId: user.id)
                    }
                }
            }
            .sheet(isPresented: $showCheckInHistory) {
                if let user = viewModel.authState.user {
                    NavigationStack {
                        CheckInHistoryView(userId: user.id)
                    }
                }
            }
        }
    }

    // MARK: - Check-In CTA Card

    private var checkInCTACard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGradient)
                        .frame(width: 56, height: 56)

                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Check In at Venues")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    Text("Earn points & unlock rewards")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()
            }

            // Features
            VStack(alignment: .leading, spacing: 10) {
                featureRow(icon: "wave.3.right", text: "NFC tap check-in")
                featureRow(icon: "qrcode", text: "QR code scanning")
                featureRow(icon: "flame.fill", text: "Build daily streaks")
                featureRow(icon: "star.fill", text: "Earn bonus points")
            }
            .font(.subheadline)

            // CTA Button
            NavigationLink {
                Text("Venues List - Coming Soon")
            } label: {
                HStack {
                    Text("Find Nearby Venues")
                        .font(.headline)

                    Spacer()

                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .padding()
                .background(Color.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.Shadow.md.color, radius: Theme.Shadow.md.radius, x: Theme.Shadow.md.x, y: Theme.Shadow.md.y)
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {
        VStack(spacing: 16) {
            if let user = viewModel.authState.user {
                // User Info Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back!")
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)

                            Text(user.formattedPhoneNumber)
                                .font(.headline)
                                .foregroundStyle(Color.textPrimary)
                        }

                        Spacer()

                        // Referral Code Badge
                        VStack(spacing: 4) {
                            Text("Code")
                                .font(.caption2)
                                .foregroundStyle(Color.textSecondary)

                            Text(user.referralCode)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primaryGradient)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Points Balance (if any)
                    if user.totalPointsAvailable > 0 {
                        Divider()

                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.gold)

                            Text("Global Balance: \(user.totalPointsAvailable) points")
                                .font(.subheadline)
                                .foregroundStyle(Color.textPrimary)

                            Spacer()
                        }
                    }
                }
                .padding(16)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // My Passes
                quickActionButton(
                    icon: "wallet.pass.fill",
                    title: "My Passes",
                    color: .purple
                ) {
                    showMyPasses = true
                }

                // Check-In History
                quickActionButton(
                    icon: "clock.fill",
                    title: "History",
                    color: .blue
                ) {
                    showCheckInHistory = true
                }

                // Venues (placeholder)
                quickActionButton(
                    icon: "mappin.circle.fill",
                    title: "Venues",
                    color: .green
                ) {
                    // Navigate to venues
                }

                // Events (placeholder)
                quickActionButton(
                    icon: "calendar.badge.clock",
                    title: "Events",
                    color: .orange
                ) {
                    // Navigate to events
                }
            }

            // Sign Out Button
            Button(action: {
                viewModel.signOut()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Helper Views

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.accentColor)
                .frame(width: 20)

            Text(text)
                .foregroundStyle(Color.textSecondary)
        }
    }

    private func quickActionButton(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Preview

#Preview("Home View") {
    HomeView()
        .environment(AuthenticationViewModel())
}
