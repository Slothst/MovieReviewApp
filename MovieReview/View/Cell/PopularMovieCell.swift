//
//  MovieCell.swift
//  MovieReview
//
//  Created by 최낙주 on 3/23/24.
//

import UIKit
import Kingfisher

class PopularMovieCell: UICollectionViewCell {
    
    @IBOutlet weak var moviePoster: UIImageView!
    
    func configure(movie: Movie) {
        moviePoster.kf.setImage(
            with: URL(
                string: "https://image.tmdb.org/t/p/w200/\(movie.posterPath)"
            )
        )
        moviePoster.contentMode = .scaleAspectFit
    }
    //https://image.tmdb.org/t/p/w120/wkfG7DaExmcVsGLR4kLouMwxeT5.jpg
}
