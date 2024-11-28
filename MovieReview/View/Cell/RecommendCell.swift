//
//  RecommendCell.swift
//  MovieReview
//
//  Created by 최낙주 on 7/12/24.
//

import UIKit

class RecommendCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    static let identifier: String = "RecommendCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    func configure(movie: Movie) {
        titleLabel.text = movie.title
    }
}
