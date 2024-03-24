//
//  TitleHeaderCollectionReusableView.swift
//  MovieReview
//
//  Created by 최낙주 on 3/24/24.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(title: String) {
        titleLabel.text = title
    }
}
