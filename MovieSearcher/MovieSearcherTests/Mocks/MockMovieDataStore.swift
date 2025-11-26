//
//  MockMovieDataStore.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
@testable import MovieSearcher

class MockMovieDataStore: MovieDataStore {
    var saveSearchResultError: Error?
    var saveMovieDetailError: Error?
    
    var saveSearchResultCallCount = 0
    var saveMovieDetailCallCount = 0
    var lastSavedSearchResult: SearchResult?
    var lastSavedMovieDetail: MovieDetail?
    
    func saveSearchResult(
        _ result: SearchResult,
        query: String,
        page: Int,
        language: String
    ) async throws {
        saveSearchResultCallCount += 1
        lastSavedSearchResult = result
        
        if let error = saveSearchResultError {
            throw error
        }
    }
    
    func saveMovieDetail(_ detail: MovieDetail) async throws {
        saveMovieDetailCallCount += 1
        lastSavedMovieDetail = detail
        
        if let error = saveMovieDetailError {
            throw error
        }
    }
}

