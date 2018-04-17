//
//  ArrayExtentions.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/17.
//  Copyright © 2018年 summer. All rights reserved.
//

import Foundation

extension Array where Element == String {
    func formatedString() -> String {
        var string = ""
        for item in self {
            string.append(item)
        }
        
        return string
    }
}
