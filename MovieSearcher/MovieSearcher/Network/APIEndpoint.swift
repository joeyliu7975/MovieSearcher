//
//  APIEndpoint.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

extension APIEndpoint {
    var baseURL: String {
        return APIConfiguration.baseURL
    }
    
    var headers: [String: String]? {
        return [
            "accept": "application/json"
        ]
    }
}

