//
//  KLanguageToolManager.swift
//  KYLLanguageTools
//
//  Created by kongyulu on 2021/1/20.
//

import Cocoa


final class KLanguageToolManager: NSObject {
    static let shared = KLanguageToolManager()
}

extension KLanguageToolManager {
   public func exportExcelToStringFile(filePath:String) {
        if filePath.isSuffix(type: "csv") || filePath.isSuffix(type: "number") {
            if KCSVToolManager.manager.parse(filePath: filePath) {
                debugPrint("导出成功:filePath=\(filePath)")
            }
            KCSVToolManager.manager.printAllParseResult()
            
        } else if filePath.isSuffix(type: "xls") {
            if KExcelToolManager.manager.exportExcelToStringFile(filePath: filePath) {
                debugPrint("导出成功:filePath=\(filePath)")
            }
        }
    }
    
    public func inputStringToDefaultExcelFile() {
        KExcelTool.share().inputStringToDefaultExcelFile()
    }
}
