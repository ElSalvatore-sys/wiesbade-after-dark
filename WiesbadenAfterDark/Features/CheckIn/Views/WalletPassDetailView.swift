//
//  WalletPassDetailView.swift
//  WiesbadenAfterDark
//
//  Detailed wallet pass view with add to wallet action
//

import SwiftUI

/// Wallet pass detail view
struct WalletPassDetailView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let pass: WalletPass

    // MARK: - View Model

    @State private var viewModel: CheckInViewModel

    // MARK: - UI State

    @State private var isAddingToWallet = false
    @State private var showSuccess = false

    // MARK: - Initialization

    init(pass: WalletPass) {
        self.pass = pass

        self._viewModel = State(initialValue: CheckInViewModel(
            checkInService: MockCheckInService.shared,
            walletPassService: RealWalletPassService.shared
        ))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Wallet Pass Card
                WalletPassCard(pass: pass, mode: .full)

                // Add to Wallet Button
                if !pass.isAddedToWallet {
                    addToWalletButton
                }

                // Usage Instructions
                usageInstructionsSection

                // Pass Information
                passInformationSection

                // NFC Instructions
                if !pass.isAddedToWallet {
                    nfcInstructionsSection
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Wallet Pass")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Added to Wallet", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your pass has been added to Apple Wallet successfully!")
        }
    }

    // MARK: - Add to Wallet Button

    private var addToWalletButton: some View {
        Button(action: {
            Task {
                await addToWallet()
            }
        }) {
            HStack(spacing: 12) {
                if isAddingToWallet {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "plus.rectangle.on.rectangle")
                        .font(.title3)
                }

                Text(isAddingToWallet ? "Adding to Wallet..." : "Add to Apple Wallet")
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
        .disabled(isAddingToWallet)
    }

    // MARK: - Usage Instructions

    private var usageInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Use")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 12) {
                instructionRow(
                    number: "1",
                    title: "Add to Wallet",
                    description: "Tap 'Add to Apple Wallet' to save your pass",
                    icon: "plus.rectangle.on.rectangle"
                )

                instructionRow(
                    number: "2",
                    title: "Visit Venue",
                    description: "Bring your iPhone to \(pass.venueName)",
                    icon: "mappin.circle.fill"
                )

                instructionRow(
                    number: "3",
                    title: "Scan Pass",
                    description: "Show QR code or tap NFC reader at venue",
                    icon: "wave.3.right"
                )

                instructionRow(
                    number: "4",
                    title: "Earn Points",
                    description: "Check in and earn loyalty points automatically",
                    icon: "star.fill"
                )
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.Shadow.sm.color, radius: Theme.Shadow.sm.radius, x: Theme.Shadow.sm.x, y: Theme.Shadow.sm.y)
    }

    // MARK: - Pass Information

    private var passInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pass Information")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 12) {
                infoRow(label: "Venue", value: pass.venueName)
                infoRow(label: "Member Tier", value: pass.memberTier)
                infoRow(label: "Points Balance", value: "\(pass.pointsBalance) pts")
                infoRow(label: "Serial Number", value: pass.serialNumber)
                infoRow(
                    label: "Last Updated",
                    value: pass.lastUpdated.formatted(date: .abbreviated, time: .shortened)
                )

                if let expiresAt = pass.expiresAt {
                    infoRow(
                        label: "Expires",
                        value: expiresAt.formatted(date: .long, time: .omitted),
                        isWarning: expiresAt < Date().addingTimeInterval(86400 * 30)
                    )
                }

                infoRow(
                    label: "Status",
                    value: pass.isAddedToWallet ? "In Wallet" : "Not Added",
                    color: pass.isAddedToWallet ? .green : .orange
                )
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.Shadow.sm.color, radius: Theme.Shadow.sm.radius, x: Theme.Shadow.sm.x, y: Theme.Shadow.sm.y)
    }

    // MARK: - NFC Instructions

    private var nfcInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "wave.3.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.primary)

                Text("NFC Check-In")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("For fastest check-in:")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)

                VStack(alignment: .leading, spacing: 8) {
                    bulletPoint("Add pass to Apple Wallet")
                    bulletPoint("When at venue, hold iPhone near NFC reader")
                    bulletPoint("Pass will appear automatically")
                    bulletPoint("Authentication happens instantly")
                }
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
            }

            Text("No NFC reader? You can also scan the QR code at venue.")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Helper Views

    private func instructionRow(number: String, title: String, description: String, icon: String) -> some View {
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
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(Color.primary)

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)
                }

                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()
        }
    }

    private func infoRow(label: String, value: String, isWarning: Bool = false, color: Color? = nil) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            HStack(spacing: 4) {
                if isWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(color ?? (isWarning ? .orange : Color.textPrimary))
            }
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(Color.primary)

            Text(text)
        }
    }

    // MARK: - Actions

    private func addToWallet() async {
        isAddingToWallet = true

        await viewModel.addPassToWallet(pass)

        isAddingToWallet = false

        if viewModel.errorMessage == nil {
            showSuccess = true
        }
    }
}

// MARK: - Preview

#Preview("Not Added") {
    NavigationStack {
        WalletPassDetailView(
            pass: WalletPass.mock()
        )
    }
}

#Preview("Added to Wallet") {
    NavigationStack {
        WalletPassDetailView(
            pass: WalletPass(
                userId: UUID(),
                venueId: UUID(),
                venueName: "Das Loft",
                passTypeIdentifier: "pass.com.ea-solutions.wad",
                serialNumber: "WAD-DAS-12345678",
                authenticationToken: UUID().uuidString,
                qrCodeData: "{}",
                nfcPayload: "wad://check-in/test",
                isAddedToWallet: true,
                lastUpdated: Date(),
                expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                memberTier: "Gold",
                pointsBalance: 850
            )
        )
    }
}

#Preview("Expiring Soon") {
    NavigationStack {
        WalletPassDetailView(
            pass: WalletPass(
                userId: UUID(),
                venueId: UUID(),
                venueName: "Nacht & Nebel",
                passTypeIdentifier: "pass.com.ea-solutions.wad",
                serialNumber: "WAD-NAC-87654321",
                authenticationToken: UUID().uuidString,
                qrCodeData: "{}",
                nfcPayload: "wad://check-in/test",
                isAddedToWallet: false,
                lastUpdated: Date().addingTimeInterval(-86400 * 7),
                expiresAt: Date().addingTimeInterval(86400 * 15), // 15 days
                memberTier: "Platinum",
                pointsBalance: 2450
            )
        )
    }
}
