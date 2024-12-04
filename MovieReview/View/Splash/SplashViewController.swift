//
//  SplashViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 12/3/24.
//

import UIKit
import Lottie

class SplashViewController: UIViewController {

    private let animationView: LottieAnimationView = {
        let lottieAnimationView = LottieAnimationView(name: "SplashLottie")
        lottieAnimationView.backgroundColor = .systemBackground
        return lottieAnimationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAnimationView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animationView.play { _ in
            if self.checkHasSession() {
                return
            } else {
                let sb = UIStoryboard(name: "Welcome", bundle: nil)
                let vc = sb.instantiateInitialViewController()
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    window.rootViewController = vc
                }
            }
        }
    }
    
    private func setAnimationView() {
        view.addSubview(animationView)
        animationView.frame = view.bounds
        animationView.center = view.center
        animationView.alpha = 1
    }
    
    private func checkHasSession() -> Bool {
        guard UserDefaults.standard.string(forKey: "session_id") != nil else {
            return false
        }
        goToMain()
        return true
    }
    
    private func goToMain() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
