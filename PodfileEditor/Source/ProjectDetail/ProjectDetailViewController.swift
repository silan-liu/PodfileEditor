//
//  ProjectDetailViewController.swift
//  PodfileEditor
//
//  Created by liusilan on 2018/3/29.
//  Copyright © 2018年 summer. All rights reserved.
//

import Cocoa

class ProjectDetailViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var textView: NSTextView!
    
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
        
        textView.string = """
        fkkkk2018-04-07 13:56:37.976367+0800 PodfileEditor[3690:110150] double click row, 1 \
        2018-04-07 13:56:38.005014+0800 PodfileEditor[3690:110150] *** Illegal NSTableView data source (<PodfileEditor.ProjectDetailViewController: 0x608000142890>).Must implement numberOfRowsInTableView: and tableView:objectValueForTableColumn:row:\
        projectInfo:~/Documents/test22018-04-07 13:56:37.976367+0800 PodfileEditor[3690:110150] double click row, 1\
        2018-04-07 13:56:38.005014+0800 PodfileEditor[3690:110150] *** Illegal NSTableView data source (<PodfileEditor.ProjectDetailViewController: 0x608000142890>).  Must implement numberOfRowsInTableView: and tableView:objectValueForTableColumn:row:
        projectInfo:~/Documents/test22018-04-07 13:56:37.976367+0800 PodfileEditor[3690:110150] double click row, 1
        2018-04-07 13:56:38.005014+0800 PodfileEditor[3690:110150] *** Illegal NSTableView data source (<PodfileEditor.ProjectDetailViewController: 0x608000142890>).  Must implement numberOfRowsInTableView: and tableView:objectValueForTableColumn:row:
        projectInfo:~/Documents/test22018-04-07 13:56:37.976367+0800 PodfileEditor[3690:110150] double click row, 1
        2018-04-07 13:56:38.005014+0800 PodfileEditor[3690:110150] *** Illegal NSTableView data source (<PodfileEditor.ProjectDetailViewController: 0x608000142890>).  Must implement numberOfRowsInTableView: and tableView:objectValueForTableColumn:row:
        projectInfo:~/Documents/test22018-04-07 13:56:37.976367+0800 PodfileEditor[3690:110150] double click row, 1
        2018-04-07 13:56:38.005014+0800 PodfileEditor[3690:110150] *** Illegal NSTableView data source (<PodfileEditor.ProjectDetailViewController: 0x608000142890>).  Must implement numberOfRowsInTableView: and tableView:objectValueForTableColumn:row:
        projectInfo:~/Documents/test2
        """
    }
    
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
    
    func updateCommandOutput(output: String) {
        DispatchQueue.main.async {
            self.textView.string = self.textView.string.appending(output)
            self.textView.scrollToEndOfDocument(nil)
        }
    }
    
    func parsePodfile() {
        if let projectInfo = projectInfo {
            print("projectInfo:\(projectInfo.projectPath)")
        }
    }
}
