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
    @IBOutlet weak var totalCountLabel: NSTextField!
    
    enum CellIdentifier: String {
        case ProjectActionCellView
    }
    
    var projectInfo: ProjectInfo? {
        didSet {
            parsePodfile()
        }
    }
    
    private lazy var installCommand: CommandExecutor? = {
        if let projectPath = projectInfo?.projectPath {
            let execuator = CommandExecutor(with: ["install", "--project-directory=\(projectPath)"])
            return execuator
        }
        
        return nil
    }()
    
    private lazy var dataController: ProjectDetailDataController = ProjectDetailDataController(projectInfo: projectInfo)
    private lazy var projectDetailCellConfigurator = ProjectDetailCellConfigurator()
    
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
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectDetailCellView"), owner: nil)  as! NSTableCellView
        
        if let dep = dataController.dependencyInfo(at: row) {
            let tableColumns = tableView.tableColumns
            if let tableColumn = tableColumn, let index = tableColumns.index(of: tableColumn) {
                projectDetailCellConfigurator.configCell(cell: cell, info: dep, index: index)
            }
        }
        
        return cell
    }
    
    // MARK:NSTableViewDataSource
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let info = self.dataController.dependencyInfo(at: row) {
            
            var string = ""
            
            // 比较version和subspec的字符串长度，取较大的
            if let versionInfo = info.versionInfo() {
                if versionInfo.count > string.count {
                    string = versionInfo
                }
            }
            
            if let subspecs = info.subspecs {
                let subspecString = PodfileUtils.subspecsToString(subspecs: subspecs)
                
                if subspecString.count > string.count {
                    string = subspecString
                }
            }

            let column = tableView.tableColumns[1]

            let margin: CGFloat = 10.0
            let maxSize = NSSize(width: column.width - margin * 2, height: .greatestFiniteMagnitude)
            
            // 计算高度
            let boundingBox = string.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: NSFont.systemFont(ofSize: 13.0)], context: nil)
            
            let totalHeight = boundingBox.height + margin * 2
            let height = totalHeight < 80 ? 80 : totalHeight
            
            return height
        }
        
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
        installCommand?.run(withHandler: { (output) in
            self.updateCommandOutput(output: output)
        }, terminalHandler: {
            self.updateCommandOutput(output: """
\n
========================================
            script end
========================================
\n
""")
        })
    }
    
    @IBAction func clearConsole(_ sender: Any) {
        self.textView.string = ""
    }
    
    @IBAction func addDependencyAction(_ sender: Any) {
        let vc = UIFactory.addDependencyViewController()
        vc.completion = { [unowned self] dep in
            self.addDependency(dep: dep)
        }
        
        self.presentViewControllerAsSheet(vc)
    }
    
    @IBAction func refreshDependency(_ sender: Any) {
        self.dataController.refresh { [unowned self] in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.totalCountLabel.stringValue = "共\(self.dataController.numberOfRows())项"
            }
        }
    }
    
    @IBAction func showInFinder(_ sender: Any) {
        if let projectPath = projectInfo?.projectPath, FileManager.default.fileExists(atPath: projectPath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: projectPath))
        } else {
            let alert = NSAlert()
            alert.messageText = "project path is not valid"
            
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.beginSheetModal(for: view.window!, completionHandler: nil)
        }
    }
    
    // MARK：func
    /// 更新命令输出
    func updateCommandOutput(output: String) {
        DispatchQueue.main.async {
            self.textView.string = self.textView.string.appending(output)
            self.textView.scrollToEndOfDocument(nil)
        }
    }
    
    /// 解析podfile
    func parsePodfile() {
        if let projectInfo = projectInfo {
            print("projectInfo:\(projectInfo.projectPath)")
            
            self.dataController.projectInfo = projectInfo
            self.dataController.analyze { [unowned self] in
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateTotalCount()
                }
            }
        }
    }
    
    /// 修改依赖
    func editDependency(at row: Int) {
        if let dependency = dataController.dependencyInfo(at: row) {
            let vc = EditDependencyViewController(dep: dependency)
            vc.completion = { [unowned self] dep in
                self.dataController.editDependency(at: row, dep: dep)
                self.tableView.reloadData()
            }
            
            self.presentViewControllerAsSheet(vc)
        }
    }
    
    /// 删除依赖
    func deleteDependency(at row: Int) {
        dataController.deleteDependency(at: row)
        tableView.reloadData()
        
        updateTotalCount()
    }
    
    /// 添加依赖
    func addDependency(dep: DependencyInfo) {
        if dataController.addDependency(dep: dep) == true {
            tableView.reloadData()
            
            updateTotalCount()
        }
    }
    
    /// 更新pod数目
    private func updateTotalCount() {
        self.totalCountLabel.stringValue = "共\(self.dataController.numberOfRows())项"
    }
    
    deinit {
        print("ProjectDetailViewController deinit")
    }
}
