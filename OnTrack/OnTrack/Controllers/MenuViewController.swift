//
//  MenuViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 08/10/22.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var accountsTableView: UITableView!
    
    var userAccounts: [[String:Any]] = []
    var loggedId: String!
    var updateTaskDetailDelegate: UpdateTaskDetailDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.first
        if touches?.view != popupView {
            self.view.window!.layer.speed = 0.5
            self.dismiss(animated: true)
        }
    }

    @IBAction func addNewAccount(_ sender: UIButton) {
        if let parent = self.presentingViewController {
            if let parentController = parent as? DashboardViewController {
                self.dismiss(animated: true)
                let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAccountViewController") as! AddAccountViewController
                parentController.addChild(storyboard)
                storyboard.currentLoggedId = loggedId
                parentController.view.addSubview(storyboard.view)
                storyboard.didMove(toParent: parentController)
            }
        }
    }
    
    func retrieveImage(data: [String:Any]) {
        
        
    }
    
    func displayImage(imgData: Data) {
       
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountsTableViewCell", for: indexPath) as! AccountsTableViewCell
        let currentUser = userAccounts[indexPath.row]
//        let avatarImgData = Data(base64Encoded: (currentUser["avatar_image_data"] as? String)!)
        cell.accessibilityIdentifier = currentUser["user_id"] as? String
        cell.selectionStyle = .none
        DispatchQueue.global(qos: .background).async {
            var avatarImgData = Data(base64Encoded: (currentUser["avatar_image_data"] as? String)!)
            DispatchQueue.main.async {
                cell.accountImageView.image = UIImage(data: avatarImgData!)
            }
        }
//        cell.accountImageView.image = UIImage(data: avatarImgData!)
        cell.accountName.text = currentUser["user_name"] as? String
        if currentUser["is_logged"] as? String == "true" {
            cell.checkMarkImageView.isHidden = false
        } else {
            cell.checkMarkImageView.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath) as? AccountsTableViewCell {
            let defaults = UserDefaults.standard
            DbOperations().updateTable(valuesToChange: ["is_logged": "false"], whereKey: "user_id", whereValue: loggedId!, tableName: AppConstants.userTable)
            defaults.set(selectedCell.accessibilityIdentifier!, forKey: "user_id")
            DbOperations().updateTable(valuesToChange: ["is_logged": "true"], whereKey: "user_id", whereValue: selectedCell.accessibilityIdentifier!, tableName: AppConstants.userTable)
            tableView.reloadData()
            if updateTaskDetailDelegate != nil {
                updateTaskDetailDelegate.updateCurrentDetail(currentUserId: selectedCell.accessibilityIdentifier!)
            }
            self.view.window!.layer.speed = 0.5
            self.dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}


extension MenuViewController {
    func setupUI() {
        view.backgroundColor = .clear
        popupView.clipsToBounds = true
        popupView.layer.cornerRadius = 10
        popupView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        accountsTableView.backgroundColor = AppColorConstants.menubarMainColor
        popupView.backgroundColor = AppColorConstants.menubarMainColor
        accountsTableView.register(UINib(nibName: "AccountsTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountsTableViewCell")
        userAccounts = DbOperations().selectTable(tableName: AppConstants.userTable) as! [[String:Any]]
    }
}
