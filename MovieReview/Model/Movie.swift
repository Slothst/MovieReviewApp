//
//  Movie.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import Foundation

struct Movie: Hashable, Decodable {
    let uuid: UUID = UUID()
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
    
    var imageURL: URL? {
        return URL(string: "https://image.tmdb.org/t/p/w300/\(posterPath)")
    }
    
    var roundedVoteAverage: String {
        let digit: Double = pow(10, 3)
        return "평점 ⭐️ \(round(voteAverage * digit) / digit)"
    }
    
    var release: String {
        return "개봉일 : \(releaseDate)"
    }
}
