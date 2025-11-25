import Foundation
import CoreData

enum MovieEntityMapper {
    
    static func toEntity(_ movie: Movie, context: NSManagedObjectContext) -> MovieEntity {
        let entity = MovieEntity(context: context)
        entity.id = Int64(movie.id)
        entity.title = movie.title
        entity.originalTitle = movie.originalTitle
        entity.overview = movie.overview
        entity.releaseDate = movie.releaseDate
        entity.posterPath = movie.posterPath
        entity.backdropPath = movie.backdropPath
        entity.voteAverage = movie.voteAverage
        entity.voteCount = Int64(movie.voteCount)
        entity.popularity = movie.popularity
        entity.genreIds = movie.genreIds
        entity.isAdult = movie.isAdult
        entity.hasVideo = movie.hasVideo
        entity.originalLanguage = movie.originalLanguage
        return entity
    }
    
    static func toEntities(_ movies: [Movie], context: NSManagedObjectContext) -> [MovieEntity] {
        return movies.map { toEntity($0, context: context) }
    }
    
    static func toEntity(
        _ searchResult: SearchResult,
        query: String,
        page: Int,
        language: String,
        context: NSManagedObjectContext
    ) -> SearchCacheEntity {
        let entity = SearchCacheEntity(context: context)
        entity.id = UUID()
        entity.query = query
        entity.page = Int32(page)
        entity.currentPage = Int32(searchResult.currentPage)
        entity.totalPages = Int32(searchResult.totalPages)
        entity.totalResults = Int64(searchResult.totalResults)
        entity.language = language
        entity.timestamp = Date()
        
        let movieEntities = toEntities(searchResult.movies, context: context)
        entity.movies = NSSet(array: movieEntities)
        
        return entity
    }
    
    static func toDomain(_ entity: MovieEntity) -> Movie {
        return Movie(
            id: Int(entity.id),
            title: entity.title ?? "",
            originalTitle: entity.originalTitle ?? "",
            overview: entity.overview ?? "",
            releaseDate: entity.releaseDate,
            posterPath: entity.posterPath,
            backdropPath: entity.backdropPath,
            voteAverage: entity.voteAverage,
            voteCount: Int(entity.voteCount),
            popularity: entity.popularity,
            genreIds: entity.genreIds ?? [],
            isAdult: entity.isAdult,
            hasVideo: entity.hasVideo,
            originalLanguage: entity.originalLanguage ?? ""
        )
    }
    
    static func toDomain(_ entities: [MovieEntity]) -> [Movie] {
        return entities.map { toDomain($0) }
    }
    
    static func toDomain(_ entity: SearchCacheEntity) -> SearchResult {
        let movies = entity.movies?.allObjects as? [MovieEntity] ?? []
        return SearchResult(
            movies: toDomain(movies),
            currentPage: Int(entity.currentPage),
            totalPages: Int(entity.totalPages),
            totalResults: Int(entity.totalResults)
        )
    }
}
