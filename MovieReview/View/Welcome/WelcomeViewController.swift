//
//  WelcomeViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 11/9/24.
//

import UIKit
import Combine
import Lottie

class WelcomeViewController: UIViewController {
    
    var viewModel: WelcomeViewModel = WelcomeViewModel(network: NetworkService(configuration: .default))
    
    var subscriptions = Set<AnyCancellable>()
    
    var requestTokenResponse: RequestTokenReponse!
    
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        bind()
        viewModel.fetchRequestToken()
    }
    
    private func setUpUI() {
        view.backgroundColor = .systemBackground
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
        guard success else {
            let alert = UIAlertController(title: "오류", message: "오류가 발생했습니다. 다시 시도해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            present(alert, animated: true)
            viewModel.fetchRequestToken()
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        goToMain()
    }
    
    private func goToMain() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
