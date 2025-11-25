//
//  MovieAccountStates.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

/// Domain Model - Movie account states model used internally by the app
/// Does not depend on API structure and can contain business logic
struct MovieAccountStates {
    let id: Int
    let favorite: Bool
    let rated: Bool
    let watchlist: Bool
}

