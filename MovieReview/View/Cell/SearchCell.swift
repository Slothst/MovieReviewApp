//
//  SearchCell.swift
//  MovieReview
//
//  Created by 최낙주 on 3/26/24.
//

import UIKit
import Kingfisher

class SearchCell: UICollectionViewCell {
    
    @IBOutlet weak var moviePoster: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        moviePoster.image = nil
    }
    
    func configure(movie: Movie) {
        moviePoster.kf.setImage(with: movie.imageURL)
        moviePoster.contentMode = .scaleAspectFit
        moviePoster.clipsToBounds = true
        
    }
}
