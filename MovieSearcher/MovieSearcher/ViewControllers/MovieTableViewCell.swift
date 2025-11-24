//
//  MovieTableViewCell.swift
//  MovieSearcher
//
//  Created by JiaSin Liu on 2025/11/24.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    static let identifier = "MovieTableViewCell"
    
    // MARK: - UI Components
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            // Poster Image
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            posterImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            posterImageView.widthAnchor.constraint(equalToConstant: 80),
            posterImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            // Release Date
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Rating
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ratingLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 4),
            
            // Overview
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            overviewLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            overviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        releaseDateLabel.text = movie.formattedReleaseDate ?? movie.releaseYear ?? "Unknown Date"
        overviewLabel.text = movie.overview.isEmpty ? "No overview available" : movie.overview
        ratingLabel.text = "⭐ \(movie.formattedVoteAverage)"
        
        // Load poster image
        if let posterURL = movie.fullPosterURL {
            loadImage(from: posterURL)
        } else {
            posterImageView.image = nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        releaseDateLabel.text = nil
        overviewLabel.text = nil
        ratingLabel.text = nil
    }
    
    // MARK: - Image Loading
    
    private func loadImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.posterImageView.image = image
                    }
                }
            } catch {
                // Failed to load image, keep placeholder
            }
        }
    }
}

