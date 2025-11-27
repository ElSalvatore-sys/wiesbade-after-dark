//
//  HomeViewModel.swift
//  WiesbadenAfterDark
//
//  ViewModel for home page with gamification and event highlights
//

import Foundation
import SwiftUI
import SwiftData
import CoreLocation

/// Home view model with gamification features
@MainActor
@Observable
final class HomeViewModel {
    // MARK: - Dependencies

    private let venueService: VenueServiceProtocol
    private let modelContext: ModelContext?

    // MARK: - Published State

    // Venues and location
    var venues: [Venue] = []
    var nearbyVenues: [Venue] = []
    var userLocation: CLLocation?

    // Events
    var todayEvents: [Event] = []
    var upcomingEvents: [Event] = []
    var allEvents: [Event] = []

    // Inventory offers
    var inventoryOffers: [Product] = []
    var expiringProducts: [Product] = []

    // User data
    var memberships: [VenueMembership] = []
    var totalPoints: Int = 0
    var recentTransactions: [PointTransaction] = []

    // UI State
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var errorMessage: String?

    // MARK: - Initialization

    init(
        venueService: VenueServiceProtocol = MockVenueService.shared,
        modelContext: ModelContext? = nil
    ) {
        self.venueService = venueService
        self.modelContext = modelContext

        print("🏠 [HomeViewModel] Initialized")
    }

    // MARK: - Data Loading Methods

    /// Loads all home page data with parallel fetching for optimal performance
    func loadHomeData(userId: UUID) async {
        print("🏠 [HomeViewModel] Loading home data (parallel)")
        let startTime = CFAbsoluteTimeGetCurrent()

        isLoading = true
        errorMessage = nil

        do {
            // STEP 1: Load venues first (required for other operations)
            venues = try await venueService.fetchVenues()
            print("   ✓ Venues loaded: \(venues.count)")

            // STEP 2: Load everything else in PARALLEL using async let
            async let eventsTask: () = loadAllEventsParallel()
            async let offersTask: () = loadInventoryOffers()
            async let membershipsTask: () = loadMemberships(userId: userId)
            async let transactionsTask: () = loadRecentTransactions(userId: userId)

            // Wait for all parallel tasks to complete
            _ = await (eventsTask, offersTask, membershipsTask, transactionsTask)

            // Calculate nearby venues if location is available
            updateNearbyVenues()

            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("✅ [HomeViewModel] Home data loaded in \(String(format: "%.2f", elapsed))s")
            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            print("❌ [HomeViewModel] Failed to load home data: \(error)")
            isLoading = false
        }
    }

    /// Refreshes home page data
    func refresh(userId: UUID) async {
        print("🔄 [HomeViewModel] Refreshing home data")

        isRefreshing = true
        await loadHomeData(userId: userId)
        isRefreshing = false
    }

    // MARK: - Events Methods

    /// Loads events from all venues using batch fetch (OPTIMIZED)
    private func loadAllEventsParallel() async {
        print("🎫 [HomeViewModel] Loading events (batch)")

        do {
            // Use batch fetch instead of per-venue iteration
            allEvents = try await venueService.fetchAllEvents()

            // Categorize events
            categorizeEvents()

            print("   ✓ Events loaded: \(allEvents.count)")
        } catch {
            print("⚠️ [HomeViewModel] Failed to load events: \(error)")
            allEvents = []
        }
    }

    /// Legacy: Loads events from all venues and categorizes them (SLOW - sequential)
    @available(*, deprecated, message: "Use loadAllEventsParallel() for better performance")
    private func loadAllEvents() async {
        print("🎫 [HomeViewModel] Loading events (sequential - deprecated)")

        var allEventsList: [Event] = []

        // Load events for each venue
        for venue in venues {
            do {
                let venueEvents = try await venueService.fetchEvents(venueId: venue.id)
                allEventsList.append(contentsOf: venueEvents)
            } catch {
                print("⚠️ [HomeViewModel] Failed to load events for venue \(venue.name): \(error)")
            }
        }

        allEvents = allEventsList

        // Categorize events
        categorizeEvents()

        print("✅ [HomeViewModel] Loaded \(allEvents.count) events")
    }

