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
}
