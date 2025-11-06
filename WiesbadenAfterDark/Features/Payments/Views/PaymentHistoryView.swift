//
//  PaymentHistoryView.swift
//  WiesbadenAfterDark
//
//  Payment history with filters
//

import SwiftUI

/// Payment history view
struct PaymentHistoryView: View {
    // MARK: - Properties

    let userId: UUID

    // MARK: - State

    @State private var payments: [Payment] = []
    @State private var selectedFilter: PaymentFilter = .all
    @State private var searchText = ""

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Filter Picker
            Picker("Filter", selection: $selectedFilter) {
                Text("All").tag(PaymentFilter.all)
                Text("Bookings").tag(PaymentFilter.bookings)
                Text("Points").tag(PaymentFilter.points)
            }
            .pickerStyle(.segmented)
            .padding()

            // Payments List
            ScrollView {
                LazyVStack(spacing: 16) {
                    if filteredPayments.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(filteredPayments) { payment in
                            PaymentCard(payment: payment)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Payment History")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search payments")
        .task {
            await loadPayments()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundStyle(Color.textSecondary.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Payments")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Text("Your payment history will appear here")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(60)
    }

    // MARK: - Computed Properties

    private var filteredPayments: [Payment] {
        var filtered = payments

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .bookings:
            filtered = filtered.filter { $0.bookingId != nil }
        case .points:
            filtered = filtered.filter { $0.pointsPurchaseId != nil }
        }

        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.paymentDescription.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Data Loading

    private func loadPayments() async {
        // TODO: Load from PaymentService
        // For mock, show sample data
        payments = [
            Payment.mock(userId: userId, amount: 120.00, status: .succeeded),
            Payment.mock(userId: userId, amount: 50.00, status: .succeeded),
            Payment.mock(userId: userId, amount: 10.00, status: .succeeded, description: "Point Purchase - Value Pack")
        ]
    }
}

// MARK: - Payment Filter

private enum PaymentFilter {
    case all
    case bookings
    case points
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PaymentHistoryView(userId: UUID())
    }
}
