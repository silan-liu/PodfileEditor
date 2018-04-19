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
    
    init(path: String) {
        podfilePath = path
    }

    func analyze() {
        print("begin analyze")
        do {
            var content = try String(contentsOf: URL(fileURLWithPath: podfilePath))
            content = content.replacingOccurrences(of: " ", with: "")
            
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines {
                // 过滤空行，注释行
                if line.isEmpty || line.hasPrefix("#") {
                    continue
                }
                
                // 匹配name，支持'xx', "xx"
                if let podName = regexMatch(pattern: "\\s*pod\\s*['\"]([\\w\\d/]*)['\"]", matchString: line) {
                    print("libname: \(podName)")
                }

                // 匹配版本号
                if let version = regexMatch(pattern: "['\"](\\d*\\.\\d*\\.\\d*)['\"]", matchString: line) {
                    print("version: \(version)")
                } else if let gitUrl = regexMatch(pattern: ":git\\s*=>\\s*['\"](.*?['\"])", matchString: line) {
                    // 匹配git
                    let url = trimQuotation(string: gitUrl)
                    print("url:\(url)")
                    
                    // 匹配branch
                    if let result = regexMatch(pattern: ":branch\\s*=>\\s*['\"](.*?['\"])", matchString: line) {
                        let branch = trimQuotation(string: result)
                        print("branch:\(branch)")
                    }
                    
                    // 匹配commit
                    if let result = regexMatch(pattern: ":commit\\s*=>\\s*['\"](.*?['\"])", matchString: line) {
                        let commit = trimQuotation(string: result)
                        print("commit:\(commit)")
                    }
                    
                    // tag
                    if let result = regexMatch(pattern: ":tag\\s*=>\\s*['\"](.*?['\"])", matchString: line) {
                        let tag = trimQuotation(string: result)
                        print("commit:\(tag)")
                    }
                    
                } else if let path = regexMatch(pattern: ":path\\s*=>\\s*['\"](.*?['\"])", matchString: line) {
                    // 匹配path
                    let path = trimQuotation(string: path)
                    print("path:\(path)")
                }
                
                // 匹配configuration
                if let result = regexMatch(pattern: ":configuration\\s*=>\\s*['\"](.*?['\"])", matchString: line) {
                    let configuration = trimQuotation(string: result)
                    print("configuration:\(configuration)")
                }
                
                // 匹配subspecs
                if let result = regexMatch(pattern: ":subspecs\\s*=>\\s*\\[(.*)\\]", matchString: line) {
                    
                    let subspecs = parseSubspecs(subspecs: result)
                    
                    print("subspecs:\(subspecs)")
                }
                
//                print("\(line)")
                print("=============")
            }
            
        } catch let error as NSError {
            print("error:\(error)")
        }
    }
    
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
        let trimmed = trimQuotation(string: subspecs)
        
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
}
