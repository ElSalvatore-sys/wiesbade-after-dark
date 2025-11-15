//
//  InventoryOffersSection.swift
//  WiesbadenAfterDark
//
//  Purpose: Display special offers with bonus point multipliers
//  Shows: List of inventory offers with bonus indicators
//

import SwiftUI

/// Section displaying special inventory offers
/// - Shows header with offer count
/// - Lists offers with bonus multipliers
/// - Empty state when no offers available
struct InventoryOffersSection: View {
    // MARK: - Properties

    let inventoryOffers: [Product]
    let venues: [Venue]
    let onProductTap: (Product) -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Special Offers")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    Text("Limited time bonus points")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                if !inventoryOffers.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)

                        Text("\(inventoryOffers.count) deals")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.gold)
                }
            }
            .padding(.horizontal)

            // Offer Cards
            if !inventoryOffers.isEmpty {
                VStack(spacing: 12) {
                    ForEach(inventoryOffers.prefix(5), id: \.id) { product in
                        InventoryOfferCard(
                            product: product,
                            venue: venue(for: product),
                            multiplier: product.bonusMultiplier,
                            expiresAt: product.bonusEndDate
                        )
                        .onTapGesture {
                            onProductTap(product)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                // Empty state
                emptyStateView
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tag")
                .font(.system(size: 48))
                .foregroundStyle(Color.textTertiary)

            Text("No special offers right now")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            Text("Check back later for bonus point deals!")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func venue(for product: Product) -> Venue? {
        venues.first(where: { $0.id == product.venueId })
    }
}

// MARK: - Preview

#Preview("Inventory Offers Section") {
    InventoryOffersSection(
        inventoryOffers: Product.mockProducts,
        venues: Venue.mockVenues,
        onProductTap: { _ in }
    )
}
