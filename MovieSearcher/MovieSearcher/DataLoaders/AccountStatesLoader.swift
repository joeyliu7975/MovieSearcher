//
//  AccountStatesLoader.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

protocol AccountStatesLoader {
    func getAccountStates(movieId: Int, accountId: String?) async throws -> MovieAccountStates?
    func markAsFavorite(
        accountId: String,
        movieId: Int,
        favorite: Bool
    ) async throws
}

