//
//  AccountStatesDataAccessProtocol.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

protocol AccountStatesDataAccessProtocol {
    func getFavoriteStatus(movieId: Int, accountId: String) async throws -> Bool?
    func saveFavoriteStatus(movieId: Int, accountId: String, isFavorite: Bool) async throws
    func getAccountStates(movieId: Int, accountId: String) async throws -> MovieAccountStates?
    func saveAccountStates(_ states: MovieAccountStates, accountId: String) async throws
}

