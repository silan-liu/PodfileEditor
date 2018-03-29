//
//  UIFactory.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/3/29.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class UIFactory: NSObject {
    static func projectDetailWindowController() -> ProjectDetailWindowController? {
        let storyboard = self.mainStoryboard()
        let controller = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue:"ProjectDetailWindowController")) as? ProjectDetailWindowController
        
        return controller
    }
    
    static func addProjectViewController() -> AddProjectViewController? {
        let storyboard = self.mainStoryboard()
        let vc = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue:"AddProjectViewController")) as? AddProjectViewController
        return vc
    }
    
    static func mainStoryboard() -> NSStoryboard? {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)

        return storyboard
    }
}
