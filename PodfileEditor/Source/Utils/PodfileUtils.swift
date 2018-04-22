//
//  PodfileUtils.swift
//  PodfileEditor
//
//  Created by silan on 2018/4/22.
//  Copyright © 2018年 summer. All rights reserved.
//

import Foundation

class PodfileUtils {
    // -> A,B
    static func subspecsToString(subspecs: [String]) -> String {
        var string = ""
        let count = subspecs.count
        var index = 0
        
        while index < count {
            string.append(subspecs[index])
            
            if index != count - 1 {
                string.append(",")
            }
            
            index = index + 1
        }
        
        return string
    }
    
    // -> ['A', 'B']
    static func subspecsToStringWithBracket(subspecs: [String]) -> String {
        var string = "["
        let count = subspecs.count
        var index = 0
        
        while index < count {
            string = string + "'\(subspecs[index])'"
            
            if index != count - 1 {
                string.append(", ")
            }
            
            index = index + 1
        }
        
        string.append("]")
        
        return string
    }
}
