//
//  MovieDetailViewModelTests.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Testing
import Combine
@testable import MovieSearcher

@MainActor
struct MovieDetailViewModelTests {
    
    // MARK: - Load Movie Detail Tests
    
    @Test("Load movie detail - success")
    func testLoadMovieDetail_Success() async throws {
        let mockRepository = MockMovieDetailRepository()
        let expectedDetail = MovieDetail(
            id: 1,
            title: "Test Movie",
            originalTitle: "Test Movie",
            overview: "Test overview",
            releaseDate: nil,
            posterPath: nil,
            backdropPath: nil,
            voteAverage: 8.5,
            voteCount: 100,
            popularity: 100.0,
            runtime: 120,
            tagline: "Test tagline",
            status: "Released",
            genres: [],
            productionCompanies: [],
            productionCountries: [],
            spokenLanguages: [],
            homepage: nil,
            imdbId: nil,
            budget: 1000000,
            revenue: 2000000
        )
        mockRepository.getMovieDetailResult = expectedDetail
        
        let viewModel = MovieDetailViewModel(
            movieId: 1,
            accountId: "test_account",
            repository: mockRepository
        )
        
        let detailExpectation = AsyncExpectation()
        let isLoadingExpectation = AsyncExpectation()
        
        let cancellable1 = viewModel.$movieDetail
            .compactMap { $0 }
            .sink { _ in
                detailExpectation.fulfill()
            }
        
        let cancellable2 = viewModel.$isLoading
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        viewModel.loadMovieDetail()
        
        try await detailExpectation.wait(timeout: .seconds(2))
        try await isLoadingExpectation.wait(timeout: .seconds(2))
        
        #expect(viewModel.movieDetail?.id == 1)
        #expect(viewModel.movieDetail?.title == "Test Movie")
        #expect(viewModel.isLoading == false)
        #expect(mockRepository.getMovieDetailCallCount == 1)
        
        cancellable1.cancel()
        cancellable2.cancel()
    }
    
    @Test("Load movie detail - error")
    func testLoadMovieDetail_Error() async throws {
        let mockRepository = MockMovieDetailRepository()
        mockRepository.getMovieDetailError = RepositoryError.dataUnavailable
        
        let viewModel = MovieDetailViewModel(
            movieId: 1,
            accountId: "test_account",
            repository: mockRepository
        )
        
        let errorExpectation = AsyncExpectation()
        
        let cancellable = viewModel.$errorMessage
            .compactMap { $0 }
            .sink { _ in
                errorExpectation.fulfill()
            }
        
        viewModel.loadMovieDetail()
        
        try await errorExpectation.wait(timeout: .seconds(2))
        
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
        #expect(mockRepository.getMovieDetailCallCount == 1)
        
        cancellable.cancel()
    }
    
    // MARK: - Load Account States Tests
    
