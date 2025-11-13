//
//  ProductServiceTests.swift
//  WiesbadenAfterDarkTests
//
//  Unit tests for ProductService and MockProductService
//

import XCTest
@testable import WiesbadenAfterDark

@MainActor
final class ProductServiceTests: XCTestCase {
    // MARK: - Properties

    var mockService: MockProductService!
    var testVenueId: UUID!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockService = MockProductService.shared
        testVenueId = UUID()
        mockService.clearAllCaches()
    }

    override func tearDown() {
        mockService.clearAllCaches()
        mockService = nil
        testVenueId = nil
        super.tearDown()
    }

    // MARK: - Fetch Products Tests

    func testFetchProducts_ReturnsProducts() async throws {
        // Given: A venue ID
        let venueId = testVenueId!

        // When: Fetching products
        let products = try await mockService.fetchProducts(venueId: venueId)

        // Then: Should return products
        XCTAssertFalse(products.isEmpty, "Should return products")
        XCTAssertTrue(products.count > 0, "Should have at least one product")

        // Verify all products belong to the venue
        for product in products {
            XCTAssertEqual(product.venueId, venueId, "Product should belong to the venue")
        }
    }

    func testFetchProducts_ContainsExpectedCategories() async throws {
        // Given: A venue ID
        let venueId = testVenueId!

        // When: Fetching products
        let products = try await mockService.fetchProducts(venueId: venueId)

        // Then: Should contain various categories
        let categories = Set(products.map { $0.category })
        XCTAssertTrue(categories.contains(.cocktails), "Should have cocktails")
        XCTAssertTrue(categories.contains(.food), "Should have food")
        XCTAssertTrue(categories.contains(.beer) || categories.contains(.wine), "Should have beverages")
    }

    // MARK: - Active Products Tests

    func testGetActiveProducts_OnlyReturnsAvailableProducts() async throws {
        // Given: A venue with products
        let venueId = testVenueId!

        // When: Fetching active products
        let activeProducts = try await mockService.getActiveProducts(venueId: venueId)

        // Then: All products should be available and in stock
        for product in activeProducts {
            XCTAssertTrue(product.isAvailable, "Product should be available")
            XCTAssertTrue(product.isInStock, "Product should be in stock")
            XCTAssertTrue(product.canPurchase, "Product should be purchasable")
        }
    }

    func testGetActiveProducts_ExcludesOutOfStock() async throws {
        // Given: A venue with products, one out of stock
        let venueId = testVenueId!
        _ = try await mockService.fetchProducts(venueId: venueId)
        mockService.simulateOutOfStock(venueId: venueId, productName: "House Red Wine")

        // When: Fetching active products
        let activeProducts = try await mockService.getActiveProducts(venueId: venueId)

        // Then: Out of stock product should not be included
        let outOfStockProduct = activeProducts.first { $0.name == "House Red Wine" }
        XCTAssertNil(outOfStockProduct, "Out of stock product should not be in active products")
    }

    // MARK: - Bonus Products Tests

    func testGetProductsWithBonus_OnlyReturnsBonusProducts() async throws {
        // Given: A venue with products
        let venueId = testVenueId!

        // When: Fetching products with bonus
        let bonusProducts = try await mockService.getProductsWithBonus(venueId: venueId)

        // Then: All products should have active bonuses
        for product in bonusProducts {
            XCTAssertTrue(product.bonusPointsActive, "Bonus should be active")
            XCTAssertTrue(product.isBonusActive, "Bonus should be currently active")
            XCTAssertGreaterThan(product.bonusMultiplier, 1.0, "Bonus multiplier should be > 1.0")
        }
    }

    func testGetProductsWithBonus_SimulateBonusActivation() async throws {
        // Given: A venue with products
        let venueId = testVenueId!
        _ = try await mockService.fetchProducts(venueId: venueId)

        // When: Simulating bonus on a product
        mockService.simulateBonus(venueId: venueId, productName: "Mojito", multiplier: 3.0)
        let bonusProducts = try await mockService.getProductsWithBonus(venueId: venueId)

        // Then: Mojito should be in the bonus products
        let mojitoWithBonus = bonusProducts.first { $0.name == "Mojito" }
        XCTAssertNotNil(mojitoWithBonus, "Mojito should have bonus")
        XCTAssertEqual(mojitoWithBonus?.bonusMultiplier, 3.0, "Bonus multiplier should be 3.0")
    }

    // MARK: - Category Filter Tests

    func testGetProductsByCategory_Cocktails() async throws {
        // Given: A venue with products
        let venueId = testVenueId!

        // When: Fetching cocktails
        let cocktails = try await mockService.getProductsByCategory(
            venueId: venueId,
            category: .cocktails
        )

        // Then: All products should be cocktails
        for product in cocktails {
            XCTAssertEqual(product.category, .cocktails, "Product should be a cocktail")
        }
        XCTAssertFalse(cocktails.isEmpty, "Should have cocktails")
    }

    func testGetProductsByCategory_Food() async throws {
        // Given: A venue with products
        let venueId = testVenueId!

        // When: Fetching food items
        let foodItems = try await mockService.getProductsByCategory(
            venueId: venueId,
            category: .food
        )

        // Then: All products should be food
        for product in foodItems {
            XCTAssertEqual(product.category, .food, "Product should be food")
        }
        XCTAssertFalse(foodItems.isEmpty, "Should have food items")
    }

    // MARK: - Product Model Tests

    func testProduct_FormattedPrice() {
        // Given: A product with a price
        let product = Product(
            venueId: testVenueId,
            name: "Test Product",
            category: .beverages,
            price: 12.50
        )

        // When: Getting formatted price
        let formatted = product.formattedPrice

        // Then: Should be properly formatted
        XCTAssertTrue(formatted.contains("12.50"), "Should contain price")
        XCTAssertTrue(formatted.contains("€"), "Should contain euro symbol")
    }

    func testProduct_CalculateBonusPoints() {
        // Given: A product with active bonus
        let product = Product(
            venueId: testVenueId,
            name: "Bonus Drink",
            category: .cocktails,
            price: 10.00,
            bonusPointsActive: true,
            bonusMultiplier: 2.0,
            bonusStartDate: Date().addingTimeInterval(-3600),
            bonusEndDate: Date().addingTimeInterval(3600)
        )

        // When: Calculating bonus points
        let bonusPoints = product.calculateBonusPoints(basePoints: 1.0)

        // Then: Should be multiplied
        XCTAssertEqual(bonusPoints, 20.0, "Should be price * base * multiplier (10 * 1 * 2)")
    }

    func testProduct_IsBonusActive_WithinDateRange() {
        // Given: A product with bonus in valid date range
        let product = Product(
            venueId: testVenueId,
            name: "Happy Hour Drink",
            category: .cocktails,
            price: 8.00,
            bonusPointsActive: true,
            bonusMultiplier: 2.0,
            bonusStartDate: Date().addingTimeInterval(-3600), // 1 hour ago
            bonusEndDate: Date().addingTimeInterval(3600)    // 1 hour from now
        )

        // When: Checking if bonus is active
        let isActive = product.isBonusActive

        // Then: Should be active
        XCTAssertTrue(isActive, "Bonus should be active within date range")
    }

    func testProduct_IsBonusActive_OutsideDateRange() {
        // Given: A product with expired bonus
        let product = Product(
            venueId: testVenueId,
            name: "Expired Bonus Drink",
            category: .cocktails,
            price: 8.00,
            bonusPointsActive: true,
            bonusMultiplier: 2.0,
            bonusStartDate: Date().addingTimeInterval(-7200), // 2 hours ago
            bonusEndDate: Date().addingTimeInterval(-3600)    // 1 hour ago
        )

        // When: Checking if bonus is active
        let isActive = product.isBonusActive

        // Then: Should not be active
        XCTAssertFalse(isActive, "Bonus should not be active outside date range")
    }

    func testProduct_CanPurchase() {
        // Given: A product that is available and in stock
        let product = Product(
            venueId: testVenueId,
            name: "Available Product",
            category: .food,
            price: 15.00,
            stockQuantity: 10,
            isAvailable: true
        )

        // When: Checking if can purchase
        let canPurchase = product.canPurchase

        // Then: Should be purchasable
        XCTAssertTrue(canPurchase, "Should be able to purchase")
    }

    func testProduct_CannotPurchase_OutOfStock() {
        // Given: A product that is out of stock
        let product = Product(
            venueId: testVenueId,
            name: "Out of Stock Product",
            category: .food,
            price: 15.00,
            stockQuantity: 0,
            isAvailable: true
        )

        // When: Checking if can purchase
        let canPurchase = product.canPurchase

        // Then: Should not be purchasable
        XCTAssertFalse(canPurchase, "Should not be able to purchase out of stock item")
    }

    // MARK: - Cache Tests

    func testClearCache_ForSpecificVenue() async throws {
        // Given: Products cached for a venue
        let venueId = testVenueId!
        _ = try await mockService.fetchProducts(venueId: venueId)

        // When: Clearing cache for that venue
        mockService.clearCache(for: venueId)

        // Then: Next fetch should return fresh data
        let products = try await mockService.fetchProducts(venueId: venueId)
        XCTAssertFalse(products.isEmpty, "Should still be able to fetch products")
    }

    func testClearAllCaches() async throws {
        // Given: Products cached for multiple venues
        let venue1 = UUID()
        let venue2 = UUID()
        _ = try await mockService.fetchProducts(venueId: venue1)
        _ = try await mockService.fetchProducts(venueId: venue2)

        // When: Clearing all caches
        mockService.clearAllCaches()

        // Then: Should be able to fetch fresh data
        let products1 = try await mockService.fetchProducts(venueId: venue1)
        let products2 = try await mockService.fetchProducts(venueId: venue2)
        XCTAssertFalse(products1.isEmpty, "Should fetch products for venue 1")
        XCTAssertFalse(products2.isEmpty, "Should fetch products for venue 2")
    }

    // MARK: - Mock Data Tests

    func testMockProducts_AperolSpritz() {
        // Given: Mock Aperol Spritz
        let product = Product.mockAperolSpritz(venueId: testVenueId)

        // Then: Should have expected properties
        XCTAssertEqual(product.name, "Aperol Spritz")
        XCTAssertEqual(product.category, .cocktails)
        XCTAssertEqual(product.price, 8.50)
        XCTAssertTrue(product.bonusPointsActive, "Should have bonus active")
        XCTAssertEqual(product.bonusMultiplier, 2.0)
    }

    func testMockProducts_AllProductsForVenue() {
        // Given: Mock products for a venue
        let products = Product.mockProductsForVenue(testVenueId)

        // Then: Should have variety of products
        XCTAssertGreaterThanOrEqual(products.count, 5, "Should have at least 5 products")

        let categories = Set(products.map { $0.category })
        XCTAssertGreaterThan(categories.count, 1, "Should have multiple categories")
    }

    // MARK: - Edge Cases

    func testProduct_ProfitMargin() {
        // Given: A product with cost
        let product = Product(
            venueId: testVenueId,
            name: "Product with Cost",
            category: .food,
            price: 10.00,
            cost: 4.00
        )

        // When: Calculating profit margin
        let margin = product.profitMargin

        // Then: Should calculate correctly ((10-4)/10 * 100 = 60%)
        XCTAssertNotNil(margin, "Should have profit margin")
        XCTAssertEqual(margin, 60.0, accuracy: 0.01, "Profit margin should be 60%")
    }

    func testProduct_ProfitMargin_NoCost() {
        // Given: A product without cost
        let product = Product(
            venueId: testVenueId,
            name: "Product without Cost",
            category: .food,
            price: 10.00,
            cost: nil
        )

        // When: Calculating profit margin
        let margin = product.profitMargin

        // Then: Should be nil
        XCTAssertNil(margin, "Should not have profit margin without cost")
    }

    func testProduct_FormattedBonus() {
        // Given: A product with active bonus
        let product = Product(
            venueId: testVenueId,
            name: "Bonus Product",
            category: .cocktails,
            price: 10.00,
            bonusPointsActive: true,
            bonusMultiplier: 3.0,
            bonusStartDate: Date().addingTimeInterval(-3600),
            bonusEndDate: Date().addingTimeInterval(3600)
        )

        // When: Getting formatted bonus
        let formatted = product.formattedBonus

        // Then: Should format correctly
        XCTAssertNotNil(formatted, "Should have formatted bonus")
        XCTAssertTrue(formatted?.contains("3x") ?? false, "Should show multiplier")
    }

    func testProduct_FormattedBonus_NoBonus() {
        // Given: A product without bonus
        let product = Product(
            venueId: testVenueId,
            name: "Regular Product",
            category: .food,
            price: 10.00,
            bonusPointsActive: false
        )

        // When: Getting formatted bonus
        let formatted = product.formattedBonus

        // Then: Should be nil
        XCTAssertNil(formatted, "Should not have formatted bonus")
    }
}
