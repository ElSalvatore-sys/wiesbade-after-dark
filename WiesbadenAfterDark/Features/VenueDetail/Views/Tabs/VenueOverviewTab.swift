//
//  VenueOverviewTab.swift
//  WiesbadenAfterDark
//
//  Overview tab showing venue details, hours, location, and contact
//

import SwiftUI
import MapKit

/// Overview tab with venue information
struct VenueOverviewTab: View {
    let venue: Venue

    @State private var venueSpecialOffers: [Product] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                // About section
                AboutSection(venue: venue)

                Divider()
                    .background(Color.textTertiary.opacity(0.2))
                    .padding(.horizontal, Theme.Spacing.lg)

                // Special Offers Section (if available)
                if !venueSpecialOffers.isEmpty {
                    SpecialOffersSection(offers: venueSpecialOffers, venue: venue)

                    Divider()
                        .background(Color.textTertiary.opacity(0.2))
                        .padding(.horizontal, Theme.Spacing.lg)
                }

                // Opening hours
                OpeningHoursSection(venue: venue)

                Divider()
                    .background(Color.textTertiary.opacity(0.2))
                    .padding(.horizontal, Theme.Spacing.lg)

                // Location
                LocationSection(venue: venue)

                Divider()
                    .background(Color.textTertiary.opacity(0.2))
                    .padding(.horizontal, Theme.Spacing.lg)

                // Contact info
                ContactSection(venue: venue)

                Divider()
                    .background(Color.textTertiary.opacity(0.2))
                    .padding(.horizontal, Theme.Spacing.lg)

                // Stats grid
                StatsSection(venue: venue)
            }
            .padding(.vertical, Theme.Spacing.lg)
        }
        .background(Color.appBackground)
        .task {
            await loadVenueOffers()
        }
    }

    // MARK: - Data Loading

    private func loadVenueOffers() async {
        // Fetch products for this specific venue with active bonuses
        let allProducts = Product.mockProductsForVenue(venue.id)
        venueSpecialOffers = allProducts.filter { $0.bonusPointsActive && $0.isBonusActive }
    }
}

// MARK: - About Section
private struct AboutSection: View {
    let venue: Venue

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("About")
                .font(Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            Text(venue.venueDescription)
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

// MARK: - Special Offers Section
private struct SpecialOffersSection: View {
    let offers: [Product]
    let venue: Venue

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Special Offers")
                .font(Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Theme.Spacing.lg)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(offers, id: \.id) { offer in
                        InventoryOfferCard(
                            product: offer,
                            venue: venue,
                            multiplier: offer.bonusMultiplier,
                            expiresAt: offer.bonusEndDate
                        )
                        .padding(.horizontal, Theme.Spacing.lg)
                    }
                }
            }
            .frame(maxHeight: 400)
        }
    }
}

// MARK: - Opening Hours Section
private struct OpeningHoursSection: View {
    let venue: Venue

    private let daysOrder = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    private let daysDisplay = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    private var currentDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date()).lowercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Opening Hours")
                    .font(Typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Spacer()

                // Open/Closed indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(venue.isOpenNow ? Color.success : Color.error)
                        .frame(width: 8, height: 8)
                    Text(venue.isOpenNow ? "Open Now" : "Closed")
                        .font(Typography.labelMedium)
                        .foregroundColor(venue.isOpenNow ? .success : .error)
                }
            }

            VStack(spacing: Theme.Spacing.sm) {
                ForEach(Array(daysOrder.enumerated()), id: \.offset) { index, day in
                    let isToday = day == currentDay

                    HStack {
                        Text(daysDisplay[index])
                            .font(Typography.bodyMedium)
                            .fontWeight(isToday ? .semibold : .regular)
                            .foregroundColor(isToday ? .textPrimary : .textSecondary)

                        Spacer()

                        if let hours = venue.openingHours[day] {
                            Text(hours)
                                .font(Typography.bodyMedium)
                                .fontWeight(isToday ? .semibold : .regular)
                                .foregroundColor(isToday ? .textPrimary : .textSecondary)
                        } else {
                            Text("Closed")
                                .font(Typography.bodyMedium)
                                .foregroundColor(.textTertiary)
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, Theme.Spacing.md)
                    .background(isToday ? Color.primaryGradientStart.opacity(0.1) : Color.clear)
                    .cornerRadius(Theme.CornerRadius.sm)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

// MARK: - Location Section
private struct LocationSection: View {
    let venue: Venue

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Location")
                .font(Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            // Address
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: Theme.Spacing.md) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(venue.address)
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)

                        Text("\(venue.postalCode) \(venue.city)")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            // Map placeholder
            ZStack {
                Rectangle()
                    .fill(Color.cardBackground)
                    .frame(height: 180)
                    .cornerRadius(Theme.CornerRadius.lg)

                VStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.textTertiary)

                    Text("Map View")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)

                    Button(action: {
                        openInMaps()
                    }) {
                        Text("Open in Maps")
                            .font(Typography.labelMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, 8)
                            .background(Color.primaryGradient.opacity(0.1))
                            .cornerRadius(Theme.CornerRadius.md)
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private func openInMaps() {
        let address = "\(venue.address), \(venue.postalCode) \(venue.city)"
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(encodedAddress)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let webUrl = URL(string: "https://maps.apple.com/?q=\(encodedAddress)") {
                UIApplication.shared.open(webUrl)
            }
        }
    }
}

// MARK: - Contact Section
private struct ContactSection: View {
    let venue: Venue

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Contact")
                .font(Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            VStack(spacing: Theme.Spacing.sm) {
                // Phone
                if let phone = venue.phone {
                    ContactRow(icon: "phone.fill", label: "Phone", value: phone) {
                        if let url = URL(string: "tel://\(phone.filter { $0.isNumber })") {
                            UIApplication.shared.open(url)
                        }
                    }
                }

                // Website
                if let website = venue.website {
                    ContactRow(icon: "globe", label: "Website", value: website) {
                        if let url = URL(string: website.hasPrefix("http") ? website : "https://\(website)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }

                // Instagram
                if let instagram = venue.instagram {
                    ContactRow(icon: "camera.fill", label: "Instagram", value: "@\(instagram)") {
                        if let url = URL(string: "instagram://user?username=\(instagram)") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else if let webUrl = URL(string: "https://instagram.com/\(instagram)") {
                                UIApplication.shared.open(webUrl)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

private struct ContactRow: View {
    let icon: String
    let label: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(Typography.captionMedium)
                        .foregroundColor(.textSecondary)

                    Text(value)
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textTertiary)
            }
            .padding(Theme.Spacing.md)
            .background(Color.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
        }
    }
}

// MARK: - Stats Section
private struct StatsSection: View {
    let venue: Venue

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Quick Stats")
                .font(Typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                StatCard(
                    icon: "calendar",
                    value: "\(venue.totalEvents)",
                    label: "Events",
                    color: .blue
                )

                StatCard(
                    icon: "person.2.fill",
                    value: "\(venue.memberCount)",
                    label: "Members",
                    color: .purple
                )

                StatCard(
                    icon: "star.fill",
                    value: venue.formattedRating,
                    label: "Rating",
                    color: .gold
                )
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

private struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(Typography.titleMedium)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Text(label)
                .font(Typography.captionMedium)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.lg)
    }
}

// MARK: - Preview
#Preview("Venue Overview Tab") {
    VenueOverviewTab(venue: Venue.mockDasWohnzimmer())
}
