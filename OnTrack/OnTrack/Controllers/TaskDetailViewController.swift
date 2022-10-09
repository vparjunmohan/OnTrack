//
//  TaskDetailViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 29/05/22.
//

import UIKit

protocol UpdateTaskDetailDelegate {
    func updateCurrentDetail(currentUserId: String)
}

class TaskDetailViewController: UIViewController {
    
    
    @IBOutlet weak var titleHeader: UILabel!
    @IBOutlet weak var taskDetailTextView: UITextView!
    @IBOutlet weak var clearButton: UIButton!
    
    var selectedTask: [String:Any]!
    var updateTaskDetailDelegate: UpdateTaskDetailDelegate!
    var taskDetails: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    @IBAction func clearCurrentDetail(_ sender: UIButton) {
        taskDetailTextView.text = ""
        selectedTask.updateValue(taskDetailTextView.text!, forKey: "task_detail")
        DbOperations().updateTable(valuesToChange: selectedTask, whereKey: "task_id", whereValue: selectedTask["task_id"] as! String, tableName: AppConstants.taskTable)
    }

    @IBAction func backToDashboard(_ sender: UIButton) {
        selectedTask.updateValue(taskDetailTextView.text!, forKey: "task_detail")
        DbOperations().updateTable(valuesToChange: selectedTask, whereKey: "task_id", whereValue: selectedTask["task_id"] as! String, tableName: AppConstants.taskTable)
        if updateTaskDetailDelegate != nil {
            updateTaskDetailDelegate?.updateCurrentDetail(currentUserId: selectedTask["user_id"] as! String)
        }
        if let parent = self.parent {
            if parent is DashboardViewController {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        }
    }
    
    @objc func showDismissKeyboard(_ sender: UITapGestureRecognizer) {
        if taskDetailTextView.isFirstResponder {
            taskDetailTextView.resignFirstResponder()
        } else {
            taskDetailTextView.becomeFirstResponder()
        }
    }
}

extension TaskDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        selectedTask.updateValue(newText, forKey: "task_detail")
        return true
    }
}

extension TaskDetailViewController {
    func setupUI() {
        clearButton.layer.cornerRadius = 5
        clearButton.clipsToBounds = true
        clearButton.layer.borderColor = UIColor.systemRed.cgColor
        clearButton.layer.borderWidth = 1
        let tap = UITapGestureRecognizer(target: self, action: #selector(showDismissKeyboard(_:)))
        taskDetailTextView.addGestureRecognizer(tap)
        
        taskDetailTextView.text = selectedTask["task_detail"] as? String
        titleHeader.text = selectedTask["task_title"] as? String
        taskDetailTextView.delegate = self
    }
}
