//
//  ExpiringPointsAlert.swift
//  WiesbadenAfterDark
//
//  UI component for displaying expiring points warnings
//

import SwiftUI
import SwiftData

// MARK: - Expiring Points Banner

/// Banner view that shows on the home page when points are expiring soon
struct ExpiringPointsBanner: View {
    let expiringMemberships: [VenueMembership]
    let onTap: (VenueMembership) -> Void
    let onDismiss: () -> Void

    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            if expiringMemberships.isEmpty {
                EmptyView()
            } else if expiringMemberships.count == 1 {
                // Single expiring membership
                SingleExpirationBanner(
                    membership: expiringMemberships[0],
                    onTap: { onTap(expiringMemberships[0]) },
                    onDismiss: onDismiss
                )
            } else {
                // Multiple expiring memberships - carousel
                TabView(selection: $currentPage) {
                    ForEach(Array(expiringMemberships.enumerated()), id: \.element.id) { index, membership in
                        SingleExpirationBanner(
                            membership: membership,
                            onTap: { onTap(membership) },
                            onDismiss: onDismiss
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 120)
            }
        }
    }
}

// MARK: - Single Expiration Banner

private struct SingleExpirationBanner: View {
    let membership: VenueMembership
    let onTap: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(urgencyColor.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: urgencyIcon)
                        .font(.system(size: 24))
                        .foregroundColor(urgencyColor)
                }

                // Content
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Points Expiring Soon")
                        .font(Typography.labelLarge)
                        .foregroundColor(.textPrimary)

                    Text(membership.expirationMessage)
                        .font(Typography.bodySmall)
                        .foregroundColor(.textSecondary)

                    Text("Tap to use now")
                        .font(Typography.labelSmall)
                        .foregroundColor(urgencyColor)
                }

                Spacer()

                // Dismiss button
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textTertiary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(urgencyColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .strokeBorder(urgencyColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, Theme.Spacing.md)
        }
        .buttonStyle(.plain)
    }

    private var urgencyColor: Color {
        if membership.isExpiringCritical {
            return .error
        } else if membership.daysUntilExpiry <= 14 {
            return .orange
        } else {
            return .warning
        }
    }

    private var urgencyIcon: String {
        if membership.isExpiringCritical {
            return "exclamationmark.triangle.fill"
        } else {
            return "clock.fill"
        }
    }
}

// MARK: - Expiring Points List

/// Detailed list view showing all expiring points by venue
struct ExpiringPointsList: View {
    @Query private var memberships: [VenueMembership]
    @Environment(\.modelContext) private var modelContext
    @State private var expiringMemberships: [VenueMembership] = []

    var body: some View {
        Group {
            if expiringMemberships.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: Theme.Spacing.md) {
                        ForEach(expiringMemberships) { membership in
                            ExpiringPointsCard(membership: membership)
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
            }
        }
        .navigationTitle("Expiring Points")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            loadExpiringMemberships()
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.success)

            Text("No Expiring Points")
                .font(Typography.titleLarge)
                .foregroundColor(.textPrimary)

            Text("All your points are safe! Keep earning and redeeming to maintain your balance.")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    private func loadExpiringMemberships() {
        // Filter memberships with expiring points
        expiringMemberships = memberships.filter { $0.hasExpiringPoints }
            .sorted { $0.daysUntilExpiry < $1.daysUntilExpiry }
    }
}

// MARK: - Expiring Points Card

struct ExpiringPointsCard: View {
    let membership: VenueMembership
    @State private var showingVenueDetail = false

    var body: some View {
        Button(action: { showingVenueDetail = true }) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Venue Name") // TODO: Fetch venue name
                            .font(Typography.titleSmall)
                            .foregroundColor(.textPrimary)

                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: urgencyIcon)
                                .font(.system(size: 14))
                                .foregroundColor(urgencyColor)

                            Text(membership.expirationMessage)
                                .font(Typography.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    Spacer()

                    // Points badge
                    VStack(spacing: 2) {
                        Text("\(membership.pointsBalance)")
                            .font(Typography.titleMedium)
                            .foregroundColor(urgencyColor)

                        Text("points")
                            .font(Typography.labelSmall)
                            .foregroundColor(.textTertiary)
                    }
                }

