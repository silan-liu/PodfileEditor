//
//  PodfileAnalyser.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/18.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class PodfileAnalyser {
    // podfile路径
    var podfilePath: String

    private var firstTargetLine: Int = -1
    
    // podfile content array
    private var contentArray = [String]()
    
    // 行数->依赖信息
    private lazy var dependencyMap = [Int: DependencyInfo]()
    
    // 行index，从小到大
    private var dependencyIndexList: [Int]  {
        let list = Array(dependencyMap.keys).sorted()
        return list
    }
    
    // index排序后，对应的dependencyList
    private var dependencyInfoList: [DependencyInfo] {
        var list = [DependencyInfo]()
        for dependencyIndex in dependencyIndexList {
            if let dependency = dependencyMap[dependencyIndex] {
                list.append(dependency)
            }
        }
        
        return list
    }
    
    // 方法起始位置定义
    private enum DefFunctionIndex: String {
        case Start
        case End
    }
    
    // 函数名 -> 定义的依赖string
    private lazy var defContent = [String: String]()
    
    init(path: String) {
        podfilePath = path
    }
    
    deinit {
        print("PodfileAnalyser deinit")
    }
    
    //MARK: Analyze
    func analyze(completion: (([DependencyInfo]) -> Void)?) {
        DispatchQueue.global().async {
            print("begin analyze")
            
            do {
                let content = try String(contentsOf: URL(fileURLWithPath: self.podfilePath))
                
                if content.isEmpty {
                    return
                }
                
                // 首先找出def function
                self.findFunction(string: content)
                
                // 以行分隔
                let lines = content.components(separatedBy: .newlines)
                
                self.contentArray = lines
                
                // 记录行数index
                var index = 0
                
                // 定义的function的行数信息
                var defIndexInfo = [String: [DefFunctionIndex: Int]]()
                
                for line in lines {
                    
                    // 判断该行是否应该解析
                    if !self.lineShouldParse(index: index, line: line, defIndexInfo: defIndexInfo) {
                        index += 1

                        continue
                    }
                    
                    // 解析依赖信息
                    if let info = self.extractDependencyInfo(line: line) {
                        self.dependencyMap[index] = info
                    }
                    
                    // 匹配到def，记录开始，结束行数
                    if let result = self.regexMatchGroup(pattern: "\\s*def\\s*(\\w+)(\\(\\))?", matchString: line) {
                        
                        if let body = self.defContent[result] {
                            
                            let bodyLines = body.components(separatedBy: .newlines)
                            
                            // 用\n分隔，第一个和最后一个元素都是""，需去除(-2)，但因要加上end这一行(+1)，整体-1
                            defIndexInfo[result] = [.Start: index, .End: (index + bodyLines.count - 1)]
                        }
                    }
                    // 判断是否target
                    else if let _ = self.regexMatchGroup(pattern: "\\s*target\\s*['\"]([\\w]+)['\"]", matchString: line) {
                        if self.firstTargetLine == -1 {
                            self.firstTargetLine = index
                            
                            print("firstTargetLine: \(self.firstTargetLine)")
                        }
                    }
                    // 判断该行是否是函数调用,test()
                    else if let result = self.regexMatchGroup(pattern: "\\s*(\\w+)\\s*\\(?\\)?", matchString: line) {
                        
                        if self.isCallFunction(functionName: result) {
                            print("call function: \(result)")
                            
                            if let functionIndexInfo = defIndexInfo[result] {
                                // 解析出function定义的pod
                                self.extractFunctionDependency(functionName: result, beginIndex: functionIndexInfo[.Start]!)
                            }
                        }
                    }
                    
                    index += 1
                }
                
                print("dependencyList count: \(self.dependencyMap.count)")
                
                for (key, value) in self.dependencyMap {
                    print("line:\(key), info:\(value)")
                }
                
                print("defIndexInfo:\(defIndexInfo)")
                
                if let completion = completion {
                    completion(self.dependencyInfoList)
                }
                
            } catch let error as NSError {
                print("error:\(error)")
            }
        }
    }
    
    // 重新分析
    func reAnalyze(completion: (([DependencyInfo]) -> Void)?) {
        dependencyMap.removeAll()
        contentArray.removeAll()
        
        analyze(completion: completion)
    }
    
    /// podFile中的依赖项
    func dependencyList() -> [DependencyInfo] {
        return dependencyInfoList
    }
    
    /// 添加依赖
    func addDependency(_ dep: DependencyInfo) -> Bool {
        // 添加到第一个target下
        let depDesc = "\t" + dep.toString()
        guard !depDesc.isEmpty, firstTargetLine != -1 else {
            return false
        }
        
        var copyContentArray = contentArray

        let insertIndex = firstTargetLine + 1
        copyContentArray.insert(depDesc, at: insertIndex)
        
        // 保存podfile
        do {
            try saveFile(array: copyContentArray)
            
            // 真正移除
            contentArray.insert(depDesc, at: insertIndex)
            
            // map中的line更新
            refreshDependencyMapWhenAdd(at: insertIndex)

            // 最后插入
            dependencyMap[insertIndex] = dep

            print("add sucess")
            
            return true
        } catch let error as NSError {
            print("saveFile Error:\(error)")
            return false
        }
    }
    
    /// 删除依赖
    func deleteDependency(at row: Int) {
        let line = lineForRow(at: row)
        
        if line != -1 && line < contentArray.count {
            // 先copy一份
            var copyContentArray = contentArray
            copyContentArray.remove(at: line)
            
            // 保存podfile
            do {
                try saveFile(array: copyContentArray)
                
                // 真正移除
                contentArray.remove(at: line)
                dependencyMap.removeValue(forKey: line)
                
                // map中的line更新
                refreshDependencyMapWhenDelete(at: line)
                
                print("delete sucess")

            } catch let error as NSError {
                print("saveFile Error:\(error)")
            }
        }
    }
    
    // 修改依赖
    func editDependency(at row: Int, dep: DependencyInfo) {
        let line = lineForRow(at: row)
            
        if line != -1 && line < contentArray.count {
            let depString = dep.toString()
            print("depString: \(depString)")

            // TODO:如果不同的target中定义了相同的依赖，则也同时修改

            
            // 先copy一份
            var copyContentArray = contentArray
            copyContentArray[line] = "\t" + dep.toString()
            
            // 保存podfile
            do {
                try saveFile(array: copyContentArray)
                
                // 保存成功后，进行修改
                contentArray[line] = dep.toString()
                dependencyMap[line] = dep
                
                print("edit success")
            } catch let error as NSError {
                print("saveFile Error:\(error)")
            }
        }
    }
    
    // row所对应的行数
    func lineForRow(at row: Int) -> Int {
        let list = dependencyIndexList
        let totalCount = list.count
        
        if row >= 0 && row < totalCount {
            // 对应行数
            let line = list[row]
            if line < contentArray.count {
                return line
            }
        }
        
        return -1
    }
    
    
    // 保存文件
    private func saveFile(array: [String]) throws {
        let content = array.joined(separator: "\n")
        
        let url = URL(fileURLWithPath: podfilePath)

        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    /// 该行是否应该解析pod信息
    ///
    /// - Parameters:
    ///   - index: 行数
    ///   - defIndexInfo: def函数开始结束行index
    /// - Returns: true/false
    private func lineShouldParse(index: Int, line: String, defIndexInfo: [String: [DefFunctionIndex: Int]]) -> Bool {
        // 过滤空行，注释行
        let trimmed = line.replacingOccurrences(of: " ", with: "")
        
        if trimmed.isEmpty || trimmed.hasPrefix("#") {
            return false
        }
        
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
    
    /// 找到podFile中定义的方法
    ///
    /// - Parameter string
    private func findFunction(string: String) {
        do {
            // 设置.可匹配换行 括号def test()可选
            let regularExp = try NSRegularExpression(pattern: "\\s*def\\s*(\\w+)\\(?\\)?(.*?)end", options:.dotMatchesLineSeparators)
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
    private func isCallFunction(functionName: String) -> Bool {
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
    private func extractFunctionDependency(functionName: String, beginIndex: Int) {
        if let body = defContent[functionName] {
            
            // 以行分隔
            var lines = body.components(separatedBy: .newlines)
            var index = beginIndex + 1
            
            // 去除头尾\n
            lines.removeFirst()
            lines.removeLast()
            
            for line in lines {
                
                // 过滤空行，注释行
                let trimmed = line.replacingOccurrences(of: " ", with: "")
                
                if trimmed.isEmpty || trimmed.hasPrefix("#") {
                    index = index + 1
                    continue
                }
                
                if let dependencyInfo = extractDependencyInfo(line: line) {
                    dependencyMap[index] = dependencyInfo
                }
                
                index = index + 1
            }
        }
    }
    
    /// 将一行输入转换成DependencyInfo
    ///
    /// - Parameter line: 一行输入
    /// - Returns: 依赖结果
    private func extractDependencyInfo(line: String) -> DependencyInfo? {
        // 过滤空行，注释行
        let trimmed = line.replacingOccurrences(of: " ", with: "")
        
        if trimmed.isEmpty || trimmed.hasPrefix("#") {
            return nil
        }
        
        // 匹配name，支持'xx', "xx/xx", "xx-xx"
        if let podName = regexMatchGroup(pattern: "\\s*pod\\s*['\"]([\\w/-]*?)['\"]", matchString: line) {
            print("libname: \(podName)")
            
            var info = DependencyInfo(name: podName)
            
            // 取版本号，以,分隔。如果有版本号，一定是跟在pod name后面，取第一个逗号后面''部分
            let list = trimmed.components(separatedBy: ",")
            if list.count > 1 {
                // 取第二个元素
                let versionString = list[1]
                
                if versionString.hasPrefix("'") || versionString.hasPrefix("\"") {
                    
                    let tmp = extractVersion(versionDesc: versionString)
                    print("versionRequirement:\(tmp.0), version: \(tmp.1)")
                    
                    info.versionRequirement = tmp.0
                    info.version = tmp.1
                    info.type = .Version
                    
                } else if let url = regexMatchGroup(pattern: ":git\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                    // 匹配git
                    print("url:\(url)")
                    
                    info.gitUrl = url
                    info.type = .Git
                    
                    // 匹配branch
                    if let branch = regexMatchGroup(pattern: ":branch\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                        print("branch:\(branch)")
                        
                        info.gitDescription = branch
                        info.gitType = .branch
                    }
                        // 匹配commit
                    else if let commit = regexMatchGroup(pattern: ":commit\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                        print("commit:\(commit)")
                        
                        info.gitDescription = commit
                        info.gitType = .commit
                    }
                        // tag
                    else if let tag = regexMatchGroup(pattern: ":tag\\s*=>\\s*['\"](.*?)['\"]", matchString: line) {
                        print("commit:\(tag)")
                        
                        info.gitDescription = tag
                        info.gitType = .tag
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
                if configurations.count >= 1 {
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
    
    /// 更新map中的line index
    private func refreshDependencyMapWhenDelete(at line: Int) {
        let indexList = dependencyIndexList
        
        for index in indexList {
            if index > line {
                // index - 1
                let dep = dependencyMap[index]
                dependencyMap[index - 1] = dep
                dependencyMap.removeValue(forKey: index)
            }
        }
    }
    
    /// 更新map中的line index
    private func refreshDependencyMapWhenAdd(at line: Int) {
        let indexList = dependencyIndexList
        
        for index in indexList.reversed() {
            if index >= line {
                // index - 1
                let dep = dependencyMap[index]
                dependencyMap[index + 1] = dep
                dependencyMap.removeValue(forKey: index)
            }
        }
    }
    
    //MARK:Helper
    /// 进行正则匹配，返回group 1
    private func regexMatchGroup(pattern: String, matchString: String) -> String? {
        return regexMatch(pattern: pattern, matchString: matchString, index: 1)
    }
    
    
    /// 正则匹配，返回全部匹配的字符串
    private func regexMatchFull(pattern: String, matchString: String) -> String? {
        return regexMatch(pattern: pattern, matchString: matchString, index: 0)
    }
    
    
    /// 正则匹配
    ///
    /// - Parameters:
    ///   - pattern: 正则表达式
    ///   - matchString: 待匹配字符串
    ///   - index: 匹配的index
    /// - Returns: 匹配字符串
    private func regexMatch(pattern: String, matchString: String, index: Int) -> String? {
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
    
    // 去除引号, '/"
    private func trimQuotation(string: String) -> String {
        var result = string.replacingOccurrences(of: "'", with: "")
        result = result.replacingOccurrences(of: "\"", with: "")
        return result
    }
    
    // 将字符串"'A','B'"转换成数组[A,B]
    private func parseSubspecs(subspecs: String) -> [String] {
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
    
    /// 将version转换成版本(限制符, 版本号)形式，如将"~> 1.0.1" -> (.Compatible, 1.0.1)
    ///
    /// - Parameter version: 完整版本号描述
    /// - Returns: (限制符, 版本号)
    private func extractVersion(versionDesc: String) -> (VersionRequirement, String) {
        
        // 提取出''之间的字符串
        if let versionString = regexMatchGroup(pattern: "'(.+)'", matchString: versionDesc) {
            
            let trimmed = versionString.replacingOccurrences(of: " ", with: "")
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
        
        return (VersionRequirement.Equal, "")
    }
}
