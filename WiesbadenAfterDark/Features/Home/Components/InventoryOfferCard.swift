//
//  InventoryOfferCard.swift
//  WiesbadenAfterDark
//
//  Card component for displaying inventory offers with point multipliers
//

import SwiftUI

/// Card displaying a product with bonus points multiplier
struct InventoryOfferCard: View {
    // MARK: - Properties

    let product: Product
    let venue: Venue?
    let multiplier: Decimal
    let expiresAt: Date?

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
            // Product Icon/Image
            productIcon

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Bonus Badge
                if let badgeText = product.bonusMultiplierText {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)

                        Text(badgeText)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(bonusColor)
                    .clipShape(Capsule())
                }

                // Product Name
                Text(product.name)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                // Venue Name
                if let venue = venue {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)

                        Text(venue.name)
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                }

                // Countdown Timer
                if let timeText = product.timeRemaining {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)

                        Text(timeText)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(product.isExpiringSoon ? Color.warning : Color.info)
                }

                // Price and Reason
                HStack {
                    Text(product.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)

                    if let reason = product.bonusReason {
                        Text("•")
                            .foregroundStyle(Color.textTertiary)

                        Text(reason)
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }

            Spacer()

            // CTA Button
            VStack {
                Button {
                    // Handle order action
                    print("🛒 Order product: \(product.name)")
                } label: {
                    Text("Order")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.primaryGradient)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .shadow(
            color: Theme.Shadow.md.color,
            radius: Theme.Shadow.md.radius,
            x: Theme.Shadow.md.x,
            y: Theme.Shadow.md.y
        )
    }

    // MARK: - Product Icon

    private var productIcon: some View {
        ZStack {
            Circle()
                .fill(Color.inputBackground)
                .frame(width: 60, height: 60)

            // Use emoji or system icon
            if let imageURL = product.imageURL, imageURL.count <= 2 {
                // It's an emoji
                Text(imageURL)
                    .font(.system(size: 30))
            } else {
                // Use category icon
                Image(systemName: categoryIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.primaryGradient)
            }
        }
    }

    // MARK: - Helpers

    /// Category-based icon
    private var categoryIcon: String {
        switch product.category.lowercased() {
        case "food":
            return "fork.knife"
        case "drink":
            return "cup.and.saucer.fill"
        case "merchandise":
            return "bag.fill"
        default:
            return "star.fill"
        }
    }

    /// Bonus badge color based on multiplier
    private var bonusColor: LinearGradient {
        let multiplierValue = NSDecimalNumber(decimal: multiplier).doubleValue

        if multiplierValue >= 3.0 {
            // 3x or more: red/orange gradient
            return LinearGradient(
                colors: [Color(hex: "#EF4444"), Color(hex: "#F59E0B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if multiplierValue >= 2.0 {
            // 2x: orange gradient
            return LinearGradient(
                colors: [Color(hex: "#F59E0B"), Color(hex: "#FBBF24")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // Default: primary gradient
            return Color.primaryGradient
        }
    }
}

// MARK: - Preview

#Preview("Inventory Offer Cards") {
    let venueId = UUID()
    let venue = Venue(
        name: "Das Wohnzimmer",
        type: .club,
        address: Address(
            street: "Langgasse 38",
            city: "Wiesbaden",
            postalCode: "65183",
            country: "Germany",
            latitude: 50.0826,
            longitude: 8.2400
        )
    )

    let products = Product.mockProductsWithBonuses(venueId: venueId)
    let bonusProducts = products.filter { $0.hasBonus }

    return ScrollView {
        VStack(spacing: 16) {
            ForEach(bonusProducts, id: \.id) { product in
                InventoryOfferCard(
                    product: product,
                    venue: venue,
                    multiplier: product.bonusMultiplier,
                    expiresAt: product.expiresAt
                )
            }
        }
        .padding()
    }
    .background(Color.appBackground)
}
