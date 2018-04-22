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
        
        let info1 = ProjectInfo(projectPath: "/Users/liusilan/Documents/workspace/douyu/project/douyu-iOS", projectName: "douyu")
        let info2 = ProjectInfo(projectPath: "/Users/liusilan/Documents/workspace/douyu/project/DYLiveRoomComponent/Example", projectName: "DYLiveRoomComponent")
        let info3 = ProjectInfo(projectPath: "/Users/liusilan/Documents/workspace/yy/ios-trunk", projectName: "YY")

        projectList?.append(info1)
        projectList?.append(info2)
        projectList?.append(info3)

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
    
    func editProject(at row: Int, projectName: String, projectPath: String) {
        let info = ProjectInfo(projectPath: projectPath, projectName: projectName)
        let rowCount = numberOfRows()
        if (row >= 0 && row < rowCount) {
            projectList?[row] = info;
        }
    }
}
