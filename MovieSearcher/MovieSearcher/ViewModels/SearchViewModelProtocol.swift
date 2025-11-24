//
//  SearchViewModelProtocol.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import Foundation
import Combine

@MainActor
protocol SearchViewModelProtocol: ObservableObject,
                                   SearchStateProtocol,
                                   PaginationProtocol,
                                   SearchableProtocol,
                                   ResettableProtocol {
    // Publishers for Combine binding
    var moviesPublisher: Published<[Movie]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
    var isEmptyPublisher: Published<Bool>.Publisher { get }
}

