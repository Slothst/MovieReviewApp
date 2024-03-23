//
//  MovieList.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import Foundation

struct MovieList: Hashable, Decodable {
    let page: Int
    let results: [Movie]
}
