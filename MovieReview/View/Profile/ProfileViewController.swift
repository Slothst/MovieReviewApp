//
//  ProfileViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import UIKit
import Combine
import Kingfisher

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    let viewModel: ProfileViewModel = ProfileViewModel(network: NetworkService(configuration: .default))
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureImageView()
        viewModel.fetchUserDetails()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }
    
    private func bind() {
        viewModel.$userDetails
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { userDetails in
                self.profileImageView.kf.setImage(with: userDetails.imageURL)
                self.username.text = "\(userDetails.name ?? userDetails.username)"
            }.store(in: &subscriptions)
    }
}
