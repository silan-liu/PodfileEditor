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
            let content = try String(contentsOf: URL(fileURLWithPath: podfilePath))

            let lines = content.components(separatedBy: .newlines)
            
            for line in lines {
                print("\(line)")
                print("====================")
            }
            
        } catch let error as NSError {
            print("error:\(error)")
        }
    }
}
