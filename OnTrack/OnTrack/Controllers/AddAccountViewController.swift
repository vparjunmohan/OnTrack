//
//  AddAccountViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 09/10/22.
//

import UIKit

class AddAccountViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var topCornerView: UIView!
    @IBOutlet weak var bottomCornerView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var fourthView: UIView!
    @IBOutlet weak var fifthView: UIView!
    
    var currentLoggedId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func createNewAccount(_ sender: UIButton) {
        
        if usernameTextField.text == "" {
            errorLabel.isHidden = false
            errorLabel.text = AppConstants.usernameEmpty
        } else {
            let dbUserList = DbOperations().selectTable(tableName: AppConstants.userTable) as! [[String:Any]]
            let userExistsFilter = dbUserList.filter { user in
                (user["user_name"] as? String)?.lowercased() == usernameTextField.text!.lowercased()
            }
            if userExistsFilter.count > 0 {
                // user name exists
                errorLabel.isHidden = false
                errorLabel.text = AppConstants.usernameExists
            } else {
                // new user
                if usernameTextField.text!.count > 12 {
                    // exceed character length
                    errorLabel.isHidden = false
                    errorLabel.text = AppConstants.exceedCharacters
                } else {
                    // create
                    if currentLoggedId != nil {
                        DbOperations().updateTable(valuesToChange: ["is_logged": "false"], whereKey: "user_id", whereValue: currentLoggedId!, tableName: AppConstants.userTable)
                    }
                    let userId = UUID().uuidString
                    AppEntity.accountManagement.updateValue(userId, forKey: "user_id")
                    AppEntity.accountManagement.updateValue(usernameTextField.text!, forKey: "user_name")
                    AppEntity.accountManagement.updateValue("true", forKey: "is_logged")
                    DbOperations().insertTable(insertvalues: AppEntity.accountManagement, tableName: AppConstants.userTable, uniquekey: "user_name")
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "logged_in")
                    defaults.set(userId, forKey: "user_id")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                    self.view.window?.rootViewController = storyboard
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }
}

extension AddAccountViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorLabel.isHidden = true
        errorLabel.text = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
