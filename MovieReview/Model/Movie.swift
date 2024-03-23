//
//  Movie.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import Foundation

struct Movie: Hashable, Identifiable, Decodable {
    let adult: Bool
    let id: Int
    let overview: String
    let posterPath: String
    let releaseDate: String
    let title: String
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case adult
        case id
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
    }
}
