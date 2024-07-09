//
//  HomeViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import UIKit
import Combine



class HomeViewController: ExtensionVC {

    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias Item = Movie
    
    enum Section: CaseIterable {
        case popular
        case screening
        case upcoming
        case topRated
        
        var title: String {
            switch self {
            case .popular:
                return "지금 인기 있는 영화"
            case .screening:
                return "현재 상영 중인 영화"
            case .upcoming:
                return "개봉 예정 중인 영화"
            case .topRated:
                return "평점 좋은 영화"
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
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "MovieCell",
                    for: indexPath
                ) as? MovieCell else { return nil }
                cell.configure(movie: item)
                return cell
            }
        )
        
        self.datasource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "TitleHeaderCollectionReusableView",
                for: indexPath
            ) as? TitleHeaderCollectionReusableView else { return nil }
            
            let allSections = Section.allCases
            header.titleLabel.text = allSections[indexPath.section].title
            return header
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.popular, .screening, .upcoming, .topRated])
        snapshot.appendItems([], toSection: .popular)
        snapshot.appendItems([], toSection: .screening)
        snapshot.appendItems([], toSection: .upcoming)
        snapshot.appendItems([], toSection: .topRated)
        datasource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.delegate = self
    }
    
    private func applyItems(_ items: [Movie], section: Section) {
        var snapshot = datasource.snapshot()
        snapshot.appendItems(items, toSection: section)
        datasource.apply(snapshot)
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
        
        viewModel.$upcomingMovies
            .receive(on: RunLoop.main)
            .sink { items in
                self.applyItems(items, section: .upcoming)
            }.store(in: &subscriptions)
        
        viewModel.$topRatedMovies
            .receive(on: RunLoop.main)
            .sink { items in
                self.applyItems(items, section: .topRated)
            }.store(in: &subscriptions)
        
        viewModel.movieTapped
            .sink { movie in
                let sb = UIStoryboard(name: "Detail", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                vc.viewModel = DetailViewModel(
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
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let allSections = Section.allCases
        if allSections[indexPath.section] == Section.popular {
            let item = viewModel.popularMovies[indexPath.item]
            viewModel.movieTapped.send(item)
        } else if allSections[indexPath.section] == Section.screening {
            let item = viewModel.screeningMovies[indexPath.item]
            viewModel.movieTapped.send(item)
        } else if allSections[indexPath.section] == Section.upcoming {
            let item = viewModel.upcomingMovies[indexPath.item]
            viewModel.movieTapped.send(item)
        } else {
            let item = viewModel.topRatedMovies[indexPath.item]
            viewModel.movieTapped.send(item)
        }
    }
}
