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
    case invalidMovieId
    case dataUnavailable
    case invalidAccountId
    
    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "Search query cannot be empty"
        case .invalidPage:
            return "Invalid page number"
        case .invalidMovieId:
            return "Invalid movie ID"
        case .dataUnavailable:
            return "Unable to fetch movie data"
        case .invalidAccountId:
            return "Invalid account ID"
        }
    }
}

protocol MovieSearchRepositoryProtocol {
    func searchMovies(
        query: String,
        page: Int
    ) async throws -> SearchResult
}

protocol MovieDetailRepositoryProtocol {
    func getMovieDetail(movieId: Int) async throws -> MovieDetail
}

protocol MovieAccountStatesRepositoryProtocol {
    func getMovieAccountStates(movieId: Int) async throws -> MovieAccountStates
}

protocol MovieFavoriteRepositoryProtocol {
    func markAsFavorite(
        accountId: String,
        movieId: Int,
        favorite: Bool
    ) async throws
}

class MovieRepository {
    private let dataLoader: MovieDataLoader
    private let accountStatesLoader: AccountStatesLoader
    private let defaultIncludeAdult: Bool
    private let defaultLanguage: String
    
    init(
        dataLoader: MovieDataLoader = CachingMovieDataDecorator(
            decoratee: CompositeMovieDataLoader()
        ),
        accountStatesLoader: AccountStatesLoader = CachingAccountStatesDecorator(
            decoratee: CompositeAccountStatesLoader()
        ),
        includeAdult: Bool = false,
        language: String = "en-US"
    ) {
        self.dataLoader = dataLoader
        self.accountStatesLoader = accountStatesLoader
        self.defaultIncludeAdult = includeAdult
        self.defaultLanguage = language
    }
}

extension MovieRepository: MovieSearchRepositoryProtocol {
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

extension MovieRepository: MovieDetailRepositoryProtocol {
    func getMovieDetail(movieId: Int) async throws -> MovieDetail {
        guard movieId > 0 else {
            throw RepositoryError.invalidMovieId
        }
        
        guard let detail = try await dataLoader.getMovieDetail(
            movieId: movieId,
            language: defaultLanguage
        ) else {
            throw RepositoryError.dataUnavailable
        }
        
        return detail
    }
}

extension MovieRepository: MovieAccountStatesRepositoryProtocol {
    func getMovieAccountStates(movieId: Int) async throws -> MovieAccountStates {
        guard movieId > 0 else {
            throw RepositoryError.invalidMovieId
        }
        
        let accountId = APIConfiguration.accountId
        guard let states = try await accountStatesLoader.getAccountStates(
            movieId: movieId,
            accountId: accountId
        ) else {
            throw RepositoryError.dataUnavailable
        }
        
        return states
    }
}

extension MovieRepository: MovieFavoriteRepositoryProtocol {
    func markAsFavorite(
        accountId: String,
        movieId: Int,
        favorite: Bool
    ) async throws {
        guard movieId > 0 else {
            throw RepositoryError.invalidMovieId
        }
        
        guard !accountId.isEmpty else {
            throw RepositoryError.invalidAccountId
        }
        
        try await accountStatesLoader.markAsFavorite(
            accountId: accountId,
            movieId: movieId,
            favorite: favorite
        )
    }
}
