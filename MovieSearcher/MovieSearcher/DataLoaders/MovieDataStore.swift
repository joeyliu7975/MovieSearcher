//
//  MovieDataStore.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

protocol MovieDataStore {
    func saveSearchResult(
        _ result: SearchResult,
        query: String,
        page: Int,
        language: String
    ) async throws
    
    func saveMovieDetail(_ detail: MovieDetail) async throws
}

