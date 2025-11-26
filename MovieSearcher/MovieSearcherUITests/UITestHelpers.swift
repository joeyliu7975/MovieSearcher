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
}

