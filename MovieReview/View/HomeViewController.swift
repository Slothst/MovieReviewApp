//
//  HomeViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias Item = Movie
    enum Section {
        case main
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    
    let viewModel: HomeViewModel = HomeViewModel(network: NetworkService(configuration: .default))
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        bind()
        viewModel.fetch()
    }
    
    private func setupUI() {
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func configureCollectionView() {
        datasource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "MovieCell",
                    for: indexPath
                ) as? PopularMovieCell else {
                    return nil
                }
                cell.configure(movie: item)
                return cell
            }
        )
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        datasource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
        collectionView.alwaysBounceVertical = false
        
        collectionView.delegate = self
    }
    
    private func applyItems(_ items: [Movie]) {
        var snapshot = datasource.snapshot()
        snapshot.appendItems(items, toSection: .main)
        datasource.apply(snapshot)
    }
    
    private func bind() {
        viewModel.$movies
            .receive(on: RunLoop.main)
            .sink { items in
                self.applyItems(items)
            }.store(in: &subscriptions)
        
//        viewModel.$movieTapped
//            .sink { movie in
//                let sb = UIStoryboard(name: "Detail", bundle: nil)
//                let vc = sb.instantiateViewController(withIdentifier: "HomeDetailViewController") as! HomeDetailViewController
//                self.navigationController?.pushViewController(vc, animated: true)
//            }.store(in: &subscriptions)
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.33),
            heightDimension: .absolute(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.8),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(
            top: -20,
            leading: -10,
            bottom: 0,
            trailing: 0
        )
        section.interGroupSpacing = 10
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.movies[indexPath.item]
        print(item.title)
//        viewModel.movieTapped.send(item)
        let sb = UIStoryboard(name: "Detail", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "HomeDetailViewController") as! HomeDetailViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
