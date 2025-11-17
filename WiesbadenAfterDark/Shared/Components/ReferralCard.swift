//
//  ReferralCard.swift
//  WiesbadenAfterDark
//
//  Prominent referral code card with copy and share functionality
//

import SwiftUI

/// Prominent card displaying referral code with one-tap copy and share functionality
struct ReferralCard: View {
    // MARK: - Properties

    let referralCode: String
    let totalEarnings: Int

    @State private var showCopied = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Top section: Referral code with copy button
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Referral Code")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)

                    Text(referralCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }

                Spacer()

                Button(action: {
                    UIPasteboard.general.string = referralCode
                    HapticManager.shared.copied()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        showCopied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showCopied = false
                        }
                    }
                }) {
                    Image(systemName: showCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .scaleEffect(showCopied ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCopied)
                }
            }

            Divider()

            // Bottom section: Earnings and share button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Earned from Referrals")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Text("\(totalEarnings) points")
                        .font(.headline)
                        .foregroundColor(.green)
                }

                Spacer()

                ShareLink(item: "Join Wiesbaden After Dark with my code: \(referralCode)") {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            // Benefit callout
            Text("Earn 25% of points when friends check in!")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("Referral Card") {
    VStack(spacing: 20) {
        ReferralCard(
            referralCode: "WIESBADEN2024",
            totalEarnings: 1250
        )
        .padding()

        ReferralCard(
            referralCode: "PARTY123",
            totalEarnings: 0
        )
        .padding()
    }
    .background(Color.appBackground)
}
