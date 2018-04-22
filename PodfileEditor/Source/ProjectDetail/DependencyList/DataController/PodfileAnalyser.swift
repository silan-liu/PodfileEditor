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
    
    // 行数->依赖信息
    private lazy var dependencyList = [Int: DependencyInfo]()
    
    enum DefFunctionIndex: String {
        case Start
        case End
    }
    
    // 函数名 -> 定义的依赖string
    private lazy var defContent = [String: String]()
    
    init(path: String) {
        podfilePath = path
    }

    func analyze() {
        print("begin analyze")
        
        do {
            let content = try String(contentsOf: URL(fileURLWithPath: podfilePath))
            
            if content.isEmpty {
                return
            }
            
            // 首先找出def function
            findFunction(string: content)
            
            // 以行分隔
            let lines = content.components(separatedBy: .newlines)
            
            // 记录行数index
            var index = -1
            
            // 定义的function的行数信息
            var defIndexInfo = [String: [DefFunctionIndex: Int]]()
            
            for line in lines {
                
                index = index + 1

                // 判断该行是否应该解析
                if !lineShouldParse(index: index, defIndexInfo: defIndexInfo) {
                    continue
                }
                
                if let result = regexMatchGroup(pattern: "\\s*target\\s*['\"]([\\w]+)['\"]", matchString: line) {
                    print("target: \(result)")
                    
                    targetMap[index] = result
                }
                // 匹配到def，记录开始，结束行数
                else if let result = regexMatchGroup(pattern: "\\s*def\\s*(\\w+)", matchString: line) {
                    
                    if let body = defContent[result] {
                        
                        let bodyLines = body.components(separatedBy: .newlines)

                        // 用newline分隔，最后一个元素是""，需去除(-1)，但因要加上end这一行(+1)，刚好抵消
                        defIndexInfo[result] = [.Start: index, .End: (index + bodyLines.count)]
                    }
                }
                // 判断该行是否是函数调用,test()
                else if let result = regexMatchGroup(pattern: "\\s*(.*?)\\s*\\(\\)", matchString: line) {
                    
                    if isCallFunction(functionName: result) {
                        print("call function: \(result)")
                        
                        if let functionIndexInfo = defIndexInfo[result] {
                            // 解析出function定义的pod
                            extractFunctionDependency(functionName: result, beginIndex: functionIndexInfo[.Start]!)
                        }
                    }
                }
            }
            
            print("dependencyList count: \(dependencyList.count)")
            
            for (key, value) in dependencyList {
                print("line:\(key), info:\(value)")
            }
            
            print("defIndexInfo:\(defIndexInfo)")
            
        } catch let error as NSError {
            print("error:\(error)")
        }
    }
    
    
    /// 该行是否应该解析pod信息
    ///
    /// - Parameters:
    ///   - index: 行数
    ///   - defIndexInfo: def函数开始结束行index
    /// - Returns: true/false
    func lineShouldParse(index: Int, defIndexInfo: [String: [DefFunctionIndex: Int]]) -> Bool {
        for (_, value) in defIndexInfo {
            // 在def -- end之间，不进行解析，若之后有调用函数，才解。
            if let startIndex = value[.Start], let endIndex = value[.End] {
                if index > startIndex && index < endIndex {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// 进行正则匹配，返回group 1
    func regexMatchGroup(pattern: String, matchString: String) -> String? {
        return regexMatch(pattern: pattern, matchString: matchString, index: 1)
    }
    
    
    /// 正则匹配，返回全部匹配的字符串
    func regexMatchFull(pattern: String, matchString: String) -> String? {
        return regexMatch(pattern: pattern, matchString: matchString, index: 0)
    }
    
    
    /// 正则匹配
    ///
    /// - Parameters:
    ///   - pattern: 正则表达式
    ///   - matchString: 待匹配字符串
    ///   - index: 匹配的index
    /// - Returns: 匹配字符串
    func regexMatch(pattern: String, matchString: String, index: Int) -> String? {
        do {
            let regularExp = try NSRegularExpression(pattern: pattern, options: [])
            
            if let match = regularExp.firstMatch(in: matchString, options: [], range: NSRange(location: 0, length: matchString.count)) {
                // 0表示匹配到的整个部分
                if match.numberOfRanges > index {
                    let range = match.range(at: index)
                    let result = (matchString as NSString).substring(with: range)
                    return result
                }
            }
        } catch let error as NSError {
            print("regexMatch error: \(error)")
        }
        
        return nil
    }
    
    
    /// 找到podFile中定义的方法
    ///
    /// - Parameter string
    func findFunction(string: String) {
        do {
            // 设置.可匹配换行
            let regularExp = try NSRegularExpression(pattern: "\\s*def\\s*(\\w+)\\(\\)\\s*(.*?)end", options:.dotMatchesLineSeparators)
            let matches = regularExp.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            for match in matches {
                // 0表示匹配到的整个部分，之后才是分组
                if match.numberOfRanges > 2  {
                    var range = match.range(at: 1)
                    let functionName = (string as NSString).substring(with: range)
                    
                    range = match.range(at: 2)
                    let functionBody = (string as NSString).substring(with: range)
                    
                    defContent[functionName] = functionBody
                    
                    print("functionName: \(functionName), functionBody:\(functionBody)")
                }
            }
        } catch let error as NSError {
            print("regexMatch error: \(error)")
        }
    }
    
    
    /// 是否在调用函数
    ///
    /// - Parameter functionName: 函数名
    /// - Returns: true/false
    func isCallFunction(functionName: String) -> Bool {
        if let _ = defContent.index(forKey: functionName) {
            return true
        }
        
        return false
    }
    
    
    /// 解析function中定义的依赖项
    ///
    /// - Parameters:
    ///   - functionName: 方法名
    ///   - beginIndex: 方法所在行数
    func extractFunctionDependency(functionName: String, beginIndex: Int) {
        if let body = defContent[functionName] {
            
            // 以行分隔
            let lines = body.components(separatedBy: .newlines)
            var index = beginIndex + 1
            
            for line in lines {
                
                if let dependencyInfo = extractDependencyInfo(line: line) {
                    dependencyList[index] = dependencyInfo
                }
                
                index = index + 1
            }
        }
    }
    
    /// 将一行输入转换成DependencyInfo
    ///
    /// - Parameter line: 一行输入
    /// - Returns: 依赖结果
    func extractDependencyInfo(line: String) -> DependencyInfo? {
        // 过滤空行，注释行
        let trimmed = line.replacingOccurrences(of: " ", with: "")
        
        if trimmed.isEmpty || trimmed.hasPrefix("#") {
            return nil
        }
        
        // 匹配name，支持'xx', "xx/xx", "xx-xx"
        if let podName = regexMatchGroup(pattern: "\\s*pod\\s*['\"]([\\w/-]*?)['\"]", matchString: line) {
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
                    
                } else if let url = regexMatchGroup(pattern: ":git\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                    // 匹配git
                    print("url:\(url)")
                    
                    info.git = url
                    info.type = .Git
                    
                    // 匹配branch
                    if let branch = regexMatchGroup(pattern: ":branch\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                        print("branch:\(branch)")
                        
                        info.gitDescription = branch
                    }
                        // 匹配commit
                    else if let commit = regexMatchGroup(pattern: ":commit\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                        print("commit:\(commit)")
                        
                        info.gitDescription = commit
                    }
                        // tag
                    else if let tag = regexMatchGroup(pattern: ":tag\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                        print("commit:\(tag)")
                        
                        info.gitDescription = tag
                    }
                    
                } else if let path = regexMatchGroup(pattern: ":path\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                    // 匹配path
                    print("path:\(path)")
                    
                    info.path = path
                    info.type = .Path
                    
                } else if let podspec = regexMatchGroup(pattern: ":podspec\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                    // 匹配podspec
                    print("podspec:\(podspec)")
                    
                    info.podspec = podspec
                    info.type = .Podspec
                }
            }
            
            // 匹配configuration
            // :configuration => 'Debug'
            if let result = regexMatchGroup(pattern: ":configuration\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                print("configuration:\(result)")
                
                info.config = result
            }
                // :configurations => ['Debug']
            else if let result = regexMatchGroup(pattern: ":configurations\\s*=>\\s*\\[(.*)\\]", matchString: line) {
                let configurations = parseSubspecs(subspecs: result)
                
                // 目前只支持一种config
                if configurations.count > 1 {
                    info.config = configurations[0]
                }
                print("configurations:\(configurations)")
            }
            
            // 匹配subspecs
            if let result = regexMatchGroup(pattern: ":subspecs\\s*=>\\s*\\[(.*)\\]", matchString: line) {
                
                let subspecs = parseSubspecs(subspecs: result)
                
                print("subspecs:\(subspecs)")
                info.subspecs = subspecs
            }
            
            print("=============\(info)")

            return info
            
        } else if let result = regexMatchGroup(pattern: "\\s*target\\s*['\"]([\\w]+)['\"]", matchString: line) {
            print("target: \(result)")
        }
        
        return nil
    }
    
    //MARK:Helper
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
