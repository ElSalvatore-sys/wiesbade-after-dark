//
//  PriceBreakdownView.swift
//  WiesbadenAfterDark
//
//  Itemized price breakdown component
//

import SwiftUI

/// Price breakdown item
struct PriceBreakdownItem {
    let label: String
    let value: String
    var isTotal: Bool = false
    var isDiscount: Bool = false
}

/// Price breakdown view
struct PriceBreakdownView: View {
    // MARK: - Properties

    let items: [PriceBreakdownItem]
    var showDivider: Bool = true

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Price Breakdown")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            if showDivider {
                Divider()
                    .padding(.horizontal, 16)
            }

            // Items
            VStack(spacing: 12) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]

                    if item.isTotal && index > 0 {
                        Divider()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }

                    PriceRow(item: item)
                }
            }
            .padding(16)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Theme.Shadow.sm.color, radius: Theme.Shadow.sm.radius, x: Theme.Shadow.sm.x, y: Theme.Shadow.sm.y)
    }
}

/// Price row
private struct PriceRow: View {
    let item: PriceBreakdownItem

    var body: some View {
        HStack {
            Text(item.label)
                .font(item.isTotal ? .headline : .subheadline)
                .foregroundStyle(item.isTotal ? Color.textPrimary : Color.textSecondary)

            Spacer()

            Text(item.value)
                .font(item.isTotal ? .headline : .subheadline)
                .fontWeight(item.isTotal ? .bold : .medium)
                .foregroundStyle(item.isDiscount ? Color.primary : (item.isTotal ? Color.textPrimary : Color.textSecondary))
        }
    }
}

// MARK: - Helper Extensions

extension PriceBreakdownView {
    /// Create breakdown for table booking
    static func forBooking(
        tableType: TableType,
        pointsUsed: Int? = nil
    ) -> PriceBreakdownView {
        var items: [PriceBreakdownItem] = []

        // Table price
        let tablePrice = tableType.basePrice
        items.append(PriceBreakdownItem(
            label: tableType.displayName,
            value: PricingConfig.formatCurrency(tablePrice)
        ))

        // Points discount
        if let pointsUsed = pointsUsed {
            let pointsValue = PricingConfig.pointsToEuro(pointsUsed)
            items.append(PriceBreakdownItem(
                label: "Points Discount (\(PricingConfig.formatPoints(pointsUsed)))",
                value: "-\(PricingConfig.formatCurrency(pointsValue))",
                isDiscount: true
            ))
        }

        // Total
        let total = pointsUsed.map { tablePrice - PricingConfig.pointsToEuro($0) } ?? tablePrice
        items.append(PriceBreakdownItem(
            label: "Total Amount",
            value: PricingConfig.formatCurrency(max(0, total)),
            isTotal: true
        ))

        return PriceBreakdownView(items: items)
    }

    /// Create breakdown for point purchase
    static func forPointPurchase(
        package: PointPackage
    ) -> PriceBreakdownView {
        var items: [PriceBreakdownItem] = []

        // Base points
        items.append(PriceBreakdownItem(
            label: "\(package.points) Points",
            value: package.displayPrice
        ))

        // Bonus
        if package.bonus > 0 {
            items.append(PriceBreakdownItem(
                label: "Bonus Points (+\(package.savingsPercent)%)",
                value: "+\(package.bonus) pts",
                isDiscount: true
            ))
        }

        // Total
        items.append(PriceBreakdownItem(
            label: "Total Points",
            value: "\(package.totalPoints) pts",
            isTotal: true
        ))

        return PriceBreakdownView(items: items)
    }
}

// MARK: - Preview

#Preview("Booking - Cash") {
    VStack(spacing: 16) {
        PriceBreakdownView.forBooking(tableType: .vip)
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Booking - Combo") {
    VStack(spacing: 16) {
        PriceBreakdownView.forBooking(
            tableType: .vip,
            pointsUsed: 800
        )
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Point Purchase") {
    VStack(spacing: 16) {
        PriceBreakdownView.forPointPurchase(
            package: PricingConfig.packages[2] // Premium
        )
    }
    .padding()
    .background(Color.appBackground)
}
