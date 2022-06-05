//
//  TaskDetailViewController.swift
//  OnTrack
//
//  Created by Arjun Mohan on 29/05/22.
//

import UIKit

protocol UpdateTaskDetail {
    func updateCurrentDetail(taskDetail: [String:Any])
}

class TaskDetailViewController: UIViewController {
    
    
    @IBOutlet weak var titleHeader: UILabel!
    @IBOutlet weak var taskDetailTextView: UITextView!
    @IBOutlet weak var clearButton: UIButton!
    
    var selectedTask: [String:Any]!
    var updateTaskDetailDelegate: UpdateTaskDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleHeader.text = selectedTask["task_title"] as? String
        taskDetailTextView.text = selectedTask["task_detail"] as? String
        taskDetailTextView.delegate = self
        taskDetailTextView.becomeFirstResponder()
    }
    
    
    @IBAction func clearCurrentDetail(_ sender: UIButton) {
        taskDetailTextView.text = ""
        selectedTask.updateValue("", forKey: "task_detail")
    }
    

    @IBAction func backToDashboard(_ sender: UIButton) {
        if updateTaskDetailDelegate != nil {
            updateTaskDetailDelegate?.updateCurrentDetail(taskDetail: selectedTask)
        }
        self.view.removeFromSuperview()
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
    }
}