                // Progress bar
                expirationProgress

                // Action button
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.white)

                    Text("Use Points Now")
                        .font(Typography.labelMedium)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.sm)
                .background(urgencyColor)
                .cornerRadius(Theme.CornerRadius.sm)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var expirationProgress: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)

                // Progress
                Rectangle()
                    .fill(urgencyColor)
                    .frame(width: progressWidth(in: geometry.size.width), height: 4)
                    .cornerRadius(2)
            }
        }
        .frame(height: 4)
    }

    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        let progress = min(1.0, max(0.0, 1.0 - (Double(membership.daysUntilExpiry) / 30.0)))
        return totalWidth * progress
    }

    private var urgencyColor: Color {
        if membership.isExpiringCritical {
            return .error
        } else if membership.daysUntilExpiry <= 14 {
            return .orange
        } else {
            return .warning
        }
    }

    private var urgencyIcon: String {
        if membership.isExpiringCritical {
            return "exclamationmark.triangle.fill"
        } else {
            return "clock.fill"
        }
    }
}

// MARK: - Expiring Points Alert Sheet

/// Bottom sheet showing expiring points details with actions
struct ExpiringPointsAlertSheet: View {
    let membership: VenueMembership
    let onUseNow: () -> Void
    let onRemindLater: () -> Void
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(urgencyColor.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: urgencyIcon)
                            .font(.system(size: 40))
                            .foregroundColor(urgencyColor)
                    }
                    .padding(.top, Theme.Spacing.lg)

                    // Title & Message
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("Points Expiring Soon!")
                            .font(Typography.titleLarge)
                            .foregroundColor(.textPrimary)

                        Text(membership.expirationMessage)
                            .font(Typography.bodyLarge)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Details card
                    VStack(spacing: Theme.Spacing.md) {
                        detailRow(
                            icon: "mappin.circle.fill",
                            label: "Venue",
                            value: "Venue Name" // TODO: Fetch venue name
                        )

                        Divider()

                        detailRow(
                            icon: "star.fill",
                            label: "Points at Risk",
                            value: "\(membership.pointsBalance) points"
                        )

                        Divider()

                        detailRow(
                            icon: "calendar",
                            label: "Expiration Date",
                            value: formattedDate(membership.calculatedExpirationDate)
                        )

                        Divider()

                        detailRow(
                            icon: "clock.fill",
                            label: "Time Remaining",
                            value: "\(membership.daysUntilExpiry) days"
                        )
                    }
                    .padding(Theme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .fill(Color.cardBackground)
                    )

                    // Info message
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.accent)

                        Text("Points expire after 180 days of inactivity at this venue.")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(Theme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                            .fill(Color.accent.opacity(0.1))
                    )

                    // Actions
                    VStack(spacing: Theme.Spacing.sm) {
                        // Primary action
                        Button(action: {
                            onUseNow()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "gift.fill")
                                Text("Use Points Now")
                                    .font(Typography.labelLarge)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.md)
                            .background(urgencyColor)
                            .foregroundColor(.white)
                            .cornerRadius(Theme.CornerRadius.md)
                        }

                        // Secondary action
                        Button(action: {
                            onRemindLater()
                            dismiss()
                        }) {
                            Text("Remind Me Later")
                                .font(Typography.labelLarge)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Spacing.md)
                                .background(Color.cardBackground)
                                .foregroundColor(.textPrimary)
                                .cornerRadius(Theme.CornerRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                        .strokeBorder(Color.borderPrimary, lineWidth: 1)
                                )
                        }

                        // Tertiary action
                        Button(action: {
                            onDismiss()
                            dismiss()
                        }) {
                            Text("Dismiss")
                                .font(Typography.labelMedium)
                                .foregroundColor(.textTertiary)
                                .padding(.vertical, Theme.Spacing.sm)
                        }
                    }
                }
                .padding(Theme.Spacing.md)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
            }
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accent)
                .frame(width: 24)

            Text(label)
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)

            Spacer()

            Text(value)
                .font(Typography.labelMedium)
                .foregroundColor(.textPrimary)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private var urgencyColor: Color {
        if membership.isExpiringCritical {
            return .error
        } else if membership.daysUntilExpiry <= 14 {
            return .orange
        } else {
            return .warning
        }
    }

    private var urgencyIcon: String {
        if membership.isExpiringCritical {
            return "exclamationmark.triangle.fill"
        } else {
            return "clock.fill"
        }
    }
}

