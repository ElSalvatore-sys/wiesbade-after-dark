//
//  ReferralExplanationView.swift
//  WiesbadenAfterDark
//
//  Explanation view for how the referral system works
//

import SwiftUI

/// View explaining how the referral system works with step-by-step instructions
struct ReferralExplanationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Label("How Referrals Work", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundColor(.textPrimary)

            // Steps
            VStack(alignment: .leading, spacing: 16) {
                // Step 1
                HStack(alignment: .top, spacing: 12) {
                    Text("1️⃣")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Share your code")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        Text("Send to friends via WhatsApp, SMS, etc.")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }

                // Step 2
                HStack(alignment: .top, spacing: 12) {
                    Text("2️⃣")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Friends sign up")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        Text("They enter your code when registering")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }

                // Step 3
                HStack(alignment: .top, spacing: 12) {
                    Text("3️⃣")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("You both earn!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        Text("Get 25% of their points forever")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview("Referral Explanation") {
    ReferralExplanationView()
        .padding()
        .background(Color.appBackground)
}
