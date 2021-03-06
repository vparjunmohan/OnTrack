//
//  TaskTableViewCell.swift
//  OnTrack
//
//  Created by Arjun Mohan on 03/01/22.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var taskContentView: UIView!
    @IBOutlet weak var priorityButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
