//
//  ProjectActionCellView.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/17.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectActionCellView: NSTableCellView {

    var editBlock: ((ProjectActionCellView) -> (Void))?
    var deleteBlock: ((ProjectActionCellView) -> (Void))?
    
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
