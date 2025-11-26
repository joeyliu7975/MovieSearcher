//
//  CompositeAccountStatesLoaderTests.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Testing
import Foundation
@testable import MovieSearcher

struct CompositeAccountStatesLoaderTests {
    
    // MARK: - Get Account States Tests
    
    @Test("Get account states - local first")
    func testGetAccountStates_LocalFirst() async throws {
        let localLoader = MockAccountStatesLoader()
        let remoteLoader = MockAccountStatesLoader()
        
        let localStates = MovieAccountStates(
            id: 1,
            favorite: true,
            rated: false,
            watchlist: false
        )
        localLoader.getAccountStatesResult = localStates
        
        let composite = CompositeAccountStatesLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        let result = try await composite.getAccountStates(
            movieId: 1,
            accountId: "test_account"
        )
        
        #expect(result?.favorite == true)
        #expect(localLoader.getAccountStatesCallCount == 1)
        
        // Wait for background remote update
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Remote should be called in background
        #expect(remoteLoader.getAccountStatesCallCount == 1)
    }
    
    @Test("Get account states - remote fallback")
    func testGetAccountStates_RemoteFallback() async throws {
        let localLoader = MockAccountStatesLoader()
        let remoteLoader = MockAccountStatesLoader()
        
        // Local returns nil
        localLoader.getAccountStatesResult = nil
        
        let remoteStates = MovieAccountStates(
            id: 1,
            favorite: false,
            rated: true,
            watchlist: false
        )
        remoteLoader.getAccountStatesResult = remoteStates
        
        let composite = CompositeAccountStatesLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        let result = try await composite.getAccountStates(
            movieId: 1,
            accountId: "test_account"
        )
        
        #expect(result?.favorite == false)
        #expect(result?.rated == true)
        #expect(localLoader.getAccountStatesCallCount == 1)
        #expect(remoteLoader.getAccountStatesCallCount == 1)
    }
    
    @Test("Get account states - both fail")
    func testGetAccountStates_BothFail() async throws {
        let localLoader = MockAccountStatesLoader()
        let remoteLoader = MockAccountStatesLoader()
        
        localLoader.getAccountStatesResult = nil
        remoteLoader.getAccountStatesError = NSError(domain: "TestError", code: 1)
        
        let composite = CompositeAccountStatesLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        await #expect(throws: NSError.self) {
            try await composite.getAccountStates(
                movieId: 1,
                accountId: "test_account"
            )
        }
        
        #expect(localLoader.getAccountStatesCallCount == 1)
        #expect(remoteLoader.getAccountStatesCallCount == 1)
    }
    
    @Test("Get account states - no account ID")
    func testGetAccountStates_NoAccountId() async throws {
        let localLoader = MockAccountStatesLoader()
        let remoteLoader = MockAccountStatesLoader()
        
        let composite = CompositeAccountStatesLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        let result = try await composite.getAccountStates(
            movieId: 1,
            accountId: nil
        )
        
        // Should use remote when no account ID
        #expect(localLoader.getAccountStatesCallCount == 0)
        #expect(remoteLoader.getAccountStatesCallCount == 1)
    }
    
    // MARK: - Mark as Favorite Tests
    
    @Test("Mark as favorite - success")
    func testMarkAsFavorite_Success() async throws {
        let localLoader = MockAccountStatesLoader()
        let remoteLoader = MockAccountStatesLoader()
        
        let composite = CompositeAccountStatesLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        try await composite.markAsFavorite(
            accountId: "test_account",
            movieId: 1,
            favorite: true
        )
        
        // Should call both local and remote
        #expect(localLoader.markAsFavoriteCallCount == 1)
        #expect(remoteLoader.markAsFavoriteCallCount == 1)
        #expect(localLoader.lastMarkAsFavoriteValue == true)
        #expect(remoteLoader.lastMarkAsFavoriteValue == true)
    }
    
    @Test("Mark as favorite - remote fails rollback")
    func testMarkAsFavorite_RemoteFails_Rollback() async throws {
        let localLoader = MockAccountStatesLoader()
        let remoteLoader = MockAccountStatesLoader()
        remoteLoader.markAsFavoriteError = NSError(domain: "TestError", code: 1)
        
        let composite = CompositeAccountStatesLoader(
            localLoader: localLoader,
            remoteLoader: remoteLoader
        )
        
        // Should throw error
        await #expect(throws: NSError.self) {
            try await composite.markAsFavorite(
                accountId: "test_account",
                movieId: 1,
                favorite: true
            )
        }
        
        #expect(localLoader.markAsFavoriteCallCount == 2)
        #expect(localLoader.lastMarkAsFavoriteValue == false)
        #expect(remoteLoader.markAsFavoriteCallCount == 1)
    }
}

