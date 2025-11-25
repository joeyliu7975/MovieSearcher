import UIKit

@MainActor
protocol NavigationRouter {
    func navigateToMovieDetail(movieId: Int)
    func showError(message: String, from viewController: UIViewController)
}

@MainActor
class AppNavigationRouter: NavigationRouter {
    typealias MovieDetailRepository = MovieDetailRepositoryProtocol & MovieAccountStatesRepositoryProtocol & MovieFavoriteRepositoryProtocol
    private weak var navigationController: UINavigationController?
    private let repository: MovieDetailRepository
    
    init(
        navigationController: UINavigationController,
        repository: MovieDetailRepository
    ) {
        self.navigationController = navigationController
        self.repository = repository
    }
    
    func navigateToMovieDetail(movieId: Int) {
        let accountId = APIConfiguration.accountId
        let viewModel = MovieDetailViewModel(
            movieId: movieId,
            accountId: accountId,
            repository: repository
        )
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

