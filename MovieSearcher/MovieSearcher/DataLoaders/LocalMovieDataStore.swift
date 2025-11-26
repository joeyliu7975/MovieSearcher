//
//  LocalMovieDataStore.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
import CoreData

class LocalMovieDataStore: MovieDataStore {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
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
    
    func saveMovieDetail(_ movieDetail: MovieDetail) async throws {
        let context = coreDataStack.newBackgroundContext()
        
        try await context.perform {
            _ = MovieEntityMapper.toEntity(movieDetail, context: context)
            try self.coreDataStack.saveBackgroundContext(context)
        }
    }
}

