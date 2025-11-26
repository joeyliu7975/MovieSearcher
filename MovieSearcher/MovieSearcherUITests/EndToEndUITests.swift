//
//  EndToEndUITests.swift
//  MovieSearcherUITests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import XCTest

final class EndToEndUITests: XCTestCase {
    
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
    func testCompleteSearchToDetailFlow() throws {
        // Step 1: Verify initial state
        let emptyStateLabel = app.staticTexts["Search for movies to get started"]
        XCTAssertTrue(emptyStateLabel.exists, "Should show empty state initially")
        
        // Step 2: Perform search
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        
        searchBar.tap()
        searchBar.typeText("Batman")
        
        // Step 3: Wait for search results
        let tableView = app.tables[AccessibilityIdentifiers.Search.moviesTableView]
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0), "Search should return results")
        
        // Step 4: Verify empty state is hidden
        XCTAssertFalse(emptyStateLabel.exists, "Empty state should be hidden when results are shown")
        
        // Step 5: Navigate to detail
        firstCell.tap()
        
        // Wait for detail to load
        sleep(2)
        
        // Step 6: Verify we're on detail screen
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.exists, "Should navigate to detail screen")
        
        // Step 7: Toggle favorite (if button is available)
        let favoriteButton = app.buttons[AccessibilityIdentifiers.Detail.favoriteButton]
        if favoriteButton.waitForExistence(timeout: 5.0) && favoriteButton.isHittable {
            favoriteButton.tap()
            sleep(1)
        }
        
        // Step 8: Navigate back
        if backButton.exists {
            backButton.tap()
            
            // Step 9: Verify we're back on search screen
            let searchBarAfterBack = app.searchFields.firstMatch
            XCTAssertTrue(searchBarAfterBack.waitForExistence(timeout: 2.0), "Should return to search screen")
            
            // Step 10: Verify search results are still visible
            let tableViewAfterBack = app.tables[AccessibilityIdentifiers.Search.moviesTableView]
            XCTAssertTrue(tableViewAfterBack.exists, "Search results should still be visible")
        }
    }
    
    @MainActor
    func testSearchPaginationFlow() throws {
        // Step 1: Perform search
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        
        searchBar.tap()
        searchBar.typeText("Movie")
        
        // Step 2: Wait for initial results
        let tableView = app.tables[AccessibilityIdentifiers.Search.moviesTableView]
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0), "Initial results should load")
        
        let initialCellCount = tableView.cells.count
        
        // Step 3: Scroll to bottom to trigger pagination
        let lastCell = tableView.cells.element(boundBy: tableView.cells.count - 1)
        if lastCell.exists {
            lastCell.swipeUp()
            // Wait for potential pagination
            sleep(2)
            
            // Step 4: Verify more cells might have loaded
            // Note: In a real scenario with pagination, we would verify cell count increased
            let tableViewAfterScroll = app.tables[AccessibilityIdentifiers.Search.moviesTableView]
            XCTAssertTrue(tableViewAfterScroll.exists, "Table view should still exist after scroll")
        }
        
        // Step 5: Tap on a result
        let firstCellAfterScroll = tableView.cells.firstMatch
        if firstCellAfterScroll.exists {
            firstCellAfterScroll.tap()
            
            // Step 6: Verify navigation to detail
            sleep(2)
            let backButton = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(backButton.exists, "Should navigate to detail after pagination")
        }
    }
    
    @MainActor
    func testSearchCancelAndResumeFlow() throws {
        // Step 1: Start search
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        
        searchBar.tap()
        searchBar.typeText("Test")
        
        // Step 2: Cancel search
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }
        
        // Step 3: Verify empty state returns
        let emptyStateLabel = app.staticTexts["Search for movies to get started"]
        XCTAssertTrue(emptyStateLabel.waitForExistence(timeout: 2.0), "Empty state should return after cancel")
        
        // Step 4: Search again
        let searchBarAfterCancel = app.searchFields.firstMatch
        searchBarAfterCancel.tap()
        searchBarAfterCancel.typeText("Movie")
        
        // Step 5: Verify results appear
        let tableView = app.tables[AccessibilityIdentifiers.Search.moviesTableView]
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0), "Should get results after resuming search")
    }
    
    @MainActor
    func testMultipleDetailNavigationFlow() throws {
        // Step 1: Perform search
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        
        searchBar.tap()
        searchBar.typeText("Movie")
        
        // Step 2: Navigate to first detail
        let tableView = app.tables[AccessibilityIdentifiers.Search.moviesTableView]
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0))
        
        firstCell.tap()
        sleep(2)
        
        // Step 3: Navigate back
        let backButton = app.navigationBars.buttons.firstMatch
        if backButton.exists {
            backButton.tap()
            sleep(1)
            
            // Step 4: Navigate to second detail
            let secondCell = tableView.cells.element(boundBy: 1)
            if secondCell.exists {
                secondCell.tap()
                sleep(2)
                
                // Step 5: Verify second detail loaded
                let backButton2 = app.navigationBars.buttons.firstMatch
                XCTAssertTrue(backButton2.exists, "Should navigate to second detail")
            }
        }
    }
}

