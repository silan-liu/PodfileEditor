//
//  ProjectInfoCellView.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/3/29.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectInfoCellView: NSTableCellView {
    
    @IBOutlet weak var projectPathLabel: NSTextField!
    @IBOutlet weak var projectNameLabel: NSTextField!
    
    var editBlock: ((ProjectInfoCellView) -> (Void))?
    var deleteBlock: ((ProjectInfoCellView) -> (Void))?

    @IBAction func edit(_ sender: Any) {
        
        if let editBlock = editBlock {
            editBlock(self)
        }
    }
    
    @IBAction func delete(_ sender: Any) {
        
        if let deleteBlock = deleteBlock {
            deleteBlock(self)
        }
    }
}
