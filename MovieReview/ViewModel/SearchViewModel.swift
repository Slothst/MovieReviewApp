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
    @Published var movieTapped = PassthroughSubject<Movie, Never>()
    
    init(network: NetworkService) {
        self.network = network
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func search(keyword: String) {
        let resource: Resource<MovieList> = Resource(
            base: APIInfo.baseURL,
            path: "3/search/movie",
            params: [
                "query": keyword,
                "include_adult": "false",
                "language": "ko-KR",
                "page": "1"
            ],
            header: [
                "accept": "application/json",
                "Authorization": APIInfo.accessToken
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

