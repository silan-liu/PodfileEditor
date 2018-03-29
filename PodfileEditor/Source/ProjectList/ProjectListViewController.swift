//
//  ViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/3/29.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    
    var projectDetailWindowController: ProjectDetailWindowController?
    
    let projectInfoCellViewName = "ProjectInfoCellView"
    let projectDetailWindowControllerName = "ProjectDetailWindowController"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(NSNib.init(nibNamed: NSNib.Name(rawValue: projectInfoCellViewName), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: projectInfoCellViewName))
        tableView.target = self
        tableView.doubleAction = #selector(doubleClickRow)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK:Action
    @IBAction func addProject(_ sender: Any) {
        if let vc = UIFactory.addProjectViewController() {
            self.presentViewControllerAsSheet(vc)
        }
    }
    
    @objc func doubleClickRow() {
        let row = tableView.clickedRow
        
        NSLog("double click row, %d", row)

        projectDetailWindowController = UIFactory.projectDetailWindowController()
        projectDetailWindowController?.showWindow(nil)
    }

    // MARK:NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: ProjectInfoCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: projectInfoCellViewName), owner: self) as! ProjectInfoCellView
 
        return cellView
    }
    
    // MARK:NSTableViewDataSource
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {

    }
}

