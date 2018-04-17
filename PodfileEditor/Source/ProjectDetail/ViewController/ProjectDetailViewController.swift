//
//  ProjectDetailViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/3/29.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectDetailViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var textView: NSTextView!
    
    enum CellIdentifier: String {
        case ProjectActionCellView
    }
    
    var installCommand: CommandExecutor = {
        let execuator = CommandExecutor(with: ["install", "--verbose"])
        return execuator
    }()
    
    var projectInfo: ProjectInfo? {
        didSet {
            parsePodfile()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        setupTableView();
    }
    
    //MARK: UI
    func setupTableView() {
        let identifier = CellIdentifier.ProjectActionCellView.rawValue
        
        tableView.register(NSNib(nibNamed: NSNib.Name(rawValue: identifier), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier))
    }
    
    //MARK: TableView Delegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
    }
    
     func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn == tableView.tableColumns.last {
            // action
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier.ProjectActionCellView.rawValue), owner: nil)  as! ProjectActionCellView
            
            cell.deleteBlock = { [weak self] cellView in
                let row = tableView.row(for: cellView)

                self?.deleteDependency(at: row)
            }
            
            cell.editBlock = { [weak self] cellView in
                let row = tableView.row(for: cellView)

                self?.editDependency(at: row)
            }
            
            return cell;
        }
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TestCell"), owner: nil)  as! NSTableCellView
        if tableColumn == tableView.tableColumns.first {
            cell.textField?.stringValue = "fds"
        } else {
            cell.textField?.stringValue = "if的好时机发送到家乐福几点开始房间看电视附近的开始放假时代峰峻单身快乐"
        }
        
        return cell
    }
    
    //MARK：Action
    @IBAction func podInstallAction(_ sender: Any) {
        self.updateCommandOutput(output: """
\n
========================================
\n
""")
        installCommand.run { (output) in
            self.updateCommandOutput(output: output)
        }
        
        self.updateCommandOutput(output: """
\n
========================================
\n
""")
    }
    
    @IBAction func clearConsole(_ sender: Any) {
        self.textView.string = ""
    }
    
    // 更新命令输出
    func updateCommandOutput(output: String) {
        DispatchQueue.main.async {
            self.textView.string = self.textView.string.appending(output)
            self.textView.scrollToEndOfDocument(nil)
        }
    }
    
    // 解析podfile
    func parsePodfile() {
        if let projectInfo = projectInfo {
            print("projectInfo:\(projectInfo.projectPath)")
        }
    }
    
    // 修改依赖
    func editDependency(at row: Int) {
        
    }
    
    // 删除依赖
    func deleteDependency(at row: Int) {
        
    }
    
    deinit {
        print("ProjectDetailViewController deinit")
    }
}
