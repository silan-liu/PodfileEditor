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
        
        let dep1 = DependencyInfo(name: "lib1", git: "http://gitlbab.lib1", gitDescription: "master")
        let dep2 = DependencyInfo(name: "lib2", git: "http://gitlbab.lib2")
        let dep3 = DependencyInfo(name: "lib3", git: "http://gitlbab.lib2", gitDescription: "0.0.1")
        let dep4 = DependencyInfo(name: "lib4", version: "9.0.2")
        let dep5 = DependencyInfo(name: "lib5", git: "http://gitlab.lib5", gitDescription: "dev", config: "debug", subspecs: ["subspec"])
        
        dependencyList.append(dep1)
        dependencyList.append(dep2)
        dependencyList.append(dep3)
        dependencyList.append(dep4)
        dependencyList.append(dep5)

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
    
    func editDependency(at row: Int, dep: DependencyInfo) {
        if (row >= 0 && row < numberOfRows()) {
            dependencyList?[row] = dep
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
