import Foundation
import Combine

@MainActor
class MovieDetailViewModel: ObservableObject {
    @Published private(set) var movieDetail: MovieDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let repository: MovieDetailRepositoryProtocol
    private let movieId: Int
    private var loadTask: Task<Void, Never>?
    
    init(movieId: Int, repository: MovieDetailRepositoryProtocol = MovieRepository()) {
        self.movieId = movieId
        self.repository = repository
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
            } catch {
                guard !Task.isCancelled else { return }
                
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    deinit {
        loadTask?.cancel()
    }
}

