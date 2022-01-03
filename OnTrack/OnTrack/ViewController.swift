//
//  ViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 03/01/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var todoTableView: UITableView!
    
    var taskListArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Create", message: "Add new task", preferredStyle: .alert)
            alert.addTextField() { newTextField in
                newTextField.placeholder = ""
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                if let textFields = alert.textFields, let tf = textFields.first, let result = tf.text {
                    if result.trimmingCharacters(in: .whitespaces).isEmpty {
                        self.displayEmptyFieldAlert()
                    } else {
                        self.taskListArray.append(result)
                        self.todoTableView.reloadData()
                        
                    }
                }

            })
        self.present(alert, animated: true)
    }
    
    func displayEmptyFieldAlert(){
        let alert = UIAlertController(title: "Alert", message: "Task name cannot be empty", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            taskListArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
