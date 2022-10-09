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
    
    let tempAccounts = ["user 1","user 2","user 3","user 4"]
    
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
        
    }
    
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountsTableViewCell", for: indexPath) as! AccountsTableViewCell
        if indexPath.row == 1 {
            cell.checkMarkImageView.isHidden = false
        } else {
            cell.checkMarkImageView.isHidden = true
        }
        cell.accountName.text = tempAccounts[indexPath.row]
        return cell
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
    }
}
