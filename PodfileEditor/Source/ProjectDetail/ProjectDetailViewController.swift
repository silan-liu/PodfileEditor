//
//  ProjectDetailViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/3/29.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectDetailViewController: NSViewController {

    var projectInfo: ProjectInfo? {
        didSet {
            parsePodfile()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func parsePodfile() {
        if let projectInfo = projectInfo {
            print("projectInfo:\(projectInfo.projectPath)")
        }
    }
}
