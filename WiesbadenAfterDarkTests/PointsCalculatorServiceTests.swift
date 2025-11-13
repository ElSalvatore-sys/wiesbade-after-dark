//
//  PointsCalculatorServiceTests.swift
//  WiesbadenAfterDarkTests
//
//  Unit tests for PointsCalculatorService margin-based algorithm
//

import XCTest
@testable import WiesbadenAfterDark

final class PointsCalculatorServiceTests: XCTestCase {

    var calculator: PointsCalculatorService!
    var testVenue: Venue!

    override func setUp() {
        super.setUp()
        calculator = PointsCalculatorService.shared

        // Create test venue with standard margins
        testVenue = Venue(
            name: "Test Venue",
            slug: "test-venue",
            type: .bar,
            description: "Test venue for unit tests",
            address: "Test Street 1",
            city: "Wiesbaden",
            postalCode: "65183",
            foodMarginPercent: 30.0,      // 30% margin
            beverageMarginPercent: 80.0,  // 80% margin
            defaultMarginPercent: 50.0    // 50% margin
        )
    }

    override func tearDown() {
        calculator = nil
        testVenue = nil
        super.tearDown()
    }

    // MARK: - Basic Calculation Tests

    func testCalculatePoints_HighMarginBeverage_NoBonus() {
        // Given: €100 purchase, 80% margin, 80% max margin, no bonus
        let amount: Decimal = 100.00
        let categoryMargin: Decimal = 80.0
        let venueMaxMargin: Decimal = 80.0
        let bonusMultiplier: Decimal = 1.0

        // When: Calculate points
        let points = calculator.calculatePoints(
            amount: amount,
            categoryMargin: categoryMargin,
            venueMaxMargin: venueMaxMargin,
            bonusMultiplier: bonusMultiplier
        )

        // Then: Should get 10 points (€100 × 10% × (80/80) × 1.0)
        XCTAssertEqual(points, 10.0, "High margin beverage should yield 10 points")
    }

    func testCalculatePoints_LowMarginFood() {
        // Given: €100 purchase, 30% margin, 80% max margin, no bonus
        let amount: Decimal = 100.00
        let categoryMargin: Decimal = 30.0
        let venueMaxMargin: Decimal = 80.0
        let bonusMultiplier: Decimal = 1.0

        // When: Calculate points
        let points = calculator.calculatePoints(
            amount: amount,
            categoryMargin: categoryMargin,
            venueMaxMargin: venueMaxMargin,
            bonusMultiplier: bonusMultiplier
        )

        // Then: Should get 3.75 points (€100 × 10% × (30/80) × 1.0)
        XCTAssertEqual(points, 3.75, "Low margin food should yield 3.75 points")
    }

    func testCalculatePoints_WithBonusMultiplier() {
        // Given: €100 purchase, 80% margin, 80% max margin, 2x bonus
        let amount: Decimal = 100.00
        let categoryMargin: Decimal = 80.0
        let venueMaxMargin: Decimal = 80.0
        let bonusMultiplier: Decimal = 2.0

        // When: Calculate points
        let points = calculator.calculatePoints(
            amount: amount,
            categoryMargin: categoryMargin,
            venueMaxMargin: venueMaxMargin,
            bonusMultiplier: bonusMultiplier
        )

        // Then: Should get 20 points (€100 × 10% × (80/80) × 2.0)
        XCTAssertEqual(points, 20.0, "2x bonus should double the points")
    }

    func testCalculatePoints_SmallPurchase() {
        // Given: €5 purchase, 80% margin
        let amount: Decimal = 5.00
        let categoryMargin: Decimal = 80.0
        let venueMaxMargin: Decimal = 80.0

        // When: Calculate points
        let points = calculator.calculatePoints(
            amount: amount,
            categoryMargin: categoryMargin,
            venueMaxMargin: venueMaxMargin,
            bonusMultiplier: 1.0
        )

        // Then: Should get 0.5 points (€5 × 10% × 1.0)
        XCTAssertEqual(points, 0.5, "Small purchase should yield proportional points")
    }

