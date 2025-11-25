import Foundation
import Combine

@MainActor
class MovieDetailViewModel: ObservableObject {
    @Published private(set) var movieDetail: MovieDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFavorite = false
    
    typealias MovieDetailRepository = MovieDetailRepositoryProtocol & MovieAccountStatesRepositoryProtocol & MovieFavoriteRepositoryProtocol
     
    private let repository: MovieDetailRepository
    private let movieId: Int
    private let accountId: String?
    private var loadTask: Task<Void, Never>?
    private var accountStatesTask: Task<Void, Never>?
    
    init(
        movieId: Int,
        accountId: String?,
        repository: MovieDetailRepository
    ) {
        self.movieId = movieId
        self.repository = repository
        self.accountId = accountId
    }
    
    func loadMovieDetail() {
        loadTask?.cancel()
        isLoading = true
        errorMessage = nil
        
        loadTask = Task {
            do {
                let detail = try await repository.getMovieDetail(movieId: movieId)
                
                guard !Task.isCancelled else { return }
                
                movieDetail = detail
                isLoading = false
                
                loadAccountStates()
            } catch {
                guard !Task.isCancelled else { return }
                
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadAccountStates() {
        accountStatesTask?.cancel()
        
        accountStatesTask = Task {
            do {
                let states = try await repository.getMovieAccountStates(
                    movieId: movieId
                )
                
                guard !Task.isCancelled else { return }
                
                isFavorite = states.favorite
            } catch {
                guard !Task.isCancelled else { return }
                
                print("Failed to load account states: \(error)")
            }
        }
    }
    
    func toggleFavorite() {
        guard let accountId = accountId else { return }
        let newFavoriteState = !isFavorite
        
        Task {
            do {
                try await repository.markAsFavorite(
                    accountId: accountId,
                    movieId: movieId,
                    favorite: newFavoriteState
                )
                
                guard !Task.isCancelled else { return }
                
                isFavorite = newFavoriteState
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "Failed to update favorite: \(error.localizedDescription)"
            }
        }
    }
    
    deinit {
        loadTask?.cancel()
        accountStatesTask?.cancel()
    }
}

