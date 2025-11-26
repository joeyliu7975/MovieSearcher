//
//  CompositeMovieDataLoaderTests.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Testing
import Foundation
@testable import MovieSearcher

struct CompositeMovieDataLoaderTests {
    
    // MARK: - Search Movies Tests
    
    @Test("Search movies - local first")
    func testSearchMovies_LocalFirst() async throws {
        let localLoader = MockMovieDataLoader()
        let remoteLoader = MockMovieDataLoader()
        
        let localResult = SearchResult(
            movies: [Movie(
                id: 1,
                title: "Local Movie",
                originalTitle: "Local Movie",
                overview: "Local",
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
        localLoader.searchMoviesResult = localResult
        
        let composite = CompositeMovieDataLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        let result = try await composite.searchMovies(
            query: "test",
            includeAdult: false,
            language: "en-US",
            page: 1
        )
        
        #expect(result?.movies.first?.title == "Local Movie")
        #expect(localLoader.searchMoviesCallCount == 1)
        #expect(remoteLoader.searchMoviesCallCount == 0)
    }
    
    @Test("Search movies - remote fallback")
    func testSearchMovies_RemoteFallback() async throws {
        let localLoader = MockMovieDataLoader()
        let remoteLoader = MockMovieDataLoader()
        
        // Local returns nil
        localLoader.searchMoviesResult = nil
        
        let remoteResult = SearchResult(
            movies: [Movie(
                id: 2,
                title: "Remote Movie",
                originalTitle: "Remote Movie",
                overview: "Remote",
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
        remoteLoader.searchMoviesResult = remoteResult
        
        let composite = CompositeMovieDataLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        let result = try await composite.searchMovies(
            query: "test",
            includeAdult: false,
            language: "en-US",
            page: 1
        )
        
        #expect(result?.movies.first?.title == "Remote Movie")
        #expect(localLoader.searchMoviesCallCount == 1)
        #expect(remoteLoader.searchMoviesCallCount == 1)
    }
    
    @Test("Search movies - both fail")
    func testSearchMovies_BothFail() async throws {
        let localLoader = MockMovieDataLoader()
        let remoteLoader = MockMovieDataLoader()
        
        localLoader.searchMoviesResult = nil
        remoteLoader.searchMoviesError = NSError(domain: "TestError", code: 1)
        
        let composite = CompositeMovieDataLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        await #expect(throws: NSError.self) {
            try await composite.searchMovies(
                query: "test",
                includeAdult: false,
                language: "en-US",
                page: 1
            )
        }
        
        #expect(localLoader.searchMoviesCallCount == 1)
        #expect(remoteLoader.searchMoviesCallCount == 1)
    }
    
    // MARK: - Get Movie Detail Tests
    
    @Test("Get movie detail - local first")
    func testGetMovieDetail_LocalFirst() async throws {
        let localLoader = MockMovieDataLoader()
        let remoteLoader = MockMovieDataLoader()
        
        let localDetail = MovieDetail(
            id: 1,
            title: "Local Movie",
            originalTitle: "Local Movie",
            overview: "Local",
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
        localLoader.getMovieDetailResult = localDetail
        
        let composite = CompositeMovieDataLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        let result = try await composite.getMovieDetail(
            movieId: 1,
            language: "en-US"
        )
        
        #expect(result?.title == "Local Movie")
        #expect(localLoader.getMovieDetailCallCount == 1)
        #expect(remoteLoader.getMovieDetailCallCount == 0)
    }
    
    @Test("Get movie detail - remote fallback")
    func testGetMovieDetail_RemoteFallback() async throws {
        let localLoader = MockMovieDataLoader()
        let remoteLoader = MockMovieDataLoader()
        
        // Local returns nil
        localLoader.getMovieDetailResult = nil
        
        let remoteDetail = MovieDetail(
            id: 2,
            title: "Remote Movie",
            originalTitle: "Remote Movie",
            overview: "Remote",
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
        remoteLoader.getMovieDetailResult = remoteDetail
        
        let composite = CompositeMovieDataLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        let result = try await composite.getMovieDetail(
            movieId: 2,
            language: "en-US"
        )
        
        #expect(result?.title == "Remote Movie")
        #expect(localLoader.getMovieDetailCallCount == 1)
        #expect(remoteLoader.getMovieDetailCallCount == 1)
    }
    
    @Test("Get movie detail - both fail")
    func testGetMovieDetail_BothFail() async throws {
        let localLoader = MockMovieDataLoader()
        let remoteLoader = MockMovieDataLoader()
        
        localLoader.getMovieDetailResult = nil
        remoteLoader.getMovieDetailError = NSError(domain: "TestError", code: 1)
        
        let composite = CompositeMovieDataLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        await #expect(throws: NSError.self) {
            try await composite.getMovieDetail(
                movieId: 1,
                language: "en-US"
            )
        }
        
        #expect(localLoader.getMovieDetailCallCount == 1)
        #expect(remoteLoader.getMovieDetailCallCount == 1)
    }
}

