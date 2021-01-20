//
//  KExcelTool.swift
//  KYLLanguageTools
//
//  Created by kongyulu on 2021/1/20.
//

import Cocoa


struct KExcelToolManager {
    static let manager = KExcelTool()
}

class KExcelTool: NSObject {
    
    /// 获取单例
    /// - Returns: 返回KCSVTool对象
    static func share() -> KExcelTool {
        return KExcelToolManager.manager
    }
    
    /// excel处理工具类，OC编写
    private var excelTool:KLanguageTool = KLanguageTool()
    

}

//MARK: - 对外接口
extension KExcelTool {
    public func exportExcelToStringFile(filePath:String) -> Bool {
        guard filePath.isSuffix(type: "xls") else {
            debugPrint("文件格式不对 filePath=\(filePath)")
            return false
        }
        excelTool.createFile(filePath)
        return true
    }
    
    public func inputStringToDefaultExcelFile() {
        excelTool.createDefaultFile()
    }
}
