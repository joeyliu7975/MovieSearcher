//
//  Movie.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

/// Domain Model - Movie model used internally by the app
/// Does not depend on API structure and can contain business logic and computed properties
struct Movie: Identifiable, Hashable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let releaseDate: Date?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let genreIds: [Int]
    let isAdult: Bool
    let hasVideo: Bool
    let originalLanguage: String
    
    // MARK: - Computed Properties
    
    /// Full poster image URL
    var fullPosterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    /// Full backdrop image URL
    var fullBackdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w1280\(backdropPath)")
    }
    
    /// Formatted release date
    var formattedReleaseDate: String? {
        guard let releaseDate = releaseDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: releaseDate)
    }
    
    /// Release year only
    var releaseYear: String? {
        guard let releaseDate = releaseDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: releaseDate)
    }
    
    /// Formatted vote average (one decimal place)
    var formattedVoteAverage: String {
        return String(format: "%.1f", voteAverage)
    }
}

