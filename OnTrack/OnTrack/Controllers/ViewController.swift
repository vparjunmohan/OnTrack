//
//  ViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 03/01/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var taskListArray: [String] = []
    var taskArrayPayload: [[String:Any]] = []
    var currentUUID: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.register(UINib(nibName: "CategoriesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        todoTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
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
                        let uuid = UUID().uuidString
                        var taskData = ["uuid": uuid, "task_title": result,"is_completed":false, "is_priority": false, "task_detail":"", "initial_bg_color": AppColorConstants.defaultTaskColor] as [String : Any]
                        self.taskArrayPayload.append(taskData)
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
    
    
    @IBAction func didClickSideBar(_ sender: UIButton) {
        let addVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideBarViewController")
        self.addChild(addVC)
        self.view.addSubview(addVC.view)
        addVC.didMove(toParent: self)
        
    }
    
    @objc func checkButtonSelected(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let senderTag = sender.tag
        let selectedCell = todoTableView.cellForRow(at: IndexPath(row: senderTag, section: 0)) as? TaskTableViewCell
        let index = taskArrayPayload.firstIndex(where: { $0["uuid"] as? String == selectedCell?.accessibilityIdentifier })
        var currentData = taskArrayPayload[index!]
        if sender.isSelected {
//            selectedCell!.taskContentView.backgroundColor = UIColor.init(hexString: "14C38E")
            currentData.updateValue(AppColorConstants.checkedTaskColor, forKey: "initial_bg_color")
            currentData.updateValue(true, forKey: "is_completed")
            taskArrayPayload.remove(at: index!)
            taskArrayPayload.insert(currentData, at: index!)
            todoTableView.reloadData()
            print(taskArrayPayload)
        } else {
//            selectedCell!.taskContentView.backgroundColor = UIColor.init(hexString: "9BA3EB")
            currentData.updateValue(AppColorConstants.defaultTaskColor, forKey: "initial_bg_color")
            currentData.updateValue(false, forKey: "is_completed")
            taskArrayPayload.remove(at: index!)
            taskArrayPayload.insert(currentData, at: index!)
            todoTableView.reloadData()
            print(taskArrayPayload)
        }
    }
    
    @objc func priorityButtonSelected(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArrayPayload.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentTask = taskArrayPayload[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        cell.taskContentView.backgroundColor = UIColor.init(hexString: (currentTask["initial_bg_color"] as? String)!)
        cell.separatorInset = .zero
        self.currentUUID = (currentTask["uuid"] as? String)!
        cell.taskContentView.layer.cornerRadius = 10
        cell.taskContentView.clipsToBounds = true
        cell.accessibilityIdentifier = currentTask["uuid"] as? String
        cell.taskNameLabel.text = currentTask["task_title"] as? String
        cell.checkButton.isSelected = (currentTask["is_completed"] as? Bool)!
        cell.priorityButton.isSelected = (currentTask["is_priority"] as? Bool)!
        cell.tag = indexPath.row
        cell.checkButton.tag = indexPath.row
        cell.priorityButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: #selector(checkButtonSelected(_:)), for: .touchUpInside)
        cell.priorityButton.addTarget(self, action: #selector(priorityButtonSelected(_:)), for: .touchUpInside)
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
        return 80
    }
    
}



extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoriesCollectionViewCell
        switch indexPath.row {
        case 0:
            // Total tasks
            cell.categoryContentView.backgroundColor = UIColor.init(hexString: AppColorConstants.totalTaskColor)
            break
        case 1:
            // Priority
            cell.categoryContentView.backgroundColor = UIColor.init(hexString: AppColorConstants.priorityTaskColor)
            break
        case 2:
            // Completed
            cell.categoryContentView.backgroundColor = UIColor.init(hexString: AppColorConstants.completedTaskColor)
            break
        default:
            break
        }
        cell.categoryContentView.layer.cornerRadius = 10
        cell.categoryContentView.clipsToBounds = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 6.0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.categoryContentView.layer.cornerRadius).cgPath
        cell.layer.masksToBounds = false
        return cell
    }
    
    
}


extension ViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 250, height: 100)

        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 1.0
        }

        func collectionView(_ collectionView: UICollectionView, layout
            collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 30.0
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 80)
    }
}
