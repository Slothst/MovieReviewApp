//
//  SearchViewController.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import UIKit
import Combine

class SearchViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var viewModel: SearchViewModel = SearchViewModel(network: NetworkService(configuration: .default))
    
    typealias Item = Movie
    
    enum Section {
        case main
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var subscriptions = Set<AnyCancellable>()
    
    private var isLoadingMoreCharacters = false
    
    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let guideView: GuideView = {
        let view = GuideView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingView.isLoading = true
        hideKeyBoardWhenTappedScreen()
        embedSearchControl()
        configureCollectionView()
        embedLoadingView()
        embedGuideView()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }
    
    func hideKeyBoardWhenTappedScreen() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapHandler() {
        searchController.searchBar.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    private func embedLoadingView() {
        self.view.addSubview(loadingView)
        NSLayoutConstraint.activate([
          self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
          self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
          self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
          self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
        NSLayoutConstraint.activate([
          self.loadingView.leftAnchor.constraint(equalTo: self.collectionView.leftAnchor),
          self.loadingView.rightAnchor.constraint(equalTo: self.collectionView.rightAnchor),
          self.loadingView.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor),
          self.loadingView.topAnchor.constraint(equalTo: self.collectionView.topAnchor),
        ])
    }
    
    private func embedGuideView() {
        self.view.addSubview(guideView)
        NSLayoutConstraint.activate([
          self.guideView.leftAnchor.constraint(equalTo: self.collectionView.leftAnchor),
          self.guideView.rightAnchor.constraint(equalTo: self.collectionView.rightAnchor),
          self.guideView.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor),
          self.guideView.topAnchor.constraint(equalTo: self.collectionView.topAnchor),
        ])
    }
    
    private func embedSearchControl() {
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "검색"
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.automaticallyShowsCancelButton = false
        self.searchController.searchBar.becomeFirstResponder()
        self.navigationItem.searchController = searchController
    }
    
    private func configureCollectionView() {
        datasource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SearchCell",
                    for: indexPath
                ) as? SearchCell else { return nil }
                cell.configure(movie: item)
                return cell
            }
        )
        
        collectionView.collectionViewLayout = layout()
        collectionView.delegate = self
    }
    
    private func bind() {
        viewModel.$searchResults
            .receive(on: RunLoop.main)
            .sink { movies in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(movies, toSection: .main)
                self.datasource.apply(snapshot)
            }.store(in: &subscriptions)
        
        viewModel.movieTapped
            .receive(on: RunLoop.main)
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .absolute(160))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item, item])
        group.interItemSpacing = .fixed(-20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let keyword = searchController.searchBar.text else { return }
        if keyword.isEmpty {
            self.guideView.isHidden = false
        } else {
            self.guideView.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.loadingView.isLoading = false
        }
        viewModel.search(keyword: keyword)
        self.loadingView.isLoading = true
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        viewModel.search(keyword: keyword)
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.searchResults[indexPath.item]
        viewModel.movieTapped.send(item)
    }
}
