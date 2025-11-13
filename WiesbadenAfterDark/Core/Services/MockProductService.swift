//
//  MockProductService.swift
//  WiesbadenAfterDark
//
//  Mock implementation of ProductServiceProtocol for testing
//  This will be used during development and testing
//

import Foundation

/// Mock product service for development and testing
/// Always returns successful responses with simulated delays
final class MockProductService: ProductServiceProtocol {
    // MARK: - Properties

    /// Simulated network delay in seconds
    private let networkDelay: TimeInterval = 1.0

    /// Cache of products per venue
    private var productCache: [UUID: [Product]] = [:]

    // MARK: - Singleton

    static let shared = MockProductService()

    // MARK: - Initialization

    private init() {
        // Initialize with some mock data
        setupMockData()
    }

    // MARK: - ProductServiceProtocol Implementation

    /// Fetches all products for a specific venue
    func fetchProducts(venueId: UUID) async throws -> [Product] {
        print("📦 [MockProductService] Fetching products for venue: \(venueId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Get or create products for this venue
        let products = productCache[venueId] ?? Product.mockProductsForVenue(venueId)
        productCache[venueId] = products

        print("✅ [MockProductService] Returned \(products.count) products")
        return products
    }

    /// Fetches active products (in stock and available) for a venue
    func getActiveProducts(venueId: UUID) async throws -> [Product] {
        print("🟢 [MockProductService] Fetching active products for venue: \(venueId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        let allProducts = try await fetchProducts(venueId: venueId)
        let activeProducts = allProducts.filter { $0.canPurchase }

        print("✅ [MockProductService] Returned \(activeProducts.count) active products")
        return activeProducts
    }

    /// Fetches products with active bonus points for a venue
    func getProductsWithBonus(venueId: UUID) async throws -> [Product] {
        print("⭐ [MockProductService] Fetching products with bonus for venue: \(venueId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        let allProducts = try await fetchProducts(venueId: venueId)
        let bonusProducts = allProducts.filter { $0.isBonusActive }

        print("✅ [MockProductService] Returned \(bonusProducts.count) products with bonuses")
        return bonusProducts
    }

    /// Fetches products by category for a venue
    func getProductsByCategory(venueId: UUID, category: ProductCategory) async throws -> [Product] {
        print("🏷️ [MockProductService] Fetching \(category.displayName) products for venue: \(venueId)")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        let allProducts = try await fetchProducts(venueId: venueId)
        let categoryProducts = allProducts.filter { $0.category == category }

        print("✅ [MockProductService] Returned \(categoryProducts.count) products in category")
        return categoryProducts
    }

    /// Clears the product cache for a specific venue
    func clearCache(for venueId: UUID) {
        productCache.removeValue(forKey: venueId)
        print("🗑️ [MockProductService] Cleared cache for venue: \(venueId)")
    }

    /// Clears all product caches
    func clearAllCaches() {
        productCache.removeAll()
        print("🗑️ [MockProductService] Cleared all product caches")
    }

    // MARK: - Mock Data Setup

    private func setupMockData() {
        // Pre-populate with mock data for a few venues
        // This will be useful for SwiftUI previews and testing
        print("🔧 [MockProductService] Initialized with mock data")
    }

    // MARK: - Test Helpers

    /// Simulate out of stock scenario
    func simulateOutOfStock(venueId: UUID, productName: String) {
        guard var products = productCache[venueId] else { return }

        if let index = products.firstIndex(where: { $0.name == productName }) {
            var product = products[index]
            product.stockQuantity = 0
            product.isAvailable = false
            products[index] = product
            productCache[venueId] = products
            print("🧪 [MockProductService] Simulated out of stock for: \(productName)")
        }
    }

    /// Simulate bonus activation
    func simulateBonus(venueId: UUID, productName: String, multiplier: Decimal = 2.0) {
        guard var products = productCache[venueId] else { return }

        if let index = products.firstIndex(where: { $0.name == productName }) {
            var product = products[index]
            product.bonusPointsActive = true
            product.bonusMultiplier = multiplier
            product.bonusDescription = "Test Bonus"
            product.bonusStartDate = Date()
            product.bonusEndDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())
            products[index] = product
            productCache[venueId] = products
            print("🧪 [MockProductService] Simulated bonus for: \(productName) (\(multiplier)x)")
        }
    }

    /// Add custom product for testing
    func addTestProduct(venueId: UUID, product: Product) {
        if productCache[venueId] != nil {
            productCache[venueId]?.append(product)
        } else {
            productCache[venueId] = [product]
        }
        print("🧪 [MockProductService] Added test product: \(product.name)")
    }

    /// Simulate network error
    func simulateNetworkError() async throws -> [Product] {
        print("🧪 [MockProductService] Simulating network error")
        throw ProductError.networkError(NSError(domain: "MockError", code: -1009))
    }

    /// Simulate venue not found
    func simulateVenueNotFound() async throws -> [Product] {
        print("🧪 [MockProductService] Simulating venue not found")
        throw ProductError.venueNotFound
    }
}

// MARK: - SwiftUI Preview Helper
extension MockProductService {
    /// Get a preview instance with pre-populated data
    static func preview(venueId: UUID) -> MockProductService {
        let service = MockProductService()
        let products = Product.mockProductsForVenue(venueId)
        service.productCache[venueId] = products
        return service
    }
}
