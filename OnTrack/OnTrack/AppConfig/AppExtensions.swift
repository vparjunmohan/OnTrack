//
//  AppExtensions.swift
//  OnTrack
//
//  Created by Arjun Mohan on 27/05/22.
//

import UIKit

//class AppExtensions: NSObject {
//
//}

extension UIView {
    func applyCommonDropShadow(radius:CGFloat, opacity: Float) {
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.borderColor = UIColor.black.cgColor
        clipsToBounds = false
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
        case 6: chars = ["F","F"] + chars
        case 8: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                  green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                  blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                  alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
    }
}

extension UITextField {
    
    func setBorderColor(color:UIColor){
        self.layer.borderColor = color.cgColor
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension String {
    func toBool() -> Bool{
        if self == "false" {
            return false
        }else{
            return true
        }
    }
}

extension AddAccountViewController {
    func setupUI() {
        errorLabel.isHidden = true
        usernameTextField.layer.cornerRadius = AppConstants.commonCornerCurve
        usernameTextField.setLeftPaddingPoints(10)
        usernameTextField.setRightPaddingPoints(10)
        errorLabel.textColor = AppColorConstants.error
        usernameTextField.delegate = self
        usernameTextField.becomeFirstResponder()
        createButton.layer.cornerRadius = 25
        createButton.applyCommonDropShadow(radius: 10, opacity: 0.5)
        createButton.layer.shadowColor = UIColor.systemPurple.cgColor
        topCornerView.layer.cornerRadius = 75
        topCornerView.applyCommonDropShadow(radius: 5, opacity: 0.5)
        topCornerView.layer.shadowColor = UIColor.systemOrange.cgColor
        bottomCornerView.layer.cornerRadius = 60
        bottomCornerView.applyCommonDropShadow(radius: 5, opacity: 0.5)
        bottomCornerView.layer.shadowColor = UIColor.systemBlue.cgColor
        view.sendSubviewToBack(bottomCornerView)
        thirdView.layer.cornerRadius = 20
        thirdView.applyCommonDropShadow(radius: 5, opacity: 0.5)
        thirdView.layer.shadowColor = UIColor.systemGreen.cgColor
        view.bringSubviewToFront(thirdView)
        fourthView.layer.cornerRadius = 75
        fourthView.applyCommonDropShadow(radius: 5, opacity: 0.5)
        fourthView.layer.shadowColor = UIColor.systemYellow.cgColor
        fifthView.layer.cornerRadius = 45
        fifthView.applyCommonDropShadow(radius: 5, opacity: 0.5)
        fifthView.layer.shadowColor = UIColor.systemIndigo.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
