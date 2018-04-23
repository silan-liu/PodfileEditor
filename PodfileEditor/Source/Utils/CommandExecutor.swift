//
//  CommandExecutor.swift
//  PodfileEditor
//
//  Created by silan on 2018/4/7.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class CommandExecutor: NSObject {
    var arguments: [String]?
    
    init(with arguments: [String]) {
        super.init()
        self.arguments = arguments
    }
    
    func run(withHandler outputHandler: ((String) -> ())? = nil, terminalHandler: (() -> Void)? = nil) {
        DispatchQueue.global().async {
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            let process = Process()
            
            process.launchPath = "/usr/local/bin/pod"
            process.arguments = self.arguments
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            
            if outputHandler != nil {
                
                outputPipe.fileHandleForReading.readabilityHandler = { pipe in
                    if let line = String(data: pipe.availableData, encoding: .utf8) {
                        outputHandler?(line)
                    }
                }
                
                errorPipe.fileHandleForReading.readabilityHandler = { pipe in
                    if let line = String(data: pipe.availableData, encoding: .utf8) {
                        outputHandler?(line)
                    }
                }
                
                process.terminationHandler = { _ in
                    outputPipe.fileHandleForReading.readabilityHandler = nil
                    errorPipe.fileHandleForReading.readabilityHandler = nil
                    
                    if let terminalHandler = terminalHandler {
                        terminalHandler()
                    }
                }
            }
            
            process.launch()
            process.waitUntilExit()
        }
        
    }
}


