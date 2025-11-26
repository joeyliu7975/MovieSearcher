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
    private var hasResumed = false
    
    nonisolated func fulfill() {
        Task {
            await fulfillAsync()
        }
    }
    
    private func fulfillAsync() {
        guard !isFulfilled, !hasResumed else { return }
        isFulfilled = true
        hasResumed = true
        let cont = continuation
        continuation = nil
        cont?.resume()
    }
    
    func wait(timeout: Duration) async throws {
        if isFulfilled {
            return
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.continuation = continuation
            
            Task {
                try await Task.sleep(for: timeout)
                // Only resume if not already fulfilled/resumed
                if !isFulfilled, !hasResumed, let cont = self.continuation {
                    hasResumed = true
                    self.continuation = nil
                    continuation.resume(throwing: TimeoutError())
                }
            }
        }
    }
}

struct TimeoutError: Error {}

