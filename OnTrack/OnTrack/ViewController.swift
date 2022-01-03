//
//  ViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 03/01/22.
//

import UIKit

class ViewController: UIViewController {

    var taskListArray: [String] = ["todo1", "todo2"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        cell.separatorInset = .zero
        cell.taskNameLabel.text = taskListArray[indexPath.row]
        return cell
    }
    
}
