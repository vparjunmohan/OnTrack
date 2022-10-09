//
//  ViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 03/01/22.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    var taskListArray: [String] = []
    var taskArrayPayload: [[String:Any]] = []
    var tempTaskArray: [[String:Any]] = []
    var selectedImage: UIImage?
    var username: String!
    var userId: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add", message: "Task Title", preferredStyle: .alert)
        alert.addTextField() { newTextField in
            newTextField.placeholder = ""
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [self] action in
            if let textFields = alert.textFields, let tf = textFields.first, let result = tf.text {
                if result.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.displayEmptyFieldAlert()
                } else {
                    AppEntity.taskManagement.updateValue(userId!, forKey: "user_id")
                    AppEntity.taskManagement.updateValue(UUID().uuidString, forKey: "task_id")
                    AppEntity.taskManagement.updateValue(result, forKey: "task_title")
                    AppEntity.taskManagement.updateValue(AppColorConstants.defaultTaskColor, forKey: "initial_bg_color")
                    DbOperations().insertTable(insertvalues: AppEntity.taskManagement, tableName: AppConstants.taskTable, uniquekey: "task_id")
                    self.taskArrayPayload = DbOperations().selectTable(tableName: AppConstants.taskTable) as! [[String:Any]]
                    self.tempTaskArray = self.taskArrayPayload
                    self.todoTableView.reloadData()
                    self.categoryCollectionView.reloadData()
                }
            }
            
        })
        self.present(alert, animated: true)
    }
    
    func displayEmptyFieldAlert(){
        let alert = UIAlertController(title: "Alert", message: "Task name cannot be empty", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func didClickSideBar(_ sender: UIButton) {
        let addVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        addVC.modalPresentationStyle = .overCurrentContext
        addVC.view.layer.speed = 0.5
        self.present(addVC, animated: true)
    }
    
    func setupUI() {
        
        if let currentUserId = UserDefaults.standard.object(forKey: "user_id") as? String {
            userId = currentUserId
            let currentUserData = DbOperations().selectTableWhere(tableName: AppConstants.userTable, selectKey: "user_id", selectValue: userId!) as! [[String:Any]]
            if currentUserData.count > 0 {
                // user exists
                let username = currentUserData[0]["user_name"] as? String
                usernameLabel.text = "Hi \(username!)"
                let avatarImgData = Data(base64Encoded: (currentUserData[0]["avatar_image_data"] as? String)!)
                avatarImageView.image = UIImage(data: avatarImgData!)
                taskArrayPayload = DbOperations().selectTableWhere(tableName: AppConstants.taskTable, selectKey: "user_id", selectValue: userId!) as! [[String:Any]]
                tempTaskArray = taskArrayPayload
                
            }
        }
        categoryCollectionView.register(UINib(nibName: "CategoriesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        todoTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        let avatarClicked = UITapGestureRecognizer(target: self, action: #selector(uploadAvatarImage))
        if selectedImage != nil {
            avatarImageView.image = selectedImage
        }
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(avatarClicked)
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 5, y:0, width: CGFloat(18), height: CGFloat(18))
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 25, height: 20))
        button.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .lightGray
        paddingView.addSubview(button)
        searchTextField.leftViewMode = .always
        searchTextField.rightViewMode = .never
        searchTextField.leftView = paddingView
        searchTextField.layer.cornerRadius = 17.5
        searchTextField.clipsToBounds = true
        searchTextField.backgroundColor = UIColor.init(hexString: AppColorConstants.searchFieldColor)
        searchTextField.delegate = self


        
        
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        //        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func touchClose(_ sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }
    
    @objc func uploadAvatarImage() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }
    
    @objc func checkButtonSelected(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let senderTag = sender.tag
        let selectedCell = todoTableView.cellForRow(at: IndexPath(row: senderTag, section: 0)) as? TaskTableViewCell
        let index = tempTaskArray.firstIndex(where: { $0["task_id"] as? String == selectedCell?.accessibilityIdentifier })
        var currentData = tempTaskArray[index!]
        if sender.isSelected {
            currentData.updateValue(AppColorConstants.checkedTaskColor, forKey: "initial_bg_color")
            currentData.updateValue("true", forKey: "is_completed")
            DbOperations().updateTable(valuesToChange: currentData, whereKey: "task_id", whereValue: currentData["task_id"] as! String, tableName: AppConstants.taskTable)
            tempTaskArray.removeAll()
            tempTaskArray = DbOperations().selectTableWhere(tableName: AppConstants.taskTable, selectKey: "user_id", selectValue: currentData["user_id"] as! String) as! [[String:Any]]
            todoTableView.reloadData()
            categoryCollectionView.reloadData()
        } else {
            currentData.updateValue(AppColorConstants.defaultTaskColor, forKey: "initial_bg_color")
            currentData.updateValue("false", forKey: "is_completed")
            DbOperations().updateTable(valuesToChange: currentData, whereKey: "task_id", whereValue: currentData["task_id"] as! String, tableName: AppConstants.taskTable)
            tempTaskArray.removeAll()
            tempTaskArray = DbOperations().selectTableWhere(tableName: AppConstants.taskTable, selectKey: "user_id", selectValue: currentData["user_id"] as! String) as! [[String:Any]]
            todoTableView.reloadData()
            categoryCollectionView.reloadData()
        }
    }
    
    @objc func priorityButtonSelected(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let senderTag = sender.tag
        let selectedCell = todoTableView.cellForRow(at: IndexPath(row: senderTag, section: 0)) as? TaskTableViewCell
        let index = tempTaskArray.firstIndex(where: { $0["task_id"] as? String == selectedCell?.accessibilityIdentifier })
        var currentData = tempTaskArray[index!]
        if sender.isSelected {
            currentData.updateValue("true", forKey: "is_priority")
            DbOperations().updateTable(valuesToChange: currentData, whereKey: "task_id", whereValue: currentData["task_id"] as! String, tableName: AppConstants.taskTable)
            tempTaskArray.removeAll()
            tempTaskArray = DbOperations().selectTableWhere(tableName: AppConstants.taskTable, selectKey: "user_id", selectValue: currentData["user_id"] as! String) as! [[String:Any]]
            todoTableView.reloadData()
            categoryCollectionView.reloadData()
        } else {
            currentData.updateValue("false", forKey: "is_priority")
            DbOperations().updateTable(valuesToChange: currentData, whereKey: "task_id", whereValue: currentData["task_id"] as! String, tableName: AppConstants.taskTable)
            tempTaskArray.removeAll()
            tempTaskArray = DbOperations().selectTableWhere(tableName: AppConstants.taskTable, selectKey: "user_id", selectValue: currentData["user_id"] as! String) as! [[String:Any]]
            todoTableView.reloadData()
            categoryCollectionView.reloadData()
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempTaskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentTask = tempTaskArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        cell.taskContentView.backgroundColor = UIColor.init(hexString: (currentTask["initial_bg_color"] as? String)!)
        cell.selectionStyle = .none
        cell.separatorInset = .zero
        cell.taskContentView.layer.cornerRadius = 10
        cell.taskContentView.clipsToBounds = true
        cell.accessibilityIdentifier = currentTask["task_id"] as? String
        cell.taskNameLabel.text = currentTask["task_title"] as? String
        cell.checkButton.isSelected = (currentTask["is_completed"] as! String).toBool()
        cell.priorityButton.isSelected = (currentTask["is_priority"] as! String).toBool()
        cell.tag = indexPath.row
        cell.checkButton.tag = indexPath.row
        cell.priorityButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: #selector(checkButtonSelected(_:)), for: .touchUpInside)
        cell.priorityButton.addTarget(self, action: #selector(priorityButtonSelected(_:)), for: .touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentTask = tempTaskArray[indexPath.row]
        let addVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskDetailViewController") as! TaskDetailViewController
        self.addChild(addVC)
        addVC.updateTaskDetailDelegate = self
        addVC.selectedTask = currentTask
        self.view.addSubview(addVC.view)
        addVC.didMove(toParent: self)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let currentData = tempTaskArray[indexPath.row]
        if editingStyle == .delete {
            // issue when deleting after searching
            DbOperations().deleteTable(deleteKey: "task_id", deleteValue: currentData["task_id"] as! String, tableName: AppConstants.taskTable)
            taskArrayPayload = DbOperations().selectTableWhere(tableName: AppConstants.taskTable, selectKey: "user_id", selectValue: currentData["user_id"] as! String) as! [[String:Any]]
            tempTaskArray = taskArrayPayload
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            categoryCollectionView.reloadData()
            
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
            cell.taskCategoryLabel.text = AppConstants.totalTaskLabelText
            cell.totalTasksLabel.text = "\(tempTaskArray.count) tasks"
            break
        case 1:
            // Priority
            cell.categoryContentView.backgroundColor = UIColor.init(hexString: AppColorConstants.priorityTaskColor)
            cell.taskCategoryLabel.text = AppConstants.priorityTaskLabelText
            let priorityFilter = tempTaskArray.filter{ item in
                item["is_priority"] as? String == "true"
            }
            cell.totalTasksLabel.text = "\(priorityFilter.count) tasks"
            break
        case 2:
            // Completed
            cell.categoryContentView.backgroundColor = UIColor.init(hexString: AppColorConstants.completedTaskColor)
            cell.taskCategoryLabel.text = AppConstants.completedTaskLabelText
            let completedFilter = tempTaskArray.filter{ item in
                item["is_completed"] as? String == "true"
            }
            cell.totalTasksLabel.text = "\(completedFilter.count) tasks"
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            let screenWidth = UIScreen.main.bounds.width
            let calculatedCellWidth = (screenWidth - 100) / 3
            return CGSize(width: calculatedCellWidth, height: 100)
        }
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 80)
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !(newText.isEmpty) {
            let filter = taskArrayPayload.filter{item in
                (item["task_title"]as! String).lowercased().contains(newText.lowercased())
            }
            tempTaskArray = filter
            todoTableView.reloadData()
        } else {
            tempTaskArray = taskArrayPayload
            todoTableView.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        tempTaskArray = taskArrayPayload
        todoTableView.reloadData()
        return true
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProviders = results.map(\.itemProvider)
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async { [self] in
                        if let image = image as? UIImage {
                            avatarImageView.image = image
                            DbOperations().updateTable(valuesToChange: ["avatar_image_data": AppUtils().convertImageToBase64String(img: avatarImageView.image!)], whereKey: "user_id", whereValue: userId!, tableName: AppConstants.userTable)
                            picker.dismiss(animated: true)
                        } else{
                            picker.dismiss(animated: true)
                            let alertController = UIAlertController(title: "Alert", message: "Error picking image", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(action)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}

extension ViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        if let touchedView = touch.view, let gestureView =
            gestureRecognizer.view, touchedView.isDescendant(of: gestureView),
           touchedView !== gestureView {
            return false
        }
        return true
    }
}

extension ViewController: UpdateTaskDetail {
    func updateCurrentDetail(taskDetail: [String : Any]) {
        let index = tempTaskArray.firstIndex(where: { ($0["task_id"] as! String) == taskDetail["task_id"] as? String })
        if let index = index {
            tempTaskArray.remove(at: index)
            tempTaskArray.insert(taskDetail, at: index)
            todoTableView.reloadData()
        }
    }
}
