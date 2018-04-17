//
//  ProjectDetailDataController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/16.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectDetailDataController: NSObject {
    
    var projectInfo: ProjectInfo?
    
    // podfile中写明的依赖
    var dependencyList: [DependencyInfo]?
    
    // podfile.lock中的依赖
    var allDenpencyList: [DependencyInfo]?
    
    init(projectInfo: ProjectInfo?) {
        super.init()
        self.projectInfo = projectInfo
        
        var dependencyList = [DependencyInfo]()
        
        let dep1 = DependencyInfo(name: "lib1", git: "http://gitlbab.lib1", branch: "master")
        let dep2 = DependencyInfo(name: "lib2", git: "http://gitlbab.lib2")
        let dep3 = DependencyInfo(name: "lib3", git: "http://gitlbab.lib2", tag: "0.0.1")
        let dep4 = DependencyInfo(name: "lib4", version: "9.0.2")
        
        dependencyList.append(dep1)
        dependencyList.append(dep2)
        dependencyList.append(dep3)
        dependencyList.append(dep4)
        
        self.dependencyList = dependencyList
    }
    
    func addDependency(dep: DependencyInfo) {
        dependencyList?.append(dep)
    }
    
    func deleteDependency(at row: Int) {

        if (row >= 0 && row < numberOfRows()) {
            dependencyList?.remove(at: row)
        }
    }
    
    func numberOfRows() -> Int {
        if let list = self.dependencyList {
            return list.count
        }
        
        return 0
    }
    
    func dependencyInfo(at row: Int) -> DependencyInfo? {
        if let list = self.dependencyList {
            if (row >= 0 && row < list.count) {
                return list[row]
            }
        }
        
        return nil
    }
}
