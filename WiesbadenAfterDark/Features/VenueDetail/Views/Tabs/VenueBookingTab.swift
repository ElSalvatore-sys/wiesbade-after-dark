//
//  VenueBookingTab.swift
//  WiesbadenAfterDark
//
//  Booking tab for table reservations
//

import SwiftUI

/// Booking tab with table reservation form
struct VenueBookingTab: View {
    let venue: Venue

    @Environment(AuthenticationViewModel.self) private var authViewModel

    @State private var selectedTableType: TableType = .standard
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot = "21:00"
    @State private var guestCount = 4
    @State private var specialRequests = ""
    @State private var showingConfirmation = false
    @State private var showPaymentSheet = false

    /// Available time slots for booking
    private let timeSlots = ["18:00", "19:00", "20:00", "21:00", "22:00", "23:00"]

    /// User points loaded from authenticated user profile
    private var userPoints: Int {
        if case .authenticated(let user) = authViewModel.authState {
            return user.totalPoints
        }
        return 0
    }

    /// Formatted time slot range (2 hour window)
    private var timeSlotRange: String {
        let hour = Int(selectedTimeSlot.prefix(2)) ?? 21
        let endHour = (hour + 2) % 24
        return "\(selectedTimeSlot) - \(String(format: "%02d:00", endHour))"
    }

    private let minDate = Date()
    private let maxDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                // Header
                Text("Reserve a Table")
                    .font(Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)

                // Table type selection
                TableTypeSelector(selectedType: $selectedTableType)

                Divider()
                    .background(Color.textTertiary.opacity(0.2))
                    .padding(.horizontal, Theme.Spacing.lg)

