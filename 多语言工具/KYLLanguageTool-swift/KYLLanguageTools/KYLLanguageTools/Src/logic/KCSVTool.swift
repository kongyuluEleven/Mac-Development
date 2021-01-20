//
//  KCSVTool.swift
//  KYLLanguageTools
//
//  Created by kongyulu on 2021/1/20.
//

import Cocoa


enum KCSVParseError: Error {
    case fileError
}

struct KCSVToolManager {
    static let manager = KCSVTool()
}

class KCSVTool: NSObject {
    
    /// 获取单例
    /// - Returns: 返回KCSVTool对象
    static func share() -> KCSVTool {
        return KCSVToolManager.manager
    }
    
    /// 获取解析 CSV文档 出来的数据
    var items:[KCSVItem] {
        return _tempItems.filter{$0.name.count>0 && $0.name != "\r"}
    }
    
    /// 解析出来的临时数据保存
    private var _tempItems:[KCSVItem] = []

}

//MARK: - 解析CSV
extension KCSVTool {
    
    /// 解析指定的 绝对路径的CSV 文件
    /// - Parameter filePath: 文件的绝对路径
    /// - Throws: 解析失败抛出异常
    /// - Returns: 解析成功返回true,否则返回false
    public func parse(filePath:String) throws -> Bool {
        //1. 先清除老数据
        _tempItems.removeAll()
        
        //2.检测文件类型
        guard filePath.isSuffix(type: "csv") else {
            debugPrint("解析csv文件失败，文件类型不对！")
            return false
        }
        
        //3. 获取csv文件的内容
        let content = try String(contentsOfFile: filePath)
        
        //4. 按照\r\n 切割内容为一个数组
        let csvLines = content.components(separatedBy: "\r\n")
        
        guard csvLines.count > 0 else {
            debugPrint("解析csv文件失败，没有获取到文件内容！")
            return false
        }
        
        //5. 翻译的多语言的名称列表
        let supportLanguages = csvLines[0].components(separatedBy: ",")
        
        //6. 遍历所有多语言名称
        for language in supportLanguages {
            let name = format(title: language)
            let item = KCSVItem()
            item.name = name
            _tempItems.append(item)
        }
        
        // 7. 解析其他行
        guard csvLines.count > 1 else {
            debugPrint("解析csv文件失败，csvLines 只解析到一行！")
            return false
        }
        
        // 8. 遍历全部数据
        for c in csvLines.enumerated() {
            //跳过第一行
            guard c.offset > 0 else {
                continue
            }
            
            // 获取值切割的数组
        }
        
        
        return false
    }
}

//MARK: - 通用方法
extension KCSVTool {
    
    /// 获取指定语言名称的数据对象
    /// - Parameter name: 指定的语言名称
    /// - Returns:  查找出来的数据对象
    func languageItem(name:String) -> KCSVItem? {
        return items.first(where: {$0.name == name})
    }
    
    
    /// 格式化多语言标题
    /// - Parameter title: 多语言标题
    /// - Returns: 格式化之后多语言标题
    func format(title:String) -> String {
        var newValue = title
        let formatters = ["{R}":",",
                          "\r":"",
                          "\u{08}":"",]
        formatters.forEach { (key,value) in
            newValue = newValue.replacingOccurrences(of: key, with: value)
        }
        return newValue
    }
}
