//
//  AccountStatesStore.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

protocol AccountStatesStore {
    func saveAccountStates(
        _ states: MovieAccountStates,
        accountId: String
    ) async throws
}

