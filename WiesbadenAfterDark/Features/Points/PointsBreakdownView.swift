//
//  PointsBreakdownView.swift
//  WiesbadenAfterDark
//
//  Created by Claude Code on 2025-11-13.
//

import SwiftUI
import Charts

// MARK: - Points Breakdown Data Models

struct PointsByCategory: Identifiable {
    let id = UUID()
    let category: String
    let points: Int
    let color: Color

    var percentage: Double = 0.0
}

struct PointsByVenue: Identifiable {
    let id = UUID()
    let venueName: String
    let totalPoints: Int
    let checkInCount: Int
    let lastVisit: Date

    var formattedLastVisit: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: lastVisit, relativeTo: Date())
    }
}

struct PointsTimeline: Identifiable {
    let id = UUID()
    let date: Date
    let points: Int
    let source: String

    var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

struct ReferralEarning: Identifiable {
    let id = UUID()
    let referredUserName: String
    let pointsEarned: Int
    let status: ReferralStatus
    let earnedDate: Date

    enum ReferralStatus {
        case pending, completed, expired

        var displayText: String {
            switch self {
            case .pending: return "Pending"
            case .completed: return "Completed"
            case .expired: return "Expired"
            }
        }

        var color: Color {
            switch self {
            case .pending: return .warning
            case .completed: return Color.success
            case .expired: return .textTertiary
            }
        }
    }
}

// MARK: - Points Breakdown View Model
@Observable @MainActor
final class PointsBreakdownViewModel {
    var selectedTimeframe: Timeframe = .month
    var isLoading: Bool = false

    // Mock data - In production, fetch from PointTransaction and CheckIn models
    var categoryBreakdown: [PointsByCategory] {
        let data = [
            PointsByCategory(category: "Check-ins", points: 2450, color: .primary),
            PointsByCategory(category: "Streaks", points: 1200, color: Color.success),
            PointsByCategory(category: "Events", points: 800, color: Color.info),
            PointsByCategory(category: "Referrals", points: 500, color: .warning),
            PointsByCategory(category: "Bonuses", points: 350, color: .primaryGradientEnd)
        ]

        let total = data.reduce(0) { $0 + $1.points }
        return data.map { item in
            var updated = item
            updated.percentage = Double(item.points) / Double(total) * 100
            return updated
        }
    }

    var venueBreakdown: [PointsByVenue] {
        [
            PointsByVenue(
                venueName: "Apollo Club",
                totalPoints: 1850,
                checkInCount: 12,
                lastVisit: Date().addingTimeInterval(-86400 * 2)
            ),
            PointsByVenue(
                venueName: "Kesselhaus",
                totalPoints: 1200,
                checkInCount: 8,
                lastVisit: Date().addingTimeInterval(-86400 * 5)
            ),
            PointsByVenue(
                venueName: "Mauritius Bar",
                totalPoints: 950,
                checkInCount: 10,
                lastVisit: Date().addingTimeInterval(-86400 * 7)
            ),
            PointsByVenue(
                venueName: "Kurhaus",
                totalPoints: 600,
                checkInCount: 4,
                lastVisit: Date().addingTimeInterval(-86400 * 14)
            ),
            PointsByVenue(
                venueName: "Brauhaus",
                totalPoints: 450,
                checkInCount: 6,
                lastVisit: Date().addingTimeInterval(-86400 * 21)
            )
        ]
    }

    var timeline: [PointsTimeline] {
        // Generate last 6 months of data
        (0..<6).reversed().map { monthsAgo in
            let date = Calendar.current.date(byAdding: .month, value: -monthsAgo, to: Date())!
            let points = Int.random(in: 400...1200)
            return PointsTimeline(date: date, points: points, source: "Multiple")
        }
    }

    var referralEarnings: [ReferralEarning] {
        [
            ReferralEarning(
                referredUserName: "Max M.",
                pointsEarned: 200,
                status: .completed,
                earnedDate: Date().addingTimeInterval(-86400 * 10)
            ),
            ReferralEarning(
                referredUserName: "Sarah K.",
                pointsEarned: 200,
                status: .completed,
                earnedDate: Date().addingTimeInterval(-86400 * 25)
            ),
            ReferralEarning(
                referredUserName: "Lucas B.",
                pointsEarned: 100,
                status: .pending,
                earnedDate: Date().addingTimeInterval(-86400 * 3)
            )
        ]
    }

    var totalPoints: Int {
        categoryBreakdown.reduce(0) { $0 + $1.points }
    }

    var totalReferralPoints: Int {
        referralEarnings.filter { $0.status == .completed }.reduce(0) { $0 + $1.pointsEarned }
    }

    enum Timeframe: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case allTime = "All Time"

        var id: String { rawValue }
    }
}

// MARK: - Points Breakdown View
struct PointsBreakdownView: View {
    @State private var viewModel = PointsBreakdownViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Header with Timeframe Selector
                headerSection

                // Summary Card
                summaryCard

                // Category Pie Chart
                categoryChartCard

                // Timeline Chart
                timelineChartCard

                // Venues Breakdown
                venuesBreakdownCard

                // Referral Earnings
                referralEarningsCard

