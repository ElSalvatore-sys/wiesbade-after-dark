//
//  PointsPackageCard.swift
//  WiesbadenAfterDark
//
//  Point package card for purchasing points
//

import SwiftUI

/// Points package card component
struct PointsPackageCard: View {
    // MARK: - Properties

    let package: PointPackage
    var isSelected: Bool = false
    var onTap: (() -> Void)?

    // MARK: - Body

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(spacing: 16) {
                // Bonus Badge (if applicable)
                if package.bonus > 0 {
                    HStack {
                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "gift.fill")
                                .font(.caption2)

                            Text("+\(package.savingsPercent)% BONUS")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primary)
                        .clipShape(Capsule())
                    }
                    .padding(.bottom, -8)
                }

                // Package Icon
                ZStack {
                    Circle()
                        .fill(iconGradient)
                        .frame(width: 60, height: 60)

                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                // Package Name
                Text(package.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                // Points Amount
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(package.totalPoints)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.primaryGradient)

                        Text("pts")
                            .font(.headline)
                            .foregroundStyle(Color.textSecondary)
                    }

                    // Breakdown
                    if package.bonus > 0 {
                        Text("\(package.points) + \(package.bonus) bonus")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                Divider()

                // Price
                VStack(spacing: 4) {
                    Text(package.displayPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    Text("\(String(format: "€%.4f", NSDecimalNumber(decimal: package.pricePerPoint).doubleValue))/pt")
                        .font(.caption2)
                        .foregroundStyle(Color.textSecondary)
                }

                // Buy Button
                Text(isSelected ? "Selected" : "Buy Now")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        if isSelected {
                            Color.primary
                        } else {
                            Color.primaryGradient
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(20)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: isSelected ? Color.primary.opacity(0.3) : Theme.Shadow.md.color,
                radius: isSelected ? 12 : Theme.Shadow.md.radius,
                x: 0,
                y: isSelected ? 6 : Theme.Shadow.md.y
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Helper Properties

    private var iconGradient: LinearGradient {
        switch package.name {
        case "Starter":
            return LinearGradient(
                colors: [Color.blue, Color.blue.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Value":
            return LinearGradient(
                colors: [Color.green, Color.green.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Premium":
            return Color.primaryGradient
        case "Ultimate":
            return LinearGradient(
                colors: [Color.gold, Color.gold.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return Color.primaryGradient
        }
    }
}

// MARK: - Preview

#Preview {
    LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
    ], spacing: 16) {
        ForEach(PricingConfig.packages) { package in
            PointsPackageCard(
                package: package,
                isSelected: package.name == "Premium"
            )
        }
    }
    .padding()
    .background(Color.appBackground)
}
