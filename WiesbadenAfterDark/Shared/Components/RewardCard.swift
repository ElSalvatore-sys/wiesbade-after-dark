//
//  RewardCard.swift
//  WiesbadenAfterDark
//
//  Reward card component for displaying redeemable rewards
//

import SwiftUI

/// Displays reward information in a card format
struct RewardCard: View {
    let reward: Reward
    var userPoints: Int = 0
    var onRedeem: (() -> Void)?

    private var canRedeem: Bool {
        reward.isAvailable && userPoints >= reward.pointsCost
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Reward image (if available) - using cached loading
            if let imageURL = reward.imageURL {
                CachedAsyncImage(
                    url: URL(string: imageURL),
                    targetSize: CGSize(width: 300, height: 120)
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.inputBackground)
                        .frame(height: 120)
                        .shimmer()
                }
                .cornerRadius(Theme.CornerRadius.md)
            }

            // Reward name
            Text(reward.name)
                .font(Typography.headlineMedium)
                .foregroundColor(.textPrimary)
                .lineLimit(2)

            // Description
            Text(reward.rewardDescription)
                .font(Typography.bodySmall)
                .foregroundColor(.textSecondary)
                .lineLimit(2)

            // Points & value
            HStack {
                // Points cost
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gold)
                    Text("\(reward.pointsCost)")
                        .font(Typography.labelMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.gold)
                }

                Spacer()

                // Cash value
                Text(reward.formattedCashValue)
                    .font(Typography.captionMedium)
                    .foregroundColor(.textSecondary)
            }

            // Stock indicator
            if let stockText = reward.stockText {
                Text(stockText)
                    .font(Typography.captionSmall)
                    .foregroundColor(.warning)
            }

            // Redeem button
            Button(action: { onRedeem?() }) {
                Text(canRedeem ? "Redeem" : "Insufficient Points")
                    .font(Typography.buttonSmall)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background {
                        if canRedeem {
                            Color.primaryGradient
                        } else {
                            Color.textTertiary.opacity(0.3)
                        }
                    }
                    .cornerRadius(Theme.CornerRadius.md)
            }
            .disabled(!canRedeem)
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(alignment: .center) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(canRedeem ? Color.clear : Color.textTertiary.opacity(0.2), lineWidth: 1)
        }
        .opacity(canRedeem ? 1.0 : 0.6)
    }
}

// MARK: - Preview
#Preview("Reward Cards") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
            ForEach(Reward.mockRewardsForVenue(UUID()), id: \.id) { reward in
                RewardCard(reward: reward, userPoints: 450) {
                    print("Redeem \(reward.name)")
                }
            }
        }
        .padding()
    }
    .background(Color.appBackground)
}
