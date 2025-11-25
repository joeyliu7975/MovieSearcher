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
    case getMovieAccountStates(movieId: Int)
    case markAsFavorite(accountId: String, mediaType: String, mediaId: Int, favorite: Bool)
}

extension MovieEndpoints: APIEndpoint {
    var headers: [String: String]? {
        var baseHeaders = [
            "accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        switch self {
        case .markAsFavorite, .getMovieAccountStates:
            baseHeaders["Authorization"] = "Bearer \(APIConfiguration.readAccessToken)"
        default:
            break
        }
        
        return baseHeaders
    }
    
    var path: String {
        switch self {
        case .searchMovies:
            return "/search/movie"
        case .getMovieDetail(let movieId, _):
            return "/movie/\(movieId)"
        case .getMovieAccountStates(let movieId):
            return "/movie/\(movieId)/account_states"
        case .markAsFavorite(let accountId, _, _, _):
            return "/account/\(accountId)/favorite"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .searchMovies, .getMovieDetail, .getMovieAccountStates:
            return .get
        case .markAsFavorite:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchMovies(let query, let includeAdult, let language, let page):
            let params: [String: Any] = [
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
        case .getMovieAccountStates(_):
            return [
                "api_key": APIConfiguration.apiKey
            ]
        case .markAsFavorite(_, let mediaType, let mediaId, let favorite):
            return [
                "media_type": mediaType,
                "media_id": mediaId,
                "favorite": favorite,
                "api_key": APIConfiguration.apiKey
            ]
        }
    }
}

