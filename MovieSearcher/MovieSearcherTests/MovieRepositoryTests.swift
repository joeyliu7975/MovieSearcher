//
//  MovieRepositoryTests.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Testing
@testable import MovieSearcher

struct MovieRepositoryTests {
    
    // MARK: - Search Movies Tests
    
    @Test("Search movies - success")
    func testSearchMovies_Success() async throws {
        let mockLoader = MockMovieDataLoader()
        let expectedResult = SearchResult(
            movies: [Movie(
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
                genreIds: [1, 2],
                isAdult: false,
                hasVideo: false,
                originalLanguage: "en"
            )],
            currentPage: 1,
            totalPages: 1,
            totalResults: 1
        )
        mockLoader.searchMoviesResult = expectedResult
        
        let repository = MovieRepository(dataLoader: mockLoader)
        let result = try await repository.searchMovies(query: "test", page: 1)
        
        #expect(result.movies.count == 1)
        #expect(result.movies.first?.title == "Test Movie")
        #expect(mockLoader.searchMoviesCallCount == 1)
    }
    
    @Test("Search movies - empty query")
    func testSearchMovies_EmptyQuery() async throws {
        let mockLoader = MockMovieDataLoader()
        let repository = MovieRepository(dataLoader: mockLoader)
        
        await #expect(throws: RepositoryError.invalidQuery) {
            try await repository.searchMovies(query: "", page: 1)
        }
        
