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
    private let dataLoader: MovieDataLoader
    
    init(dataLoader: MovieDataLoader = CompositeMovieDataLoader()) {
        self.dataLoader = dataLoader
    }
    
    func searchMovies(
        query: String,
        includeAdult: Bool = false,
        language: String = "en-US",
        page: Int = 1
    ) async throws -> SearchResult {
        guard let result = try await dataLoader.searchMovies(
            query: query,
            includeAdult: includeAdult,
            language: language,
            page: page
        ) else {
            throw NSError(
                domain: "MovieRepository",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to fetch movies"]
            )
        }
        return result
    }
}
