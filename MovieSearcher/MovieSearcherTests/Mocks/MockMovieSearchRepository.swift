//
//  MockMovieSearchRepository.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
@testable import MovieSearcher

class MockMovieSearchRepository: MovieSearchRepositoryProtocol {
    var searchMoviesResult: SearchResult?
    var searchMoviesError: Error?
    
    var searchMoviesCallCount = 0
    var lastSearchQuery: String?
    var lastSearchPage: Int?
    
    func searchMovies(query: String, page: Int) async throws -> SearchResult {
        searchMoviesCallCount += 1
        lastSearchQuery = query
        lastSearchPage = page
        
        if let error = searchMoviesError {
            throw error
        }
        
        guard let result = searchMoviesResult else {
            throw RepositoryError.dataUnavailable
        }
        
        return result
    }
}

