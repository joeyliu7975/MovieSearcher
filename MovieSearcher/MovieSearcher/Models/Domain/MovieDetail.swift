import Foundation

struct Genre {
    let id: Int
    let name: String
}

struct ProductionCompany {
    let id: Int
    let logoPath: String?
    let name: String
    let originCountry: String
}

struct ProductionCountry {
    let iso31661: String
    let name: String
}

struct SpokenLanguage {
    let englishName: String
    let iso6391: String
    let name: String
}

struct MovieDetail {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let releaseDate: Date?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let runtime: Int?
    let tagline: String?
    let status: String
    let genres: [Genre]
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let spokenLanguages: [SpokenLanguage]
    let homepage: String?
    let imdbId: String?
    let budget: Int
    let revenue: Int
    
    var fullPosterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var fullBackdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w1280\(backdropPath)")
    }
    
    var formattedReleaseDate: String? {
        guard let releaseDate = releaseDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: releaseDate)
    }
    
    var formattedRuntime: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var formattedVoteAverage: String {
        return String(format: "%.1f", voteAverage)
    }
    
    var genresString: String {
        return genres.map { $0.name }.joined(separator: ", ")
    }
    
    var productionCountriesString: String {
        return productionCountries.map { $0.name }.joined(separator: ", ")
    }
    
    var spokenLanguagesString: String {
        return spokenLanguages.map { $0.englishName }.joined(separator: ", ")
    }
    
    var formattedBudget: String? {
        guard budget > 0 else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: budget))
    }
    
    var formattedRevenue: String? {
        guard revenue > 0 else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: revenue))
    }
}