    /// Categorizes events into today and upcoming
    private func categorizeEvents() {
        let now = Date()
        let calendar = Calendar.current

        // Today's events (happening today)
        todayEvents = allEvents.filter { event in
            calendar.isDateInToday(event.startTime) && event.startTime > now
        }.sorted { $0.startTime < $1.startTime }

        // If no events today, show events happening right now
        if todayEvents.isEmpty {
            todayEvents = allEvents.filter { event in
                event.startTime <= now && event.endTime > now
            }.sorted { $0.startTime < $1.startTime }
        }

        // Upcoming events (next 7 days, excluding today)
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: now)!
        upcomingEvents = allEvents.filter { event in
            !calendar.isDateInToday(event.startTime) &&
            event.startTime > now &&
            event.startTime < nextWeek
        }.sorted { $0.startTime < $1.startTime }

        print("📅 [HomeViewModel] Today: \(todayEvents.count) events, Upcoming: \(upcomingEvents.count) events")
    }

    /// Gets the venue for an event
    func venue(for event: Event) -> Venue? {
        return venues.first { $0.id == event.venueId }
    }

    // MARK: - Inventory Offers Methods

    /// Priority venue names for special offers display (in order)
    private let priorityVenues = [
        "Das Wohnzimmer",
        "Hotel am Kochbrunnen",
        "Harput Restaurant"
    ]

    /// Loads inventory offers with bonuses from all venues
    private func loadInventoryOffers() async {
        print("🛒 [HomeViewModel] Loading inventory offers")

        // Mock data for now - in production, this would be an API call
        var allOffers: [Product] = []

        for venue in venues {
            let products = Product.mockProductsForVenue(venue.id)
            let bonusProducts = products.filter { $0.bonusPointsActive }
            allOffers.append(contentsOf: bonusProducts)
        }

        // Filter by priority venues and sort by venue priority order
        let filteredOffers = allOffers
            .filter { product in
                // Find the venue name for this product
                guard let productVenue = venues.first(where: { $0.id == product.venueId }) else {
                    return false
                }
                return priorityVenues.contains(productVenue.name)
            }
            .sorted { product1, product2 in
                // Get venue names for both products
                let venue1 = venues.first(where: { $0.id == product1.venueId })?.name ?? ""
                let venue2 = venues.first(where: { $0.id == product2.venueId })?.name ?? ""

                // Get priority indices (higher index = lower priority)
                let index1 = priorityVenues.firstIndex(of: venue1) ?? 999
                let index2 = priorityVenues.firstIndex(of: venue2) ?? 999

                return index1 < index2
            }

        inventoryOffers = filteredOffers

        // Filter expiring products (expires within 24 hours)
        expiringProducts = inventoryOffers.filter { $0.isExpiringSoon }

        print("✅ [HomeViewModel] Loaded \(inventoryOffers.count) inventory offers from priority venues (\(expiringProducts.count) expiring soon)")
    }

    /// Gets the venue for a product
    func venue(for product: Product) -> Venue? {
        return venues.first { $0.id == product.venueId }
    }

    // MARK: - Memberships Methods

    /// Loads user memberships from all venues
    private func loadMemberships(userId: UUID) async {
        print("🎖️ [HomeViewModel] Loading memberships")

        var allMemberships: [VenueMembership] = []

        for venue in venues {
            do {
                if let membership = try await venueService.fetchMembership(userId: userId, venueId: venue.id) {
                    allMemberships.append(membership)
                }
            } catch {
                // No membership for this venue - that's okay
                print("ℹ️ [HomeViewModel] No membership for venue \(venue.name)")
            }
        }

        memberships = allMemberships

        // Calculate total points across all venues
        totalPoints = memberships.reduce(0) { $0 + $1.pointsBalance }

        print("✅ [HomeViewModel] Loaded \(memberships.count) memberships with \(totalPoints) total points")
    }

    /// Gets points balance for a specific venue
    func pointsBalance(for venueId: UUID) -> Int {
        return memberships.first { $0.venueId == venueId }?.pointsBalance ?? 0
    }

    // MARK: - Transactions Methods

    /// Loads recent transactions for the user
    private func loadRecentTransactions(userId: UUID) async {
        print("💳 [HomeViewModel] Loading recent transactions")

        // In production, this would fetch from the backend
        // For now, use mock data if we have memberships
        guard !memberships.isEmpty else {
            recentTransactions = []
            return
        }

        // Generate mock transactions for the first venue
        if let firstMembership = memberships.first,
           let venue = venues.first(where: { $0.id == firstMembership.venueId }) {
            recentTransactions = PointTransaction.mockHistory(
                userId: userId,
                venueId: venue.id,
                venueName: venue.name,
                count: 8
            )
        }

        print("✅ [HomeViewModel] Loaded \(recentTransactions.count) recent transactions")
    }

    // MARK: - Location Methods

    /// Updates user location
    func updateLocation(_ location: CLLocation) {
        userLocation = location
        updateNearbyVenues()
    }

    /// Calculates and updates nearby venues
    private func updateNearbyVenues() {
        guard let location = userLocation else {
            nearbyVenues = []
            return
        }

        // Calculate distances and sort by proximity
        let venuesWithDistances = venues.compactMap { venue -> (venue: Venue, distance: CLLocationDistance)? in
            guard let latitude = venue.latitude, let longitude = venue.longitude else {
                return nil
            }
            let venueLocation = CLLocation(latitude: latitude, longitude: longitude)
            let distance = location.distance(from: venueLocation)
            return (venue, distance)
        }

        // Sort by distance and take top 5
        nearbyVenues = venuesWithDistances
            .sorted { $0.distance < $1.distance }
            .prefix(5)
            .map { $0.venue }

        print("📍 [HomeViewModel] Updated nearby venues: \(nearbyVenues.count)")
    }

    /// Gets distance to venue in kilometers
    func distance(to venue: Venue) -> String? {
        guard let location = userLocation,
              let latitude = venue.latitude,
              let longitude = venue.longitude else { return nil }

        let venueLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = location.distance(from: venueLocation)
        let distanceInKm = distanceInMeters / 1000.0

        if distanceInKm < 1.0 {
            return String(format: "%.0fm", distanceInMeters)
        } else {
            return String(format: "%.1fkm", distanceInKm)
        }
    }

    // MARK: - Helper Methods

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }

    /// Gets active bonuses summary text
    func activeBonusesSummary() -> String? {
        var bonuses: [String] = []

        // Check for events with multipliers today
        let eventBonuses = todayEvents.filter { $0.pointsMultiplier > 1.0 }
        if !eventBonuses.isEmpty {
            bonuses.append("\(eventBonuses.count) event bonus\(eventBonuses.count == 1 ? "" : "es")")
        }

        // Check for inventory offers
        if !inventoryOffers.isEmpty {
            bonuses.append("\(inventoryOffers.count) product deal\(inventoryOffers.count == 1 ? "" : "s")")
        }

        // Check for expiring products
        if !expiringProducts.isEmpty {
            bonuses.append("\(expiringProducts.count) expiring soon")
        }

        if bonuses.isEmpty {
            return nil
        }

        return bonuses.joined(separator: " • ")
    }

    /// Checks if there are any active bonuses
    var hasActiveBonuses: Bool {
        return !todayEvents.filter { $0.pointsMultiplier > 1.0 }.isEmpty ||
               !inventoryOffers.isEmpty
    }
}
