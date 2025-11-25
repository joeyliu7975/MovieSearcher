//
//  MovieMapper.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

/// Mapper - Responsible for converting API Entity (DTO) to Domain Model
enum MovieMapper {
    
    /// Convert MovieDTO to Movie domain model
    static func toDomain(_ dto: MovieDTO) -> Movie {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return Movie(
            id: dto.id,
            title: dto.title,
            originalTitle: dto.originalTitle,
            overview: dto.overview,
            releaseDate: dto.releaseDate.flatMap { dateFormatter.date(from: $0) },
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            popularity: dto.popularity,
            genreIds: dto.genreIds,
            isAdult: dto.adult,
            hasVideo: dto.video,
            originalLanguage: dto.originalLanguage
        )
    }
    
    /// Convert array of MovieDTO to array of Movie domain models
    static func toDomain(_ dtos: [MovieDTO]) -> [Movie] {
        return dtos.map { toDomain($0) }
    }
    
    /// Convert SearchResponseDTO to SearchResult domain model
    static func toDomain(_ dto: SearchResponseDTO) -> SearchResult {
        return SearchResult(
            movies: toDomain(dto.results),
            currentPage: dto.page,
            totalPages: dto.totalPages,
            totalResults: dto.totalResults
        )
    }
    
    /// Convert MovieAccountStatesDTO to MovieAccountStates domain model
    static func toDomain(_ dto: MovieAccountStatesDTO) -> MovieAccountStates {
        return MovieAccountStates(
            id: dto.id,
            favorite: dto.favorite,
            rated: dto.rated,
            watchlist: dto.watchlist
        )
    }
}

