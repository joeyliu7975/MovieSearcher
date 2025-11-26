import Foundation

class CompositeMovieDataLoader: MovieDataLoader {
    private let localLoader: MovieDataLoader
    private let remoteLoader: MovieDataLoader
    
    init(
        localLoader: MovieDataLoader = LocalMovieDataLoader(),
        remoteLoader: MovieDataLoader = RemoteMovieDataLoader()
    ) {
        self.localLoader = localLoader
        self.remoteLoader = remoteLoader
    }
    
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResult? {
        if let local = try await localLoader.searchMovies(
            query: query,
            includeAdult: includeAdult,
            language: language,
            page: page
        ) {
            return local
        }
        
        return try await remoteLoader.searchMovies(
            query: query,
            includeAdult: includeAdult,
            language: language,
            page: page
        )
    }
    
    func getMovieDetail(
        movieId: Int,
        language: String
    ) async throws -> MovieDetail? {
        if let local = try await localLoader.getMovieDetail(
            movieId: movieId,
            language: language
        ) {
            return local
        }
        
        return try await remoteLoader.getMovieDetail(
            movieId: movieId,
            language: language
        )
    }
}
