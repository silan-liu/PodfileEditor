//
//  AddDependencyViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/4/18.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class AddDependencyViewController: NSViewController {

    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var typePopupButton: NSPopUpButton!
    @IBOutlet weak var urlLabel: NSTextField!
    @IBOutlet weak var branchTextField: NSTextField!
    @IBOutlet weak var subspecTextField: NSTextField!
    @IBOutlet weak var versionRequirementLabel: NSTextField!
    @IBOutlet weak var branchLabel: NSTextField!
    @IBOutlet weak var configPopUpButton: NSPopUpButton!
    @IBOutlet weak var versionRequirementPopupButton: NSPopUpButton!
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var gitTypeLabel: NSTextField!
    @IBOutlet weak var gitTypePopUpButton: NSPopUpButton!
    
    var completion: ((DependencyInfo) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    
        setupUI()
    }
    
    //MARK: UI
    func setupUI()  {
        // 更新ui，如果在xib中改了type
        chooseType(typePopupButton)
    }
    
    // 显示版本号限制
    func showVersionRequirement(show: Bool) {
        branchLabel.isHidden = show
        branchTextField.isHidden = show
        
        versionRequirementLabel.isHidden = !show
        versionRequirementPopupButton.isHidden = !show
    }
    
    // 显示git type相关ui
    func showGitTypeUI(show: Bool) {
        gitTypeLabel.isHidden = !show
        gitTypePopUpButton.isHidden = !show
    }
    
    //MARK: Action
    @IBAction func chooseType(_ sender: Any) {
        let popupButton = sender as! NSPopUpButton
        let tag = popupButton.indexOfSelectedItem
        if (tag == 1) {
            // git
            urlLabel.stringValue = "url"
            branchTextField.isEnabled = true
            showVersionRequirement(show: false)
            showGitTypeUI(show: true)
            
        } else if (tag == 2) {
            urlLabel.stringValue = "path"

            // textField不能输入
            branchTextField.isEnabled = false
            showVersionRequirement(show: false)
            showGitTypeUI(show: false)

        } else if (tag == 0) {
            urlLabel.stringValue = "version (optional)"
            showVersionRequirement(show: true)
            showGitTypeUI(show: false)

        } else if (tag == 3) {
            urlLabel.stringValue = "podspec"
            
            // textField不能输入
            branchTextField.isEnabled = false
            showVersionRequirement(show: false)
            showGitTypeUI(show: false)
        }
    }
    
    @IBAction func chooseVersionRequirement(_ sender: Any) {
        let popupButton = sender as! NSPopUpButton
        if let title = popupButton.selectedItem?.title {
            print("chooseVersionRequirement:\(title)")
        }
    }
    
    @IBAction func chooseConfiguration(_ sender: Any) {
        let popupButton = sender as! NSPopUpButton
        if let title = popupButton.selectedItem?.title {
            print("chooseConfiguration:\(title)")
        }
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        let result = checkInput()
        if (!result.0) {
            errorLabel.stringValue = result.1
            return
        }
        
        let name = nameTextField.stringValue
        let url = urlTextField.stringValue
        let branch = branchTextField.stringValue
        let type = typePopupButton.indexOfSelectedItem
        let versionRequirement = versionRequirementPopupButton.indexOfSelectedItem
        
        let configIndex = configPopUpButton.indexOfSelectedItem
        var config = configPopUpButton.selectedItem?.title
        
        if configIndex == 0 {
            config = nil
        }

        let gitType = gitTypePopUpButton.selectedItem?.title
        
        let subspecString = subspecTextField.stringValue
        let subspec = subspecs(string: subspecString)
        
        var dep: DependencyInfo? = nil
        if (type == 0) {
           // version
            dep = DependencyInfo(name: name, version: url, versionRequirement: VersionRequirement(rawValue: versionRequirement)!, config: config, subspecs: subspec)
        } else if (type == 1) {
            // git
            dep = DependencyInfo(name: name, gitUrl: url, gitType: GitType(rawValue: gitType!)!, gitDescription: branch, config: config, subspecs: subspec)
        } else if (type == 2) {
            // path
            dep = DependencyInfo(name: name, path: url, config: config, subspecs: subspec)
        } else if (type == 3) {
            // podspec
            dep = DependencyInfo(name: name, podspec: url, config: config, subspecs: subspec);
        }
        
        if let dep = dep {
            print("dep: \(dep)")
            if let completion = completion {
                completion(dep)
            }
        }
        
        self.dismiss(nil)
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(nil)
    }
    
    func checkInput() -> (Bool, String) {
        
        if nameTextField.stringValue.isEmpty {
            return (false, "please input name")
        }
        
        let type = typePopupButton.indexOfSelectedItem
        if (type != 0) {
            if urlTextField.stringValue.isEmpty {
                return (false, "please input url/path")
            }
        }
        
        return (true, "")
    }
    
    func subspecs(string: String) -> [String]? {
        if string.isEmpty {
            return nil
        }
        
        let result = string.replacingOccurrences(of: " ", with: "")
        let list = result.components(separatedBy: ",")
        return list
    }
}
