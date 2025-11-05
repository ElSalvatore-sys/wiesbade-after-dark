//
//  WalletPassCard.swift
//  WiesbadenAfterDark
//
//  Apple Wallet-style pass card component
//

import SwiftUI

/// Display mode for wallet pass card
enum WalletPassCardMode {
    case compact // For list view
    case full // For detail view with QR code
}

/// Wallet pass card component
struct WalletPassCard: View {
    // MARK: - Properties

    let pass: WalletPass
    var mode: WalletPassCardMode = .compact
    var onTap: (() -> Void)?

    // MARK: - Body

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 0) {
                // Header Section (Venue branding)
                headerSection
                    .frame(height: mode == .compact ? 100 : 120)

                // Content Section
                contentSection
                    .padding(mode == .compact ? 16 : 20)
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Theme.Shadow.md.color, radius: Theme.Shadow.md.radius, x: Theme.Shadow.md.x, y: Theme.Shadow.md.y)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PassCardButtonStyle())
    }

    // MARK: - Header Section

    private var headerSection: some View {
        ZStack {
            // Background gradient
            Color.primaryGradient

            // Pattern overlay (dots or circles for visual interest)
            GeometryReader { geometry in
                ForEach(0..<8) { i in
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .offset(
                            x: CGFloat(i % 4) * (geometry.size.width / 3),
                            y: CGFloat(i / 4) * 50 - 20
                        )
                }
            }

            // Header Content
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // App name
                    Text("Wiesbaden After Dark")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))

                    // Venue name
                    Text(pass.venueName)
                        .font(mode == .compact ? .title3 : .title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }

                Spacer()

                // Membership badge
                VStack(spacing: 2) {
                    Image(systemName: "star.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)

                    Text(pass.memberTier)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(spacing: mode == .compact ? 12 : 16) {
            // Points Balance
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Points Balance")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)

                    Text("\(pass.pointsBalance)")
                        .font(mode == .compact ? .title2 : .largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                }

                Spacer()

                // Status indicator
                HStack(spacing: 6) {
                    Image(systemName: pass.isAddedToWallet ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.caption)
                        .foregroundStyle(pass.isAddedToWallet ? .green : Color.primary)

                    Text(pass.isAddedToWallet ? "In Wallet" : "Add to Wallet")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(pass.isAddedToWallet ? .green : Color.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill((pass.isAddedToWallet ? Color.green : Color.primary).opacity(0.1))
                )
            }

            // QR Code (full mode only)
            if mode == .full {
                qrCodeSection
            }

            // Pass Details
            VStack(spacing: 8) {
                passDetailRow(
                    label: "Serial Number",
                    value: pass.serialNumber
                )

                passDetailRow(
                    label: "Last Updated",
                    value: pass.lastUpdated.formatted(date: .abbreviated, time: .shortened)
                )

                if let expiresAt = pass.expiresAt {
                    passDetailRow(
                        label: "Expires",
                        value: expiresAt.formatted(date: .abbreviated, time: .omitted),
                        isWarning: expiresAt < Date().addingTimeInterval(86400 * 30) // Expires in 30 days
                    )
                }
            }
        }
    }

    // MARK: - QR Code Section

    private var qrCodeSection: some View {
        VStack(spacing: 12) {
            Divider()

            // QR Code Placeholder (in real app, generate actual QR code from qrCodeData)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 180, height: 180)

                // Mock QR code pattern
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(0..<5) { _ in
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 20, height: 20)
                        }
                    }
                    HStack(spacing: 8) {
                        ForEach(0..<5) { i in
                            Rectangle()
                                .fill(i % 2 == 0 ? Color.black : Color.white)
                                .frame(width: 20, height: 20)
                        }
                    }
                    HStack(spacing: 8) {
                        ForEach(0..<5) { i in
                            Rectangle()
                                .fill(i % 2 == 1 ? Color.black : Color.white)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .padding(20)

                // QR Code icon overlay
                Image(systemName: "qrcode")
                    .font(.system(size: 60))
                    .foregroundStyle(.black.opacity(0.3))
            }
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            Text("Scan at venue for quick check-in")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            Divider()
        }
    }

    // MARK: - Helper Views

    private func passDetailRow(label: String, value: String, isWarning: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            HStack(spacing: 4) {
                if isWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isWarning ? .orange : Color.textPrimary)
            }
        }
    }
}

// MARK: - Button Style

struct PassCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Compact Mode") {
    ScrollView {
        VStack(spacing: 16) {
            // Active pass
            WalletPassCard(
                pass: WalletPass.mock(),
                mode: .compact
            )

            // Pass not added to wallet
            WalletPassCard(
                pass: WalletPass(
                    userId: UUID(),
                    venueId: UUID(),
                    venueName: "Das Loft",
                    passTypeIdentifier: "pass.com.ea-solutions.wad",
                    serialNumber: "WAD-DAS-12345678",
                    authenticationToken: UUID().uuidString,
                    qrCodeData: "{}",
                    nfcPayload: "wad://check-in/test",
                    isAddedToWallet: false,
                    lastUpdated: Date(),
                    expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                    memberTier: "Gold",
                    pointsBalance: 850
                ),
                mode: .compact
            )

            // Expiring soon pass
            WalletPassCard(
                pass: WalletPass(
                    userId: UUID(),
                    venueId: UUID(),
                    venueName: "Kulturzentrum Schlachthof",
                    passTypeIdentifier: "pass.com.ea-solutions.wad",
                    serialNumber: "WAD-KUL-87654321",
                    authenticationToken: UUID().uuidString,
                    qrCodeData: "{}",
                    nfcPayload: "wad://check-in/test",
                    isAddedToWallet: true,
                    lastUpdated: Date().addingTimeInterval(-86400 * 7),
                    expiresAt: Date().addingTimeInterval(86400 * 15), // 15 days
                    memberTier: "Bronze",
                    pointsBalance: 230
                ),
                mode: .compact
            )
        }
        .padding()
    }
    .background(Color.appBackground)
}

#Preview("Full Mode") {
    ScrollView {
        VStack(spacing: 20) {
            WalletPassCard(
                pass: WalletPass.mock(),
                mode: .full
            )

            WalletPassCard(
                pass: WalletPass(
                    userId: UUID(),
                    venueId: UUID(),
                    venueName: "Nacht & Nebel",
                    passTypeIdentifier: "pass.com.ea-solutions.wad",
                    serialNumber: "WAD-NAC-11223344",
                    authenticationToken: UUID().uuidString,
                    qrCodeData: "{}",
                    nfcPayload: "wad://check-in/test",
                    isAddedToWallet: false,
                    lastUpdated: Date(),
                    expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                    memberTier: "Platinum",
                    pointsBalance: 2450
                ),
                mode: .full
            )
        }
        .padding()
    }
    .background(Color.appBackground)
}
