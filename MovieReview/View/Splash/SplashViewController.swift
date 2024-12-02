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
            let sb = UIStoryboard(name: "Welcome", bundle: nil)
            let vc = sb.instantiateInitialViewController()
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                window.rootViewController = vc
            }
        }
    }
    
    private func setAnimationView() {
        view.addSubview(animationView)
        animationView.frame = view.bounds
        animationView.center = view.center
        animationView.alpha = 1
    }
}
