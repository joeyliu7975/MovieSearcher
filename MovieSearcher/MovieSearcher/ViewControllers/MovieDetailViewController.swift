import UIKit
import Combine

class MovieDetailViewController: UIViewController {
    private let viewModel: MovieDetailViewModel
    private let router: NavigationRouter?
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.accessibilityIdentifier = AccessibilityIdentifiers.Detail.loadingIndicator
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.accessibilityIdentifier = AccessibilityIdentifiers.Detail.favoriteButton
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: MovieDetailViewModel, router: NavigationRouter? = nil) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadMovieDetail()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Movie Details"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backdropImageView)
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(taglineLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(infoStackView)
        view.addSubview(loadingIndicator)
        view.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 250),
            
            posterImageView.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: -75),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.widthAnchor.constraint(equalToConstant: 120),
            posterImageView.heightAnchor.constraint(equalToConstant: 180),
            
            titleLabel.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            taglineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            taglineLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            taglineLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            overviewLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            infoStackView.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 16),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            favoriteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$movieDetail
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movieDetail in
                self?.updateUI(with: movieDetail)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(message: errorMessage)
            }
            .store(in: &cancellables)
        
        viewModel.$isFavorite
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite in
                self?.favoriteButton.isHidden = false
                self?.favoriteButton.setImage(UIImage(named: isFavorite ? "heart_fill": "heart_hollow"), for: .normal)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with movieDetail: MovieDetail) {
        titleLabel.text = movieDetail.title
        taglineLabel.text = movieDetail.tagline
        overviewLabel.text = movieDetail.overview
        
        if let posterURL = movieDetail.fullPosterURL {
            loadImage(from: posterURL, into: posterImageView)
        }
        
        if let backdropURL = movieDetail.fullBackdropURL {
            loadImage(from: backdropURL, into: backdropImageView)
        }
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let releaseDate = movieDetail.formattedReleaseDate {
            addInfoRow(title: "Release Date", value: releaseDate)
        }
        
        if let runtime = movieDetail.formattedRuntime {
            addInfoRow(title: "Runtime", value: runtime)
        }
        
        if !movieDetail.genresString.isEmpty {
            addInfoRow(title: "Genres", value: movieDetail.genresString)
        }
        
        addInfoRow(title: "Rating", value: "⭐ \(movieDetail.formattedVoteAverage) (\(movieDetail.voteCount) votes)")
        
        if !movieDetail.productionCountriesString.isEmpty {
            addInfoRow(title: "Country", value: movieDetail.productionCountriesString)
        }
        
        if let budget = movieDetail.formattedBudget {
            addInfoRow(title: "Budget", value: budget)
        }
        
        if let revenue = movieDetail.formattedRevenue {
            addInfoRow(title: "Revenue", value: revenue)
        }
    }
    
    private func addInfoRow(title: String, value: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14)
        valueLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        infoStackView.addArrangedSubview(stackView)
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        imageView.image = image
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
    
    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavorite()
    }
    
    private func showError(message: String) {
        router?.showError(message: message, from: self)
    }
}

