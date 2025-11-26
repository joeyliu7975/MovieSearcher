//
//  AccessibilityIdentifiers.swift
//  MovieSearcherUITests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

/// Centralized accessibility identifiers for UI testing
/// This mirrors the main app's AccessibilityIdentifiers for consistency
enum AccessibilityIdentifiers {
    enum Search {
        static let searchBar = "searchBar"
        static let moviesTableView = "moviesTableView"
        static let loadingIndicator = "loadingIndicator"
        static let emptyStateLabel = "emptyStateLabel"
    }
    
    enum Detail {
        static let favoriteButton = "favoriteButton"
        static let loadingIndicator = "detailLoadingIndicator"
    }
}

