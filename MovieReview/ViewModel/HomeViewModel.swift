//
//  HomeViewModel.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import Foundation
import Combine

final class HomeViewModel {
    let network: NetworkService
    
    @Published private(set) var popularMovies = [Movie]()
    @Published private(set) var screeningMovies = [Movie]()
    
    @Published var movieTapped = PassthroughSubject<Movie, Never>()
    
    init(network: NetworkService) {
        self.network = network
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func fetch() {
        fetchPopularMovies()
        fetchScreeningMovies()
    }
    
    private func fetchPopularMovies() {
        let resource: Resource<MovieList> = Resource(
            base: "https://api.themoviedb.org/",
            path: "3/movie/popular",
            params: ["language": "en-US", "page": "1"],
            header: [
                "accept": "application/json",
                "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3MjEzZTY2MTM1YjExOGY2MGNkODQwNzNiNjlkNWU4ZSIsInN1YiI6IjY1ZmU1NTc1NzcwNzAwMDE2MzA5NTE2NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.B7dz-DrrgTeDwDmXjVOlQM9xbnb6c2EuKEglFGq7OXY"
              ]
        )
        network.load(resource)
            .map { $0.results }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.popularMovies, on: self)
            .store(in: &subscriptions)
    }
    
    private func fetchScreeningMovies() {
        let resource: Resource<MovieList> = Resource(
            base: "https://api.themoviedb.org/",
            path: "3/movie/now_playing",
            params: ["language": "en-US", "page": "1"],
            header: [
                "accept": "application/json",
                "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3MjEzZTY2MTM1YjExOGY2MGNkODQwNzNiNjlkNWU4ZSIsInN1YiI6IjY1ZmU1NTc1NzcwNzAwMDE2MzA5NTE2NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.B7dz-DrrgTeDwDmXjVOlQM9xbnb6c2EuKEglFGq7OXY"
              ]
        )
        network.load(resource)
            .map { $0.results }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.screeningMovies, on: self)
            .store(in: &subscriptions)
    }
}
