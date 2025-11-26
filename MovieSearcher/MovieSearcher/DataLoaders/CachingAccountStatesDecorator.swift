//
//  CachingAccountStatesDecorator.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

class CachingAccountStatesDecorator<T: AccountStatesLoader>: AccountStatesLoader {
    private let decoratee: T
    private let store: AccountStatesStore
    
    init(
        decoratee: T,
        store: AccountStatesStore = LocalAccountStatesStore()
    ) {
        self.decoratee = decoratee
        self.store = store
    }
    
    func getAccountStates(
        movieId: Int,
        accountId: String?
    ) async throws -> MovieAccountStates? {
        let states = try await decoratee.getAccountStates(
            movieId: movieId,
            accountId: accountId
        )
        
        // 自動保存（如果是從遠端取得的）
        if let states = states, let accountId = accountId {
            Task.detached { [weak self] in
                try? await self?.store.saveAccountStates(
                    states,
                    accountId: accountId
                )
            }
        }
        
        return states
    }
    
    func markAsFavorite(
        accountId: String,
        movieId: Int,
        favorite: Bool
    ) async throws {
        // 直接轉發，不需要額外處理（因為 decoratee 已經處理了樂觀更新）
        try await decoratee.markAsFavorite(
            accountId: accountId,
            movieId: movieId,
            favorite: favorite
        )
    }
}