    func testCalculatePoints_ZeroMargin() {
        // Given: €100 purchase, 0% margin
        let amount: Decimal = 100.00
        let categoryMargin: Decimal = 0.0
        let venueMaxMargin: Decimal = 80.0

        // When: Calculate points
        let points = calculator.calculatePoints(
            amount: amount,
            categoryMargin: categoryMargin,
            venueMaxMargin: venueMaxMargin,
            bonusMultiplier: 1.0
        )

        // Then: Should get 0 points (no margin = no points)
        XCTAssertEqual(points, 0.0, "Zero margin should yield zero points")
    }

    func testCalculatePoints_ZeroMaxMargin() {
        // Given: Venue with zero max margin (edge case)
        let amount: Decimal = 100.00
        let categoryMargin: Decimal = 50.0
        let venueMaxMargin: Decimal = 0.0

        // When: Calculate points
        let points = calculator.calculatePoints(
            amount: amount,
            categoryMargin: categoryMargin,
            venueMaxMargin: venueMaxMargin,
            bonusMultiplier: 1.0
        )

        // Then: Should get 0 points (prevent division by zero)
        XCTAssertEqual(points, 0.0, "Zero max margin should yield zero points")
    }

    // MARK: - Simple Points Calculation Tests

    func testCalculateSimplePoints_FoodCategory() {
        // Given: €50 food purchase
        let amount: Decimal = 50.00

        // When: Calculate points for food category
        let points = calculator.calculateSimplePoints(
            amount: amount,
            category: .food,
            venue: testVenue,
            bonusMultiplier: 1.0
        )

        // Then: Should use food margin (30%)
        // €50 × 10% × (30/80) = 1.88 (rounded to 1.88)
        XCTAssertEqual(points, 1.88, accuracy: 0.01, "Food should use 30% margin")
    }

    func testCalculateSimplePoints_BeverageCategory() {
        // Given: €50 beverage purchase
        let amount: Decimal = 50.00

        // When: Calculate points for beverage category
        let points = calculator.calculateSimplePoints(
            amount: amount,
            category: .beverage,
            venue: testVenue,
            bonusMultiplier: 1.0
        )

        // Then: Should use beverage margin (80%)
        // €50 × 10% × (80/80) = 5.0
        XCTAssertEqual(points, 5.0, "Beverage should use 80% margin")
    }

    func testCalculateSimplePoints_OtherCategory() {
        // Given: €50 other purchase
        let amount: Decimal = 50.00

        // When: Calculate points for other category
        let points = calculator.calculateSimplePoints(
            amount: amount,
            category: .other,
            venue: testVenue,
            bonusMultiplier: 1.0
        )

        // Then: Should use default margin (50%)
        // €50 × 10% × (50/80) = 3.13 (rounded to 3.13)
        XCTAssertEqual(points, 3.13, accuracy: 0.01, "Other should use 50% default margin")
    }

    // MARK: - Order Calculation Tests

    func testCalculatePointsForOrder_SingleItem() {
        // Given: Single cocktail order
        let orderItems = [
            OrderItem(
                productId: UUID(),
                name: "Cocktail",
                category: .beverage,
                price: 12.00,
                quantity: 1,
                marginPercent: 80.0,
                bonusMultiplier: 1.0
            )
        ]

        // When: Calculate points for order
        let result = calculator.calculatePointsForOrder(
            orderItems: orderItems,
            venue: testVenue
        )

        // Then: €12 × 10% × (80/80) × 1.0 = 1.2 points
        XCTAssertEqual(result.totalPoints, 1.2, "Single cocktail should yield 1.2 points")
        XCTAssertEqual(result.bonusPoints, 0, "No bonus points without multiplier")
        XCTAssertEqual(result.roundedPoints, 1, "Should round to 1 point")
    }

    func testCalculatePointsForOrder_MultipleItems() {
        // Given: Mixed order (2 cocktails + 1 burger)
        let orderItems = [
            OrderItem(
                productId: UUID(),
                name: "Cocktail",
                category: .beverage,
                price: 12.00,
                quantity: 2,
                marginPercent: 80.0,
                bonusMultiplier: 1.0
            ),
            OrderItem(
                productId: UUID(),
                name: "Burger",
                category: .food,
                price: 15.00,
                quantity: 1,
                marginPercent: 30.0,
                bonusMultiplier: 1.0
            )
        ]

        // When: Calculate points for order
        let result = calculator.calculatePointsForOrder(
            orderItems: orderItems,
            venue: testVenue
        )

        // Then: Cocktails: €24 × 10% × (80/80) = 2.4 points
        //       Burger: €15 × 10% × (30/80) = 0.56 points
        //       Total: 2.96 points
        XCTAssertEqual(result.totalPoints, 2.96, accuracy: 0.01, "Mixed order should yield 2.96 points")
        XCTAssertEqual(result.breakdown.count, 2, "Should have 2 breakdown items")
        XCTAssertEqual(result.roundedPoints, 3, "Should round to 3 points")
    }

