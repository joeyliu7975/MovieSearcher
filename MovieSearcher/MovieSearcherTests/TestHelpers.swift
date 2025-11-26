//
//  TestHelpers.swift
//  MovieSearcherTests
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

// Helper for async expectations in tests
actor AsyncExpectation {
    private var isFulfilled = false
    private var continuation: CheckedContinuation<Void, Error>?
    
    nonisolated func fulfill() {
        Task {
            await fulfillAsync()
        }
    }
    
    private func fulfillAsync() {
        isFulfilled = true
        continuation?.resume()
        continuation = nil
    }
    
    func wait(timeout: Duration) async throws {
        if isFulfilled {
            return
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.continuation = continuation
            
            Task {
                try await Task.sleep(for: timeout)
                if !isFulfilled {
                    continuation.resume(throwing: TimeoutError())
                }
            }
        }
    }
}

struct TimeoutError: Error {}

