//
//  SearchStateProtocol.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

@MainActor
protocol SearchStateProtocol {
    var movies: [Movie] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var isEmpty: Bool { get }
}

