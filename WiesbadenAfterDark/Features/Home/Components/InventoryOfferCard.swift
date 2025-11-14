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
        HStack(spacing: 16) {
            // Product Icon (Professional SF Symbol)
            productIconView

            // Content Section
            VStack(alignment: .leading, spacing: 6) {
                // Header: Product Name + Bonus Badge
                HStack(alignment: .top, spacing: 8) {
                    Text(product.name)
                        .font(Typography.headlineSmall)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    // Strategic Bonus Badge
                    if multiplierValue > 1 {
                        bonusBadge
                    }
                }

                // Venue Location
                if let venue = venue {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)

                        Text(venue.name)
                            .font(Typography.bodySmall)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Bottom Row: Price + Expiry Timer
                HStack(alignment: .bottom) {
                    Text(product.formattedPrice)
                        .font(Typography.headlineMedium)
                        .foregroundColor(.primary)

                    Spacer()

                    // Expiry Countdown
                    if let timeText = product.timeRemaining {
                        expiryIndicator(timeText: timeText)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(16)
        .frame(height: 110)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.04),
            radius: 8,
            x: 0,
            y: 2
        )
    }

    // MARK: - Subviews

    /// Professional product icon with SF Symbol
    private var productIconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.08))

            Image(systemName: categoryIcon)
                .font(.system(size: 28))
                .foregroundColor(.secondary)
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
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.08))
                    )
            }
        }
    }

    /// Refined expiry countdown indicator
    private func expiryIndicator(timeText: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.system(size: 11))

            Text(timeText.replacingOccurrences(of: "Expires in ", with: ""))
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(isExpiringSoon ? Color(hex: "#F59E0B") : .secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isExpiringSoon ? Color.orange.opacity(0.1) : Color.gray.opacity(0.08))
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
        VStack(spacing: 12) {
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
    .background(Color.gray.opacity(0.05))
}
