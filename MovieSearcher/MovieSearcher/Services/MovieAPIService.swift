//
//  MovieAPIService.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

protocol MovieAPIServiceProtocol {
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResponseDTO
    func getMovieDetail(
        movieId: Int,
        language: String
    ) async throws -> MovieDetailDTO
}

class MovieAPIService: MovieAPIServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResponseDTO {
        let endpoint = MovieEndpoints.searchMovies(
            query: query,
            includeAdult: includeAdult,
            language: language,
            page: page
        )
        return try await networkService.request(endpoint, responseType: SearchResponseDTO.self)
    }
    
    func getMovieDetail(
        movieId: Int,
        language: String
    ) async throws -> MovieDetailDTO {
        let endpoint = MovieEndpoints.getMovieDetail(
            movieId: movieId,
            language: language
        )
        return try await networkService.request(endpoint, responseType: MovieDetailDTO.self)
    }
}

