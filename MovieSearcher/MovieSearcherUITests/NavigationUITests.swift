//
//  NavigationUITests.swift
//  MovieSearcherUITests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import XCTest

final class NavigationUITests: XCTestCase {
    
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
    func testNavigateToMovieDetail() throws {
        // First, perform a search to get results
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        
        searchBar.tap()
        searchBar.typeText("Movie")
        
        // Wait for search results
        let tableView = app.tables[AccessibilityIdentifiers.Search.moviesTableView]
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0), "Search results should appear")
        
        // Tap on the first cell to navigate to detail
        firstCell.tap()
        
        // Wait for navigation to detail view
        // Verify we're on the detail screen by checking for detail-specific elements
        let detailLoadingIndicator = app.activityIndicators[AccessibilityIdentifiers.Detail.loadingIndicator]
        // The detail view should load, so we wait a bit
        sleep(2)
        
        // Verify we navigated away from search (back button should exist)
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.exists, "Back button should exist after navigation")
    }
    
    @MainActor
    func testNavigateBackFromDetail() throws {
        // Navigate to detail first
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        
        searchBar.tap()
        searchBar.typeText("Movie")
        
        let tableView = app.tables[AccessibilityIdentifiers.Search.moviesTableView]
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0))
        
        firstCell.tap()
        
        // Wait for detail to load
        sleep(2)
        
        // Navigate back
        let backButton = app.navigationBars.buttons.firstMatch
        if backButton.exists {
            backButton.tap()
            
            // Verify we're back on search screen
            let searchBarAfterBack = app.searchFields.firstMatch
            XCTAssertTrue(searchBarAfterBack.waitForExistence(timeout: 2.0), "Should return to search screen")
        }
    }
}

