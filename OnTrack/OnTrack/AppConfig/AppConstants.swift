//
//  AppConstants.swift
//  OnTrack
//
//  Created by Arjun Mohan on 28/05/22.
//

import UIKit

class AppConstants: NSObject {

    // Homescreem collectionview constants
    public static let totalTaskLabelText : String = "Total Tasks"
    public static let completedTaskLabelText : String = "Completed Tasks"
    public static let priorityTaskLabelText : String = "Priority Tasks"
    
    // Database tables
    public static let userTable : String = "UserTable"
    public static let taskTable : String = "TaskTable"
    
    // Error messages
    public static let usernameEmpty : String = "Username cannot be empty"
    public static let usernameExists : String = "Username already exists"
    public static let exceedCharacters : String = "Username can only have 12 characters"
    
    // Common corner curve
    public static let commonCornerCurve: CGFloat = 5.0
}
