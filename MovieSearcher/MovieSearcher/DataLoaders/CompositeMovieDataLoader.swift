import Foundation

class CompositeMovieDataLoader: MovieDataLoader {
    private let localDataLoader: LocalMovieDataLoader
    private let remoteDataLoader: RemoteMovieDataLoader
    
    init(
        localDataLoader: LocalMovieDataLoader = LocalMovieDataLoader(),
        remoteDataLoader: RemoteMovieDataLoader = RemoteMovieDataLoader()
    ) {
        self.localDataLoader = localDataLoader
        self.remoteDataLoader = remoteDataLoader
    }
    
    func searchMovies(
        query: String,
        includeAdult: Bool,
        language: String,
        page: Int
    ) async throws -> SearchResult? {
        if let local = try await localDataLoader.searchMovies(
            query: query,
            includeAdult: includeAdult,
            language: language,
            page: page
        ) {
            return local
        }
        
        guard let remote = try await remoteDataLoader.searchMovies(
            query: query,
            includeAdult: includeAdult,
            language: language,
            page: page
        ) else {
            return nil
        }
        
        Task.detached { [weak self] in
            try? await self?.localDataLoader.saveSearchResult(
                remote,
                query: query,
                page: page,
                language: language
            )
        }
        
        return remote
    }
    
    func getMovieDetail(
        movieId: Int,
        language: String
    ) async throws -> MovieDetail? {
        if let local = try await localDataLoader.getMovieDetail(
            movieId: movieId,
            language: language
        ) {
            return local
        }
        
        guard let remote = try await remoteDataLoader.getMovieDetail(
            movieId: movieId,
            language: language
        ) else {
            return nil
        }
        
        Task.detached { [weak self] in
            try? await self?.localDataLoader.saveMovieDetail(remote)
        }
        
        return remote
    }
}
