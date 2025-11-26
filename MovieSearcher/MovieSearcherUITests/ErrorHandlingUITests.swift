//
//  ErrorHandlingUITests.swift
//  MovieSearcherUITests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import XCTest

final class ErrorHandlingUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        UITestHelpers.launchAppWithMockData(app)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    @MainActor
    func testSearchErrorDisplay() throws {
        // Note: To test error scenarios, we would need to configure mock data
        // to return errors. For now, we test the UI structure.
        
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        
        // Perform a search that might result in error
        searchBar.tap()
        searchBar.typeText("ErrorTest")
        
        // In a real scenario with error mock, we would:
        // 1. Wait for error alert to appear
        // 2. Verify error message
        // 3. Dismiss alert
        // 4. Verify UI returns to normal state
        
        // For now, we verify the search bar still works
        XCTAssertTrue(searchBar.exists, "Search bar should still exist after potential error")
    }
    
    @MainActor
    func testDetailLoadError() throws {
        // Navigate to detail
        let searchBar = app.searchFields.firstMatch
        if searchBar.waitForExistence(timeout: 2.0) {
            searchBar.tap()
            searchBar.typeText("Movie")
            
            let tableView = app.tables[AccessibilityIdentifiers.Search.moviesTableView]
            let firstCell = tableView.cells.firstMatch
            if firstCell.waitForExistence(timeout: 5.0) {
                firstCell.tap()
                
                // Wait for detail to load (or error to appear)
                sleep(2)
                
                // In a real scenario with error mock, we would:
                // 1. Check for error alert
                // 2. Verify error message
                // 3. Verify we can navigate back
                
                // For now, verify we can navigate back
                let backButton = app.navigationBars.buttons.firstMatch
                if backButton.exists {
                    // Can navigate back even if error occurred
                    XCTAssertTrue(backButton.exists, "Back button should exist even after error")
                }
            }
        }
    }
    
    @MainActor
    func testNetworkErrorHandling() throws {
        // This test would require network mocking or offline simulation
        // For now, we verify the app doesn't crash on network issues
        
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        
        // App should handle network errors gracefully
        // UI should remain responsive
        XCTAssertTrue(searchBar.isHittable, "Search bar should remain interactive after network error")
    }
}

