//
//  DependencyInfo.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/17.
//  Copyright © 2018年 summer. All rights reserved.
//

import Foundation

enum VersionRequirement {
    
    // "~>"
    case Compatible
    
    // "=="
    case Equal
    
    // ">"
    case GreaterThan
    
    // ">="
    case GreaterThanOrEqual
    
    // "<"
    case LessThan
    
    // "<="
    case LessThanOrEqual
    
    func description() -> String {
        switch self {
        case .Compatible:
            return "~>"
            
        case .Equal:
            return ""
            
        case .GreaterThan:
            return ">"
            
        case .GreaterThanOrEqual:
            return ">="
            
        case .LessThan:
            return "<"
            
        case .LessThanOrEqual:
            return "<="
        }
    }
}

enum GitPointType {
    case Branch
    case Commit
    case Tag
}

struct DependencyInfo {
    var name: String
    
    // 版本号
    var version: String?
    
    // 版本号限制
    var versionRequirement: VersionRequirement?

    // 指向git时，可能出现的选项
    var git: String?
    
    var branch: String?
    var commit: String?
    var tag: String?

    // 指向本地路径
    var path: String?
    
    // configuration
    var config: String?
    
    var subspecs:[String]?
    
    init(name: String, version: String, versionRequirement: VersionRequirement = VersionRequirement.Equal, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.version = version
        self.versionRequirement = versionRequirement
        self.config = config
        self.subspecs = subspecs
    }
    
    init(name: String, path: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.path = path
        self.config = config
        self.subspecs = subspecs
    }
    
    init(name: String, git: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.config = config
        self.subspecs = subspecs
    }
    
    init(name: String, git: String, branch: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.branch = branch
        self.config = config
        self.subspecs = subspecs
    }
    
    init(name: String, git: String, commit: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.commit = commit
        self.config = config
        self.subspecs = subspecs
    }
    
    init(name: String, git: String, tag: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.tag = tag
        self.config = config
        self.subspecs = subspecs
    }
}