    func testCalculatePointsForOrder_WithBonus() {
        // Given: Cocktail with 2x bonus
        let orderItems = [
            OrderItem(
                productId: UUID(),
                name: "Signature Cocktail",
                category: .beverage,
                price: 12.00,
                quantity: 1,
                marginPercent: 80.0,
                bonusMultiplier: 2.0
            )
        ]

        // When: Calculate points for order
        let result = calculator.calculatePointsForOrder(
            orderItems: orderItems,
            venue: testVenue
        )

        // Then: €12 × 10% × (80/80) × 2.0 = 2.4 points
        XCTAssertEqual(result.totalPoints, 2.4, "2x bonus should double points")
        XCTAssertEqual(result.basePoints, 1.2, "Base points should be 1.2")
        XCTAssertEqual(result.bonusPoints, 1.2, "Bonus points should be 1.2")
        XCTAssertEqual(result.roundedPoints, 2, "Should round to 2 points")
    }

    func testCalculatePointsForOrder_MultipleItemsWithMixedBonus() {
        // Given: Order with mixed bonus multipliers
        let orderItems = [
            OrderItem(
                productId: UUID(),
                name: "Signature Cocktail (2x Bonus)",
                category: .beverage,
                price: 12.00,
                quantity: 1,
                marginPercent: 80.0,
                bonusMultiplier: 2.0
            ),
            OrderItem(
                productId: UUID(),
                name: "Wine (1.5x Bonus)",
                category: .beverage,
                price: 8.00,
                quantity: 1,
                marginPercent: 80.0,
                bonusMultiplier: 1.5
            ),
            OrderItem(
                productId: UUID(),
                name: "Burger (No Bonus)",
                category: .food,
                price: 15.00,
                quantity: 1,
                marginPercent: 30.0,
                bonusMultiplier: 1.0
            )
        ]

        // When: Calculate points for order
        let result = calculator.calculatePointsForOrder(
            orderItems: orderItems,
            venue: testVenue
        )

        // Then: Cocktail: €12 × 10% × (80/80) × 2.0 = 2.4 points
        //       Wine: €8 × 10% × (80/80) × 1.5 = 1.2 points
        //       Burger: €15 × 10% × (30/80) × 1.0 = 0.56 points
        //       Total: 4.16 points
        XCTAssertEqual(result.totalPoints, 4.16, accuracy: 0.01, "Mixed bonus order should yield 4.16 points")
        XCTAssertEqual(result.breakdown.count, 3, "Should have 3 breakdown items")
        XCTAssertEqual(result.roundedPoints, 4, "Should round to 4 points")
    }

    func testCalculatePointsForOrder_EmptyOrder() {
        // Given: Empty order
        let orderItems: [OrderItem] = []

        // When: Calculate points for empty order
        let result = calculator.calculatePointsForOrder(
            orderItems: orderItems,
            venue: testVenue
        )

        // Then: Should get 0 points
        XCTAssertEqual(result.totalPoints, 0, "Empty order should yield 0 points")
        XCTAssertEqual(result.breakdown.count, 0, "Should have no breakdown items")
    }

    // MARK: - Edge Cases

    func testCalculatePoints_NegativeAmount() {
        // Given: Negative amount (refund scenario)
        let amount: Decimal = -50.00

        // When: Calculate points
        let points = calculator.calculatePoints(
            amount: amount,
            categoryMargin: 80.0,
            venueMaxMargin: 80.0,
            bonusMultiplier: 1.0
        )

        // Then: Should get negative points
        XCTAssertEqual(points, -5.0, "Negative amount should yield negative points")
    }

