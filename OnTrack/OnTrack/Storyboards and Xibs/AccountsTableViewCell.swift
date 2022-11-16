//
//  AccountsTableViewCell.swift
//  OnTrack
//
//  Created by Arjun Mohan on 08/10/22.
//

import UIKit

class AccountsTableViewCell: UITableViewCell {

    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var innerContentView: UIView!
    @IBOutlet weak var removeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        innerContentView.layer.cornerRadius = 10
        innerContentView.clipsToBounds = true
        innerContentView.backgroundColor = UIColor(hexString: AppColorConstants.defaultTaskColor)
        removeButton.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
