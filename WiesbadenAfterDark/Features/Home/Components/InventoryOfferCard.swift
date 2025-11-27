//
//  InventoryOfferCard.swift
//  WiesbadenAfterDark
//
//  Professional card component for displaying inventory offers
//  Redesigned for sophisticated, minimalist aesthetic
//

import SwiftUI

/// Professional card displaying product offers with strategic bonus indicators
struct InventoryOfferCard: View {
    // MARK: - Properties

    let product: Product
    let venue: Venue?
    let multiplier: Decimal
    let expiresAt: Date?

    // MARK: - Computed Properties

    private var multiplierValue: Double {
        NSDecimalNumber(decimal: multiplier).doubleValue
    }

    private var isHighValueBonus: Bool {
        multiplierValue >= 3.0
    }

    private var isMediumValueBonus: Bool {
        multiplierValue >= 2.0 && multiplierValue < 3.0
    }

    private var isExpiringSoon: Bool {
        guard let expires = expiresAt else { return false }
        return expires.timeIntervalSinceNow < 3600 * 6 // Less than 6 hours
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Product Icon (Professional SF Symbol)
            productIconView

            // Content Section
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                // Header: Product Name + Bonus Badge
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    Text(product.name)
                        .font(Typography.headlineSmall)
                        .foregroundColor(.orange)
                        .lineLimit(1)

                    Spacer()

                    // Strategic Bonus Badge
                    if multiplierValue > 1 {
                        bonusBadge
                    }
                }

                // Venue Location
                if let venue = venue {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)

                        Text(venue.name)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Bottom Row: Price + Expiry Timer
                HStack(alignment: .bottom) {
                    Text(product.formattedPrice)
                        .font(Typography.headlineMedium)
                        .foregroundColor(.gold)

                    Spacer()

                    // Expiry Countdown
                    if let timeText = product.timeRemaining {
                        expiryIndicator(timeText: timeText)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(Theme.Spacing.md)
        .frame(height: 110)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .shadow(
            color: Theme.Shadow.md.color,
            radius: Theme.Shadow.md.radius,
            x: Theme.Shadow.md.x,
            y: Theme.Shadow.md.y
        )
    }

    // MARK: - Subviews

    /// Professional product icon with SF Symbol
    private var productIconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                .fill(Color.cardBorder)

            Image(systemName: categoryIcon)
                .font(.system(size: 28))
                .foregroundColor(.textSecondary)
        }
        .frame(width: 70, height: 70)
    }

    /// Strategic bonus badge with tiered styling
    private var bonusBadge: some View {
        Group {
            if isHighValueBonus {
                // 3x+ PROMINENT: Large, bold, attention-grabbing
                Text("\(Int(multiplierValue))× POINTS")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#F59E0B"), Color(hex: "#EF4444")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
            } else if isMediumValueBonus {
                // 2x SUBTLE: Refined, professional, clear
                Text("\(Int(multiplierValue))×")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#D97706")) // Darker gold
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#FCD34D").opacity(0.12))
                    )
            } else {
                // 1.5x MINIMAL: Very understated
                Text("\(String(format: "%.1f", multiplierValue))×")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.cardBorder)
                    )
            }
        }
    }

    /// Refined expiry countdown indicator
    private func expiryIndicator(timeText: String) -> some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "clock")
                .font(.system(size: 11))

            Text(timeText.replacingOccurrences(of: "Expires in ", with: ""))
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(isExpiringSoon ? Color.orange : .textSecondary)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: Theme.Spacing.xs)
                .fill(isExpiringSoon ? Color.orange.opacity(0.15) : Color.cardBorder)
        )
    }

    // MARK: - Helpers

    /// Professional SF Symbol for product category
    private var categoryIcon: String {
        switch product.category {
        case .cocktails:
            return "wineglass.fill"
        case .beer:
            return "mug.fill"
        case .wine:
            return "wineglass.fill"
        case .spirits:
            return "wineglass"
        case .beverages:
            return "cup.and.saucer.fill"
        case .food:
            return "fork.knife"
        case .appetizers:
            return "leaf.fill"
        case .desserts:
            return "birthday.cake.fill"
        }
    }
}

// MARK: - Preview

#Preview("Professional Inventory Offers") {
    let venueId = UUID()
    let venue = Venue(
        name: "Das Wohnzimmer",
        slug: "das-wohnzimmer",
        type: .club,
        description: "Cozy club in Wiesbaden",
        address: "Langgasse 38",
        city: "Wiesbaden",
        postalCode: "65183",
        latitude: 50.0826,
        longitude: 8.2400
    )

    // Create mock products with different multipliers
    let products = Product.mockProductsForVenue(venueId)
    let bonusProducts = products.filter { $0.bonusPointsActive }

    ScrollView {
        VStack(spacing: Theme.Spacing.cardGap) {
            // High value bonus (3x+)
            if let product = bonusProducts.first {
                InventoryOfferCard(
                    product: product,
                    venue: venue,
                    multiplier: 3.5,
                    expiresAt: Date().addingTimeInterval(3600 * 5)
                )
            }

            // Medium value bonus (2x)
            if bonusProducts.count > 1 {
                InventoryOfferCard(
                    product: bonusProducts[1],
                    venue: venue,
                    multiplier: 2.0,
                    expiresAt: Date().addingTimeInterval(3600 * 12)
                )
            }

            // Low value bonus (1.5x)
            if bonusProducts.count > 2 {
                InventoryOfferCard(
                    product: bonusProducts[2],
                    venue: venue,
                    multiplier: 1.5,
                    expiresAt: Date().addingTimeInterval(3600 * 24)
                )
            }
        }
        .padding()
    }
    .background(Color.appBackground)
}
