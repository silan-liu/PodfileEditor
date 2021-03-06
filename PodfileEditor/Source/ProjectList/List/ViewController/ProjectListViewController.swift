//
//  ViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/3/29.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate {

    @IBOutlet weak var tableView: NSTableView!
    
    var projectDetailWindowController: ProjectDetailWindowController?
    
    lazy var projectInfoCellConfigurator = ProjectInfoCellConfigurator()
    lazy var projectListDataController = ProjectListDataController()
    
    let projectInfoCellViewName = "ProjectInfoCellView"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(NSNib.init(nibNamed: NSNib.Name(rawValue: projectInfoCellViewName), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: projectInfoCellViewName))
        tableView.target = self
        tableView.doubleAction = #selector(doubleClickRow)
    }

    deinit {
        print("ProjectListViewController dealloc")
    }
    
    // MARK:Action
    @IBAction func addProject(_ sender: Any) {
        if let vc = UIFactory.addProjectViewController() {
            vc.chooseCompletion = { [unowned self] (projectName, projectPath) in
                self.projectListDataController.addProject(projectName: projectName, projectPath: projectPath)
                self.tableView.reloadData()
            }
            
            self.presentViewControllerAsSheet(vc)
        }
    }
    
    @objc func doubleClickRow() {
        let row = tableView.clickedRow
        
        NSLog("double click row, %d", row)

        gotoDetail(at: row)
    }

    // MARK:NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return projectListDataController.numberOfRows()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: ProjectInfoCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: projectInfoCellViewName), owner: self) as! ProjectInfoCellView
 
        if let projectInfo = projectListDataController.projectInfoAtRow(row: row) {
            projectInfoCellConfigurator.configCell(cell: cellView, info: projectInfo)
        }
        
        cellView.deleteBlock = { [unowned self] cell in
            let row = tableView.row(for: cellView)
            self.deleteProject(at: row)
        }
        
        cellView.editBlock = { [unowned self] cell in
            let row = tableView.row(for: cellView)
            self.editProject(at: row)
        }
        
        return cellView
    }
    
    // MARK:NSTableViewDataSource
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100
    }
    
    // MARK:Edit/Del
    func editProject(at row: Int) {
        // 编辑project信息
         if let projectInfo = projectListDataController.projectInfoAtRow(row: row) {
            let vc = EditProjectViewController(projectInfo: projectInfo)
            
            vc.chooseCompletion = { [unowned self] (projectName, projectPath) in
                self.projectListDataController.editProject(at: row, projectName: projectName, projectPath: projectPath)
                self.tableView.reloadData()
            }
            
            self.presentViewControllerAsSheet(vc)
        }
    }
    
    func deleteProject(at row: Int) {
        projectListDataController.deleteProject(at: row)
        tableView.reloadData()
    }
    
    func gotoDetail(at row: Int) {
        
        if let projectInfo = projectListDataController.projectInfoAtRow(row: row) {
            // 进入详情页
            projectDetailWindowController = UIFactory.projectDetailWindowController()
            projectDetailWindowController?.window?.delegate = self
            
            projectDetailWindowController?.window?.title = projectInfo.projectName
            
            if let detailVC = projectDetailWindowController?.contentViewController as? ProjectDetailViewController {
                detailVC.projectInfo = projectInfo
            }
            
            projectDetailWindowController?.showWindow(self)
        }
    }
    
    //MARK: NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        projectDetailWindowController = nil
    }
}

