//
//  LocalAccountStatesStore.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

class LocalAccountStatesStore: AccountStatesStore {
    private let dataAccess: LocalAccountStatesDataAccess
    
    init(dataAccess: LocalAccountStatesDataAccess = LocalAccountStatesDataAccess()) {
        self.dataAccess = dataAccess
    }
    
    func saveAccountStates(
        _ states: MovieAccountStates,
        accountId: String
    ) async throws {
        try await dataAccess.saveAccountStates(states, accountId: accountId)
    }
}

