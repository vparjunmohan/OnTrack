//
//  CategoriesCollectionViewCell.swift
//  OnTrack
//
//  Created by Arjun Mohan on 04/01/22.
//

import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var totalTasksLabel: UILabel!
    @IBOutlet weak var taskCategoryLabel: UILabel!
    @IBOutlet weak var categoryContentView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
