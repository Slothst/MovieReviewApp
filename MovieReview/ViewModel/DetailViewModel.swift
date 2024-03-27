//
//  DetailViewModel.swift
//  MovieReview
//
//  Created by 최낙주 on 3/24/24.
//

import Foundation
import Combine

final class DetailViewModel {
    
    let network: NetworkService
    
    @Published var movieDetail: Movie?
    
    init(network: NetworkService, movieDetail: Movie) {
        self.network = network
        self.movieDetail = movieDetail
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func fetch() {
        let resource: Resource<Movie> = Resource(
            base: APIInfo.baseURL,
            path: "3/movie/\(movieDetail?.id ?? 0)",
            params: ["language": "ko-KR"],
            header: [
                "accept": "application/json",
                "Authorization": APIInfo.accessToken
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
