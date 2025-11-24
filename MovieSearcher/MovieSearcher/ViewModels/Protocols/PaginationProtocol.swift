//
//  PaginationProtocol.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

@MainActor
protocol PaginationProtocol {
    var hasMorePages: Bool { get }
    func loadNextPage()
}