    func testCalculatePoints_VeryLargeAmount() {
        // Given: Very large purchase
        let amount: Decimal = 10000.00

        // When: Calculate points
        let points = calculator.calculatePoints(
            amount: amount,
            categoryMargin: 80.0,
            venueMaxMargin: 80.0,
            bonusMultiplier: 1.0
        )

        // Then: Should handle large numbers correctly
        XCTAssertEqual(points, 1000.0, "Large amounts should calculate correctly")
    }

    func testCalculatePoints_Rounding() {
        // Given: Amount that results in fractional points
        let amount: Decimal = 12.34

        // When: Calculate points
        let points = calculator.calculatePoints(
            amount: amount,
            categoryMargin: 80.0,
            venueMaxMargin: 80.0,
            bonusMultiplier: 1.0
        )

        // Then: Should round to 2 decimal places
        // €12.34 × 10% = 1.234, rounded to 1.23
        XCTAssertEqual(points, 1.23, "Should round to 2 decimal places")
    }

    // MARK: - Real-World Scenarios

    func testRealWorldScenario_NightOut() {
        // Scenario: Night out at Das Wohnzimmer
        // - 3 cocktails @ €12 each (80% margin, 2x bonus on special)
        // - 1 burger @ €15 (30% margin)
        // - 2 beers @ €5.50 each (80% margin)

        let orderItems = [
            OrderItem(
                productId: UUID(),
                name: "Signature Cocktail",
                category: .beverage,
                price: 12.00,
                quantity: 3,
                marginPercent: 80.0,
                bonusMultiplier: 2.0
            ),
            OrderItem(
                productId: UUID(),
                name: "Classic Burger",
                category: .food,
                price: 15.00,
                quantity: 1,
                marginPercent: 30.0,
                bonusMultiplier: 1.0
            ),
            OrderItem(
                productId: UUID(),
                name: "Draft Beer",
                category: .beverage,
                price: 5.50,
                quantity: 2,
                marginPercent: 80.0,
                bonusMultiplier: 1.0
            )
        ]

        // When: Calculate points
        let result = calculator.calculatePointsForOrder(
            orderItems: orderItems,
            venue: testVenue
        )

        // Then: Cocktails: €36 × 10% × (80/80) × 2.0 = 7.2 points
        //       Burger: €15 × 10% × (30/80) × 1.0 = 0.56 points
        //       Beers: €11 × 10% × (80/80) × 1.0 = 1.1 points
        //       Total: 8.86 points
        XCTAssertEqual(result.totalPoints, 8.86, accuracy: 0.01, "Night out should yield 8.86 points")
        XCTAssertEqual(result.roundedPoints, 9, "Should round to 9 points")
        XCTAssertGreaterThan(result.bonusPoints, 0, "Should have bonus points from cocktails")
    }

    func testRealWorldScenario_DinnerForTwo() {
        // Scenario: Romantic dinner at fine dining restaurant
        // - 2 main courses @ €45 each (30% margin)
        // - 1 bottle of wine @ €60 (80% margin, 1.5x bonus)
        // - 2 desserts @ €12 each (40% margin)

        let orderItems = [
            OrderItem(
                productId: UUID(),
                name: "Main Course",
                category: .food,
                price: 45.00,
                quantity: 2,
                marginPercent: 30.0,
                bonusMultiplier: 1.0
            ),
            OrderItem(
                productId: UUID(),
                name: "Wine Bottle",
                category: .beverage,
                price: 60.00,
                quantity: 1,
                marginPercent: 80.0,
                bonusMultiplier: 1.5
            ),
            OrderItem(
                productId: UUID(),
                name: "Dessert",
                category: .food,
                price: 12.00,
                quantity: 2,
                marginPercent: 40.0,
                bonusMultiplier: 1.0
            )
        ]

        // When: Calculate points
        let result = calculator.calculatePointsForOrder(
            orderItems: orderItems,
            venue: testVenue
        )

        // Then: Mains: €90 × 10% × (30/80) = 3.38 points
        //       Wine: €60 × 10% × (80/80) × 1.5 = 9.0 points
        //       Desserts: €24 × 10% × (40/80) = 1.2 points
        //       Total: 13.58 points
        XCTAssertEqual(result.totalPoints, 13.58, accuracy: 0.01, "Dinner should yield 13.58 points")
        XCTAssertEqual(result.roundedPoints, 14, "Should round to 14 points")
    }
}
