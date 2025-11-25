import UIKit

protocol NavigationRouter {
    func navigateToMovieDetail(movieId: Int)
}

class AppNavigationRouter: NavigationRouter {
    private weak var navigationController: UINavigationController?
    private let repository: MovieDetailRepositoryProtocol
    
    init(
        navigationController: UINavigationController,
        repository: MovieDetailRepositoryProtocol = MovieRepository()
    ) {
        self.navigationController = navigationController
        self.repository = repository
    }
    
    func navigateToMovieDetail(movieId: Int) {
        let viewModel = MovieDetailViewModel(movieId: movieId, repository: repository)
        let viewController = MovieDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

