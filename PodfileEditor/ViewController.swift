//
//  ViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/3/29.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(NSNib.init(nibNamed: NSNib.Name(rawValue: "ProjectInfoCellView"), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectInfoCellView"))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK:NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: ProjectInfoCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectInfoCellView"), owner: self) as! ProjectInfoCellView
        
        cellView.textField?.stringValue = "hello"
        cellView.textField?.textColor = NSColor.red
        
        return cellView
    }
    
    // MARK:NSTableViewDataSource
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100
    }
}