    @Test("Load account states - success")
    func testLoadAccountStates_Success() async throws {
        let mockRepository = MockMovieDetailRepository()
        let expectedStates = MovieAccountStates(
            id: 1,
            favorite: true,
            rated: false,
            watchlist: false
        )
        mockRepository.getMovieAccountStatesResult = expectedStates
        
        let viewModel = MovieDetailViewModel(
            movieId: 1,
            accountId: "test_account",
            repository: mockRepository
        )
        
        // Load movie detail first to trigger account states loading
        mockRepository.getMovieDetailResult = MovieDetail(
            id: 1,
            title: "Test",
            originalTitle: "Test",
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
        
        let favoriteExpectation = AsyncExpectation()
        
        let cancellable = viewModel.$isFavorite
            .compactMap { $0 }
            .sink { _ in
                favoriteExpectation.fulfill()
            }
        
        viewModel.loadMovieDetail()
        
        try await favoriteExpectation.wait(timeout: .seconds(2))
        
        #expect(viewModel.isFavorite == true)
        #expect(mockRepository.getMovieAccountStatesCallCount == 1)
        
        cancellable.cancel()
    }
    
    @Test("Load account states - no account ID")
    func testLoadAccountStates_NoAccountId() async throws {
        let mockRepository = MockMovieDetailRepository()
        mockRepository.getMovieDetailResult = MovieDetail(
            id: 1,
            title: "Test",
            originalTitle: "Test",
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
        
        let viewModel = MovieDetailViewModel(
            movieId: 1,
            accountId: nil,
            repository: mockRepository
        )
        
        viewModel.loadMovieDetail()
        
        // Wait for movie detail to load
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Account states should not be loaded
        #expect(mockRepository.getMovieAccountStatesCallCount == 0)
    }
    
    @Test("Load account states - error")
    func testLoadAccountStates_Error() async throws {
        let mockRepository = MockMovieDetailRepository()
        mockRepository.getMovieDetailResult = MovieDetail(
            id: 1,
            title: "Test",
            originalTitle: "Test",
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
        mockRepository.getMovieAccountStatesError = RepositoryError.dataUnavailable
        
        let viewModel = MovieDetailViewModel(
            movieId: 1,
            accountId: "test_account",
            repository: mockRepository
        )
        
        viewModel.loadMovieDetail()
        
        // Wait for operations to complete
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Error should be handled silently (only printed)
        #expect(mockRepository.getMovieAccountStatesCallCount == 1)
    }
    
    // MARK: - Toggle Favorite Tests
    
    @Test("Toggle favorite - success")
    func testToggleFavorite_Success() async throws {
        let mockRepository = MockMovieDetailRepository()
        // Set initial favorite state to false
        mockRepository.getMovieAccountStatesResult = MovieAccountStates(
            id: 1,
            favorite: false,
            rated: false,
            watchlist: false
        )
        
        let viewModel = MovieDetailViewModel(
            movieId: 1,
            accountId: "test_account",
            repository: mockRepository
        )
        
        // Load initial favorite state
        viewModel.loadAccountStates()
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for initial load
        
        // Verify initial state
        #expect(viewModel.isFavorite == false)
        
        let favoriteExpectation = AsyncExpectation()
        
        let cancellable = viewModel.$isFavorite
            .compactMap { $0 }
            .sink { isFavorite in
                if isFavorite == true {
                    favoriteExpectation.fulfill()
                }
            }
        
        viewModel.toggleFavorite()
        
        try await favoriteExpectation.wait(timeout: .seconds(2))
        
        #expect(viewModel.isFavorite == true)
        #expect(mockRepository.markAsFavoriteCallCount == 1)
        #expect(mockRepository.lastMarkAsFavoriteValue == true)
        
        cancellable.cancel()
    }
    
    @Test("Toggle favorite - error")
    func testToggleFavorite_Error() async throws {
        let mockRepository = MockMovieDetailRepository()
        mockRepository.markAsFavoriteError = RepositoryError.dataUnavailable
        // Set initial favorite state to false
        mockRepository.getMovieAccountStatesResult = MovieAccountStates(
            id: 1,
            favorite: false,
            rated: false,
            watchlist: false
        )
        
        let viewModel = MovieDetailViewModel(
            movieId: 1,
            accountId: "test_account",
            repository: mockRepository
        )
        
        // Load initial favorite state
        viewModel.loadAccountStates()
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for initial load
        
        // Verify initial state
        #expect(viewModel.isFavorite == false)
        
        let errorExpectation = AsyncExpectation()
        
        let cancellable = viewModel.$errorMessage
            .compactMap { $0 }
            .sink { _ in
                errorExpectation.fulfill()
            }
        
        viewModel.toggleFavorite()
        
        try await errorExpectation.wait(timeout: .seconds(2))
        
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isFavorite == false) // Should not change on error
        #expect(mockRepository.markAsFavoriteCallCount == 1)
        
        cancellable.cancel()
    }
    
    @Test("Toggle favorite - no account ID")
    func testToggleFavorite_NoAccountId() async throws {
        let mockRepository = MockMovieDetailRepository()
        let viewModel = MovieDetailViewModel(
            movieId: 1,
            accountId: nil,
            repository: mockRepository
        )
        
        viewModel.toggleFavorite()
        
        // Wait a bit
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(mockRepository.markAsFavoriteCallCount == 0)
    }
    
    @Test("Toggle favorite - no favorite state")
    func testToggleFavorite_NoFavoriteState() async throws {
        let mockRepository = MockMovieDetailRepository()
        let viewModel = MovieDetailViewModel(
            movieId: 1,
            accountId: "test_account",
            repository: mockRepository
        )
        
        // isFavorite is nil
        viewModel.toggleFavorite()
        
        // Wait a bit
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(mockRepository.markAsFavoriteCallCount == 0)
    }
}

