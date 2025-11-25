import UIKit

protocol NavigationRouter {
    func navigateToMovieDetail(movieId: Int)
    func showError(message: String, from viewController: UIViewController)
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
        let viewController = MovieDetailViewController(viewModel: viewModel, router: self)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showError(message: String, from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}

