//
//  CompositeAccountStatesLoader.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

class CompositeAccountStatesLoader: AccountStatesLoader {
    private let localLoader: LocalAccountStatesLoader
    private let remoteLoader: RemoteAccountStatesLoader
    
    init(
        localLoader: LocalAccountStatesLoader = LocalAccountStatesLoader(),
        remoteLoader: RemoteAccountStatesLoader = RemoteAccountStatesLoader()
    ) {
        self.localLoader = localLoader
        self.remoteLoader = remoteLoader
    }
    
    func getAccountStates(movieId: Int, accountId: String?) async throws -> MovieAccountStates? {
        if let accountId = accountId,
           let local = try await localLoader.getAccountStates(movieId: movieId, accountId: accountId) {
            Task.detached { [weak self] in
                guard let self = self else { return }
                do {
                    if let remote = try await self.remoteLoader.getAccountStates(
                        movieId: movieId,
                        accountId: accountId
                    ) {
                        try? await self.localLoader.saveAccountStates(
                            remote,
                            accountId: accountId
                        )
                    }
                } catch {
                    print("Background update failed: \(error)")
                }
            }
            return local
        }
        
        guard let remote = try await remoteLoader.getAccountStates(
            movieId: movieId,
            accountId: accountId
        ) else {
            return nil
        }
         
        if let accountId = accountId {
            Task.detached { [weak self] in
                try? await self?.localLoader.saveAccountStates(
                    remote,
                    accountId: accountId
                )
            }
        }
        
        return remote
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

