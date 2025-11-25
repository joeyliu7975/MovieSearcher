import Foundation

enum MovieDetailMapper {
    static func toDomain(_ dto: MovieDetailDTO) -> MovieDetail {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return MovieDetail(
            id: dto.id,
            title: dto.title,
            originalTitle: dto.originalTitle,
            overview: dto.overview,
            releaseDate: dto.releaseDate.flatMap { dateFormatter.date(from: $0) },
            posterPath: dto.posterPath,
            backdropPath: dto.backdropPath,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            popularity: dto.popularity,
            runtime: dto.runtime,
            tagline: dto.tagline,
            status: dto.status,
            genres: dto.genres.map { Genre(id: $0.id, name: $0.name) },
            productionCompanies: dto.productionCompanies.map {
                ProductionCompany(
                    id: $0.id,
                    logoPath: $0.logoPath,
                    name: $0.name,
                    originCountry: $0.originCountry
                )
            },
            productionCountries: dto.productionCountries.map {
                ProductionCountry(
                    iso31661: $0.iso31661,
                    name: $0.name
                )
            },
            spokenLanguages: dto.spokenLanguages.map {
                SpokenLanguage(
                    englishName: $0.englishName,
                    iso6391: $0.iso6391,
                    name: $0.name
                )
            },
            homepage: dto.homepage,
            imdbId: dto.imdbId,
            budget: dto.budget,
            revenue: dto.revenue
        )
    }
}

