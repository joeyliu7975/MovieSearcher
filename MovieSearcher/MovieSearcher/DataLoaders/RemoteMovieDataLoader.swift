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
    
    func getMovieDetail(
        movieId: Int,
        language: String
    ) async throws -> MovieDetail? {
        let dto = try await apiService.getMovieDetail(
            movieId: movieId,
            language: language
        )
        return MovieDetailMapper.toDomain(dto)
    }
}
