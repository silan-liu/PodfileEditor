//
//  AddDependencyViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/18.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class AddDependencyViewController: NSViewController {

    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var typePopupButton: NSPopUpButton!
    @IBOutlet weak var branchTextField: NSTextField!
    @IBOutlet weak var subspecTextField: NSTextField!
    @IBOutlet weak var versionRequirementLabel: NSTextField!
    @IBOutlet weak var branchLabel: NSTextField!
    @IBOutlet weak var versionRequirementPopupButton: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        branchLabel.isHidden = true
        branchTextField.isHidden = true
        
        versionRequirementLabel.isHidden = false
        versionRequirementPopupButton.isHidden = false
        
        setupUI()
    }
    
    //MARK: UI
    func setupUI()  {
        versionRequirementPopupButton.addItems(withTitles: [">", "<=", "<"])
    }
    
    //MARK: Action
    @IBAction func chooseType(_ sender: Any) {
    }
    
    @IBAction func chooseVersionRequirement(_ sender: Any) {
    }
    
    @IBAction func chooseConfiguration(_ sender: Any) {
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        self.dismiss(nil)
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(nil)
    }
}
