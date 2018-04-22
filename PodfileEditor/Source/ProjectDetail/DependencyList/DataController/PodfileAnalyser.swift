//
//  PodfileAnalyser.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/18.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class PodfileAnalyser {
    var podfilePath: String
    private lazy var targetMap = [Int: String]()
    // [target:["index": "dependecny"]]
    private lazy var dependencyList = [String: [Int: DependencyInfo]]()

    init(path: String) {
        podfilePath = path
    }

    func analyze() {
        print("begin analyze")
        
        do {
            let content = try String(contentsOf: URL(fileURLWithPath: podfilePath))
            
            let lines = content.components(separatedBy: .newlines)
            
            // 记录行数index
            var index = 0
            
            for line in lines {
                
                index = index + 1
                
                // 过滤空行，注释行
                let trimmed = line.replacingOccurrences(of: " ", with: "")
                
                if trimmed.isEmpty || trimmed.hasPrefix("#") {
                    continue
                }
                
                // 匹配name，支持'xx', "xx"
                if let podName = regexMatch(pattern: "\\s*pod\\s*['\"](.*?)['\"]", matchString: line) {
                    print("libname: \(podName)")
                    
                    var info = DependencyInfo(name: podName)
                    
                    // 取版本号，以,分隔
                    let list = trimmed.components(separatedBy: ",")
                    if list.count > 1 {
                        // 取第二个元素
                        var versionString = list[1]
                        
                        if versionString.hasPrefix("'") || versionString.hasPrefix("\"") {
                            
                            versionString = trimQuotation(string: versionString)

                            let tmp = extractVersion(versionDesc: versionString)
                            print("versionRequirement:\(tmp.0), version: \(tmp.1)")

                            info.versionRequirement = tmp.0
                            info.version = tmp.1
                            info.type = .Version
                            
                        } else if let url = regexMatch(pattern: ":git\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                            // 匹配git
                            print("url:\(url)")
                            
                            info.git = url
                            info.type = .Git
                            
                            // 匹配branch
                            if let branch = regexMatch(pattern: ":branch\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                                print("branch:\(branch)")
                                
                                info.gitDescription = branch
                            }
                            // 匹配commit
                            else if let commit = regexMatch(pattern: ":commit\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                                print("commit:\(commit)")
                                
                                info.gitDescription = commit
                            }
                            // tag
                            else if let tag = regexMatch(pattern: ":tag\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                                print("commit:\(tag)")
                                
                                info.gitDescription = tag
                            }
                            
                        } else if let path = regexMatch(pattern: ":path\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                            // 匹配path
                            print("path:\(path)")
                            
                            info.path = path
                            info.type = .Path
                            
                        } else if let podspec = regexMatch(pattern: ":podspec\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                            // 匹配podspec
                            print("podspec:\(podspec)")
                            
                            info.podspec = podspec
                            info.type = .Podspec
                        }
                    }
                    
                    // 匹配configuration
                    // :configuration => 'Debug'
                    if let result = regexMatch(pattern: ":configuration\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                        print("configuration:\(result)")
                        
                        info.config = result
                    }
                    // :configurations => ['Debug']
                    else if let result = regexMatch(pattern: ":configurations\\s*=>\\s*\\[(.*)\\]", matchString: line) {
                        let configurations = parseSubspecs(subspecs: result)
                        
                        // 目前只支持一种config
                        if configurations.count > 1 {
                            info.config = configurations[0]
                        }
                        print("configurations:\(configurations)")
                    }
                    
                    // 匹配subspecs
                    if let result = regexMatch(pattern: ":subspecs\\s*=>\\s*\\[(.*)\\]", matchString: line) {
                        
                        let subspecs = parseSubspecs(subspecs: result)
                        
                        print("subspecs:\(subspecs)")
                        info.subspecs = subspecs
                    }
                    
                    let target = findTarget(index: index)
                    print("find target: \(target)")
                    
                    if (!target.isEmpty) {
                        if var map = dependencyList[target] {
                            map[index] = info
                            dependencyList[target] = map
                        } else {
                            dependencyList[target] = [index: info]
                        }
                    }
                    
                    print("=============\(info)")
                } else if let result = regexMatch(pattern: "\\s*target\\s*['\"]([\\w\\d]+)['\"]", matchString: line) {
                    print("target: \(result)")
                    
                    targetMap[index] = result
                }
            }
            
            for (key, value) in dependencyList {
                print("target:\(key), count: \(value.count), dependencyList:\(value)")
            }
            
            print("target count:\(targetMap.count)")
            
            for (key, value) in targetMap {
                print("line:\(key), target:\(value)")
            }
            
        } catch let error as NSError {
            print("error:\(error)")
        }
    }
    
    // 正则匹配
    func regexMatch(pattern: String, matchString: String) -> String? {
        do {
            let versionRegularExp = try NSRegularExpression(pattern: pattern, options: [])
            if let match = versionRegularExp.firstMatch(in: matchString, options: [], range: NSRange(location: 0, length: matchString.count)) {
                // 0表示匹配到的整个部分，之后才是分组
                if match.numberOfRanges > 1 {
                    let range = match.range(at: 1)
                    let result = (matchString as NSString).substring(with: range)
                    return result
                }
            }
        } catch let error as NSError {
            print("regexMatch error: \(error)")
        }
        
        return nil
    }
    
    // 去除引号, '/"
    func trimQuotation(string: String) -> String {
        var result = string.replacingOccurrences(of: "'", with: "")
        result = result.replacingOccurrences(of: "\"", with: "")
        return result
    }
    
    // 将字符串"'A','B'"转换成数组[A,B]
    func parseSubspecs(subspecs: String) -> [String] {
        var trimmed = trimQuotation(string: subspecs)
        trimmed = trimmed.replacingOccurrences(of: " ", with: "")
        
        // 以,分隔
        var result = [String]()
        let list = trimmed.components(separatedBy: ",")
    
        for subspec in list {
            if !subspecs.isEmpty {
                result.append(subspec)
            }
        }
        
        return result
    }
    
    // 根据pod所在行数找到对应的target，选择最近的target
    func findTarget(index: Int) -> String {
        var result = SSIZE_MAX
        var rightTarget = ""
        
        for (line, target) in targetMap {
            if (index > line && (index - line) < result) {
                result = index - line
                
                rightTarget = target
            }
        }
        
        return rightTarget
    }
    
    
    /// 将version转换成版本(限制符, 版本号)形式，如将"~> 1.0.1" -> (.Compatible, 1.0.1)
    ///
    /// - Parameter version: 完整版本号描述
    /// - Returns: (限制符, 版本号)
    func extractVersion(versionDesc: String) -> (VersionRequirement, String) {
        let trimmed = versionDesc.replacingOccurrences(of: " ", with: "")
        var versionRequirementString = "=="
        var versionRequirement = VersionRequirement.Equal
        
        if trimmed.hasPrefix("~>") {
            versionRequirementString = "~>"
            versionRequirement = VersionRequirement.Compatible
            
        } else if trimmed.hasPrefix(">") {
            versionRequirementString = ">"
            versionRequirement = VersionRequirement.GreaterThan
            
        } else if trimmed.hasPrefix(">=") {
            versionRequirementString = ">="
            versionRequirement = VersionRequirement.GreaterThanOrEqual
            
        } else if trimmed.hasPrefix("<") {
            versionRequirementString = "<"
            versionRequirement = VersionRequirement.LessThan
            
        } else if trimmed.hasPrefix("<=") {
            versionRequirementString = "<="
            versionRequirement = VersionRequirement.LessThanOrEqual
        }
        
        let verison = trimmed.replacingOccurrences(of: versionRequirementString, with: "")
        return (versionRequirement, verison)
    }
}
