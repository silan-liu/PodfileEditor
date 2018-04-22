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
    
    lazy var podfileAnalyser: PodfileAnalyser? = {
        
        if let path = projectInfo?.projectPath {
            let podfilePath = path + "/Podfile"
        
            let analyser = PodfileAnalyser(path: podfilePath)
            
            return analyser
        }
        
        return nil
    }()
    
    init(projectInfo: ProjectInfo?) {
        super.init()
        self.projectInfo = projectInfo
    }
    
    func addDependency(dep: DependencyInfo) {
        dependencyList?.append(dep)
    }
    
    func deleteDependency(at row: Int) {

        if (row >= 0 && row < numberOfRows()) {
            dependencyList?.remove(at: row)
            podfileAnalyser?.deleteDependency(at: row)
        }
    }
    
    func editDependency(at row: Int, dep: DependencyInfo) {
        if (row >= 0 && row < numberOfRows()) {
            dependencyList?[row] = dep
            
            podfileAnalyser?.editDependency(at: row, dep: dep)
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
    
    func analyze(completion: (() -> Void)?) {
        podfileAnalyser?.analyze(completion: { dependencyList in
            
            self.dependencyList = dependencyList
            
            if let completion = completion {
                completion()
            }
        })
    }
}
