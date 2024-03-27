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
    @Published private(set) var upcomingMovies = [Movie]()
    @Published private(set) var topRatedMovies = [Movie]()
    
    @Published var movieTapped = PassthroughSubject<Movie, Never>()
    
    init(network: NetworkService) {
        self.network = network
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func fetch() {
        fetchPopularMovies()
        fetchScreeningMovies()
        fetchUpcomingMovies()
        fetchTopRatedMovies()
    }
    
    private func fetchPopularMovies() {
        let resource: Resource<MovieList> = Resource(
            base: APIInfo.baseURL,
            path: "3/movie/popular",
            params: ["language": "ko-KR", "page": "1"],
            header: [
                "accept": "application/json",
                "Authorization": APIInfo.accessToken
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
            base: APIInfo.baseURL,
            path: "3/movie/now_playing",
            params: ["language": "ko-KR", "page": "1"],
            header: [
                "accept": "application/json",
                "Authorization": APIInfo.accessToken
              ]
        )
        network.load(resource)
            .map { $0.results }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.screeningMovies, on: self)
            .store(in: &subscriptions)
    }

    private func fetchUpcomingMovies() {
        let resource: Resource<MovieList> = Resource(
            base: APIInfo.baseURL,
            path: "3/movie/upcoming",
            params: ["language": "ko-KR", "page": "1"],
            header: [
                "accept": "application/json",
                "Authorization": APIInfo.accessToken
              ]
        )
        network.load(resource)
            .map { $0.results }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.upcomingMovies, on: self)
            .store(in: &subscriptions)
    }

    private func fetchTopRatedMovies() {
        let resource: Resource<MovieList> = Resource(
            base: APIInfo.baseURL,
            path: "3/movie/top_rated",
            params: ["language": "ko-KR", "page": "1"],
            header: [
                "accept": "application/json",
                "Authorization": APIInfo.accessToken
              ]
        )
        network.load(resource)
            .map { $0.results }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.topRatedMovies, on: self)
            .store(in: &subscriptions)
    }
}
