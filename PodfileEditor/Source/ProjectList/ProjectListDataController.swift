//
//  ProjectListDataController.swift
//  PodfileEditor
//
//  Created by silan on 2018/4/4.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectListDataController: NSObject {
    private var projectList: [ProjectInfo]?
    
    override init() {
        super.init()
        
        // test
        projectList = [ProjectInfo]()
        
        let info1 = ProjectInfo(projectPath: "~/Documents/test1", projectName: "test1")
        let info2 = ProjectInfo(projectPath: "~/Documents/test2", projectName: "test2")
        
        projectList?.append(info1)
        projectList?.append(info2)
    }
    
    func numberOfRows() -> Int {
        if let projectList = projectList {
            return projectList.count
        }
        
        return 0
    }
    
    func projectInfoAtRow(row: Int) -> ProjectInfo? {
        let rowCount = numberOfRows()
        if (row >= 0 && row < rowCount) {
            return projectList?[row]
        }
        
        return nil
    }
    
    func addProject(projectName: String, projectPath: String) {
        let info = ProjectInfo(projectPath: projectPath, projectName: projectName)
        projectList?.append(info)
    }
    
    func deleteProject(at row: Int) {
        let rowCount = numberOfRows()
        if (row >= 0 && row < rowCount) {
            projectList?.remove(at: row)
        }
    }
}
