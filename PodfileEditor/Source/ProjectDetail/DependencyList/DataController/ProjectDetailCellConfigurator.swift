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
        let value = valueAtIndex(index: index, info: info)
        if let value = value {
            cell.textField?.stringValue = !value.isEmpty ? value : "None"
        } else {
            cell.textField?.stringValue = "None"
        }
    }
    
    func valueAtIndex(index: Int, info: DependencyInfo) -> String? {
        switch index {
        case 0:
            return info.name
            
        case 1:
            let version = versionInfo(info: info)
            return version
            
        case 2:
            return info.config

        case 3:
            if let subspecs = info.subspecs {
                return PodfileUtils.subspecsToString(subspecs: subspecs)
            }
            
            return nil

        default:
            return nil
        }
    }
    
    func versionInfo(info: DependencyInfo) -> String? {
        switch info.type {
        case SourceType.Version:
            if let versionRequirement = info.versionRequirement, let version = info.version {
                return versionRequirement.description() + " " + version
            }
            
            return nil
        case SourceType.Path:
            return info.path
        case SourceType.Podspec:
            return info.podspec
        case SourceType.Git:
            if let git = info.gitUrl {
                var value = "git => " + git
                if let gitDescription = info.gitDescription, let gitType = info.gitType?.rawValue {
                    value = value + "\n\n\(gitType) => " + gitDescription
                }

                return value
            }
            
            return nil
        }
    }
}
