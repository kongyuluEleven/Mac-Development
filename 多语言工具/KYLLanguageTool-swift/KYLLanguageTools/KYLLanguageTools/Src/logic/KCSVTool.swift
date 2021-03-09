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
    
    
    private var lock = NSLock()

}

//MARK: - 解析CSV
extension KCSVTool {
    
    /// 解析指定的 绝对路径的CSV 文件
    /// - Parameter filePath: 文件的绝对路径
    /// - Throws: 解析失败抛出异常
    /// - Returns: 解析成功返回true,否则返回false
    public func parse(filePath:String) -> Bool {
        //1. 先清除老数据
        _tempItems.removeAll()
        
        //2.检测文件类型
        guard filePath.isSuffix(type: "csv") || filePath.isSuffix(type: "number")else {
            debugPrint("解析csv文件失败，文件类型不对！")
            return false
        }
        
        var content:String? = nil
        //3. 获取csv文件的内容
         do {
            content =  try String(contentsOfFile: filePath)
            //print("content=\(String(describing: content))")
        } catch let err {
            print("出现异常，err=\(err)")
        }
        
        //4. 按照\r\n 切割内容为一个数组
        guard let csvLines = content?.components(separatedBy: "\r\n"),
              csvLines.count > 0 else {
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
            let values = c.element.components(separatedBy: ",")
            
            //如果只的数组不等于支持的语言的数组个数，则报错
//            if values.count != supportLanguages.count {
//                DispatchQueue.main.async {
//                    NSAlert(message: c.element).runModal()
//                }
//                //throw KCSVParseError.fileError
//                //return false
//                continue
//            }
            
            // 如果第一个值获取不到，则继续遍历
            guard var value0 = values.first else {
                continue
            }
            
            //格式化获取的值
            value0 = format(title: value0)
            
            //遍历已经存在的数据列表
            for item in _tempItems.enumerated() {
                //如果存在的值数组已经大于或者等于切割的是的数组元素个数，则跳过
                guard values.count > item.offset else {
                    continue
                }
                
                //格式化
                item.element.list[value0] = format(title: values[item.offset])
            }
        }
        
        
        return true
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

//MARK: - 保存文件CSV文件内容到LocationString
extension KCSVTool {
    public func printAllParseResult() {
        _tempItems.forEach { (item) in
            print("name = \(item.name) \n \t {")
            print(item.list)
            print("\n \t }")
        }
    }
    
    public func exportCVSToString(cvsFilePath:String, savePath:String) -> Bool {
        
        guard let srcpath = export(cvsFilePath: cvsFilePath) else {
            print("export(cvsFilePath:)失败")
            return false
        }
        
        //压缩文件
//        let zipPath = srcpath.appendingPathComponent("KLanguage.zip")
//
//        if !SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: srcpath) {
//            print("压缩文件失败:zipPath=\(zipPath), srcpath=\(srcpath)")
//            return false
//        }
        
        //移动文件到目标
        let filemanger = FileManager.default
        do {
            //let srcPath = savePath.deleteLastPathComponent()
            try filemanger.moveItem(atPath: srcpath, toPath: savePath)
            //try filemanger.copyItem(atPath: srcpath, toPath: savePath)
            
        } catch let error {
            print("移动文件失败. savePath=\(savePath),error=\(error)")
            return false
        }
        
        //删除临时目录
        
        return true
    }
    
    
    public func exportCVS(cvsFilePath:String, saveZipName:String) -> Bool {
        
        guard let srcPath = export(cvsFilePath: cvsFilePath) else {
            print("export(cvsFilePath:)失败")
            return false
        }
        //压缩文件
        let zipPath = srcPath.appendingPathComponent(saveZipName)
        
        if !SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: srcPath) {
            print("压缩文件失败:zipPath=\(zipPath), srcPath=\(srcPath)")
            return false
        }

        guard let path = getSelectPath(exportFileName: saveZipName) else {
            print("没有选择路径")
            return false
        }
        
        //删除临时文件
        do {
            let fileManager = FileManager.default
            try fileManager.moveItem(atPath: zipPath, toPath: path)
            try fileManager.removeItem(atPath: zipPath)
            try fileManager.removeItem(atPath: srcPath)
        } catch let error {
            print("移除文件失败:\(error)")
        }
        
        
        return true
    }
    
    public func export(cvsFilePath:String) -> String? {
        //1. 解析cvs文件到缓存
        guard parse(filePath: cvsFilePath) else {return nil}
        
        //2. 处理缓存
        
        //3. 保存缓存文件到LocalizationString文件
        guard let tempPath = getTempDataPath() else {
            print("临时目录不存在")
            return nil
        }

        //加锁
        lock.lock()
        defer {
            lock.unlock()
        }
        
        var savePath:String? = tempPath
        //写入文件
        _tempItems.forEach { (item) in
            let languageName = item.name
            let languageContents = item.list
            
            //根据语言创建一个多语言文件
            let dir = "\(tempPath)/\(languageName)"
            if !dir.isExistFile() {
                do {
                    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    print("文件路径创建失败：error=\(error)")
                    savePath = nil
                }
            }
            //let filePath = dir.appendingPathComponent("Localizable.txt")
            let filePath = dir.appendingPathComponent("Localizable.strings")
            //将languageContents 创建为一个组装好的string
            let contentList = languageContents.map { " \"\($0.key)\" = \"\($0.value)\" ;" }
            let content = contentList.joined(separator: "\n")
            do {
                try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            } catch let error {
                print("写入文件失败. filePath=\(filePath),error=\(error)")
                savePath = nil
            }
        }
        
        return savePath
    }
}


//MARK: - 文件保存
extension KCSVTool {
    
