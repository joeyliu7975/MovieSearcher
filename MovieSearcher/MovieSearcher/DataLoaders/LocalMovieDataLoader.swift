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
            
            if context.hasChanges {
                try self.coreDataStack.saveBackgroundContext(context)
            }
        }
    }
}
