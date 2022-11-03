//
//  AppEntity.swift
//  OnTrack
//
//  Created by Arjun Mohan on 09/10/22.
//

import UIKit

class AppEntity: NSObject {

    // Task Management
    public static var taskManagement = ["user_id": "", "task_id": "", "task_title": "", "is_completed": "false", "is_priority": "false", "task_detail": "", "initial_bg_color": ""] as [String : Any]
    
    //Account Management
    public static var accountManagement = ["user_name": "", "user_id": "", "avatar_image_data": "", "is_logged": "false"] as [String:Any]
}
