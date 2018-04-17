//
//  ProjectDetailInfo.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/17.
//  Copyright © 2018年 summer. All rights reserved.
//

import Foundation

struct ProjectDetailInfo {
    var projectInfo: ProjectInfo
    
    // podfile中写明的依赖
    var dependencyList: [DependencyInfo]
    
    // podfile.lock中的依赖
    var allDenpencyList: [DependencyInfo]
}
