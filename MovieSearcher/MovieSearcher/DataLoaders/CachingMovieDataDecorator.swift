//
//  CachingMovieDataDecorator.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

class CachingMovieDataDecorator<T: MovieDataLoader>: MovieDataLoader {
    private let decoratee: T
    private let store: MovieDataStore
    
    init(
        decoratee: T,
        store: MovieDataStore = LocalMovieDataStore()
    ) {
        self.decoratee = decoratee
        self.store = store
    }
    
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResult? {
        let result = try await decoratee.searchMovies(
            query: query,
            includeAdult: includeAdult,
            language: language,
            page: page
        )
        
        if let result = result {
            Task.detached { [weak self] in
                try? await self?.store.saveSearchResult(
                    result,
                    query: query,
                    page: page,
                    language: language
                )
            }
        }
        
        return result
    }
    
    func getMovieDetail(
        movieId: Int,
        language: String
    ) async throws -> MovieDetail? {
        let detail = try await decoratee.getMovieDetail(
            movieId: movieId,
            language: language
        )
        
        // 自動保存（保存操作是冪等的，所以即使本地已有資料也可以保存）
        if let detail = detail {
            Task.detached { [weak self] in
                try? await self?.store.saveMovieDetail(detail)
            }
        }
        
        return detail
    }
}

