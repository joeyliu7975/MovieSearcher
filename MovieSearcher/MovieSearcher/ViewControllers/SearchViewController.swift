//
//  SearchViewController.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private let repository = MovieRepository()
    private var movies: [Movie] = []
    private var currentPage = 1
    private var totalPages = 0
    private var isLoading = false
    private var searchTask: Task<Void, Never>?
    
    // MARK: - UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search movies..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Search for movies to get started"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Movie Search"
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            // Search Bar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Empty State
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Search
    
    private func searchMovies(query: String, page: Int = 1) {
        // Cancel previous search
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            movies = []
            currentPage = 1
            totalPages = 0
            updateUI()
            return
        }
        
        isLoading = true
        updateUI()
        
        searchTask = Task {
            do {
                let searchResult = try await repository.searchMovies(
                    query: query,
                    includeAdult: false,
                    language: "en-US",
                    page: page
                )
                
                // Check if task was cancelled
                guard !Task.isCancelled else { return }
                
                if page == 1 {
                    movies = searchResult.movies
                } else {
                    movies.append(contentsOf: searchResult.movies)
                }
                
                currentPage = searchResult.currentPage
                totalPages = searchResult.totalPages
                isLoading = false
                
                await MainActor.run {
                    updateUI()
                }
            } catch {
                guard !Task.isCancelled else { return }
                
                isLoading = false
                await MainActor.run {
                    updateUI()
                    showError(error)
                }
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        if isLoading {
            loadingIndicator.startAnimating()
            emptyStateLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            emptyStateLabel.isHidden = !movies.isEmpty
        }
        
        tableView.reloadData()
    }
    
    private func showError(_ error: Error) {
        let message: String
        if let apiError = error as? APIError {
            message = apiError.errorDescription ?? "An error occurred"
        } else {
            message = error.localizedDescription
        }
        
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text else { return }
        searchMovies(query: query, page: 1)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Optional: Implement debouncing for real-time search
        // For now, only search on button click
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as! MovieTableViewCell
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Navigate to detail view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load more when scrolling near the end
        if indexPath.row == movies.count - 1 && !isLoading && currentPage < totalPages {
            let nextPage = currentPage + 1
            if let query = searchBar.text, !query.isEmpty {
                searchMovies(query: query, page: nextPage)
            }
        }
    }
}

