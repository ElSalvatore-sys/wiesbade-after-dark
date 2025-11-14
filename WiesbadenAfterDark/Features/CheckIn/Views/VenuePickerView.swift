import SwiftUI
import SwiftData

struct VenuePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let venues: [Venue]
    let userMemberships: [VenueMembership]
    let userId: UUID
    let onSelect: (Venue, VenueMembership) -> Void

    @State private var searchText = ""
    @State private var sortOption: SortOption = .recent

    enum SortOption: String, CaseIterable {
        case recent = "Recent"
        case name = "Name"
        case distance = "Distance"

        var icon: String {
            switch self {
            case .recent: return "clock"
            case .name: return "textformat.abc"
            case .distance: return "location"
            }
        }
    }

    private var filteredVenues: [Venue] {
        let venuesWithMemberships = venues.filter { venue in
            userMemberships.contains { $0.venueId == venue.id }
        }

        let filtered = searchText.isEmpty ? venuesWithMemberships : venuesWithMemberships.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }

        return sortedVenues(filtered)
    }

    private func sortedVenues(_ venues: [Venue]) -> [Venue] {
        switch sortOption {
        case .recent:
            // Sort by most recent check-in (would need check-in data)
            return venues.sorted { $0.name < $1.name }
        case .name:
            return venues.sorted { $0.name < $1.name }
        case .distance:
            // Sort by distance (would need location data)
            return venues.sorted { $0.name < $1.name }
        }
    }

    private func membership(for venue: Venue) -> VenueMembership? {
        userMemberships.first { $0.venueId == venue.id }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sort Options
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                withAnimation {
                                    sortOption = option
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: option.icon)
                                        .font(.system(size: 14))
                                    Text(option.rawValue)
                                        .font(Typography.bodySmall)
                                }
                                .foregroundColor(sortOption == option ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(sortOption == option ? Color.purple : Color.gray.opacity(0.15))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(uiColor: .systemBackground))

                Divider()

                // Venues List
                if filteredVenues.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Venues Available" : "No Results",
                        systemImage: searchText.isEmpty ? "building.2" : "magnifyingglass",
                        description: Text(searchText.isEmpty
                            ? "You don't have any venue memberships yet. Visit venues to join and start earning points!"
                            : "No venues match '\(searchText)'")
                    )
                } else {
                    List {
                        ForEach(filteredVenues) { venue in
                            if let membership = membership(for: venue) {
                                VenuePickerRow(
                                    venue: venue,
                                    membership: membership,
                                    onTap: {
                                        onSelect(venue, membership)
                                        dismiss()
                                    }
                                )
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Select Venue")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search venues...")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct VenuePickerRow: View {
    let venue: Venue
    let membership: VenueMembership
    let onTap: () -> Void

    private var tierColor: Color {
        switch membership.tier {
        case .bronze: return .orange
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .purple
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Venue Icon
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: venueIcon(for: venue.type))
                        .font(.system(size: 24))
                        .foregroundColor(.purple)
                }

                VStack(alignment: .leading, spacing: 6) {
                    // Venue Name
                    Text(venue.name)
                        .font(Typography.headlineSmall)
                        .foregroundColor(.primary)

                    // Tier Badge
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                            Text(membership.tier.rawValue.capitalized)
                                .font(Typography.captionSmall)
                        }
                        .foregroundColor(tierColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tierColor.opacity(0.15))
                        .cornerRadius(6)

                        // Points
                        Text("\(membership.pointsBalance) pts")
                            .font(Typography.captionSmall)
                            .foregroundColor(.secondary)
                    }

                    // Location/Category
                    HStack(spacing: 8) {
                        Image(systemName: "building.2")
                            .font(.system(size: 12))
                        Text(venue.type.rawValue.capitalized)
                            .font(Typography.captionSmall)
                    }
                    .foregroundColor(.secondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private func venueIcon(for type: VenueType) -> String {
        switch type {
        case .club: return "speaker.wave.3"
        case .bar: return "wineglass"
        case .restaurant: return "fork.knife"
        case .barRestaurantClub: return "fork.knife.circle"
        case .lounge: return "moon.stars"
        case .hotel: return "building.2"
        }
    }
}

#Preview {
    VenuePickerView(
        venues: [],
        userMemberships: [],
        userId: UUID(),
        onSelect: { _, _ in }
    )
}
