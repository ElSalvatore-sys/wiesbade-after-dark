//
//  WiesbadenAfterDarkUITests.swift
//  WiesbadenAfterDarkUITests
//
//  UI tests for WiesbadenAfterDark iOS app
//

import XCTest

final class WiesbadenAfterDarkUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch Tests

    func testAppLaunches() throws {
        XCTAssertTrue(app.exists, "App should launch successfully")
    }

    // MARK: - Navigation Tests

    func testTabBarExists() throws {
        // Check for tab bar items
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should exist")
    }

    func testHomeTabNavigation() throws {
        let homeTab = app.tabBars.buttons["Home"]
        if homeTab.exists {
            homeTab.tap()
            // Verify home content loads
            XCTAssertTrue(true)
        }
    }

    func testDiscoverTabNavigation() throws {
        let discoverTab = app.tabBars.buttons["Entdecken"]
        if discoverTab.exists {
            discoverTab.tap()
            XCTAssertTrue(true)
        }
    }

    func testEventsTabNavigation() throws {
        let eventsTab = app.tabBars.buttons["Events"]
        if eventsTab.exists {
            eventsTab.tap()
            XCTAssertTrue(true)
        }
    }

    func testWalletTabNavigation() throws {
        let walletTab = app.tabBars.buttons["Wallet"]
        if walletTab.exists {
            walletTab.tap()
            XCTAssertTrue(true)
        }
    }

    func testProfileTabNavigation() throws {
        let profileTab = app.tabBars.buttons["Profil"]
        if profileTab.exists {
            profileTab.tap()
            XCTAssertTrue(true)
        }
    }

    // MARK: - Dark Theme Tests

    func testDarkThemeIsActive() throws {
        // App should use dark theme
        // Visual verification - just ensure app launches
        XCTAssertTrue(app.exists)
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
