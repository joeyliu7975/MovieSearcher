//
//  ResettableProtocol.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation

@MainActor
protocol ResettableProtocol {
    func reset()
    func clearError()
}

