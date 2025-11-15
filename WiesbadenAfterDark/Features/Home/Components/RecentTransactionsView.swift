//
//  RecentTransactionsView.swift
//  WiesbadenAfterDark
//
//  Extracted from HomeView refactoring - displays recent point transactions
//

import SwiftUI

struct RecentTransactionsView: View {
    let transactions: [PointTransaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            if transactions.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.textTertiary)

                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: transaction.source.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(transactionColor(for: transaction))
                                .frame(width: 40, height: 40)
                                .background(transactionColor(for: transaction).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            // Description and date
                            VStack(alignment: .leading, spacing: 4) {
                                Text(transaction.shortDescription)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.textPrimary)
                                    .lineLimit(1)

                                Text(transaction.timeAgo)
                                    .font(.caption)
                                    .foregroundStyle(Color.textSecondary)
                            }

                            Spacer()

                            // Amount
                            Text(transaction.formattedAmount)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(transaction.amount > 0 ? Color.success : Color.error)
                        }
                        .padding(.vertical, 12)

                        // Divider (except for last item)
                        if index < min(4, transactions.count - 1) {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .shadow(
            color: Theme.Shadow.md.color,
            radius: Theme.Shadow.md.radius,
            x: Theme.Shadow.md.x,
            y: Theme.Shadow.md.y
        )
    }

    private func transactionColor(for transaction: PointTransaction) -> Color {
        switch transaction.type {
        case .earn: return .blue
        case .redeem: return .red
        case .bonus: return .green
        case .refund: return .orange
        }
    }
}
