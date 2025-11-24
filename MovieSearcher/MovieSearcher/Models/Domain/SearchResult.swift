//
//  SearchResult.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

/// Domain Model - Search result model
struct SearchResult {
    let movies: [Movie]
    let currentPage: Int
    let totalPages: Int
    let totalResults: Int
    
    /// Whether there are more pages available
    var hasMorePages: Bool {
        return currentPage < totalPages
    }
    
    /// Whether the result is empty
    var isEmpty: Bool {
        return movies.isEmpty
    }
}

