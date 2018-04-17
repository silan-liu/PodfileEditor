//
//  ProjectDetailCellConfigurator.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/17.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectDetailCellConfigurator: NSObject {
    func configCell(cell: NSTableCellView, info: DependencyInfo, index: Int) {
        if let value = valueAtIndex(index: index, info: info) {
            cell.textField?.stringValue = value
        }
    }
    
    func valueAtIndex(index: Int, info: DependencyInfo) -> String? {
        switch index {
        case 0:
            return info.name
        case 1:
            return info.git
        case 2:
            return info.config

        case 3:
            return info.subspecs?.formatedString()

        default:
            return nil
        }
    }
}
