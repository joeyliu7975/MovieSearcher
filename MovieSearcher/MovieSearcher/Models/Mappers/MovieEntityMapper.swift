import Foundation
import CoreData

private struct GenreCodable: Codable {
    let id: Int
    let name: String
}

private struct ProductionCompanyCodable: Codable {
    let id: Int
    let logoPath: String?
    let name: String
    let originCountry: String
}

private struct ProductionCountryCodable: Codable {
    let iso31661: String
    let name: String
}

private struct SpokenLanguageCodable: Codable {
    let englishName: String
    let iso6391: String
    let name: String
}

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
    
    static func toEntity(_ movieDetail: MovieDetail, context: NSManagedObjectContext) -> MovieEntity {
        let entity: MovieEntity
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movieDetail.id)
        request.fetchLimit = 1
        
        if let existing = try? context.fetch(request).first {
            entity = existing
        } else {
            entity = MovieEntity(context: context)
        }
        
        entity.id = Int64(movieDetail.id)
        entity.title = movieDetail.title
        entity.originalTitle = movieDetail.originalTitle
        entity.overview = movieDetail.overview
        entity.releaseDate = movieDetail.releaseDate
        entity.posterPath = movieDetail.posterPath
        entity.backdropPath = movieDetail.backdropPath
        entity.voteAverage = movieDetail.voteAverage
        entity.voteCount = Int64(movieDetail.voteCount)
        entity.popularity = movieDetail.popularity
        
        entity.runtime = movieDetail.runtime.map { Int32($0) } ?? 0
        entity.tagline = movieDetail.tagline
        entity.status = movieDetail.status
        
        if let genresData = encodeGenres(movieDetail.genres) {
            entity.genres = genresData
        }
        
        if let companiesData = encodeProductionCompanies(movieDetail.productionCompanies) {
            entity.productionCompanies = companiesData
        }
        
        if let countriesData = encodeProductionCountries(movieDetail.productionCountries) {
            entity.productionCountries = countriesData
        }
        
        if let languagesData = encodeSpokenLanguages(movieDetail.spokenLanguages) {
            entity.spokenLanguages = languagesData
        }
        
        entity.homepage = movieDetail.homepage
        entity.imdbId = movieDetail.imdbId
        entity.budget = Int64(movieDetail.budget)
        entity.revenue = Int64(movieDetail.revenue)
        entity.detailTimestamp = Date()
        
        return entity
    }
    
    static func toDetailDomain(_ entity: MovieEntity) -> MovieDetail? {
        guard let title = entity.title,
              let originalTitle = entity.originalTitle,
              let overview = entity.overview,
              let status = entity.status else {
            return nil
        }
        
        return MovieDetail(
            id: Int(entity.id),
            title: title,
            originalTitle: originalTitle,
            overview: overview,
            releaseDate: entity.releaseDate,
            posterPath: entity.posterPath,
            backdropPath: entity.backdropPath,
            voteAverage: entity.voteAverage,
            voteCount: Int(entity.voteCount),
            popularity: entity.popularity,
            runtime: entity.runtime > 0 ? Int(entity.runtime) : nil,
            tagline: entity.tagline,
            status: status,
            genres: decodeGenres(from: entity.genres),
            productionCompanies: decodeProductionCompanies(from: entity.productionCompanies),
            productionCountries: decodeProductionCountries(from: entity.productionCountries),
            spokenLanguages: decodeSpokenLanguages(from: entity.spokenLanguages),
            homepage: entity.homepage,
            imdbId: entity.imdbId,
            budget: Int(entity.budget),
            revenue: Int(entity.revenue)
        )
    }
    
    private static func encodeGenres(_ genres: [Genre]) -> Data? {
        let codables = genres.map { GenreCodable(id: $0.id, name: $0.name) }
        return try? JSONEncoder().encode(codables)
    }
    
    private static func decodeGenres(from data: Data?) -> [Genre] {
        guard let data = data,
              let codables = try? JSONDecoder().decode([GenreCodable].self, from: data) else {
            return []
        }
        return codables.map { Genre(id: $0.id, name: $0.name) }
    }
    
    private static func encodeProductionCompanies(_ companies: [ProductionCompany]) -> Data? {
        let codables = companies.map {
            ProductionCompanyCodable(
                id: $0.id,
                logoPath: $0.logoPath,
                name: $0.name,
                originCountry: $0.originCountry
            )
        }
        return try? JSONEncoder().encode(codables)
    }
    
    private static func decodeProductionCompanies(from data: Data?) -> [ProductionCompany] {
        guard let data = data,
              let codables = try? JSONDecoder().decode([ProductionCompanyCodable].self, from: data) else {
            return []
        }
        return codables.map {
            ProductionCompany(
                id: $0.id,
                logoPath: $0.logoPath,
                name: $0.name,
                originCountry: $0.originCountry
            )
        }
    }
    
    private static func encodeProductionCountries(_ countries: [ProductionCountry]) -> Data? {
        let codables = countries.map {
            ProductionCountryCodable(iso31661: $0.iso31661, name: $0.name)
        }
        return try? JSONEncoder().encode(codables)
    }
    
    private static func decodeProductionCountries(from data: Data?) -> [ProductionCountry] {
        guard let data = data,
              let codables = try? JSONDecoder().decode([ProductionCountryCodable].self, from: data) else {
            return []
        }
        return codables.map {
            ProductionCountry(iso31661: $0.iso31661, name: $0.name)
        }
    }
    
    private static func encodeSpokenLanguages(_ languages: [SpokenLanguage]) -> Data? {
        let codables = languages.map {
            SpokenLanguageCodable(
                englishName: $0.englishName,
                iso6391: $0.iso6391,
                name: $0.name
            )
        }
        return try? JSONEncoder().encode(codables)
    }
    
    private static func decodeSpokenLanguages(from data: Data?) -> [SpokenLanguage] {
        guard let data = data,
              let codables = try? JSONDecoder().decode([SpokenLanguageCodable].self, from: data) else {
            return []
        }
        return codables.map {
            SpokenLanguage(
                englishName: $0.englishName,
                iso6391: $0.iso6391,
                name: $0.name
            )
        }
    }
    
    /// Convert FavoriteEntity to MovieAccountStates domain model
    /// Note: Currently only favorite status is stored, rated and watchlist default to false
    static func toAccountStatesDomain(_ favoriteEntity: FavoriteEntity) -> MovieAccountStates {
        return MovieAccountStates(
            id: Int(favoriteEntity.movieId),
            favorite: true, // If entity exists, favorite is true
            rated: false,   // Currently not stored, default to false
            watchlist: false // Currently not stored, default to false
        )
    }
}
