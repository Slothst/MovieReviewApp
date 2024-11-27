//
//  AuthManager.swift
//  MovieReview
//
//  Created by 최낙주 on 11/9/24.
//

import Foundation
import Combine

final class AuthViewModel {
    
    let network: NetworkService
    
    @Published var requestTokenResponse: RequestTokenReponse?
    @Published var session: Session?
    
    private var sessionString: String? {
        return UserDefaults.standard.string(forKey: "session_id")
    }
    
    init(network: NetworkService,
         requestTokenResponse: RequestTokenReponse
    ) {
        self.network = network
        self.requestTokenResponse = requestTokenResponse
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    var signInURL: URL? {
        let base: String = "https://www.themoviedb.org/authenticate"
        let string: String = "\(base)/\(requestTokenResponse?.request_token ?? "")"
        return URL(string: string)
    }
    
    func fetchRequestToken() {
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
                print(requestTokenReponse.request_token)
            }.store(in: &subscriptions)
    }
    
    func createSession(completion: @escaping (Bool) -> Void) {
        guard let requestToken = requestTokenResponse?.request_token else {
            return
        }
        let resource: Resource<Session> = Resource(
            base: APIInfo.baseURL,
            path: "3/authentication/session/new",
            params: ["request_token": "\(requestToken)"],
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
            } receiveValue: { session in
                self.session = session
                self.cacheSession(session: session)
                print(session.session_id)
                completion(true)
            }.store(in: &subscriptions)
    }
    
    public func cacheSession(session: Session) {
        UserDefaults.standard.setValue(session.session_id, forKey: "session_id")
    }
    
    public func signOut(completion: @escaping (Bool) -> Void) {
        UserDefaults.standard.setValue(nil, forKey: "session_id")
        completion(true)
    }
}
