//
//  CheckInCard.swift
//  WiesbadenAfterDark
//
//  Check-in history card component (compact & full modes)
//

import SwiftUI

/// Display mode for check-in card
enum CheckInCardMode {
    case compact // For lists
    case full // For detail view
}

/// Check-in history card component
struct CheckInCard: View {
    // MARK: - Properties

    let checkIn: CheckIn
    var mode: CheckInCardMode = .compact

    // MARK: - Computed Properties

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: checkIn.checkInTime, relativeTo: Date())
    }

    private var methodColor: Color {
        switch checkIn.checkInMethod {
        case .nfc:
            return Color.primary
        case .qr:
            return Color.secondary
        case .manual:
            return Color.gray
        }
    }

    private var methodIcon: String {
        switch checkIn.checkInMethod {
        case .nfc:
            return "wave.3.right.circle.fill"
        case .qr:
            return "qrcode"
        case .manual:
            return "hand.tap.fill"
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: mode == .compact ? 12 : 16) {
            // Header Row
            HStack(alignment: .top, spacing: 12) {
                // Venue Icon
                ZStack {
                    Circle()
                        .fill(Color.primaryGradient)
                        .frame(width: mode == .compact ? 48 : 56, height: mode == .compact ? 48 : 56)

                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: mode == .compact ? 24 : 28))
                        .foregroundStyle(.white)
                }

                // Venue Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(checkIn.venueName)
                        .font(mode == .compact ? .headline : .title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)

                    HStack(spacing: 8) {
                        // Time Ago
                        Text(timeAgo)
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)

                        // Method Badge
                        HStack(spacing: 4) {
                            Image(systemName: methodIcon)
                                .font(.caption2)
                            Text(checkIn.checkInMethod.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(methodColor)
                        .clipShape(Capsule())
                    }
                }

                Spacer()

                // Points Badge
                VStack(spacing: 2) {
                    Text("+\(checkIn.pointsEarned)")
                        .font(mode == .compact ? .title3 : .title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)

                    Text("points")
                        .font(.caption2)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            // Streak Badge (if applicable)
            if checkIn.isStreakBonus {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)

                    Text("Day \(checkIn.streakDay) Streak")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)

                    Text("×\(String(format: "%.1f", NSDecimalNumber(decimal: checkIn.streakMultiplier).doubleValue))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }

            // Points Breakdown (full mode only)
            if mode == .full {
                Divider()

                VStack(spacing: 8) {
                    // Base Points
                    pointBreakdownRow(
                        label: "Base Points",
                        value: "\(checkIn.basePoints)",
                        showPlus: false
                    )

                    // Multipliers
                    if checkIn.pointsMultiplier > 1.0 || checkIn.isStreakBonus {
                        if checkIn.pointsMultiplier > 1.0 {
                            pointBreakdownRow(
                                label: "Event/Weekend Bonus",
                                value: "×\(String(format: "%.1f", NSDecimalNumber(decimal: checkIn.pointsMultiplier).doubleValue))",
                                showPlus: false,
                                color: Color.primary
                            )
                        }

                        if checkIn.isStreakBonus {
                            pointBreakdownRow(
                                label: "Streak Bonus (Day \(checkIn.streakDay))",
                                value: "×\(String(format: "%.1f", NSDecimalNumber(decimal: checkIn.streakMultiplier).doubleValue))",
                                showPlus: false,
                                color: .orange
                            )
                        }
                    }

                    Divider()

                    // Total
                    pointBreakdownRow(
                        label: "Total Earned",
                        value: "\(checkIn.pointsEarned)",
                        showPlus: true,
                        isBold: true,
                        color: Color.primary
                    )
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cardBackground.opacity(0.5))
                )
            }
        }
        .padding(mode == .compact ? 16 : 20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Theme.Shadow.sm.color, radius: Theme.Shadow.sm.radius, x: Theme.Shadow.sm.x, y: Theme.Shadow.sm.y)
    }

    // MARK: - Helper Views

    private func pointBreakdownRow(
        label: String,
        value: String,
        showPlus: Bool = false,
        isBold: Bool = false,
        color: Color = Color.primary
    ) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(showPlus ? "+\(value)" : value)
                .font(.subheadline)
                .fontWeight(isBold ? .bold : .medium)
                .foregroundStyle(color)
        }
    }
}

// MARK: - Preview

#Preview("Compact Mode") {
    VStack(spacing: 16) {
        // Regular Check-in
        CheckInCard(
            checkIn: CheckIn.mock(),
            mode: .compact
        )

        // Streak Check-in
        CheckInCard(
            checkIn: CheckIn(
                userId: UUID(),
                venueId: UUID(),
                venueName: "Das Loft",
                checkInTime: Date().addingTimeInterval(-3600), // 1 hour ago
                checkInMethod: .nfc,
                pointsEarned: 125,
                basePoints: 50,
                pointsMultiplier: 1.0,
                eventId: nil,
                streakDay: 3,
                isStreakBonus: true,
                streakMultiplier: 1.5
            ),
            mode: .compact
        )

        // QR Code Check-in
        CheckInCard(
            checkIn: CheckIn(
                userId: UUID(),
                venueId: UUID(),
                venueName: "Nacht & Nebel",
                checkInTime: Date().addingTimeInterval(-86400), // 1 day ago
                checkInMethod: .qr,
                pointsEarned: 60,
                basePoints: 50,
                pointsMultiplier: 1.2,
                eventId: nil,
                streakDay: 1,
                isStreakBonus: false,
                streakMultiplier: 1.0
            ),
            mode: .compact
        )
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Full Mode") {
    ScrollView {
        VStack(spacing: 16) {
            // Regular Check-in
            CheckInCard(
                checkIn: CheckIn.mock(),
                mode: .full
            )

            // Streak Check-in with Event
            CheckInCard(
                checkIn: CheckIn(
                    userId: UUID(),
                    venueId: UUID(),
                    venueName: "Das Loft",
                    checkInTime: Date().addingTimeInterval(-3600),
                    checkInMethod: .nfc,
                    pointsEarned: 180,
                    basePoints: 50,
                    pointsMultiplier: 1.44, // 1.2 weekend × 1.2 event
                    eventId: UUID(),
                    streakDay: 5,
                    isStreakBonus: true,
                    streakMultiplier: 2.5
                ),
                mode: .full
            )

            // Manual Check-in
            CheckInCard(
                checkIn: CheckIn(
                    userId: UUID(),
                    venueId: UUID(),
                    venueName: "Kulturzentrum Schlachthof",
                    checkInTime: Date().addingTimeInterval(-172800), // 2 days ago
                    checkInMethod: .manual,
                    pointsEarned: 50,
                    basePoints: 50,
                    pointsMultiplier: 1.0,
                    eventId: nil,
                    streakDay: 1,
                    isStreakBonus: false,
                    streakMultiplier: 1.0
                ),
                mode: .full
            )
        }
        .padding()
    }
    .background(Color.appBackground)
}
