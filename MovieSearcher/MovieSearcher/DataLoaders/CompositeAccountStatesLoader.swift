//
//  CompositeAccountStatesLoader.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

class CompositeAccountStatesLoader: AccountStatesLoader {
    private let localLoader: AccountStatesLoader
    private let remoteLoader: AccountStatesLoader
    
    init(
        localLoader: AccountStatesLoader = LocalAccountStatesLoader(),
        remoteLoader: AccountStatesLoader = RemoteAccountStatesLoader()
    ) {
        self.localLoader = localLoader
        self.remoteLoader = remoteLoader
    }
    
    func getAccountStates(movieId: Int, accountId: String?) async throws -> MovieAccountStates? {
        if let accountId = accountId,
           let local = try await localLoader.getAccountStates(
               movieId: movieId,
               accountId: accountId
           ) {
            Task.detached { [weak self] in
                guard let self = self else { return }
                _ = try? await self.remoteLoader.getAccountStates(
                    movieId: movieId,
                    accountId: accountId
                )
            }
            return local
        }
        
        return try await remoteLoader.getAccountStates(
            movieId: movieId,
            accountId: accountId
        )
    }
    
    func markAsFavorite(
        accountId: String,
        movieId: Int,
        favorite: Bool
    ) async throws {
        try await localLoader.markAsFavorite(
            accountId: accountId,
            movieId: movieId,
            favorite: favorite
        )
        
        do {
            try await remoteLoader.markAsFavorite(
                accountId: accountId,
                movieId: movieId,
                favorite: favorite
            )
        } catch {
            try? await localLoader.markAsFavorite(
                accountId: accountId,
                movieId: movieId,
                favorite: !favorite
            )
            throw error
        }
    }
}

