//
//  MockAccountStatesLoader.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
@testable import MovieSearcher

class MockAccountStatesLoader: AccountStatesLoader {
    var getAccountStatesResult: MovieAccountStates?
    var getAccountStatesError: Error?
    var markAsFavoriteError: Error?
    
    var getAccountStatesCallCount = 0
    var markAsFavoriteCallCount = 0
    var lastMarkAsFavoriteAccountId: String?
    var lastMarkAsFavoriteMovieId: Int?
    var lastMarkAsFavoriteValue: Bool?
    
    func getAccountStates(movieId: Int, accountId: String?) async throws -> MovieAccountStates? {
        getAccountStatesCallCount += 1
        
        if let error = getAccountStatesError {
            throw error
        }
        
        return getAccountStatesResult
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

