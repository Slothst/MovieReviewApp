//
//  AuthViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 11/9/24.
//

import UIKit
import WebKit
import Combine

class AuthViewController: UIViewController, WKNavigationDelegate {
    
    var viewModel: AuthViewModel!
    var subscriptions = Set<AnyCancellable>()
    
    private let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        let config = WKWebViewConfiguration()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero,
                                configuration: config)
        return webView
    }()

    public var completionHandler: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWebView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

    private func setupUI() {
        title = "Sign In"
        view.backgroundColor = .systemBackground
    }
    
    private func loadWebView() {
        webView.navigationDelegate = self
        guard let url = viewModel.signInURL else {
            return
        }
        view.addSubview(webView)
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        // Exchange the code for access token
        guard (URLComponents(string: url.absoluteString)?.string?.hasSuffix("allow"))! else {
            return
        }
        webView.isHidden = true
        viewModel.createSession() { [weak self] success in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
}