        await #expect(throws: RepositoryError.invalidQuery) {
            try await repository.searchMovies(query: "   ", page: 1)
        }
        
        #expect(mockLoader.searchMoviesCallCount == 0)
    }
    
    @Test("Search movies - invalid page")
    func testSearchMovies_InvalidPage() async throws {
        let mockLoader = MockMovieDataLoader()
        let repository = MovieRepository(dataLoader: mockLoader)
        
        await #expect(throws: RepositoryError.invalidPage) {
            try await repository.searchMovies(query: "test", page: 0)
        }
        
        await #expect(throws: RepositoryError.invalidPage) {
            try await repository.searchMovies(query: "test", page: -1)
        }
        
        #expect(mockLoader.searchMoviesCallCount == 0)
    }
    
    @Test("Search movies - data unavailable")
    func testSearchMovies_DataUnavailable() async throws {
        let mockLoader = MockMovieDataLoader()
        mockLoader.searchMoviesResult = nil
        
        let repository = MovieRepository(dataLoader: mockLoader)
        
        await #expect(throws: RepositoryError.dataUnavailable) {
            try await repository.searchMovies(query: "test", page: 1)
        }
        
        #expect(mockLoader.searchMoviesCallCount == 1)
    }
    
    // MARK: - Get Movie Detail Tests
    
    @Test("Get movie detail - success")
    func testGetMovieDetail_Success() async throws {
        let mockLoader = MockMovieDataLoader()
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
        mockLoader.getMovieDetailResult = expectedDetail
        
        let repository = MovieRepository(dataLoader: mockLoader)
        let detail = try await repository.getMovieDetail(movieId: 1)
        
        #expect(detail.id == 1)
        #expect(detail.title == "Test Movie")
        #expect(mockLoader.getMovieDetailCallCount == 1)
    }
    
    @Test("Get movie detail - invalid movie ID")
    func testGetMovieDetail_InvalidMovieId() async throws {
        let mockLoader = MockMovieDataLoader()
        let repository = MovieRepository(dataLoader: mockLoader)
        
        await #expect(throws: RepositoryError.invalidMovieId) {
            try await repository.getMovieDetail(movieId: 0)
        }
        
        await #expect(throws: RepositoryError.invalidMovieId) {
            try await repository.getMovieDetail(movieId: -1)
        }
        
        #expect(mockLoader.getMovieDetailCallCount == 0)
    }
    
    @Test("Get movie detail - data unavailable")
    func testGetMovieDetail_DataUnavailable() async throws {
        let mockLoader = MockMovieDataLoader()
        mockLoader.getMovieDetailResult = nil
        
        let repository = MovieRepository(dataLoader: mockLoader)
        
        await #expect(throws: RepositoryError.dataUnavailable) {
            try await repository.getMovieDetail(movieId: 1)
        }
        
        #expect(mockLoader.getMovieDetailCallCount == 1)
    }
    
    // MARK: - Get Account States Tests
    
    @Test("Get movie account states - success")
    func testGetMovieAccountStates_Success() async throws {
        let mockLoader = MockAccountStatesLoader()
        let expectedStates = MovieAccountStates(
            id: 1,
            favorite: true,
            rated: false,
            watchlist: false
        )
        mockLoader.getAccountStatesResult = expectedStates
        
        let repository = MovieRepository(accountStatesLoader: mockLoader)
        let states = try await repository.getMovieAccountStates(movieId: 1)
        
        #expect(states.id == 1)
        #expect(states.favorite == true)
        #expect(mockLoader.getAccountStatesCallCount == 1)
    }
    
    @Test("Get movie account states - invalid movie ID")
    func testGetMovieAccountStates_InvalidMovieId() async throws {
        let mockLoader = MockAccountStatesLoader()
        let repository = MovieRepository(accountStatesLoader: mockLoader)
        
        await #expect(throws: RepositoryError.invalidMovieId) {
            try await repository.getMovieAccountStates(movieId: 0)
        }
        
        await #expect(throws: RepositoryError.invalidMovieId) {
            try await repository.getMovieAccountStates(movieId: -1)
        }
        
        #expect(mockLoader.getAccountStatesCallCount == 0)
    }
    
    @Test("Get movie account states - data unavailable")
    func testGetMovieAccountStates_DataUnavailable() async throws {
        let mockLoader = MockAccountStatesLoader()
        mockLoader.getAccountStatesResult = nil
        
        let repository = MovieRepository(accountStatesLoader: mockLoader)
        
        await #expect(throws: RepositoryError.dataUnavailable) {
            try await repository.getMovieAccountStates(movieId: 1)
        }
        
        #expect(mockLoader.getAccountStatesCallCount == 1)
    }
    
    // MARK: - Mark as Favorite Tests
    
    @Test("Mark as favorite - success")
    func testMarkAsFavorite_Success() async throws {
        let mockLoader = MockAccountStatesLoader()
        let repository = MovieRepository(accountStatesLoader: mockLoader)
        
        try await repository.markAsFavorite(
            accountId: "test_account",
            movieId: 1,
            favorite: true
        )
        
        #expect(mockLoader.markAsFavoriteCallCount == 1)
        #expect(mockLoader.lastMarkAsFavoriteAccountId == "test_account")
        #expect(mockLoader.lastMarkAsFavoriteMovieId == 1)
        #expect(mockLoader.lastMarkAsFavoriteValue == true)
    }
    
    @Test("Mark as favorite - invalid movie ID")
    func testMarkAsFavorite_InvalidMovieId() async throws {
        let mockLoader = MockAccountStatesLoader()
        let repository = MovieRepository(accountStatesLoader: mockLoader)
        
        await #expect(throws: RepositoryError.invalidMovieId) {
            try await repository.markAsFavorite(
                accountId: "test_account",
                movieId: 0,
                favorite: true
            )
        }
        
        await #expect(throws: RepositoryError.invalidMovieId) {
            try await repository.markAsFavorite(
                accountId: "test_account",
                movieId: -1,
                favorite: true
            )
        }
        
        #expect(mockLoader.markAsFavoriteCallCount == 0)
    }
    
    @Test("Mark as favorite - empty account ID")
    func testMarkAsFavorite_EmptyAccountId() async throws {
        let mockLoader = MockAccountStatesLoader()
        let repository = MovieRepository(accountStatesLoader: mockLoader)
        
        await #expect(throws: RepositoryError.invalidAccountId) {
            try await repository.markAsFavorite(
                accountId: "",
                movieId: 1,
                favorite: true
            )
        }
        
        #expect(mockLoader.markAsFavoriteCallCount == 0)
    }
}

