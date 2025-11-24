//
//  MovieEndpoints.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

enum MovieEndpoints {
    case searchMovies(query: String, includeAdult: Bool, language: String, page: Int)
}

extension MovieEndpoints: APIEndpoint {
    var path: String {
        switch self {
        case .searchMovies:
            return "/search/movie"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchMovies(let query, let includeAdult, let language, let page):
            var params: [String: Any] = [
                "query": query,
                "include_adult": includeAdult,
                "language": language,
                "page": page,
                "api_key": APIConfiguration.apiKey
            ]
            return params
        }
    }
}

