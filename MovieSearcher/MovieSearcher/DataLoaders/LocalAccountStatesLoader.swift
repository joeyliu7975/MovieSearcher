//
//  LocalAccountStatesLoader.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

class LocalAccountStatesLoader: AccountStatesLoader {
    private let localDataLoader: LocalMovieDataLoader
    
    init(localDataLoader: LocalMovieDataLoader = LocalMovieDataLoader()) {
        self.localDataLoader = localDataLoader
    }
    
    func getAccountStates(movieId: Int, accountId: String?) async throws -> MovieAccountStates? {
        guard let accountId = accountId, !accountId.isEmpty else {
            return nil
        }
        
        return try await localDataLoader.getAccountStates(
            movieId: movieId,
            accountId: accountId
        )
    }
    
    func markAsFavorite(
        accountId: String,
        movieId: Int,
        favorite: Bool
    ) async throws {
        try await localDataLoader.saveFavoriteStatus(
            movieId: movieId,
            accountId: accountId,
            isFavorite: favorite
        )
    }
    
    func saveAccountStates(_ states: MovieAccountStates, accountId: String) async throws {
        try await localDataLoader.saveAccountStates(states, accountId: accountId)
    }
}

