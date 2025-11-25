//
//  MovieRepository.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

enum RepositoryError: LocalizedError {
    case invalidQuery
    case invalidPage
    case dataUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "Search query cannot be empty"
        case .invalidPage:
            return "Invalid page number"
        case .dataUnavailable:
            return "Unable to fetch movie data"
        }
    }
}

protocol MovieRepositoryProtocol {
    func searchMovies(
        query: String,
        page: Int
    ) async throws -> SearchResult
}

class MovieRepository: MovieRepositoryProtocol {
    private let dataLoader: MovieDataLoader
    private let defaultIncludeAdult: Bool
    private let defaultLanguage: String
    
    init(
        dataLoader: MovieDataLoader = CompositeMovieDataLoader(),
        includeAdult: Bool = false,
        language: String = "en-US"
    ) {
        self.dataLoader = dataLoader
        self.defaultIncludeAdult = includeAdult
        self.defaultLanguage = language
    }
    
    func searchMovies(
        query: String,
        page: Int
    ) async throws -> SearchResult {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            throw RepositoryError.invalidQuery
        }
        
        guard page > 0 else {
            throw RepositoryError.invalidPage
        }
        
        guard let result = try await dataLoader.searchMovies(
            query: trimmedQuery,
            includeAdult: defaultIncludeAdult,
            language: defaultLanguage,
            page: page
        ) else {
            throw RepositoryError.dataUnavailable
        }
        
        return result
    }
}
