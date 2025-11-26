//
//  LocalAccountStatesDataAccess.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
import CoreData

class LocalAccountStatesDataAccess {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
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

