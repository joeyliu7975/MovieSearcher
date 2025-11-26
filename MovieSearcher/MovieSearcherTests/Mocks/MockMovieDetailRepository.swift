//
//  MockMovieDetailRepository.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
@testable import MovieSearcher

class MockMovieDetailRepository: MovieDetailRepositoryProtocol, MovieAccountStatesRepositoryProtocol, MovieFavoriteRepositoryProtocol {
    var getMovieDetailResult: MovieDetail?
    var getMovieDetailError: Error?
    var getMovieAccountStatesResult: MovieAccountStates?
    var getMovieAccountStatesError: Error?
    var markAsFavoriteError: Error?
    
    var getMovieDetailCallCount = 0
    var getMovieAccountStatesCallCount = 0
    var markAsFavoriteCallCount = 0
    var lastMarkAsFavoriteAccountId: String?
    var lastMarkAsFavoriteMovieId: Int?
    var lastMarkAsFavoriteValue: Bool?
    
    func getMovieDetail(movieId: Int) async throws -> MovieDetail {
        getMovieDetailCallCount += 1
        
        if let error = getMovieDetailError {
            throw error
        }
        
        guard let result = getMovieDetailResult else {
            throw RepositoryError.dataUnavailable
        }
        
        return result
    }
    
    func getMovieAccountStates(movieId: Int) async throws -> MovieAccountStates {
        getMovieAccountStatesCallCount += 1
        
        if let error = getMovieAccountStatesError {
            throw error
        }
        
        guard let result = getMovieAccountStatesResult else {
            throw RepositoryError.dataUnavailable
        }
        
        return result
    }
    
    func markAsFavorite(
        accountId: String,
        movieId: Int,
        favorite: Bool
    ) async throws {
        markAsFavoriteCallCount += 1
        lastMarkAsFavoriteAccountId = accountId
        lastMarkAsFavoriteMovieId = movieId
        lastMarkAsFavoriteValue = favorite
        
        if let error = markAsFavoriteError {
            throw error
        }
    }
}

