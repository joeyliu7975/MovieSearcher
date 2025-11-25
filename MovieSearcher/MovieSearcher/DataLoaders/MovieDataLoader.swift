//
//  MovieDataLoader.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

protocol MovieDataLoader {
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResult?
    
    func getMovieDetail(
        movieId: Int,
        language: String
    ) async throws -> MovieDetail?
}
