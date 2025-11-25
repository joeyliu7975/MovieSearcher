//
//  RemoteAccountStatesLoader.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

class RemoteAccountStatesLoader: AccountStatesLoader {
    private let apiService: MovieAPIServiceProtocol
    
    init(apiService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.apiService = apiService
    }
    
    func getAccountStates(movieId: Int, accountId: String?) async throws -> MovieAccountStates? {
        let dto = try await apiService.getMovieAccountStates(movieId: movieId)
        return MovieMapper.toDomain(dto)
    }
    
    func markAsFavorite(
        accountId: String,
        movieId: Int,
        favorite: Bool
    ) async throws {
        _ = try await apiService.markAsFavorite(
            accountId: accountId,
            mediaType: "movie",
            mediaId: movieId,
            favorite: favorite
        )
    }
}

