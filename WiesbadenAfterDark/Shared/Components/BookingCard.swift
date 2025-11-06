//
//  BookingCard.swift
//  WiesbadenAfterDark
//
//  Booking display card with compact and full modes
//

import SwiftUI

/// Booking card display mode
enum BookingCardMode {
    case compact // For lists
    case full // For detail view
}

/// Booking card component
struct BookingCard: View {
    // MARK: - Properties

    let booking: Booking
    let venueName: String
    var mode: BookingCardMode = .compact
    var onTap: (() -> Void)?

    // MARK: - Body

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Table Type Icon
                ZStack {
                    Circle()
                        .fill(Color.primaryGradient)
                        .frame(width: mode == .compact ? 50 : 60, height: mode == .compact ? 50 : 60)

                    Image(systemName: booking.tableType.icon)
                        .font(.system(size: mode == .compact ? 24 : 28))
                        .foregroundStyle(.white)
                }

                // Booking Info
                VStack(alignment: .leading, spacing: mode == .compact ? 4 : 8) {
                    // Venue Name
                    Text(venueName)
                        .font(mode == .compact ? .headline : .title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)

                    // Table Type
                    Text(booking.tableType.displayName)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)

                    // Date & Time
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)

                        Text(booking.formattedDate)
                            .font(.caption)

                        Text("•")
                            .font(.caption)

                        Text(booking.timeSlot)
                            .font(.caption)
                    }
                    .foregroundStyle(Color.textSecondary)

                    // Party Size & Status
                    HStack(spacing: 12) {
                        // Party Size
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.caption2)

                            Text("\(booking.partySize) guests")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.textSecondary)

                        // Status Badge
                        StatusBadge(status: booking.status)
                    }

                    // Price (Full mode only)
                    if mode == .full {
                        Divider()
                            .padding(.vertical, 4)

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total")
                                    .font(.caption2)
                                    .foregroundStyle(Color.textSecondary)

                                Text(booking.formattedCost)
                                    .font(.headline)
                                    .foregroundStyle(Color.primary)
                            }

                            Spacer()

                            if let paymentMethod = booking.paymentMethod {
                                HStack(spacing: 4) {
                                    Image(systemName: paymentMethod.icon)
                                        .font(.caption)

                                    Text(paymentMethod.displayName)
                                        .font(.caption)
                                }
                                .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                }

                Spacer()

                // Price (Compact mode)
                if mode == .compact {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(booking.formattedCost)
                            .font(.headline)
                            .foregroundStyle(Color.primary)

                        if booking.paidWithPoints {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)

                                Text("\(booking.pointsUsed ?? 0) pts")
                                    .font(.caption2)
                            }
                            .foregroundStyle(Color.primary)
                        }
                    }
                }
            }
            .padding(mode == .compact ? 16 : 20)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Theme.Shadow.sm.color, radius: Theme.Shadow.sm.radius, x: Theme.Shadow.sm.x, y: Theme.Shadow.sm.y)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(onTap == nil)
    }
}

/// Booking status badge
private struct StatusBadge: View {
    let status: BookingStatus

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)

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
        case .confirmed:
            return .green
        case .pending:
            return .orange
        case .cancelled:
            return .red
        case .completed:
            return .blue
        }
    }
}

// MARK: - Preview

#Preview("Compact") {
    VStack(spacing: 16) {
        BookingCard(
            booking: Booking(
                userId: UUID(),
                venueId: UUID(),
                tableType: .vip,
                partySize: 4,
                bookingDate: Date(),
                timeSlot: "21:00 - 23:00",
                totalCost: 120.00,
                paymentMethod: .card,
                status: .confirmed,
                confirmationCode: "ABC12345"
            ),
            venueName: "Das Loft",
            mode: .compact
        )

        BookingCard(
            booking: Booking(
                userId: UUID(),
                venueId: UUID(),
                tableType: .standard,
                partySize: 2,
                bookingDate: Date().addingTimeInterval(86400),
                timeSlot: "20:00 - 22:00",
                totalCost: 50.00,
                paidWithPoints: true,
                pointsUsed: 1000,
                paymentMethod: .points,
                status: .pending,
                confirmationCode: "XYZ98765"
            ),
            venueName: "Nacht & Nebel",
            mode: .compact
        )
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Full") {
    BookingCard(
        booking: Booking(
            userId: UUID(),
            venueId: UUID(),
            tableType: .premium,
            partySize: 8,
            bookingDate: Date(),
            timeSlot: "22:00 - 02:00",
            totalCost: 200.00,
            paymentMethod: .applePay,
            status: .confirmed,
            confirmationCode: "PRE54321"
        ),
        venueName: "Das Wohnzimmer",
        mode: .full
    )
    .padding()
    .background(Color.appBackground)
}
