//
//  PaymentMethodSelector.swift
//  WiesbadenAfterDark
//
//  Payment method selection component
//

import SwiftUI

/// Payment method selector
struct PaymentMethodSelector: View {
    // MARK: - Properties

    let amount: Decimal
    let pointsCost: Int
    let availablePoints: Int
    let onSelect: (PaymentMethodType) -> Void

    // MARK: - Computed Properties

    private var hasEnoughPoints: Bool {
        availablePoints >= pointsCost
    }

    private var pointsValue: Decimal {
        PricingConfig.pointsToEuro(availablePoints)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Text("Choose Payment Method")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Text("Select how you'd like to pay")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.bottom, 8)

            // Payment Methods
            VStack(spacing: 12) {
                // Card Payment
                PaymentMethodButton(
                    icon: "creditcard.fill",
                    title: "Pay with Card",
                    subtitle: PricingConfig.formatCurrency(amount),
                    gradient: Color.primaryGradient,
                    onTap: {
                        onSelect(.card)
                    }
                )

                // Apple Pay
                PaymentMethodButton(
                    icon: "apple.logo",
                    title: "Apple Pay",
                    subtitle: "Fast & secure",
                    gradient: LinearGradient(
                        colors: [Color.black, Color.gray.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    onTap: {
                        onSelect(.applePay)
                    }
                )

                // Points Payment
                PaymentMethodButton(
                    icon: "star.fill",
                    title: "Pay with Points",
                    subtitle: hasEnoughPoints ? "\(pointsCost) points" : "Need \(pointsCost - availablePoints) more points",
                    gradient: LinearGradient(
                        colors: hasEnoughPoints ? [Color.gold, Color.gold.opacity(0.7)] : [Color.gray, Color.gray.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    isDisabled: !hasEnoughPoints,
                    onTap: {
                        onSelect(.points)
                    }
                )
            }

            // Points Balance Info
            if availablePoints > 0 {
                Divider()
                    .padding(.vertical, 8)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Points Balance")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)

                        HStack(spacing: 4) {
                            Text(PricingConfig.formatPoints(availablePoints))
                                .font(.headline)
                                .foregroundStyle(Color.primary)

                            Text("≈ \(PricingConfig.formatCurrency(pointsValue))")
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }

                    Spacer()

                    if !hasEnoughPoints && availablePoints > 0 {
                        Button("Buy More") {
                            // TODO: Navigate to buy points
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                    }
                }
                .padding(12)
                .background(Color.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
    }
}

/// Payment method button
private struct PaymentMethodButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: LinearGradient
    var isDisabled: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(20)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isDisabled)
    }
}

// MARK: - Preview

#Preview("Enough Points") {
    PaymentMethodSelector(
        amount: 120.00,
        pointsCost: 2400,
        availablePoints: 3000,
        onSelect: { method in
            print("Selected: \(method.rawValue)")
        }
    )
    .background(Color.appBackground)
}

#Preview("Insufficient Points") {
    PaymentMethodSelector(
        amount: 120.00,
        pointsCost: 2400,
        availablePoints: 800,
        onSelect: { method in
            print("Selected: \(method.rawValue)")
        }
    )
    .background(Color.appBackground)
}