                // Date picker
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("Date")
                        .font(Typography.headlineMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    DatePicker(
                        "Select date",
                        selection: $selectedDate,
                        in: minDate...maxDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(Theme.Spacing.md)
                    .background(Color.cardBackground)
                    .cornerRadius(Theme.CornerRadius.md)
                }
                .padding(.horizontal, Theme.Spacing.lg)

                // Time slot picker
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("Time Slot")
                        .font(Typography.headlineMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            ForEach(timeSlots, id: \.self) { slot in
                                Button(action: { selectedTimeSlot = slot }) {
                                    Text(slot)
                                        .font(Typography.bodyMedium)
                                        .fontWeight(selectedTimeSlot == slot ? .semibold : .regular)
                                        .foregroundColor(selectedTimeSlot == slot ? .white : .textPrimary)
                                        .padding(.horizontal, Theme.Spacing.md)
                                        .padding(.vertical, Theme.Spacing.sm)
                                        .background(selectedTimeSlot == slot ? Color.primary : Color.cardBackground)
                                        .cornerRadius(Theme.CornerRadius.sm)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)

                Divider()
                    .background(Color.textTertiary.opacity(0.2))
                    .padding(.horizontal, Theme.Spacing.lg)

                // Guest count
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("Number of Guests")
                        .font(Typography.headlineMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    HStack {
                        Button(action: {
                            if guestCount > 1 {
                                guestCount -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(guestCount > 1 ? .primary : .textTertiary)
                        }
                        .disabled(guestCount <= 1)

                        Spacer()

                        Text("\(guestCount)")
                            .font(Typography.titleLarge)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .frame(width: 60)

                        Spacer()

                        Button(action: {
                            if guestCount < 20 {
                                guestCount += 1
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(guestCount < 20 ? .primary : .textTertiary)
                        }
                        .disabled(guestCount >= 20)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Color.cardBackground)
                    .cornerRadius(Theme.CornerRadius.md)
                }
                .padding(.horizontal, Theme.Spacing.lg)

                Divider()
                    .background(Color.textTertiary.opacity(0.2))
                    .padding(.horizontal, Theme.Spacing.lg)

                // Special requests
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("Special Requests (Optional)")
                        .font(Typography.headlineMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    TextField("Any special requests or dietary restrictions?", text: $specialRequests, axis: .vertical)
                        .lineLimit(3...5)
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textPrimary)
                        .padding(Theme.Spacing.md)
                        .background(Color.cardBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                }
                .padding(.horizontal, Theme.Spacing.lg)

                // Pricing summary
                PricingSummary(tableType: selectedTableType, guestCount: guestCount)

                // Submit button
                Button(action: {
                    submitBooking()
                }) {
                    Text("Confirm Reservation")
                        .font(Typography.button)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.primaryGradient)
                        .cornerRadius(Theme.CornerRadius.lg)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, Theme.Spacing.lg)

                // Info note
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)

                    Text("Reservations are confirmed within 24 hours")
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Color.appBackground)
        .alert("Reservation Confirmed", isPresented: $showingConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your reservation for \(guestCount) guests on \(formattedDate) has been submitted. You'll receive a confirmation shortly.")
        }
        .sheet(isPresented: $showPaymentSheet) {
            PaymentSheet(
                booking: BookingDetails(
                    venueId: venue.id,
                    venueName: venue.name,
                    tableType: selectedTableType,
                    partySize: guestCount,
                    date: selectedDate,
                    timeSlot: timeSlotRange,
                    specialRequests: specialRequests.isEmpty ? nil : specialRequests,
                    totalCost: selectedTableType.basePrice,
                    pointsCost: selectedTableType.pointsCost,
                    userPoints: userPoints
                ),
                userId: authViewModel.authState.user?.id ?? UUID()
            )
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: selectedDate)
    }

    private func submitBooking() {
        // Verify user is authenticated
        guard let userId = authViewModel.authState.user?.id else {
            print("❌ [VenueBooking] Cannot submit booking - user not authenticated!")
            // In production, show an alert to the user
            return
        }

        print("👤 [VenueBooking] Submitting booking for user: \(userId)")

        // Show payment sheet
        showPaymentSheet = true
    }
}

// MARK: - Table Type Selector
private struct TableTypeSelector: View {
    @Binding var selectedType: TableType

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Table Type")
                .font(Typography.headlineMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Theme.Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    TableTypeCard(
                        type: .standard,
                        isSelected: selectedType == .standard,
                        onSelect: { selectedType = .standard }
                    )

                    TableTypeCard(
                        type: .vip,
                        isSelected: selectedType == .vip,
                        onSelect: { selectedType = .vip }
                    )

                    TableTypeCard(
                        type: .premium,
                        isSelected: selectedType == .premium,
                        onSelect: { selectedType = .premium }
                    )
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
    }
}

private struct TableTypeCard: View {
    let type: TableType
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                // Icon & name
                HStack {
                    Image(systemName: type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .primary)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }

                Text(type.displayName)
                    .font(Typography.headlineMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .textPrimary)

                Text(type.description)
                    .font(Typography.captionMedium)
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .textSecondary)
                    .lineLimit(2)

                Spacer()

                // Pricing
                Text("€\(type.minimumSpend) min spend")
                    .font(Typography.labelMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 160, height: 180)
            .padding(Theme.Spacing.md)
            .background {
                if isSelected {
                    Color.primaryGradient
                } else {
                    Color.cardBackground
                }
            }
            .cornerRadius(Theme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(isSelected ? Color.clear : Color.textTertiary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Pricing Summary
private struct PricingSummary: View {
    let tableType: TableType
    let guestCount: Int

    private var estimatedTotal: Int {
        tableType.minimumSpend
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Pricing Summary")
                    .font(Typography.headlineMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Spacer()
            }

            VStack(spacing: Theme.Spacing.sm) {
                HStack {
                    Text("\(tableType.displayName) Table")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)

                    Spacer()

                    Text("€\(tableType.minimumSpend)")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textPrimary)
                }

                HStack {
                    Text("Guests")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)

                    Spacer()

                    Text("\(guestCount)")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textPrimary)
                }

                Divider()
                    .background(Color.textTertiary.opacity(0.2))

                HStack {
                    Text("Minimum Spend")
                        .font(Typography.headlineMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Text("€\(estimatedTotal)")
                        .font(Typography.headlineMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Color.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

// MARK: - Preview
#Preview("Venue Booking Tab") {
    VenueBookingTab(venue: Venue.mockDasWohnzimmer())
}
