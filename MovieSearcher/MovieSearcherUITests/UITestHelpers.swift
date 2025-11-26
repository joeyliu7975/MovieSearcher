//
//  UITestHelpers.swift
//  MovieSearcherUITests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import XCTest

struct UITestHelpers {
    
    // MARK: - App Launch Helpers
    
    static func launchAppWithMockData(_ app: XCUIApplication) {
        app.launchArguments = ["--use-mock-data"]
        app.launch()
    }
    
    // MARK: - Wait Helpers
    
    static func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    static func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
    
    // MARK: - Keyboard Helpers
    
    /// Tap the search button on keyboard to submit search
    static func tapSearchButton(_ app: XCUIApplication) {
        let keyboard = app.keyboards.element
        
        guard keyboard.exists else { return }
        
        // Try to find "Search" button first
        let searchButton = app.keyboards.buttons["Search"]
        if searchButton.exists {
            searchButton.tap()
            return
        }
        
        // Fallback to "return" button
        let returnButton = app.keyboards.buttons["return"]
        if returnButton.exists {
            returnButton.tap()
            return
        }
        
        // Last resort: use typeText("\n") to simulate return key
        let searchBar = app.searchFields.firstMatch
        if searchBar.exists {
            searchBar.typeText("\n")
        }
    }
    
    /// Dismiss keyboard without triggering any UI interactions
    static func dismissKeyboard(_ app: XCUIApplication) {
        let keyboard = app.keyboards.element
        
        guard keyboard.exists else { return }
        
        // Method 1: Try to tap search/return button
        tapSearchButton(app)
        
        // Method 2: If keyboard still exists, tap navigation bar (safest)
        if keyboard.exists {
            let navBar = app.navigationBars.firstMatch
            if navBar.exists {
                navBar.tap()
            }
        }
        
        // Wait for keyboard to disappear
        _ = keyboard.waitForNonExistence(timeout: 2.0)
    }
}

