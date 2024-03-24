//
//  HomeDetailViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import UIKit
import Combine
import Kingfisher

class HomeDetailViewController: UIViewController {
    
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var viewModel: HomeDetailViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.fetch()
        bind()
    }
    
    private func setupUI() {
        navigationItem.title = viewModel.movieDetail?.title
    }
    
    private func bind() {
        viewModel.$movieDetail
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { movie in
                self.moviePoster.kf.setImage(with: movie.imageURL)
                self.titleLabel.text = movie.title
                self.averageLabel.text = movie.roundedVoteAverage
                self.releaseLabel.text = movie.release
                self.overviewLabel.text = movie.overview
            }.store(in: &subscriptions)
    }
}
