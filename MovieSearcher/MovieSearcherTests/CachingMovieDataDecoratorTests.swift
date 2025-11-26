//
//  CachingMovieDataDecoratorTests.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Testing
import Foundation
@testable import MovieSearcher

struct CachingMovieDataDecoratorTests {
    
    // MARK: - Search Movies Tests
    
    @Test("Search movies - caches result")
    func testSearchMovies_CachesResult() async throws {
        let mockLoader = MockMovieDataLoader()
        let mockStore = MockMovieDataStore()
        
        let expectedResult = SearchResult(
            movies: [Movie(
                id: 1,
                title: "Test Movie",
                originalTitle: "Test Movie",
                overview: "Test",
                releaseDate: nil,
                posterPath: nil,
                backdropPath: nil,
                voteAverage: 8.0,
                voteCount: 100,
                popularity: 100.0,
                genreIds: [],
                isAdult: false,
                hasVideo: false,
                originalLanguage: "en"
            )],
            currentPage: 1,
            totalPages: 1,
            totalResults: 1
        )
        mockLoader.searchMoviesResult = expectedResult
        
        let decorator = CachingMovieDataDecorator(
            decoratee: mockLoader,
            store: mockStore
        )
        
        let result = try await decorator.searchMovies(
            query: "test",
            includeAdult: false,
            language: "en-US",
            page: 1
        )
        
        #expect(result?.movies.first?.title == "Test Movie")
        #expect(mockLoader.searchMoviesCallCount == 1)
        
        // Wait for async save to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(mockStore.saveSearchResultCallCount == 1)
        #expect(mockStore.lastSavedSearchResult?.movies.first?.title == "Test Movie")
    }
    
    @Test("Search movies - store error does not fail")
    func testSearchMovies_StoreError_DoesNotFail() async throws {
        let mockLoader = MockMovieDataLoader()
        let mockStore = MockMovieDataStore()
        mockStore.saveSearchResultError = NSError(domain: "StoreError", code: 1)
        
        let expectedResult = SearchResult(
            movies: [Movie(
                id: 1,
                title: "Test Movie",
                originalTitle: "Test Movie",
                overview: "Test",
                releaseDate: nil,
                posterPath: nil,
                backdropPath: nil,
                voteAverage: 8.0,
                voteCount: 100,
                popularity: 100.0,
                genreIds: [],
                isAdult: false,
                hasVideo: false,
                originalLanguage: "en"
            )],
            currentPage: 1,
            totalPages: 1,
            totalResults: 1
        )
        mockLoader.searchMoviesResult = expectedResult
        
        let decorator = CachingMovieDataDecorator(
            decoratee: mockLoader,
            store: mockStore
        )
        
        // Should not throw error even if store fails
        let result = try await decorator.searchMovies(
            query: "test",
            includeAdult: false,
            language: "en-US",
            page: 1
        )
        
        #expect(result != nil)
        #expect(mockLoader.searchMoviesCallCount == 1)
        
        // Wait for async save attempt
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(mockStore.saveSearchResultCallCount == 1)
    }
    
    // MARK: - Get Movie Detail Tests
    
    @Test("Get movie detail - caches result")
    func testGetMovieDetail_CachesResult() async throws {
        let mockLoader = MockMovieDataLoader()
        let mockStore = MockMovieDataStore()
        
        let expectedDetail = MovieDetail(
            id: 1,
            title: "Test Movie",
            originalTitle: "Test Movie",
            overview: "Test",
            releaseDate: nil,
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 8.0,
            voteCount: 100,
            popularity: 100.0,
            runtime: nil,
            tagline: nil,
            status: "Released",
            genres: [],
            productionCompanies: [],
            productionCountries: [],
            spokenLanguages: [],
            homepage: nil,
            imdbId: nil,
            budget: 0,
            revenue: 0
        )
        mockLoader.getMovieDetailResult = expectedDetail
        
        let decorator = CachingMovieDataDecorator(
            decoratee: mockLoader,
            store: mockStore
        )
        
        let result = try await decorator.getMovieDetail(
            movieId: 1,
            language: "en-US"
        )
        
        #expect(result?.title == "Test Movie")
        #expect(mockLoader.getMovieDetailCallCount == 1)
        
        // Wait for async save to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(mockStore.saveMovieDetailCallCount == 1)
        #expect(mockStore.lastSavedMovieDetail?.title == "Test Movie")
    }
    
    @Test("Get movie detail - store error does not fail")
    func testGetMovieDetail_StoreError_DoesNotFail() async throws {
        let mockLoader = MockMovieDataLoader()
        let mockStore = MockMovieDataStore()
        mockStore.saveMovieDetailError = NSError(domain: "StoreError", code: 1)
        
        let expectedDetail = MovieDetail(
            id: 1,
            title: "Test Movie",
            originalTitle: "Test Movie",
            overview: "Test",
            releaseDate: nil,
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 8.0,
            voteCount: 100,
            popularity: 100.0,
            runtime: nil,
            tagline: nil,
            status: "Released",
            genres: [],
            productionCompanies: [],
            productionCountries: [],
            spokenLanguages: [],
            homepage: nil,
            imdbId: nil,
            budget: 0,
            revenue: 0
        )
        mockLoader.getMovieDetailResult = expectedDetail
        
        let decorator = CachingMovieDataDecorator(
            decoratee: mockLoader,
            store: mockStore
        )
        
        // Should not throw error even if store fails
        let result = try await decorator.getMovieDetail(
            movieId: 1,
            language: "en-US"
        )
        
        #expect(result != nil)
        #expect(mockLoader.getMovieDetailCallCount == 1)
        
        // Wait for async save attempt
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(mockStore.saveMovieDetailCallCount == 1)
    }
}

