//
//  SearchableProtocol.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

@MainActor
protocol SearchableProtocol {
    func searchMovies(query: String, page: Int)
}

