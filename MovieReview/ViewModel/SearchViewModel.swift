//
//  SearchViewModel.swift
//  MovieReview
//
//  Created by 최낙주 on 3/26/24.
//

import Foundation
import Combine

final class SearchViewModel {
    
    let network: NetworkService
    
    @Published var searchResults = [Movie]()
    
    init(network: NetworkService) {
        self.network = network
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func search(keyword: String) {
        let resource: Resource<MovieList> = Resource(
            base: "https://api.themoviedb.org/",
            path: "3/search/movie",
            params: [
                "query": keyword,
                "include_adult": "false",
                "language": "en-US",
                "page": "1"
            ],
            header: [
                "accept": "application/json",
                "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3MjEzZTY2MTM1YjExOGY2MGNkODQwNzNiNjlkNWU4ZSIsInN1YiI6IjY1ZmU1NTc1NzcwNzAwMDE2MzA5NTE2NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.B7dz-DrrgTeDwDmXjVOlQM9xbnb6c2EuKEglFGq7OXY"
              ]
        )
        
        network.load(resource)
            .map { $0.results }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.searchResults, on: self)
            .store(in: &subscriptions)
    }
}

