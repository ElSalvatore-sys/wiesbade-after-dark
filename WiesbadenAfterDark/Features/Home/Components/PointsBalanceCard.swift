//
//  PointsBalanceCard.swift
//  WiesbadenAfterDark
//
//  Purpose: Large, prominent display of user's total points balance
//  Shows: Total points, euro value, optional venue breakdown
//

import SwiftUI

/// Giant points balance card with gradient styling
/// - Displays total points in large font
/// - Shows 1:1 euro conversion
/// - Optional breakdown by venue (if multiple memberships)
struct PointsBalanceCard: View {
    // MARK: - Properties

    let totalPoints: Int
    let memberships: [VenueMembership]
    let venues: [Venue]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            // "Your Points" label
            Text("Your Points")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            // HUGE Points Balance
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(totalPoints)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Image(systemName: "star.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.orange)
            }

            // Euro value conversion
            Text("= €\(totalPoints / 10) value")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textSecondary)

            // Venue breakdown (if multiple memberships)
            if memberships.count > 1 {
                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Points by Venue")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)

                    ForEach(memberships.prefix(3), id: \.id) { membership in
                        if let venue = venues.first(where: { $0.id == membership.venueId }) {
                            HStack {
                                Text(venue.name)
                                    .font(.caption)
                                    .foregroundStyle(Color.textPrimary)

                                Spacer()

                                Text("\(membership.pointsBalance) pts")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.12),
                    Color.orange.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.gold.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(
            color: Color.orange.opacity(0.15),
            radius: 20,
            x: 0,
            y: 10
        )
    }
}

// MARK: - Preview

#Preview("Points Balance Card") {
    PointsBalanceCard(
        totalPoints: 450,
        memberships: VenueMembership.mockMemberships,
        venues: Venue.mockVenues
    )
    .padding()
}
