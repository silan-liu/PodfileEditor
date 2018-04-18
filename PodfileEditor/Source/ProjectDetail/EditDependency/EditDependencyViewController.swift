//
//  EditDependencyViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/18.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class EditDependencyViewController: AddDependencyViewController {

    var dependencyInfo: DependencyInfo? = nil
    
    init(dep: DependencyInfo) {
        dependencyInfo = dep
        super.init(nibName: NSNib.Name("AddDependencyViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        updateUI()
    }
    
    func updateUI() {
        if let dependencyInfo = dependencyInfo {
            nameTextField.stringValue = dependencyInfo.name
            
            let type = dependencyInfo.type
            typePopupButton.selectItem(at: type.rawValue)
            
            if (type == SourceType.Version) {
                urlTextField.stringValue = dependencyInfo.version ?? ""
                versionRequirementPopupButton.selectItem(at: (dependencyInfo.versionRequirement?.rawValue) ?? 0)
            } else if (type == SourceType.Git) {
                urlTextField.stringValue = dependencyInfo.git ?? ""
                branchTextField.stringValue = dependencyInfo.gitDescription ?? ""
            } else if (type == SourceType.Path) {
                urlTextField.stringValue = dependencyInfo.path ?? ""
            }
            
            configPopUpButton.selectItem(at: dependencyInfo.configIndex.rawValue)
            subspecTextField.stringValue = dependencyInfo.subspecs?.formatedString() ?? ""
        }
    }
}
