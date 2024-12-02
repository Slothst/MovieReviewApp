//
//  UserDetails.swift
//  MovieReview
//
//  Created by 최낙주 on 11/28/24.
//

import Foundation

struct UserDetails: Codable {
    let avatar: Avatar
    let id: Int
    let name: String?
    let username: String
    
    var imageURL: URL? {
        return URL(string: "https://image.tmdb.org/t/p/w200/\(avatar.tmdb.avatar_path)")
    }
}

struct Avatar: Codable {
    let tmdb: Tmdb
}

struct Tmdb: Codable {
    let avatar_path: String
}

