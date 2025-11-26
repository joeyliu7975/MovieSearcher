//
//  MockMovieDataLoader.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
@testable import MovieSearcher

class MockMovieDataLoader: MovieDataLoader {
    var searchMoviesResult: SearchResult?
    var searchMoviesError: Error?
    var getMovieDetailResult: MovieDetail?
    var getMovieDetailError: Error?
    
    var searchMoviesCallCount = 0
    var getMovieDetailCallCount = 0
    
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResult? {
        searchMoviesCallCount += 1
        
        if let error = searchMoviesError {
            throw error
        }
        
        return searchMoviesResult
    }
    
    func getMovieDetail(
        movieId: Int,
        language: String
    ) async throws -> MovieDetail? {
        getMovieDetailCallCount += 1
        
        if let error = getMovieDetailError {
            throw error
        }
        
        return getMovieDetailResult
    }
}

