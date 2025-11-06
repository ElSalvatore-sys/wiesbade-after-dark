//
//  PaymentCard.swift
//  WiesbadenAfterDark
//
//  Payment history card component
//

import SwiftUI

/// Payment card component
struct PaymentCard: View {
    // MARK: - Properties

    let payment: Payment
    var onTap: (() -> Void)?

    // MARK: - Body

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Payment Method Icon
                ZStack {
                    Circle()
                        .fill(iconBackground)
                        .frame(width: 50, height: 50)

                    Image(systemName: payment.paymentMethod.icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                // Payment Info
                VStack(alignment: .leading, spacing: 6) {
                    // Description
                    Text(payment.paymentDescription)
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(2)

                    // Payment Method
                    HStack(spacing: 6) {
                        Text(payment.paymentMethod.displayName)
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)

                        if let pointsUsed = payment.pointsUsed {
                            Text("•")
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)

                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption)

                                Text("\(pointsUsed) pts")
                                    .font(.subheadline)
                            }
                            .foregroundStyle(Color.primary)
                        }
                    }

                    // Date
                    Text(payment.formattedDate)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)

                    // Status Badge
                    StatusBadge(status: payment.status)
                }

                Spacer()

                // Amount
                VStack(alignment: .trailing, spacing: 4) {
                    Text(payment.formattedAmount)
                        .font(.headline)
                        .foregroundStyle(amountColor)

                    if payment.isRefunded, let refundedAmount = payment.refundedAmount {
                        Text("-\(PricingConfig.formatCurrency(refundedAmount))")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Theme.Shadow.sm.color, radius: Theme.Shadow.sm.radius, x: Theme.Shadow.sm.x, y: Theme.Shadow.sm.y)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(onTap == nil)
    }

    // MARK: - Helper Properties

    private var iconBackground: LinearGradient {
        switch payment.status {
        case .succeeded:
            return Color.primaryGradient
        case .failed:
            return LinearGradient(
                colors: [.red, .red.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .refunded, .partiallyRefunded:
            return LinearGradient(
                colors: [.orange, .orange.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [.gray, .gray.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var amountColor: Color {
        switch payment.status {
        case .succeeded:
            return Color.textPrimary
        case .failed:
            return .red
        case .refunded, .partiallyRefunded:
            return .orange
        default:
            return Color.textSecondary
        }
    }
}

/// Payment status badge
private struct StatusBadge: View {
    let status: PaymentStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)

            Text(status.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(statusColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch status {
        case .succeeded:
            return .green
        case .pending, .processing:
            return .orange
        case .failed:
            return .red
        case .refunded, .partiallyRefunded:
            return .blue
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        PaymentCard(
            payment: Payment.mock(
                amount: 120.00,
                paymentMethod: .card,
                status: .succeeded,
                description: "Table Booking - VIP Section"
            )
        )

        PaymentCard(
            payment: Payment.mock(
                amount: 10.00,
                paymentMethod: .applePay,
                status: .succeeded,
                description: "Point Purchase - Value Pack"
            )
        )

        PaymentCard(
            payment: Payment(
                userId: UUID(),
                amount: 50.00,
                paymentMethod: .points,
                status: .succeeded,
                pointsUsed: 1000,
                paymentDescription: "Table Booking - Standard"
            )
        )

        PaymentCard(
            payment: Payment.mock(
                amount: 120.00,
                paymentMethod: .card,
                status: .failed,
                description: "Table Booking - VIP Section"
            )
        )
    }
    .padding()
    .background(Color.appBackground)
}
