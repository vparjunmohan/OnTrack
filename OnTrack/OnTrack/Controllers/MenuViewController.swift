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
            if let parent = self.parent {
                if parent is DashboardViewController {
                    let defaults = UserDefaults.standard
                    if updateTaskDetailDelegate != nil {
                        if let selectedUserId = defaults.object(forKey: "user_id") as? String {
                            updateTaskDetailDelegate.updateCurrentDetail(currentUserId: selectedUserId)
                        }
                    }
                    self.willMove(toParent: nil)
                    self.view.removeFromSuperview()
                    self.removeFromParent()
                }
            }
        }
    }

    @IBAction func addNewAccount(_ sender: UIButton) {
        if let parent = self.parent {
            if parent is DashboardViewController {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAccountViewController") as! AddAccountViewController
                parent.addChild(storyboard)
                storyboard.currentLoggedId = loggedId
                parent.view.addSubview(storyboard.view)
                storyboard.didMove(toParent: parent)
            }
        }
//        if let parent = self.presentingViewController {
//            if let parentController = parent as? DashboardViewController {
//                self.dismiss(animated: true)
//                let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAccountViewController") as! AddAccountViewController
//                parentController.addChild(storyboard)
//                storyboard.currentLoggedId = loggedId
//                parentController.view.addSubview(storyboard.view)
//                storyboard.didMove(toParent: parentController)
//            }
//        }
    }
    
    @objc func deleteAccount(_ sender: UIButton) {
        if let deleteUserId = sender.accessibilityIdentifier {
            DbOperations().deleteTable(deleteKey: "user_id", deleteValue: deleteUserId, tableName: AppConstants.userTable)
            DbOperations().deleteTable(deleteKey: "user_id", deleteValue: deleteUserId, tableName: AppConstants.taskTable)
            userAccounts = DbOperations().selectTable(tableName: AppConstants.userTable) as! [[String:Any]]
            if userAccounts.count > 0 {
                // user account exists
                let initialAccount = userAccounts[0]
                DbOperations().updateTable(valuesToChange: ["is_logged": "true"], whereKey: "user_id", whereValue: initialAccount["user_id"] as! String, tableName: AppConstants.userTable)
                let defaults = UserDefaults.standard
                defaults.set(initialAccount["user_id"] as! String, forKey: "user_id")
                accountsTableView.reloadData()
                if let parent = self.parent {
                    if parent is DashboardViewController {
                        let defaults = UserDefaults.standard
                        if updateTaskDetailDelegate != nil {
                            updateTaskDetailDelegate.updateCurrentDetail(currentUserId: initialAccount["user_id"] as! String)
                        }
                        self.willMove(toParent: nil)
                        self.view.removeFromSuperview()
                        self.removeFromParent()
                    }
                }
            } else {
                // all user accounts deleted
                // clear user defaults. remove controllers. set add account controller as root controller
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "user_id")
                defaults.removeObject(forKey: "logged_in")
                if let parent = self.parent {
                    if parent is DashboardViewController {
                        self.willMove(toParent: nil)
                        self.view.removeFromSuperview()
                        self.removeFromParent()
                        if UserDefaults.standard.object(forKey: "logged_in") as? Bool == nil {
                            let viewController =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAccountViewController") as! AddAccountViewController
                            parent.view.window?.rootViewController = viewController
                            parent.view.window?.makeKeyAndVisible()
                        }
                    }
                }
            }
        }
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
//        DispatchQueue.global(qos: .background).async {
//            var avatarImgData = Data(base64Encoded: (currentUser["avatar_image_data"] as? String)!)
//            DispatchQueue.main.async {
//                cell.accountImageView.image = UIImage(data: avatarImgData!)
//            }
//        }
//        cell.accountImageView.image = UIImage(data: avatarImgData!)
        cell.accountName.text = currentUser["user_name"] as? String
        cell.removeButton.accessibilityIdentifier = currentUser["user_id"] as? String
        cell.removeButton.addTarget(self, action: #selector(deleteAccount(_:)), for: .touchUpInside)
        if currentUser["is_logged"] as? String == "true" {
            cell.checkMarkImageView.isHidden = false
            cell.accountName.font = UIFont(name: "Avenir Next Demi Bold", size: 16)
        } else {
            cell.checkMarkImageView.isHidden = true
            cell.accountName.font = UIFont(name: "Avenir Next Regular", size: 16)
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
            if let parent = self.parent {
                if parent is DashboardViewController {
                    self.willMove(toParent: nil)
                    self.view.removeFromSuperview()
                    self.removeFromParent()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}


extension MenuViewController {
    func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        popupView.clipsToBounds = true
        popupView.layer.cornerRadius = 10
        popupView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        accountsTableView.backgroundColor = .white
        popupView.backgroundColor = .white
        accountsTableView.register(UINib(nibName: "AccountsTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountsTableViewCell")
        userAccounts = DbOperations().selectTable(tableName: AppConstants.userTable) as! [[String:Any]]
    }
}
