import Foundation

struct MovieAccountStatesDTO: Codable {
    let id: Int
    let favorite: Bool
    let rated: Bool
    let watchlist: Bool
}