    /// 获取数据保存的临时目录，不存在则创建，如果创建目录失败返回nil
    /// - Returns: 返回确保存在的目标，否则返回nil
    func getTempDataPath() -> String? {
        let tempDataPath = tempSavePath().appendingPathComponent("kyl_language")
        
        let filemanger = FileManager.default
        
        if !filemanger.fileExists(atPath: tempDataPath) {
            //不存在路径，则创建
            do {
                try filemanger.createDirectory(atPath: tempDataPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("创建路径失败：path=\(tempDataPath),error=\(error)")
                return nil
            }
        }
        return tempDataPath
    }
    
    func tempSavePath() -> String {
//        var  path :String? = nil
//        do {
//            try path = FileManager.default.createTemporaryDirectory().path
//        } catch let error {
//            print("创建临时目录失败,error=\(error)")
//        }
//        //NSHomeDirectory() + "/Documents"
//        return path ?? KFileTool.appSupportPath
        
        return NSHomeDirectory().appending("/Downloads")
    }
    
   public func save(fileData:Data, to exportFileName:String) -> Bool {
        var saveRet = false
        let savePanel = NSSavePanel()
        savePanel.title = "保存文件"
        savePanel.message = "选择文件保存地址"
        savePanel.directoryURL =  URL (fileURLWithPath: NSHomeDirectory().appending("/Desktop"))
        savePanel.nameFieldStringValue = exportFileName
        savePanel.allowsOtherFileTypes = true
        savePanel.isExtensionHidden = false
        savePanel.canCreateDirectories = true
        savePanel.allowedFileTypes = ["zip"]
        savePanel.begin { (result) in
            if result == .OK {
                if let url = savePanel.url{
                    do {
                        try fileData.write(to: url)
                        print("保存文件成功 url=\(url)")
                        saveRet = true
                    }
                    catch let error {
                        print("\(#function), 保存文件失败，出现异常  error = \(error)")
                    }
                }
            }
        }
        
        return saveRet
    }
    
   public func getSelectPath(exportFileName:String) -> String? {
        var savePath:String? = nil
        let savePanel = NSSavePanel()
        savePanel.title = "保存文件"
        savePanel.message = "选择文件保存地址"
        savePanel.directoryURL =  URL (fileURLWithPath: NSHomeDirectory().appending("/Desktop"))
        savePanel.nameFieldStringValue = exportFileName
        savePanel.allowsOtherFileTypes = true
        savePanel.isExtensionHidden = false
        savePanel.canCreateDirectories = true
        //savePanel.allowedFileTypes = ["zip"]
        savePanel.begin { (result) in
            if result == .OK {
                if let path = savePanel.url?.path {
                    savePath = path
                }
            }
        }
        
        return savePath
    }
    
    
    private static func openFilePanel(types: [String], completionHandler: @escaping((NSOpenPanel) -> Void)) {
        let openDlg = NSOpenPanel()
        openDlg.canChooseFiles = true
        openDlg.canChooseDirectories = true
        openDlg.allowedFileTypes = types
        openDlg.allowsMultipleSelection = false
        openDlg.begin {(result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                completionHandler(openDlg)
            } else if  result.rawValue == NSFileHandlingPanelCancelButton {
                completionHandler(openDlg)
            }
        }
    }
}
