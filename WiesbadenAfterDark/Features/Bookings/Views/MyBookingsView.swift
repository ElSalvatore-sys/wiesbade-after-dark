//
//  MyBookingsView.swift
//  WiesbadenAfterDark
//
//  User's bookings list with upcoming/past tabs
//

import SwiftUI
import SwiftData

/// My bookings view
struct MyBookingsView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(AuthenticationViewModel.self) private var authViewModel
    @Environment(VenueViewModel.self) private var venueViewModel

    // MARK: - Query

    @Query(sort: \Booking.bookingDate, order: .reverse)
    private var allBookings: [Booking]

    // MARK: - State

    @State private var selectedTab: BookingTab = .upcoming
    @State private var selectedBooking: Booking?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Bookings", selection: $selectedTab) {
                    Text("Upcoming").tag(BookingTab.upcoming)
                    Text("Past").tag(BookingTab.past)
                }
                .pickerStyle(.segmented)
                .padding()

                // DEBUG: Show user ID
                if let userId = currentUserId {
                    Text("User ID: \(userId.uuidString)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                } else {
                    Text("❌ NO USER ID")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(.bottom, 4)
                }

                // DEBUG: Show counts
                Text("DB: \(allBookings.count) | Mine: \(userBookings.count) | Showing: \(displayedBookings.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)

                // Bookings List
                if selectedTab == .upcoming {
                    if displayedBookings.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(displayedBookings) { booking in
                                    BookingCard(
                                        booking: booking,
                                        venueName: getVenueName(for: booking.venueId),
                                        mode: .compact,
                                        onTap: {
                                            selectedBooking = booking
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    if displayedBookings.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(displayedBookings) { booking in
                                    BookingCard(
                                        booking: booking,
                                        venueName: getVenueName(for: booking.venueId),
                                        mode: .compact,
                                        onTap: {
                                            selectedBooking = booking
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .background(Color.appBackground)
            .navigationTitle("My Bookings")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedBooking) { booking in
                BookingDetailView(
                    booking: booking,
                    userId: currentUserId ?? UUID()
                )
            }
            .onAppear {
                logBookingsState()
            }
            .onChange(of: allBookings.count) { oldValue, newValue in
                print("📊 [MyBookings] Bookings count changed: \(oldValue) → \(newValue)")
                logBookingsState()
            }
            .onChange(of: selectedTab) { _, _ in
                print("📊 [MyBookings] Tab changed to: \(selectedTab == .upcoming ? "Upcoming" : "Past")")
                logBookingsState()
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedTab == .upcoming ? "calendar.badge.plus" : "clock.badge.checkmark")
                .font(.system(size: 60))
                .foregroundStyle(Color.textSecondary.opacity(0.5))

            VStack(spacing: 8) {
                Text(selectedTab == .upcoming ? "No Upcoming Bookings" : "No Past Bookings")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Text(selectedTab == .upcoming ? "Book a table to see it here" : "Your booking history will appear here")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(60)
    }

    // MARK: - Computed Properties

    private var currentUserId: UUID? {
        // Try to get user from authState
        if case .authenticated(let user) = authViewModel.authState {
            return user.id
        }
        return nil
    }

    private var userBookings: [Booking] {
        guard let userId = currentUserId else {
            print("❌ [MyBookings] No current user ID!")
            return []
        }

        print("🔍 [MyBookings] Filtering \(allBookings.count) bookings for user: \(userId)")

        let filtered = allBookings.filter { booking in
            let matches = booking.userId == userId
            if !matches {
                print("   ❌ Booking \(booking.id) userId \(booking.userId) != \(userId)")
            } else {
                print("   ✅ Booking \(booking.id) matches!")
            }
            return matches
        }

        print("✅ [MyBookings] Found \(filtered.count) bookings for user")
        return filtered
    }

    private var displayedBookings: [Booking] {
        let now = Date()
        let filtered = userBookings.filter { booking in
            switch selectedTab {
            case .upcoming:
                return booking.bookingDate >= now
            case .past:
                return booking.bookingDate < now
            }
        }

        if selectedTab == .upcoming {
            return filtered.sorted { $0.bookingDate < $1.bookingDate }
        } else {
            return filtered.sorted { $0.bookingDate > $1.bookingDate }
        }
    }

    // MARK: - Helper Methods

    private func getVenueName(for venueId: UUID) -> String {
        // Try to get venue from VenueViewModel
        if let venue = venueViewModel.venues.first(where: { $0.id == venueId }) {
            return venue.name
        }
        return "Unknown Venue"
    }

    private func logBookingsState() {
        print("📋 [MyBookings] ========== BOOKINGS STATE ==========")
        print("📋 [MyBookings] Total bookings in DB: \(allBookings.count)")

        if let userId = currentUserId {
            print("📋 [MyBookings] Current user ID: \(userId)")
        } else {
            print("❌ [MyBookings] NO CURRENT USER!")
            print("❌ [MyBookings] Auth state: \(authViewModel.authState)")
        }

        print("📋 [MyBookings] User's bookings: \(userBookings.count)")
        print("📋 [MyBookings] Displayed bookings: \(displayedBookings.count)")
        print("📋 [MyBookings] Selected tab: \(selectedTab == .upcoming ? "Upcoming" : "Past")")

        if !allBookings.isEmpty {
            print("📋 [MyBookings] All bookings in DB:")
            for booking in allBookings {
                let venueName = getVenueName(for: booking.venueId)
                print("   - Booking ID: \(booking.id)")
                print("     User ID: \(booking.userId)")
                print("     Venue: \(venueName)")
                print("     Table: \(booking.tableType.displayName)")
                print("     Date: \(booking.bookingDate.formatted(date: .abbreviated, time: .shortened))")
                print("     Status: \(booking.status.rawValue)")
                print("     Matches current user: \(booking.userId == currentUserId)")
                print("")
            }
        } else {
            print("📋 [MyBookings] No bookings in database")
        }

        print("📋 [MyBookings] =====================================")
    }
}

// MARK: - Booking Tab

private enum BookingTab {
    case upcoming
    case past
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MyBookingsView()
            .environment(AuthenticationViewModel(modelContext: previewContainer.mainContext))
            .environment(VenueViewModel(modelContext: previewContainer.mainContext))
            .modelContainer(previewContainer)
    }
}

@MainActor
private var previewContainer: ModelContainer = {
    let schema = Schema([
        User.self,
        Venue.self,
        Booking.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    return container
}()