// MARK: - Expiring Points Section (for Profile)

/// Section for profile view showing expiring points summary
struct ExpiringPointsSection: View {
    let userId: UUID

    @Environment(\.modelContext) private var modelContext
    @State private var expiringMemberships: [VenueMembership] = []
    @State private var showingExpiringPointsList = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Expiring Points")
                    .font(Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Spacer()

                if !expiringMemberships.isEmpty {
                    Button(action: { showingExpiringPointsList = true }) {
                        Text("View All")
                            .font(Typography.labelMedium)
                            .foregroundColor(.accent)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)

            if expiringMemberships.isEmpty {
                // Empty state
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.success)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("No Expiring Points")
                            .font(Typography.bodyMedium)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)

                        Text("All your points are safe")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()
                }
                .padding(Theme.Spacing.md)
                .background(Color.success.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.md)
                .padding(.horizontal, Theme.Spacing.lg)
            } else {
                // Expiring points summary
                VStack(spacing: Theme.Spacing.sm) {
                    ForEach(expiringMemberships.prefix(3)) { membership in
                        ExpiringPointsRow(membership: membership)
                    }

                    if expiringMemberships.count > 3 {
                        Button(action: { showingExpiringPointsList = true }) {
                            Text("View \(expiringMemberships.count - 3) more")
                                .font(Typography.labelMedium)
                                .foregroundColor(.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Spacing.sm)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
        .onAppear {
            loadExpiringMemberships()
        }
        .sheet(isPresented: $showingExpiringPointsList) {
            NavigationStack {
                ExpiringPointsList()
            }
        }
    }

    private func loadExpiringMemberships() {
        Task {
            do {
                let fetchDescriptor = FetchDescriptor<VenueMembership>(
                    predicate: #Predicate<VenueMembership> {
                        $0.userId == userId && $0.isActive && $0.pointsBalance > 0
                    }
                )

                let memberships = try modelContext.fetch(fetchDescriptor)

                // Filter to only those expiring soon
                expiringMemberships = memberships.filter { $0.hasExpiringPoints }
                    .sorted { $0.daysUntilExpiry < $1.daysUntilExpiry }
            } catch {
                print("❌ Failed to load expiring memberships: \(error)")
            }
        }
    }
}

// MARK: - Expiring Points Row

private struct ExpiringPointsRow: View {
    let membership: VenueMembership

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Urgency indicator
            Circle()
                .fill(urgencyColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text("Venue Name") // TODO: Fetch venue name
                    .font(Typography.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)

                Text(membership.expirationMessage)
                    .font(Typography.bodySmall)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Text("\(membership.pointsBalance)")
                .font(Typography.labelLarge)
                .fontWeight(.bold)
                .foregroundColor(urgencyColor)
        }
        .padding(Theme.Spacing.md)
        .background(urgencyColor.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.md)
    }

    private var urgencyColor: Color {
        if membership.isExpiringCritical {
            return .error
        } else if membership.daysUntilExpiry <= 14 {
            return .orange
        } else {
            return .warning
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VenueMembership.self, configurations: config)

    let membership = VenueMembership(
        userId: UUID(),
        venueId: UUID(),
        pointsBalance: 450,
        lastActivityDate: Calendar.current.date(byAdding: .day, value: -165, to: Date())!
    )

    return VStack {
        ExpiringPointsBanner(
            expiringMemberships: [membership],
            onTap: { _ in },
            onDismiss: {}
        )
    }
    .padding()
    .background(Color.appBackground)
    .modelContainer(container)
}
