//
//  MovieDisplayModel.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
import UIKit

struct MovieDisplayModel {
    let id: Int
    let title: String
    let releaseDate: String
    let overview: String
    let posterImageURL: URL?
    let backdropImageURL: URL?
    let rating: String
    let voteCount: String
    
    /// Create View Model from Domain Model
    init(from movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.releaseDate = movie.formattedReleaseDate ?? movie.releaseYear ?? "Unknown Date"
        self.overview = movie.overview.isEmpty ? "No overview available" : movie.overview
        self.posterImageURL = movie.fullPosterURL
        self.backdropImageURL = movie.fullBackdropURL
        self.rating = "⭐ \(movie.formattedVoteAverage)"
        self.voteCount = "\(movie.voteCount) votes"
    }
}

/// View Model for search results
struct SearchResultDisplayModel {
    let movies: [MovieDisplayModel]
    let currentPage: Int
    let totalPages: Int
    let totalResults: Int
    let hasMorePages: Bool
    let isEmpty: Bool
    
    init(from searchResult: SearchResult) {
        self.movies = searchResult.movies.map { MovieDisplayModel(from: $0) }
        self.currentPage = searchResult.currentPage
        self.totalPages = searchResult.totalPages
        self.totalResults = searchResult.totalResults
        self.hasMorePages = searchResult.hasMorePages
        self.isEmpty = searchResult.isEmpty
    }
}

