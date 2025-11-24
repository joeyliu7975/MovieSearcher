//
//  APIConfiguration.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

struct APIConfiguration {
    static let baseURL = "https://api.themoviedb.org/3"
    
    static var apiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String,
              !apiKey.isEmpty else {
            #if DEBUG
            // Fallback for development - remove in production
            return "API NOT FOUND!"
            #else
            fatalError("TMDB_API_KEY not found in Info.plist")
            #endif
        }
        return apiKey
    }
    
    static var readAccessToken: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDB_READ_ACCESS_TOKEN") as? String,
              !token.isEmpty else {
            #if DEBUG
            // Fallback for development - remove in production
            return "TMDB_READ_ACCESS_TOKEN not found in Info.plist"
            #else
            fatalError("TMDB_READ_ACCESS_TOKEN not found in Info.plist")
            #endif
        }
        return token
    }
    
    static let imageBaseURL = "https://image.tmdb.org/t/p"
    static let defaultTimeout: TimeInterval = 30
}

