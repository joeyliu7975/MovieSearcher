//
//  MovieRepository.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

protocol MovieRepositoryProtocol {
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResult
}

class MovieRepository: MovieRepositoryProtocol {
    private let apiService: MovieAPIServiceProtocol
    
    init(apiService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.apiService = apiService
    }
    
    func searchMovies(
        query: String,
        includeAdult: Bool = false,
        language: String = "en-US",
        page: Int = 1
    ) async throws -> SearchResult {
        let dto = try await apiService.searchMovies(
            query: query,
            includeAdult: includeAdult,
            language: language,
            page: page
        )
        return MovieMapper.toDomain(dto)
    }
}

