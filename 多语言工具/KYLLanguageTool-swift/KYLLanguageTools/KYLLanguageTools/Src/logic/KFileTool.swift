//
//  KFileTool.swift
//  KYLLanguageTools
//
//  Created by kongyulu on 2021/1/20.
//

import AppKit

class KFileTool {

}

//MARK: - 文件路径选择
extension KFileTool {
    
    static var appSupportPath:String  {
        return NSHomeDirectory().appendingFormat("/Library/Application Support/%@", Bundle.main.appName)
    }
    
    static func openPanel(fileType:String = "") -> String? {
        return self.openPanel(panel: { (pannel) in
            pannel.allowedFileTypes = fileType.count > 0 ? [fileType] : []
            pannel.canChooseFiles = true
            pannel.canChooseDirectories = false
        })
    }
    
    static func openDirectory() -> String? {
        return self.openPanel(panel: { (pannel) in
            pannel.canChooseDirectories = true
            pannel.canChooseFiles = false
        })
    }
    
    static func openPanel(panel:((_ make:NSOpenPanel) -> Void)) -> String? {
        let openPanel = NSOpenPanel()
        panel(openPanel)
        guard openPanel.runModal().rawValue == NSFileHandlingPanelOKButton else {
            return nil
        }
        return openPanel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "")
    }
}
