//
//  ProjectInfoCellConfigurator.swift
//  PodfileEditor
//
//  Created by silan on 2018/4/4.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectInfoCellConfigurator: NSObject {
    func configCell(cell: ProjectInfoCellView, info: ProjectInfo) {
        cell.projectNameLabel.stringValue = info.projectName
        cell.projectPathLabel.stringValue = info.projectPath
    }
}
