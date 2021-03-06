//
//  EditProjectViewController.swift
//  PodfileEditor
//
//  Created by silan on 2018/4/4.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class EditProjectViewController: AddProjectViewController {

    // 编辑时需要
    var projectInfo: ProjectInfo
    
    init(projectInfo: ProjectInfo) {
        self.projectInfo = projectInfo

        super.init(nibName: NSNib.Name("AddProjectViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        self.projectNameTextField.stringValue = projectInfo.projectName
        self.pathTextField.stringValue = projectInfo.projectPath
    }
    
    override func beforeDismissAction(name: String, path: String) {
        if name == projectInfo.projectName && path == projectInfo.projectPath {
            print("Project No Changes")
            return
        }
        
        super.beforeDismissAction(name: name, path: path)
    }
}
