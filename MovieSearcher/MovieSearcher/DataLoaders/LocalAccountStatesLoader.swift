//
//  LocalAccountStatesLoader.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

class LocalAccountStatesLoader: AccountStatesLoader {
    private let dataAccess: AccountStatesDataAccessProtocol
    
    init(dataAccess: AccountStatesDataAccessProtocol = LocalAccountStatesDataAccess()) {
        self.dataAccess = dataAccess
    }
    
    func getAccountStates(movieId: Int, accountId: String?) async throws -> MovieAccountStates? {
        guard let accountId = accountId, !accountId.isEmpty else {
            return nil
        }
        
        return try await dataAccess.getAccountStates(
            movieId: movieId,
            accountId: accountId
        )
    }
    
    func markAsFavorite(
        accountId: String,
        movieId: Int,
        favorite: Bool
    ) async throws {
        try await dataAccess.saveFavoriteStatus(
            movieId: movieId,
            accountId: accountId,
            isFavorite: favorite
        )
    }
}

