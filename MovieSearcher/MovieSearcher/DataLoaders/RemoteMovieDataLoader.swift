import Foundation

class RemoteMovieDataLoader: MovieDataLoader {
    private let apiService: MovieAPIServiceProtocol
    
    init(apiService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.apiService = apiService
    }
    
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResult? {
        let dto = try await apiService.searchMovies(
            query: query,
            includeAdult: includeAdult,
            language: language,
            page: page
        )
        return MovieMapper.toDomain(dto)
    }
}
