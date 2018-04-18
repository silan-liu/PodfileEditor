//
//  DependencyInfo.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/17.
//  Copyright © 2018年 summer. All rights reserved.
//

import Foundation

enum VersionRequirement: Int {
    
    // "=="
    case Equal = 0
    
    // "~>"
    case Compatible
    
    // ">="
    case GreaterThanOrEqual
    
    // ">"
    case GreaterThan
    
    // "<="
    case LessThanOrEqual
    
    // "<"
    case LessThan
    
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

enum SourceType: Int {
    case Version
    case Git
    case Path
}

enum GitPointType {
    case None
    case Branch
    case Commit
    case Tag
}

enum Configauration: Int {
    case None
    case Debug
    case Release
}

struct DependencyInfo {
    var name: String
    
    var type: SourceType = SourceType.Version

    // 版本号
    var version: String?
    
    // 版本号限制
    var versionRequirement: VersionRequirement?
    
    // 指向git时，可能出现的选项
    var git: String?
    var gitType: GitPointType = .None
    
    // branch/commit/tag
    var gitDescription: String?
    
    var branch: String?
    var commit: String?
    var tag: String?

    // 指向本地路径
    var path: String?
    
    // configuration
    var config: String?
    
    var configIndex: Configauration  {
        if config == "" || config == "None" {
            return .None
        } else if config == "Debug" || config == "debug" {
            return .Debug
        } else if config == "Relase" || config == "release" {
            return .Release
        }
        
        return .None
    }
    
    var subspecs:[String]?
    
    init(name: String, version: String, versionRequirement: VersionRequirement = VersionRequirement.Equal, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.version = version
        self.versionRequirement = versionRequirement
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Version
    }
    
    init(name: String, path: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.path = path
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Path
    }
    
    init(name: String, git: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.git = git
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Git
    }
    
    init(name: String, git: String, branch: String? = nil, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.git = git
        self.branch = branch
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Git
    }
    
    init(name: String, git: String, commit: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.git = git
        self.commit = commit
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Git
    }
    
    init(name: String, git: String, tag: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.git = git
        self.tag = tag
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Git
    }
    
    init(name: String, git: String, gitDescription: String? = nil, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.git = git
        self.gitDescription = gitDescription
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Git
    }
}
