//
//  HomeDetailViewModel.swift
//  MovieReview
//
//  Created by 최낙주 on 3/24/24.
//

import Foundation
import Combine

final class HomeDetailViewModel {
    
    let network: NetworkService
    
    @Published var movieDetail: Movie?
    
    init(network: NetworkService, movieDetail: Movie) {
        self.network = network
        self.movieDetail = movieDetail
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func fetch() {
        let resource: Resource<Movie> = Resource(
            base: "https://api.themoviedb.org/",
            path: "3/movie/\(movieDetail?.id ?? 0)",
            params: ["language": "en-US"],
            header: [
                "accept": "application/json",
                "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3MjEzZTY2MTM1YjExOGY2MGNkODQwNzNiNjlkNWU4ZSIsInN1YiI6IjY1ZmU1NTc1NzcwNzAwMDE2MzA5NTE2NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.B7dz-DrrgTeDwDmXjVOlQM9xbnb6c2EuKEglFGq7OXY"
              ]
        )
        network.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("---> error: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { movie in
                self.movieDetail = movie
            }.store(in: &subscriptions)
    }
}
