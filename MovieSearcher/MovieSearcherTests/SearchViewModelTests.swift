//
//  SearchViewModelTests.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Testing
import Combine
@testable import MovieSearcher

@MainActor
struct SearchViewModelTests {
    
    // MARK: - Search Movies Tests
    
    @Test("Search movies - success")
    func testSearchMovies_Success() async throws {
        let mockRepository = MockMovieSearchRepository()
        let expectedMovies = [
            Movie(
                id: 1,
                title: "Movie 1",
                originalTitle: "Movie 1",
                overview: "Overview 1",
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
            ),
            Movie(
                id: 2,
                title: "Movie 2",
                originalTitle: "Movie 2",
                overview: "Overview 2",
                releaseDate: nil,
                posterPath: nil,
                backdropPath: nil,
                voteAverage: 7.5,
                voteCount: 50,
                popularity: 50.0,
                genreIds: [],
                isAdult: false,
                hasVideo: false,
                originalLanguage: "en"
            )
        ]
        mockRepository.searchMoviesResult = SearchResult(
            movies: expectedMovies,
            currentPage: 1,
            totalPages: 2,
            totalResults: 2
        )
        
        let viewModel = SearchViewModel(repository: mockRepository)
        
        let moviesExpectation = AsyncExpectation()
        let isLoadingExpectation = AsyncExpectation()
        
        let cancellable1 = viewModel.moviesPublisher
            .sink { movies in
                if movies.count == 2 {
                    moviesExpectation.fulfill()
                }
            }
        
        let cancellable2 = viewModel.isLoadingPublisher
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        viewModel.searchMovies(query: "test", page: 1)
        
        try await moviesExpectation.wait(timeout: .seconds(2))
        try await isLoadingExpectation.wait(timeout: .seconds(2))
        
        #expect(viewModel.movies.count == 2)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isEmpty == false)
        #expect(mockRepository.searchMoviesCallCount == 1)
        
        cancellable1.cancel()
        cancellable2.cancel()
    }
    
    @Test("Search movies - empty query")
    func testSearchMovies_EmptyQuery() async throws {
        let mockRepository = MockMovieSearchRepository()
        let viewModel = SearchViewModel(repository: mockRepository)
        
        viewModel.searchMovies(query: "", page: 1)
        
        // Wait a bit for async operations
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(viewModel.movies.isEmpty)
        #expect(viewModel.isEmpty == true)
        #expect(mockRepository.searchMoviesCallCount == 0)
    }
    
    @Test("Search movies - error handling")
    func testSearchMovies_Error() async throws {
        let mockRepository = MockMovieSearchRepository()
        mockRepository.searchMoviesError = RepositoryError.dataUnavailable
        
        let viewModel = SearchViewModel(repository: mockRepository)
        
        let errorExpectation = AsyncExpectation()
        
        let cancellable = viewModel.errorMessagePublisher
            .compactMap { $0 }
            .sink { _ in
                errorExpectation.fulfill()
            }
        
        viewModel.searchMovies(query: "test", page: 1)
        
        try await errorExpectation.wait(timeout: .seconds(2))
        
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
        #expect(mockRepository.searchMoviesCallCount == 1)
        
        cancellable.cancel()
    }
    
    @Test("Load next page - success")
    func testLoadNextPage_Success() async throws {
        let mockRepository = MockMovieSearchRepository()
        mockRepository.searchMoviesResult = SearchResult(
            movies: [Movie(
                id: 1,
                title: "Movie 1",
                originalTitle: "Movie 1",
                overview: "Overview",
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
            totalPages: 2,
            totalResults: 2
        )
        
        let viewModel = SearchViewModel(repository: mockRepository)
        viewModel.searchMovies(query: "test", page: 1)
        
        // Wait for first search to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Load next page
        viewModel.loadNextPage()
        
        // Wait for next page to load
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(mockRepository.searchMoviesCallCount == 2)
        #expect(mockRepository.lastSearchPage == 2)
    }
    
    @Test("Load next page - when loading")
    func testLoadNextPage_WhenLoading() async throws {
        let mockRepository = MockMovieSearchRepository()
        let viewModel = SearchViewModel(repository: mockRepository)
        
        viewModel.searchMovies(query: "test", page: 1)
        
        // Immediately try to load next page while still loading
        viewModel.loadNextPage()
        
        // Wait a bit
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Should only have one call (the initial search)
        #expect(mockRepository.searchMoviesCallCount <= 1)
    }
    
    @Test("Load next page - no more pages")
    func testLoadNextPage_NoMorePages() async throws {
        let mockRepository = MockMovieSearchRepository()
        mockRepository.searchMoviesResult = SearchResult(
            movies: [Movie(
                id: 1,
                title: "Movie 1",
                originalTitle: "Movie 1",
                overview: "Overview",
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
        
        let viewModel = SearchViewModel(repository: mockRepository)
        viewModel.searchMovies(query: "test", page: 1)
        
        // Wait for search to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Try to load next page (should not load)
        viewModel.loadNextPage()
        
        // Wait a bit
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(mockRepository.searchMoviesCallCount == 1)
    }
    
    @Test("Has more pages - true")
    func testHasMorePages_True() async throws {
        let mockRepository = MockMovieSearchRepository()
        mockRepository.searchMoviesResult = SearchResult(
            movies: [],
            currentPage: 1,
            totalPages: 3,
            totalResults: 0
        )
        
        let viewModel = SearchViewModel(repository: mockRepository)
        viewModel.searchMovies(query: "test", page: 1)
        
        // Wait for search to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(viewModel.hasMorePages == true)
    }
    
    @Test("Has more pages - false")
    func testHasMorePages_False() async throws {
        let mockRepository = MockMovieSearchRepository()
        mockRepository.searchMoviesResult = SearchResult(
            movies: [],
            currentPage: 1,
            totalPages: 1,
            totalResults: 0
        )
        
        let viewModel = SearchViewModel(repository: mockRepository)
        viewModel.searchMovies(query: "test", page: 1)
        
        // Wait for search to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        #expect(viewModel.hasMorePages == false)
    }
    
    @Test("Reset - clears state")
    func testReset_ClearsState() async throws {
        let mockRepository = MockMovieSearchRepository()
        mockRepository.searchMoviesResult = SearchResult(
            movies: [Movie(
                id: 1,
                title: "Movie 1",
                originalTitle: "Movie 1",
                overview: "Overview",
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
        
        let viewModel = SearchViewModel(repository: mockRepository)
        viewModel.searchMovies(query: "test", page: 1)
        
        // Wait for search to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        viewModel.reset()
        
        #expect(viewModel.movies.isEmpty)
        #expect(viewModel.isEmpty == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
}

