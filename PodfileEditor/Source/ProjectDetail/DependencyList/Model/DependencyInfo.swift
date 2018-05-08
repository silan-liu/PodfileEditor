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

enum GitType: String {
    case branch
    case commit
    case tag
}

enum SourceType: Int {
    case Version
    case Git
    case Path
    case Podspec
}

enum Configauration: Int {
    case None
    case Debug
    case Release
}

struct DependencyInfo: Equatable {
    var name: String
    
    var type: SourceType = SourceType.Version

    // 版本号
    var version: String?
    
    // 版本号限制
    var versionRequirement: VersionRequirement?
    
    // 指向git时，可能出现的选项
    var gitUrl: String?
    
    // gitType
    var gitType: GitType?
    
    // branch/commit/tag
    var gitDescription: String?

    // 指向本地路径
    var path: String?
    
    // 指向podspc
    var podspec: String?
    
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
    
    init(name: String) {
        self.name = name
    }
    
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
    
    init(name: String, podspec: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.podspec = podspec
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Podspec
    }
    
    init(name: String, gitUrl: String, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.gitUrl = gitUrl
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Git
    }
    
    init(name: String, gitUrl: String, gitType:GitType, gitDescription: String? = nil, config: String? = nil, subspecs: [String]? = nil) {
        self.name = name
        self.gitUrl = gitUrl
        self.gitType = gitType
        self.gitDescription = gitDescription
        self.config = config
        self.subspecs = subspecs
        self.type = SourceType.Git
    }
    
    
    /// 转换成pod书写格式, pod 'xx', '0.0.1'
    ///
    /// - Returns: string
    func toString() -> String {
        
        if !name.isEmpty {
            var string = "pod "
            
            string = string + "'\(name)'"
            
            if type == .Version {
                if let ver = version, !ver.isEmpty {
                    if let requirement = versionRequirement {
                        // 转换成字符串
                        let requirementDesc = requirement.description()
                        if requirementDesc.isEmpty {
                            string = string + ", '\(ver)'"
                        } else {
                            string = string + ", '\(requirement.description()) \(ver)'"
                        }
                    } else {
                        string = string + ", '\(ver)'"
                    }
                }
            } else if type == .Git {
                if let url = gitUrl {
                    string = string + ", :git => '\(url)'"
                    
                    if let gitDescription = gitDescription, let gitType = gitType, !gitDescription.isEmpty {
                        string = string + ", :\(gitType.rawValue) => '\(gitDescription)'"
                    }
                }
            
            } else if type == .Path {
                if let path = path {
                    string = string + ", :path => '\(path)'"
                }
            } else if type == .Podspec {
                if let podspec = podspec {
                    string = string + ", :podspec => '\(podspec)'"
                }
            }
            
            if let config = config, config != "None" {
                string = string + ", :configuration => '\(config)'"
            }
            
            if let subspecs = subspecs {
                let subspecString = PodfileUtils.subspecsToStringWithBracket(subspecs: subspecs)
                string =  string + ", :subspecs => \(subspecString)"
            }
            
            return string
        }
        
        return ""
    }
    
    static func ==(lhs: DependencyInfo, rhs: DependencyInfo) -> Bool {
        
        if lhs.name != rhs.name {
            return false
        }
        
        if lhs.type != rhs.type {
            return false
        }
        
        if lhs.version != rhs.version {
            return false
        }
        
        if lhs.versionRequirement != rhs.versionRequirement {
            return false
        }
        
        if lhs.gitUrl != rhs.gitUrl {
            return false
        }
        
        if lhs.gitType != rhs.gitType {
            return false
        }
        
        if lhs.gitDescription != rhs.gitDescription {
            return false
        }
        
        if lhs.path != rhs.path {
            return false
        }
        
        if lhs.podspec != rhs.podspec {
            return false
        }
        
        if lhs.config != rhs.config {
            return false
        }
        
        if (lhs.subspecs != nil && rhs.subspecs == nil) || (lhs.subspecs == nil && rhs.subspecs != nil) {
            return false
        }
        
        if let lSubspecs = lhs.subspecs, let rSubspecs = rhs.subspecs, PodfileUtils.subspecsToString(subspecs: lSubspecs) != PodfileUtils.subspecsToString(subspecs: rSubspecs) {
            return false
        }
        
        return true
    }
    
    func versionInfo() -> String? {
        switch type {
        case SourceType.Version:
            if let versionRequirement = self.versionRequirement, let version = self.version {
                return versionRequirement.description() + " " + version
            }
            
            return nil
        case SourceType.Path:
            if let path = self.path {
                return ":path => " + path
            }
            
            return nil
            
        case SourceType.Podspec:
            
            if let podspec = self.podspec {
                return ":podspec => " + podspec
            }
            
            return nil
            
        case SourceType.Git:
            if let git = self.gitUrl {
                var value = ":git => " + git
                if let gitDescription = self.gitDescription, let gitType = self.gitType?.rawValue {
                    value = value + "\n\n\(gitType) => " + gitDescription
                }
                
                return value
            }
            
            return nil
        }
    }
}
