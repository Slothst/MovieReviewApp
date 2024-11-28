//
//  ProfileViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import UIKit
import Combine

class ProfileViewController: UIViewController {

    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    
    let viewModel: ProfileViewModel = ProfileViewModel(network: NetworkService(configuration: .default))
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchUserDetails()
        bind()
    }
    
    func bind() {
        viewModel.$userDetails
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { userDetails in
                self.id.text = "\(userDetails.id)"
                self.name.text = "\(userDetails.name ?? "")"
                self.username.text = "\(userDetails.username)"
            }.store(in: &subscriptions)
    }
}
