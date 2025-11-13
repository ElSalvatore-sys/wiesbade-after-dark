//
//  WalletPassGenerationView.swift
//  WiesbadenAfterDark
//
//  View for generating a new Apple Wallet pass for venue membership
//

import SwiftUI
import PassKit

/// Wallet pass generation view
struct WalletPassGenerationView: View {
    // MARK: - Properties

    let venue: Venue
    let membership: VenueMembership
    let userId: UUID
    let onPassGenerated: (WalletPass) -> Void

    // MARK: - View Model

    @State private var viewModel: CheckInViewModel

    // MARK: - UI State

    @State private var isGenerating = false
    @State private var generatedPass: WalletPass?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    // MARK: - Initialization

    init(
        venue: Venue,
        membership: VenueMembership,
        userId: UUID,
        onPassGenerated: @escaping (WalletPass) -> Void
    ) {
        self.venue = venue
        self.membership = membership
        self.userId = userId
        self.onPassGenerated = onPassGenerated

        self._viewModel = State(initialValue: CheckInViewModel(
            checkInService: MockCheckInService.shared,
            walletPassService: RealWalletPassService.shared
        ))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let pass = generatedPass {
                    // Show generated pass with add to wallet option
                    generatedPassSection(pass)
                } else {
                    // Show generation prompt
                    generationPromptSection
                }

                // Benefits section
                benefitsSection

                // How it works section
                howItWorksSection
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Apple Wallet Pass")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK") {
                if let pass = generatedPass {
                    onPassGenerated(pass)
                }
            }
        } message: {
            Text("Your pass has been generated and added to Apple Wallet!")
        }
    }

    // MARK: - Generated Pass Section

    private func generatedPassSection(_ pass: WalletPass) -> some View {
        VStack(spacing: 20) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.green)
            }

            VStack(spacing: 8) {
                Text("Pass Generated!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Text("Your \(venue.name) membership pass is ready")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Pass preview card
            WalletPassCard(pass: pass, mode: .full)

            // Add to Wallet button
            Button(action: {
                Task {
                    await addToWallet(pass)
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.rectangle.on.rectangle")
                        .font(.title3)

                    Text("Add to Apple Wallet")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.black, Color.gray.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.Shadow.md.color, radius: Theme.Shadow.md.radius, x: Theme.Shadow.md.x, y: Theme.Shadow.md.y)
    }

    // MARK: - Generation Prompt Section

    private var generationPromptSection: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.primaryGradient.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.primaryGradient)
            }

            // Title & description
            VStack(spacing: 8) {
                Text("Generate Wallet Pass")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Text("Add \(venue.name) to Apple Wallet for quick check-ins and instant access to your points")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Membership info
            VStack(spacing: 12) {
                infoRow(label: "Venue", value: venue.name)
                infoRow(label: "Member Tier", value: membership.tier.displayName)
                infoRow(label: "Points Balance", value: "\(membership.pointsBalance) pts")
            }
            .padding(16)
            .background(Color.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Generate button
            Button(action: {
                Task {
                    await generatePass()
                }
            }) {
                HStack(spacing: 12) {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }

                    Text(isGenerating ? "Generating Pass..." : "Generate Pass")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isGenerating)
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.Shadow.md.color, radius: Theme.Shadow.md.radius, x: Theme.Shadow.md.x, y: Theme.Shadow.md.y)
    }

    // MARK: - Benefits Section

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Benefits")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 12) {
                benefitRow(
                    icon: "bolt.fill",
                    title: "Instant Check-In",
                    description: "Tap your phone at the venue to check in instantly"
                )

                benefitRow(
                    icon: "wave.3.right",
                    title: "NFC Support",
                    description: "Works with NFC readers for contactless check-ins"
                )

                benefitRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Auto Updates",
                    description: "Pass automatically updates when you earn points"
                )

                benefitRow(
                    icon: "lock.fill",
                    title: "Secure",
                    description: "Protected with Apple Wallet security"
                )
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.Shadow.sm.color, radius: Theme.Shadow.sm.radius, x: Theme.Shadow.sm.x, y: Theme.Shadow.sm.y)
    }

    // MARK: - How It Works Section

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How It Works")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 12) {
                stepRow(
                    number: "1",
                    title: "Generate Pass",
                    description: "Create your digital membership pass"
                )

                stepRow(
                    number: "2",
                    title: "Add to Wallet",
                    description: "Save to Apple Wallet with one tap"
                )

                stepRow(
                    number: "3",
                    title: "Visit Venue",
                    description: "Show pass at venue for check-in"
                )

                stepRow(
                    number: "4",
                    title: "Earn Rewards",
                    description: "Points automatically update on your pass"
                )
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.Shadow.sm.color, radius: Theme.Shadow.sm.radius, x: Theme.Shadow.sm.x, y: Theme.Shadow.sm.y)
    }

    // MARK: - Helper Views

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.textPrimary)
        }
    }

    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.primary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
    }

    private func stepRow(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Number badge
            ZStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 32, height: 32)

                Text(number)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
    }

    // MARK: - Actions

    private func generatePass() async {
        isGenerating = true

        await viewModel.generateWalletPass(
            userId: userId,
            venue: venue,
            membership: membership
        )

        isGenerating = false

        if let error = viewModel.errorMessage {
            errorMessage = error
            showError = true
        } else {
            // Fetch the generated pass
            if let pass = viewModel.walletPasses.first(where: { $0.venueId == venue.id }) {
                generatedPass = pass
            }
        }
    }

    private func addToWallet(_ pass: WalletPass) async {
        guard PKPassLibrary.isPassLibraryAvailable() else {
            errorMessage = "Apple Wallet is not available on this device"
            showError = true
            return
        }

        await viewModel.addPassToWallet(pass)

        if let error = viewModel.errorMessage {
            errorMessage = error
            showError = true
        } else {
            showSuccess = true
        }
    }
}

// MARK: - Preview

#Preview("Generation Prompt") {
    NavigationStack {
        WalletPassGenerationView(
            venue: Venue.mockDasWohnzimmer(),
            membership: VenueMembership.mockMembership(
                userId: UUID(),
                venueId: UUID()
            ),
            userId: UUID(),
            onPassGenerated: { _ in }
        )
    }
}

#Preview("Pass Generated") {
    NavigationStack {
        WalletPassGenerationView(
            venue: Venue.mockDasWohnzimmer(),
            membership: VenueMembership.mockMembership(
                userId: UUID(),
                venueId: UUID()
            ),
            userId: UUID(),
            onPassGenerated: { _ in }
        )
    }
}
