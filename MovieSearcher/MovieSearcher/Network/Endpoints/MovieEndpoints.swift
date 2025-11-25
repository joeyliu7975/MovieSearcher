//
//  MovieEndpoints.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

enum MovieEndpoints {
    case searchMovies(query: String, includeAdult: Bool, language: String, page: Int)
    case getMovieDetail(movieId: Int, language: String)
}

extension MovieEndpoints: APIEndpoint {
    var path: String {
        switch self {
        case .searchMovies:
            return "/search/movie"
        case .getMovieDetail(let movieId, _):
            return "/movie/\(movieId)"
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
        case .getMovieDetail(_, let language):
            return [
                "language": language,
                "api_key": APIConfiguration.apiKey
            ]
        }
    }
}

