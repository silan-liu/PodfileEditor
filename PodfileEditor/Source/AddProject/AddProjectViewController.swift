//
//  AddProjectViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/3/29.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class AddProjectViewController: NSViewController {
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var pathTextField: NSTextField!
    @IBOutlet weak var projectNameTextField: NSTextField!
    
    typealias CompletionBlock = (String, String) -> (Void)
    public var chooseCompletion: CompletionBlock?
    
    private let openPanel: NSOpenPanel = {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        return openPanel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    // MARK: action
    @IBAction func cancleAction(_ sender: Any) {
        self.dismiss(nil)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        
        if self.checkInput() {
            self.dismiss(nil)
            
            if let chooseCompletion = chooseCompletion {
                chooseCompletion(projectNameTextField.stringValue, pathTextField.stringValue)
            }
        }
    }

    @IBAction func choosePodFilePath(_ sender: Any) {
        if (self.openPanel.runModal() == .OK) {
            
            if let url = self.openPanel.url {
                projectNameTextField.stringValue = url.lastPathComponent
                errorLabel.stringValue = self.checkPath(path: url.path).1
                
                pathTextField.stringValue = url.path
            }
        }
    }
    
    // MARK:func
    func checkInput() -> Bool {
        if projectNameTextField.stringValue.isEmpty {
            errorLabel.stringValue = "Please input project name"
            return false
        }
        
        let result = checkPath(path: pathTextField.stringValue)
        
        return result.0
    }
    
    func checkPath(path: String) -> (Bool, String) {
        if path.isEmpty {
            return (false, "Path is empty")
        }
        
        let podfilePath = path.appending("/Podfile")
        let fileManager = FileManager.default
        let result = fileManager.fileExists(atPath: podfilePath)
        
        let msg = result ? "" : "Path doesn't include Podfile."
        return (result, msg)
    }
}
