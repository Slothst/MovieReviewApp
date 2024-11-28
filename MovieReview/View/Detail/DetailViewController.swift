//
//  DetailViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import UIKit
import Combine
import Kingfisher

class DetailViewController: UIViewController {
    
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var recommendationsTableView: UITableView!
    
    enum Section: CaseIterable {
        case recommendations
    }
    
    var datasource: UITableViewDiffableDataSource<Section, Movie>!
    
    var viewModel: DetailViewModel!
    var subscriptions = Set<AnyCancellable>()
    
    var recommendations = [Movie]()

    override func viewDidLoad() {
        super.viewDidLoad()
//        recommendationsTableView.delegate = self
        setupUI()
        configureTableView()
        bind()
        viewModel.fetch()
    }
    
    private func setupUI() {
        navigationItem.title = viewModel.movieDetail?.title
    }
    
    private func configureTableView() {
        datasource = UITableViewDiffableDataSource<Section, Movie>(
            tableView: recommendationsTableView,
            cellProvider: { tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: RecommendCell.identifier,
                    for: indexPath
                ) as? RecommendCell else { return UITableViewCell() }
                cell.configure(movie: item)
                return cell
            }
        )
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        snapshot.appendSections([.recommendations])
        snapshot.appendItems([], toSection: .recommendations)
        datasource.apply(snapshot)
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
        
        viewModel.$recommendations
            .receive(on: RunLoop.main)
            .sink { items in
                var snapshot = self.datasource.snapshot()
                snapshot.appendItems(items, toSection: .recommendations)
                self.datasource.apply(snapshot)
            }.store(in: &subscriptions)
    }
}

//extension DetailViewController: UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(viewModel.recommendations.count)
//        return viewModel.recommendations.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: RecommendCell.identifier,
//            for: indexPath
//        ) as? RecommendCell else { return UITableViewCell() }
//        cell.configure(movie: viewModel.recommendations[indexPath.row])
//        return cell
//    }
//}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
