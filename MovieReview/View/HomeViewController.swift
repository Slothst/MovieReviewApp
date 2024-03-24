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
    
    enum Section: Int, CaseIterable {
        case popular
        case screening
        
        var title: String {
            switch self {
            case .popular:
                return "지금 인기 있는 영화"
            case .screening:
                return "현재 상영 중인 영화"
            }
        }
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
                guard let section = Section(rawValue: indexPath.section) else { return nil }
                let cell = self.configureCell(for: section, item: item, collectionView: collectionView, indexPath: indexPath)
                return cell
            }
        )
        
        datasource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TitleHeaderCollectionReusableView", for: indexPath) as? TitleHeaderCollectionReusableView else { return nil }
            
            let allSections = Section.allCases
            header.titleLabel.text = allSections[indexPath.section].title
            return header
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.popular, .screening])
        snapshot.appendItems([], toSection: .popular)
        snapshot.appendItems([], toSection: .screening)
        datasource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
        collectionView.alwaysBounceVertical = false
        
        collectionView.delegate = self
    }
    
    private func applyItems(_ items: [Movie], section: Section) {
        var snapshot = datasource.snapshot()
        snapshot.appendItems(items, toSection: section)
        datasource.apply(snapshot)
    }
    
    private func configureCell(for section: Section, item: Item, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        switch section {
        case .popular:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PopularMovieCell",
                for: indexPath
            ) as! PopularMovieCell
            cell.configure(movie: item)
            return cell
        case .screening:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ScreeningMovieCell",
                for: indexPath
            ) as! ScreeningMovieCell
            cell.configure(movie: item)
            return cell
        }
    }
    
    private func bind() {
        viewModel.$popularMovies
            .receive(on: RunLoop.main)
            .sink { items in
                self.applyItems(items, section: .popular)
            }.store(in: &subscriptions)
        
        viewModel.$screeningMovies
            .receive(on: RunLoop.main)
            .sink { items in
                self.applyItems(items, section: .screening)
            }.store(in: &subscriptions)
        
        viewModel.movieTapped
            .sink { movie in
                let sb = UIStoryboard(name: "Detail", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "HomeDetailViewController") as! HomeDetailViewController
                vc.viewModel = HomeDetailViewModel(
                    network: NetworkService(configuration: .default),
                    movieDetail: movie
                )
                self.navigationController?.pushViewController(vc, animated: true)
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
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 0,
            bottom: 10,
            trailing: 0
        )
        section.interGroupSpacing = 10
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.popularMovies[indexPath.item]
        viewModel.movieTapped.send(item)
    }
}
