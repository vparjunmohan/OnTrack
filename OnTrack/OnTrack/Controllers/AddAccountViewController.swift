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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        usernameTextField.delegate = self
        usernameTextField.becomeFirstResponder()
    }
    
    
    @IBAction func createNewAccount(_ sender: UIButton) {
        
        if usernameTextField.text == "" {
            errorLabel.isHidden = false
            errorLabel.text = AppConstants.usernameEmpty
            errorLabel.textColor = AppColorConstants.error
        } else {
            let dbUserList = DbOperations().selectTable(tableName: AppConstants.userTable) as! [[String:Any]]
            let userExistsFilter = dbUserList.filter { user in
                user["user_name"] as? String == usernameTextField.text!.lowercased()
            }
            if userExistsFilter.count > 0 {
                // user name exists
                errorLabel.isHidden = false
                errorLabel.text = AppConstants.usernameExists
                errorLabel.textColor = AppColorConstants.error
            } else {
                // new user
                let userId = UUID().uuidString
                AppEntity.accountManagement.updateValue(userId, forKey: "user_id")
                AppEntity.accountManagement.updateValue(usernameTextField.text!.lowercased(), forKey: "user_name")
                AppEntity.accountManagement.updateValue(AppUtils().convertImageToBase64String(img: avatarImageView.image!), forKey: "avatar_image_data")
                DbOperations().insertTable(insertvalues: AppEntity.accountManagement, tableName: AppConstants.userTable, uniquekey: "user_name")
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "logged_in")
                defaults.set(userId, forKey: "user_id")
                let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
                self.view.window?.rootViewController = storyboard
                self.view.window?.makeKeyAndVisible()
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
}
