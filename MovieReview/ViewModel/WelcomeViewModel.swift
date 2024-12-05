//
//  WelcomeViewModel.swift
//  MovieReview
//
//  Created by 최낙주 on 11/19/24.
//

import Foundation
import Combine

final class WelcomeViewModel {
    
    let network: NetworkService
    
    @Published private(set) var requestTokenResponse: RequestTokenReponse?
    
    @Published var buttonTapped = PassthroughSubject<RequestTokenReponse, Never>()
    
    init(network: NetworkService) {
        self.network = network
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func fetchRequestToken() {
        print("called")
        let resource: Resource<RequestTokenReponse> = Resource(
            base: APIInfo.baseURL,
            path: "3/authentication/token/new",
            params: [:],
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
            } receiveValue: { requestTokenReponse in
                self.requestTokenResponse = requestTokenReponse
            }.store(in: &subscriptions)
    }
}
