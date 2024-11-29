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
        
        self.recommendationsTableView.delegate = self
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

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Detail", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.viewModel = DetailViewModel(
            network: NetworkService(configuration: .default),
            movieDetail: viewModel.recommendations[indexPath.row]
        )
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