                Spacer(minLength: Theme.Spacing.xl)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.lg)
        }
        .darkBackground()
        .navigationTitle("Points Breakdown")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Timeframe Picker
            Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
                ForEach(PointsBreakdownViewModel.Timeframe.allCases) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Points Earned")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(.secondary)

                    Text("\(viewModel.totalPoints)")
                        .font(Typography.displayMedium)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primaryGradientStart, .primaryGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Equivalent Value")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(.secondary)

                    let euroValue = Decimal(viewModel.totalPoints) / 10
                    Text("€\(String(format: "%.2f", NSDecimalNumber(decimal: euroValue).doubleValue))")
                        .font(Typography.titleLarge)
                        .foregroundStyle(Color.success)
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .cardStyle()
    }

    // MARK: - Category Chart Card
    private var categoryChartCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Points by Category", systemImage: "chart.pie.fill")
                .font(Typography.headlineMedium)
                .foregroundStyle(.primary)

            // Pie Chart
            Chart(viewModel.categoryBreakdown) { item in
                SectorMark(
                    angle: .value("Points", item.points),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }
            .frame(height: 200)

            // Legend
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(viewModel.categoryBreakdown) { item in
                    HStack(spacing: Theme.Spacing.sm) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)

                        Text(item.category)
                            .font(Typography.bodyMedium)
                            .foregroundStyle(.primary)

                        Spacer()

                        Text("\(item.points) pts")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(.secondary)

                        Text("(\(String(format: "%.1f", item.percentage))%)")
                            .font(Typography.bodySmall)
                            .foregroundStyle(Color.gray.opacity(0.6))
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Timeline Chart Card
    private var timelineChartCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Points Over Time", systemImage: "chart.line.uptrend.xyaxis")
                .font(Typography.headlineMedium)
                .foregroundStyle(.primary)

            // Line Chart
            Chart(viewModel.timeline) { item in
                LineMark(
                    x: .value("Month", item.monthYear),
                    y: .value("Points", item.points)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primaryGradientStart, .primaryGradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                AreaMark(
                    x: .value("Month", item.monthYear),
                    y: .value("Points", item.points)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .primary.opacity(0.3),
                            .primaryGradientEnd.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                PointMark(
                    x: .value("Month", item.monthYear),
                    y: .value("Points", item.points)
                )
                .foregroundStyle(.primary)
                .symbolSize(60)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 200)

            // Average Info
            let avgPoints = viewModel.timeline.reduce(0) { $0 + $1.points } / viewModel.timeline.count
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.info)

                Text("Average: \(avgPoints) points/month")
                    .font(Typography.bodySmall)
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }

    // MARK: - Venues Breakdown Card
    private var venuesBreakdownCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Points by Venue", systemImage: "building.2.fill")
                .font(Typography.headlineMedium)
                .foregroundStyle(.primary)

            VStack(spacing: Theme.Spacing.sm) {
                ForEach(viewModel.venueBreakdown) { venue in
                    venueRow(venue)
                }
            }
        }
        .cardStyle()
    }

    private func venueRow(_ venue: PointsByVenue) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            // Venue Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.primary.opacity(0.2), .primaryGradientEnd.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: "building.2.fill")
                    .foregroundStyle(.primary)
                    .font(.title3)
            }

            // Venue Info
            VStack(alignment: .leading, spacing: 4) {
                Text(venue.venueName)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(.primary)

                HStack(spacing: Theme.Spacing.xs) {
                    Text("\(venue.checkInCount) check-ins")
                        .font(Typography.bodySmall)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(Color.gray.opacity(0.6))

                    Text(venue.formattedLastVisit)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Color.gray.opacity(0.6))
                }
            }

            Spacer()

            // Points
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(venue.totalPoints)")
                    .font(Typography.headlineMedium)
                    .foregroundStyle(.primary)

                Text("points")
                    .font(Typography.bodySmall)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
    }

    // MARK: - Referral Earnings Card
    private var referralEarningsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Label("Referral Earnings", systemImage: "person.2.fill")
                    .font(Typography.headlineMedium)
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(viewModel.totalReferralPoints) pts")
                    .font(Typography.headlineMedium)
                    .foregroundStyle(Color.success)
            }

            if viewModel.referralEarnings.isEmpty {
                // Empty State
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "person.2.badge.gearshape")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.gray.opacity(0.6))

                    Text("No referrals yet")
                        .font(Typography.bodyLarge)
                        .foregroundStyle(.secondary)

                    Text("Invite friends to earn bonus points")
                        .font(Typography.bodySmall)
                        .foregroundStyle(Color.gray.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.xl)
            } else {
                VStack(spacing: Theme.Spacing.sm) {
                    ForEach(viewModel.referralEarnings) { referral in
                        referralRow(referral)
                    }
                }
            }
        }
        .cardStyle()
    }

    private func referralRow(_ referral: ReferralEarning) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(referral.status.color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Text(referral.referredUserName.prefix(1))
                    .font(Typography.headlineMedium)
                    .foregroundStyle(referral.status.color)
            }

            // Referral Info
            VStack(alignment: .leading, spacing: 4) {
                Text(referral.referredUserName)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(.primary)

                Text(referral.status.displayText)
                    .font(Typography.bodySmall)
                    .foregroundStyle(referral.status.color)
            }

            Spacer()

            // Points
            Text("+\(referral.pointsEarned)")
                .font(Typography.headlineMedium)
                .foregroundStyle(
                    referral.status == .completed ? Color.success : .textTertiary
                )
        }
        .padding(Theme.Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PointsBreakdownView()
    }
}
