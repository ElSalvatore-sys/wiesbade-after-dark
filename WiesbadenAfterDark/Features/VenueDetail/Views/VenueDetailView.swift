//
//  VenueDetailView.swift
//  WiesbadenAfterDark
//
//  Main venue detail page with 5 tabs
//

import SwiftUI

/// Main venue detail view with tabs
struct VenueDetailView: View {
    @Environment(VenueViewModel.self) private var viewModel
    @Environment(AuthenticationViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    let venue: Venue

    @State private var selectedTab = 0

    private let tabs = ["Overview", "Events", "Booking", "Community", "Rewards"]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Hero header
                VenueHeader(venue: venue, onBack: { dismiss() })

                // Tab picker
                TabPicker(tabs: tabs, selectedTab: $selectedTab)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)

                // Tab content
                TabView(selection: $selectedTab) {
                    VenueOverviewTab(venue: venue)
                        .tag(0)

                    VenueEventsTab(venue: venue)
                        .tag(1)

                    VenueBookingTab(venue: venue)
                        .tag(2)

                    VenueCommunityTab(venue: venue)
                        .tag(3)

                    VenueRewardsTab(venue: venue)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .navigationBarHidden(true)
        .task {
            // Load venue details when view appears
            if let userId = authViewModel.authState.user?.id {
                await viewModel.fetchMembership(userId: userId, venueId: venue.id)
            }
        }
    }
}

// MARK: - Venue Header
private struct VenueHeader: View {
    let venue: Venue
    let onBack: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Cover image
            if let imageURL = venue.coverImageURL {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.cardBackground)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.cardBackground)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 250)
                .clipped()
            }

            // Gradient overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.3),
                    Color.clear
                ],
                startPoint: .bottom,
                endPoint: .center
            )
            .frame(height: 250)

            // Content overlay
            VStack(alignment: .leading) {
                Spacer()

                // Venue name & type
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text(venue.name)
                        .font(Typography.displayMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    HStack {
                        VenueTypeBadge(type: venue.type)

                        // Open/Closed badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(venue.isOpenNow ? Color.success : Color.error)
                                .frame(width: 8, height: 8)
                            Text(venue.isOpenNow ? "Open Now" : (venue.nextOpeningInfo ?? "Closed"))
                                .font(Typography.labelMedium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(Theme.CornerRadius.pill)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.md)
            }
            .frame(height: 250)

            // Back button
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
            .padding(Theme.Spacing.md)
        }

        // Quick stats bar
        HStack(spacing: Theme.Spacing.lg) {
            StatItem(icon: "person.2.fill", value: "\(venue.memberCount)", label: "Members")
            StatItem(icon: "clock.fill", value: venue.isOpenNow ? "Open" : "Closed", label: venue.nextOpeningInfo ?? "")
            StatItem(icon: "star.fill", value: venue.formattedRating, label: "Rating")
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .background(Color.cardBackground)
    }
}

private struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(Typography.labelMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                if !label.isEmpty {
                    Text(label)
                        .font(Typography.captionSmall)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
}

// MARK: - Tab Picker
private struct TabPicker: View {
    let tabs: [String]
    @Binding var selectedTab: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.md) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    TabButton(title: tab, isSelected: selectedTab == index) {
                        withAnimation {
                            selectedTab = index
                        }
                    }
                }
            }
        }
    }
}

private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(Typography.headlineSmall)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .textPrimary : .textSecondary)

                if isSelected {
                    Rectangle()
                        .fill(Color.primaryGradient)
                        .frame(height: 3)
                        .cornerRadius(1.5)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 3)
                }
            }
        }
        .animation(Theme.Animation.quick, value: isSelected)
    }
}

// MARK: - Preview
#Preview("Venue Detail") {
    VenueDetailView(venue: Venue.mockDasWohnzimmer())
        .environment(VenueViewModel())
        .environment(AuthenticationViewModel())
}
