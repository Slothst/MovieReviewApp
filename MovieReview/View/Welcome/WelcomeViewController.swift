//
//  WelcomeViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 11/9/24.
//

import UIKit
import Combine

class WelcomeViewController: UIViewController {
    
    var viewModel: WelcomeViewModel = WelcomeViewModel(network: NetworkService(configuration: .default))
    
    var subscriptions = Set<AnyCancellable>()
    
    var requestTokenResponse: RequestTokenReponse!
    
    @IBOutlet weak var button: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        bind()
        viewModel.fetchRequestToken()
    }

    func bind() {
        viewModel.$requestTokenResponse
            .receive(on: RunLoop.main)
            .sink { requestTokenReponse in
                self.requestTokenResponse = requestTokenReponse
            }.store(in: &subscriptions)
        
        viewModel.buttonTapped
            .sink { requestTokenResponse in
                let sb = UIStoryboard(name: "Auth", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
                vc.viewModel = AuthViewModel(
                    network: NetworkService(configuration: .default),
                    requestTokenResponse: requestTokenResponse
                )
                vc.completionHandler = { [weak self] success in
                    DispatchQueue.main.async {
                        self?.handleSignIn(success: success)
                    }
                }
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            }.store(in: &subscriptions)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        viewModel.buttonTapped.send(requestTokenResponse)
    }
    
    private func handleSignIn(success: Bool) {
        // Log user in or yell at them for error
        guard success else {
            let alert = UIAlertController(title: "Oops", message: "Something went wrong when signing in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
