//
//  TaskDetailViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 29/05/22.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    
    @IBOutlet weak var titleHeader: UILabel!
    
    var selectedTask: [String:Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(selectedTask)
    }
    

    @IBAction func backToDashboard(_ sender: UIButton) {
        self.view.removeFromSuperview()
    }
    

}
