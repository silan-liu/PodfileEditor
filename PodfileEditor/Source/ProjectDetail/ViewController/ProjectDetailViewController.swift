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
    
    private lazy var dataController: ProjectDetailDataController = ProjectDetailDataController(projectInfo: projectInfo)

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
        return dataController.numberOfRows()
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
        
        if let dep = dataController.dependencyInfo(at: row) {
            if tableColumn == tableView.tableColumns.first {
                cell.textField?.stringValue = dep.name
            } else {
                cell.textField?.stringValue = "testest"
            }
        }
        
        return cell
    }
    
    // MARK:NSTableViewDataSource
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 80
    }
    
    //MARK：Action
    @IBAction func podInstallAction(_ sender: Any) {
        self.updateCommandOutput(output: """
\n
========================================
            script start
========================================
\n
""")
        installCommand.run { (output) in
            self.updateCommandOutput(output: output)
        }
        
        self.updateCommandOutput(output: """
\n
========================================
            script end
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
        dataController.deleteDependency(at: row)
        tableView.reloadData()
    }
    
    deinit {
        print("ProjectDetailViewController deinit")
    }
}
