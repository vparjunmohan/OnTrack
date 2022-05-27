//
//  SideBarViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 05/01/22.
//

import UIKit

class SideBarViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
    }
    

    @IBAction func didClickBackButton(_ sender: UIButton) {
        self.view.removeFromSuperview()
    }
    
    
}
