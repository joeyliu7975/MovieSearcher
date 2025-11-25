//
//  SearchViewModel.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: SearchViewModelProtocol {
    
    // MARK: - Published Properties
    
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isEmpty = true
    
    // MARK: - Private Properties
    
    private let repository: MovieSearchRepositoryProtocol
    private var currentPage = 1
    private var totalPages = 0
    private var currentQuery: String = ""
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Publishers
    
    var moviesPublisher: Published<[Movie]>.Publisher { $movies }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    var isEmptyPublisher: Published<Bool>.Publisher { $isEmpty }
    
    // MARK: - Computed Properties
    
    var hasMorePages: Bool {
        return currentPage < totalPages
    }
    
    // MARK: - Initialization
    
    init(repository: MovieSearchRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    func searchMovies(query: String, page: Int = 1) {
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            reset()
            return
        }
        
        currentQuery = query
        
        if page == 1 {
            isLoading = true
            errorMessage = nil
            movies = []
        }
        
        searchTask = Task {
            do {
                let searchResult = try await repository.searchMovies(
                    query: query,
                    page: page
                )
                
                guard !Task.isCancelled else { return }
                
                if page == 1 {
                    movies = searchResult.movies
                } else {
                    movies.append(contentsOf: searchResult.movies)
                }
                
                currentPage = searchResult.currentPage
                totalPages = searchResult.totalPages
                isLoading = false
                isEmpty = searchResult.isEmpty
                
            } catch {
                guard !Task.isCancelled else { return }
                
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadNextPage() {
        guard !isLoading, hasMorePages, !currentQuery.isEmpty else { return }
        let nextPage = currentPage + 1
        searchMovies(query: currentQuery, page: nextPage)
    }
    
    func reset() {
        searchTask?.cancel()
        movies = []
        currentPage = 1
        totalPages = 0
        currentQuery = ""
        isLoading = false
        errorMessage = nil
        isEmpty = true
    }
    
    func clearError() {
        errorMessage = nil
    }
}

