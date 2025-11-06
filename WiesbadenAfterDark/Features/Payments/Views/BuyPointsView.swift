//
//  BuyPointsView.swift
//  WiesbadenAfterDark
//
//  Point purchase packages view
//

import SwiftUI

/// Buy points view
struct BuyPointsView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let userId: UUID

    // MARK: - State

    @State private var viewModel = PaymentViewModel()
    @State private var selectedPackage: PointPackage?
    @State private var showPaymentMethod = false
    @State private var showSuccess = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Buy Points")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    Text("Choose a package to get started")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.top)

                // Point Packages Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(PricingConfig.packages) { package in
                        PointsPackageCard(
                            package: package,
                            isSelected: selectedPackage?.id == package.id,
                            onTap: {
                                selectedPackage = package
                                showPaymentMethod = true
                            }
                        )
                    }
                }

                // Benefits Section
                benefitsSection
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Buy Points")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaymentMethod) {
            if let package = selectedPackage {
                paymentMethodSheet(for: package)
            }
        }
        .fullScreenCover(isPresented: $showSuccess) {
            if case .pointsPurchaseSucceeded(let purchase) = viewModel.paymentState {
                PointsPurchaseSuccessView(
                    purchase: purchase,
                    onDismiss: {
                        showSuccess = false
                        dismiss()
                    }
                )
            }
        }
        .onChange(of: viewModel.paymentState) { _, newState in
            if case .pointsPurchaseSucceeded = newState {
                showPaymentMethod = false
                showSuccess = true
            }
        }
    }

    // MARK: - Payment Method Sheet

    private func paymentMethodSheet(for package: PointPackage) -> some View {
        let isProcessing = viewModel.paymentState == .processing

        return NavigationStack {
            VStack(spacing: 24) {
                // Package Summary
                VStack(spacing: 12) {
                    Text("Purchase Summary")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)

                    VStack(spacing: 8) {
                        HStack {
                            Text(package.name + " Pack")
                                .font(.headline)

                            Spacer()

                            Text(package.displayPrice)
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                        }

                        HStack {
                            Text("\(package.totalPoints) points")
                                .font(.subheadline)
                                .foregroundStyle(Color.textSecondary)

                            Spacer()

                            if package.bonus > 0 {
                                Text("+\(package.savingsPercent)% bonus")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Payment Methods
                VStack(spacing: 12) {
                    Text("Choose Payment Method")
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)

                    Button(action: {
                        purchasePoints(package: package, method: .card)
                    }) {
                        paymentMethodButton(
                            icon: "creditcard.fill",
                            title: "Pay with Card",
                            subtitle: package.displayPrice
                        )
                    }
                    .disabled(isProcessing)

                    Button(action: {
                        purchasePoints(package: package, method: .applePay)
                    }) {
                        paymentMethodButton(
                            icon: "apple.logo",
                            title: "Apple Pay",
                            subtitle: "Fast & secure",
                            isApplePay: true
                        )
                    }
                    .disabled(isProcessing)
                }

                // Processing State
                if case .processing = viewModel.paymentState {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color.primary)
                        .padding()
                }

                // Error State
                if case .failed(let message) = viewModel.paymentState {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Spacer()
            }
            .padding()
            .background(Color.appBackground)
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if case .processing = viewModel.paymentState {
                        EmptyView()
                    } else {
                        Button("Cancel") {
                            showPaymentMethod = false
                            viewModel.reset()
                        }
                    }
                }
            }
        }
    }

    private func paymentMethodButton(
        icon: String,
        title: String,
        subtitle: String,
        isApplePay: Bool = false
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(20)
        .background {
            if isApplePay {
                Color.black
            } else {
                Color.primaryGradient
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Benefits Section

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Why Buy Points?")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 12) {
                benefitRow(
                    icon: "star.fill",
                    title: "Save Money",
                    description: "Get bonus points with larger packages"
                )

                benefitRow(
                    icon: "bolt.fill",
                    title: "Instant Booking",
                    description: "Book tables instantly without entering card details"
                )

                benefitRow(
                    icon: "gift.fill",
                    title: "Special Offers",
                    description: "Access exclusive point-only deals"
                )

                benefitRow(
                    icon: "clock.fill",
                    title: "Never Expire",
                    description: "Your points never expire - use them anytime"
                )
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    // MARK: - Purchase Points

    private func purchasePoints(package: PointPackage, method: PaymentMethodType) {
        Task {
            await viewModel.purchasePoints(
                userId: userId,
                package: package,
                paymentMethod: method
            )
        }
    }
}

/// Points purchase success view
private struct PointsPurchaseSuccessView: View {
    let purchase: PointsPurchase
    let onDismiss: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success Icon
            ZStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 120, height: 120)

                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }
            .scaleEffect(showContent ? 1 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showContent)

            // Success Message
            VStack(spacing: 8) {
                Text("Points Added!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textPrimary)

                Text("+\(purchase.totalPoints) points")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.primaryGradient)

                if purchase.hasBonusPoints {
                    Text("Including \(purchase.bonusPoints) bonus points!")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .opacity(showContent ? 1 : 0)

            Button(action: onDismiss) {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
            .opacity(showContent ? 1 : 0)

            Spacer()
        }
        .background(Color.appBackground)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showContent = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BuyPointsView(userId: UUID())
    }
}
