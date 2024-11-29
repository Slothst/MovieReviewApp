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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section: CaseIterable {
        case recommendations
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, Movie>!
    
    var viewModel: DetailViewModel!
    var subscriptions = Set<AnyCancellable>()
    
    var recommendations = [Movie]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        bind()
        viewModel.fetch()
    }
    
    private func setupUI() {
        navigationItem.title = viewModel.movieDetail?.title
    }
    
    private func configureCollectionView() {
        datasource = UICollectionViewDiffableDataSource<Section, Movie>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as? MovieCell else { return nil
                }
                cell.configure(movie: item)
                return cell
            }
        )
        
        self.datasource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TitleHeaderCollectionReusableView", for: indexPath) as? TitleHeaderCollectionReusableView else { return nil }
            header.titleLabel.text = "추천 영화"
            return header
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
        snapshot.appendSections([.recommendations])
        snapshot.appendItems([], toSection: .recommendations)
        datasource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
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
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.33),
            heightDimension: .absolute(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(160)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(-20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 10,
            trailing: 0
        )
        section.interGroupSpacing = -20
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension DetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Detail", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.viewModel = DetailViewModel(
            network: NetworkService(configuration: .default),
            movieDetail: viewModel.recommendations[indexPath.row]
        )
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
