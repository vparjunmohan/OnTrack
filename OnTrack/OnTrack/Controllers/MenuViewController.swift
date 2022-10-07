//
//  MenuViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 08/10/22.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.first
        if touches?.view != popupView {
//            let transition: CATransition = CATransition()
//            transition.duration = 0.05
            self.view.window!.layer.speed = 0.5
//            self.view.window!.layer.add(transition, forKey: nil)
            self.dismiss(animated: true)
        }
    }


}


extension MenuViewController {
    func setupUI() {
        view.backgroundColor = .clear
        popupView.clipsToBounds = true
        popupView.layer.cornerRadius = 20
        popupView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}
