//
//  ProfileViewModel.swift
//  MovieReview
//
//  Created by 최낙주 on 11/27/24.
//

import Foundation
import Combine

final class ProfileViewModel {
    
    let network: NetworkService
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var userDetails: UserDetails?
    
    init(network: NetworkService) {
        self.network = network
    }
    
    var session_id: String? {
        return UserDefaults.standard.string(forKey: "session_id")
    }
    
    func fetchUserDetails() {
        let resource: Resource<UserDetails> = Resource(
            base: APIInfo.baseURL,
            path: "3/account",
            params: ["session_id": "\(session_id ?? "")"],
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
            } receiveValue: { userDetails in
                self.userDetails = userDetails
            }.store(in: &subscriptions)
    }
}
