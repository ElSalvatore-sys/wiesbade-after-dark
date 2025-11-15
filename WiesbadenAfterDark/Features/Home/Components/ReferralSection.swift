//
//  ReferralSection.swift
//  WiesbadenAfterDark
//
//  Purpose: Wrapper component combining referral card and explanation
//  Used in: Home screen to promote referral program
//

import SwiftUI

/// Section displaying referral code card with explanation
/// - Shows user's referral code card
/// - Displays explanation of how referrals work
struct ReferralSection: View {
    // MARK: - Properties

    let user: User

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            ReferralCard(
                referralCode: user.referralCode,
                totalEarnings: Int(user.totalPointsEarned * 0.25) // Estimate 25% from referrals
            )

            ReferralExplanationView()
        }
    }
}

// MARK: - Preview

#Preview("Referral Section") {
    ReferralSection(user: User.mockUsers[0])
        .padding()
}
