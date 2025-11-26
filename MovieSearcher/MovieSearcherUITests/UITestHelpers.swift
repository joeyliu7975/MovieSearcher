//
//  UITestHelpers.swift
//  MovieSearcherUITests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import XCTest
@testable import MovieSearcher

struct UITestHelpers {
    
    // MARK: - Test Data
    
    static func createSampleMovie(id: Int = 1, title: String = "Test Movie") -> Movie {
        return Movie(
            id: id,
            title: title,
            originalTitle: title,
            overview: "This is a test movie overview",
            releaseDate: Date(),
            posterPath: "/test_poster.jpg",
            backdropPath: "/test_backdrop.jpg",
            voteAverage: 8.5,
            voteCount: 1000,
            popularity: 100.0,
            genreIds: [1, 2],
            isAdult: false,
            hasVideo: true,
            originalLanguage: "en"
        )
    }
    
    static func createSampleMovies(count: Int = 3) -> [Movie] {
        return (1...count).map { index in
            createSampleMovie(id: index, title: "Test Movie \(index)")
        }
    }
    
    static func createSampleMovieDetail(id: Int = 1) -> MovieDetail {
        return MovieDetail(
            id: id,
            title: "Test Movie",
            originalTitle: "Test Movie",
            overview: "This is a detailed overview of the test movie",
            releaseDate: Date(),
            posterPath: "/test_poster.jpg",
            backdropPath: "/test_backdrop.jpg",
            voteAverage: 8.5,
            voteCount: 1000,
            popularity: 100.0,
            runtime: 120,
            tagline: "Test tagline",
            status: "Released",
            genres: [],
            productionCompanies: [],
            productionCountries: [],
            spokenLanguages: [],
            homepage: nil,
            imdbId: nil,
            budget: 1000000,
            revenue: 2000000
        )
    }
    
    static func createSampleMovieAccountStates(id: Int = 1, favorite: Bool = false) -> MovieAccountStates {
        return MovieAccountStates(
            id: id,
            favorite: favorite,
            rated: false,
            watchlist: false
        )
    }
    
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

