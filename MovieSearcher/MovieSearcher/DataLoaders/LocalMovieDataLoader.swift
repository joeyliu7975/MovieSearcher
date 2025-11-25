import Foundation
import CoreData

class LocalMovieDataLoader: MovieDataLoader {
    private let coreDataStack: CoreDataStack
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResult? {
        let context = coreDataStack.viewContext
        
        return try await context.perform {
            let request: NSFetchRequest<SearchCacheEntity> = SearchCacheEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "query == %@ AND page == %d AND language == %@",
                query, page, language
            )
            request.fetchLimit = 1
            
            guard let entity = try context.fetch(request).first else {
                return nil
            }
            
            if let timestamp = entity.timestamp,
               Date().timeIntervalSince(timestamp) > self.cacheExpirationInterval {
                context.delete(entity)
                try? context.save()
                return nil
            }
            
            return MovieEntityMapper.toDomain(entity)
        }
    }
    
    func saveSearchResult(
        _ result: SearchResult,
        query: String,
        page: Int,
        language: String
    ) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let request: NSFetchRequest<SearchCacheEntity> = SearchCacheEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "query == %@ AND page == %d AND language == %@",
                query, page, language
            )
            
            let existing = try context.fetch(request)
            existing.forEach { context.delete($0) }
            
            _ = MovieEntityMapper.toEntity(
                result,
                query: query,
                page: page,
                language: language,
                context: context
            )
            
            try self.coreDataStack.saveBackgroundContext(context)
        }
    }
    
    func getMovieDetail(
        movieId: Int,
        language: String
    ) async throws -> MovieDetail? {
        let context = coreDataStack.viewContext
        
        return try await context.perform {
            let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", movieId)
            request.fetchLimit = 1
            
            guard let entity = try context.fetch(request).first else {
                return nil
            }
            
            guard let detailTimestamp = entity.detailTimestamp else {
                return nil
            }
            
            if Date().timeIntervalSince(detailTimestamp) > self.cacheExpirationInterval {
                context.delete(entity)
                try? context.save()
                return nil
            }
            
            return MovieEntityMapper.toDetailDomain(entity)
        }
    }
    
    func saveMovieDetail(
        _ movieDetail: MovieDetail
    ) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            _ = MovieEntityMapper.toEntity(movieDetail, context: context)
            try self.coreDataStack.saveBackgroundContext(context)
        }
    }
    
    func clearExpiredCache() async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let request: NSFetchRequest<SearchCacheEntity> = SearchCacheEntity.fetchRequest()
            let allCaches = try context.fetch(request)
            
            let expired = allCaches.filter { entity in
                guard let timestamp = entity.timestamp else { return true }
                return Date().timeIntervalSince(timestamp) > self.cacheExpirationInterval
            }
            
            expired.forEach { context.delete($0) }
            
            let movieRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            let allMovies = try context.fetch(movieRequest)
            
            let expiredDetails = allMovies.filter { entity in
                guard let timestamp = entity.detailTimestamp else { return false }
                return Date().timeIntervalSince(timestamp) > self.cacheExpirationInterval
            }
            
            expiredDetails.forEach { entity in
                entity.detailTimestamp = nil
                entity.runtime = 0
                entity.tagline = nil
                entity.status = nil
                entity.genres = nil
                entity.productionCompanies = nil
                entity.productionCountries = nil
                entity.spokenLanguages = nil
                entity.homepage = nil
                entity.imdbId = nil
                entity.budget = 0
                entity.revenue = 0
            }
            
            if context.hasChanges {
                try self.coreDataStack.saveBackgroundContext(context)
            }
        }
    }
    
    func getFavoriteStatus(movieId: Int, accountId: String) async throws -> Bool? {
        let context = coreDataStack.viewContext
        
        return try await context.perform {
            let request: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "movieId == %d AND accountId == %@",
                movieId, accountId
            )
            request.fetchLimit = 1
            
            return try context.fetch(request).first != nil
        }
    }
    
    func saveFavoriteStatus(movieId: Int, accountId: String, isFavorite: Bool) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            let request: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "movieId == %d AND accountId == %@",
                movieId, accountId
            )
            
            let existing = try context.fetch(request)
            existing.forEach { context.delete($0) }
            
            if isFavorite {
                let favoriteEntity = FavoriteEntity(context: context)
                favoriteEntity.movieId = Int64(movieId)
                favoriteEntity.accountId = accountId
                favoriteEntity.timestamp = Date()
                
                let movieRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                movieRequest.predicate = NSPredicate(format: "id == %d", movieId)
                movieRequest.fetchLimit = 1
                if let movieEntity = try context.fetch(movieRequest).first {
                    favoriteEntity.movie = movieEntity
                }
            }
            
            try self.coreDataStack.saveBackgroundContext(context)
        }
    }
    
    func getAccountStates(movieId: Int, accountId: String) async throws -> MovieAccountStates? {
        let context = coreDataStack.viewContext
        
        return try await context.perform {
            let request: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "movieId == %d AND accountId == %@",
                movieId, accountId
            )
            request.fetchLimit = 1
            
            guard let favoriteEntity = try context.fetch(request).first else {
                return nil
            }
            
            return MovieEntityMapper.toAccountStatesDomain(favoriteEntity)
        }
    }
    
    func saveAccountStates(_ states: MovieAccountStates, accountId: String) async throws {
        try await saveFavoriteStatus(
            movieId: states.id,
            accountId: accountId,
            isFavorite: states.favorite
        )
    }
}
