//
//  AccountsTableViewCell.swift
//  OnTrack
//
//  Created by Arjun Mohan on 08/10/22.
//

import UIKit

class AccountsTableViewCell: UITableViewCell {

    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var innerContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        innerContentView.layer.cornerRadius = 15
        innerContentView.clipsToBounds = true
        accountImageView.layer.cornerRadius = 5
        accountImageView.clipsToBounds = true
        innerContentView.backgroundColor = AppColorConstants.menuCellColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
