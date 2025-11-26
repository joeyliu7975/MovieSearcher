//
//  CacheManager.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
import CoreData

class CacheManager {
    private let coreDataStack: CoreDataStack
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
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
}

