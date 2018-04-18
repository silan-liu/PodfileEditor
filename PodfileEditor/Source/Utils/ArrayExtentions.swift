//
//  ArrayExtentions.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/17.
//  Copyright © 2018年 summer. All rights reserved.
//

import Foundation

extension Array where Element == String {
    func formateString(_ splitCharacter: String) -> String {
        var string = ""
        let count = self.count
        var index = 0
        
        while index < count {
            string.append(self[index])

            if index != count - 1 {
                string.append(splitCharacter)
            }
            
            index = index + 1
        }

        return string
    }
}
