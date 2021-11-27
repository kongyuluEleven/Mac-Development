//
//  String+file.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

// MARK: - 文件路径
public extension String {
    
    /// 是否是目录
    /// - Returns: 是目录返回true,否则返回false
    func isDirectory() -> Bool {
        var isDir: ObjCBool = ObjCBool(false)
        FileManager.default.fileExists(atPath: self, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    
    /// 字符串表示的路径是否存在
    /// - Returns: 路径存在返回true,否则返回false
    func isExistFolder() -> Bool {
        if !self.isDirectory() {
            return false
        }
        return FileManager.default.fileExists(atPath: self)
    }
    
    
    /// 字符串表示路径下的文件是否存在
    /// - Returns: 文件存在返回true,否则返回false
    func isExistFile() -> Bool {
        var isDir: ObjCBool = ObjCBool(false)
        let isExist = FileManager.default.fileExists(atPath: self, isDirectory: &isDir)
        return isExist && !isDir.boolValue
    }
    
    //计算文件大小，单位为MB单位
    func calculateFileSize() -> Double {
        var dic: [FileAttributeKey: Any] = [:]
        do {
            dic =  try FileManager.default.attributesOfItem(atPath: self)
        }catch let error as NSError {
            print("\(#function) error=\(error)")
        }
        
        let val = dic[FileAttributeKey.size] as? NSNumber
        return val == nil ? 0 : val!.doubleValue / (1024 * 1024)
    }
    
    //计算文件夹大小，单位MB单位
    func folderSize() -> Double {
        guard isExistFolder() else {
            return calculateFileSize()
        }
        
        var fileSize:Double = 0.0
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: self)
            for file in files {
                let path = self + "/\(file)"
                fileSize = fileSize + path.folderSize()
            }
        } catch let error as NSError {
            print("\(#function) error=\(error)")
        }
        return fileSize
    }
    
    //计算路径剩余空间，M单位
    func folderFreeSize() -> Double {
        let dic = try? FileManager.default.attributesOfFileSystem(forPath: self)
        guard let freeSize = (dic?[FileAttributeKey.systemFreeSize] as? NSNumber)?.doubleValue else {return 0}
        return freeSize / (1024*1024)
    }
    
    
    /// 在字符串最后最近一个路径分段 例如追加一个：“/文件夹或文件名”
    /// - Parameter pathComponent: 需要追加的文件名
    /// - Returns: 返回追加后，完整的路径
    func appendingPathComponent(_ pathComponent: String) -> String {
        let path = self + "/" + pathComponent
        return path
    }
    
    /// 删除路径的最后一个分段
    /// - Returns: 返回删除了最后分段的路径
    func deleteLastPathComponent() -> String {
        let str = self as NSString
        let path = str.deletingLastPathComponent
        return path
    }
    
    
    /// 获取路径的最后一个分段字符串
    /// - Returns: 返回路径的最后一个分段字符串
    func lastPathComponent() -> String {
        let str = self as NSString
        let ext = str.lastPathComponent
        return ext
    }
    
    
    /// 删除字符串表示的路径的文件扩展名
    /// - Returns: 返回删除了扩展名的路径字符串
    func deletingPathExtension() -> String {
        let str = self as NSString
        let path = str.deletingPathExtension
        return path
    }
    
    
    /// 从路径中获取文件名
    var fileName: String {
        let names = self.components(separatedBy: "/")
        if let safeName = names.last {
            let pathExtensions = safeName.components(separatedBy: ".")
            if let pathExtension = pathExtensions.first {
                return pathExtension
            }
        }
        return self
    }
    
    
    /// 从路径中获取扩展名
    var pathExtension: String {
        let names = self.components(separatedBy: "/")
        if let safeName = names.last {
            let pathExtensions = safeName.components(separatedBy: ".")
            if let pathExtension = pathExtensions.last {
                return pathExtension
            }
        }
        return self
    }
}

// MARK: - 文件路径权限
public extension String {
    
    /// 文件路径是否有写权限
    /// - Returns: 有权限则返回true,否则返回false
    func isWriteable() -> Bool {
        return FileManager.default.isWritableFile(atPath: self)
    }
    
    /// 文件路径是否有读权限
    /// - Returns: 有权限则返回true,否则返回false
    func isReadable() -> Bool {
        return FileManager.default.isReadableFile(atPath: self)
    }
    
    /// 文件路径是否有被删除权限
    /// - Returns: 有权限则返回true,否则返回false
    func isDeletable() -> Bool {
        return FileManager.default.isDeletableFile(atPath: self)
    }
    
    /// 文件路径是否有可执行权限
    /// - Returns: 有权限则返回true,否则返回false
    func isExecutable() -> Bool {
        return FileManager.default.isExecutableFile(atPath: self)
    }
}


// MARK: - 文件目录内容获取
public extension String {
    /// 获取文件夹下面所有的文件
    ///
    /// - Parameters:
    ///   - path: 文件夹路径
    ///   - allowFileTypes: 允许查询的文件后缀 默认为全部支持
    /// - Returns: 查询出的文件
    static func findAllFiles(path:String, allowFileTypes:[String] = []) -> [String] {
        /// 存放查询出的文件数组
        var files:[String] = []
        /// 是否是文件夹 默认不是
        var isDirectory = ObjCBool(false)
        /// 查询路径是否存在 不存在直接返回空数组
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            return files
        }
        /// 如果过滤的数组存在对文件进行过滤
        if allowFileTypes.count > 0 {
            /// 如果不存在最后一个错误直接返回
            guard let lastPath = path.components(separatedBy: "/").last else {
                return files
            }
            /// 获取文件后缀 如果不存在就返回
            guard let lastExtern = lastPath.components(separatedBy: ".").last else {
                return files
            }
            guard !allowFileTypes.contains(lastExtern) else {
                return files
            }
        }
        
        /// 如果是文件就直接的添加 否则就获取文件夹的子元素
        if !isDirectory.boolValue {
            files.append(path)
        } else {
            /// 如果不存在子元素就返回
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
                return files
            }
            for content in contents {
                /// 获取子元素的路径 替换//成/
                let subPath = "\(path)/\(content)".replacingOccurrences(of: "//", with: "/")
                files.append(contentsOf: findAllFiles(path: subPath))
            }
        }
        
        return files
    }
    
    
    /// 判断一个文件后缀是不是指定的后缀
    ///
    /// - Parameters:
    ///   - typeName: 指定的后缀名称
    ///   - filePath: 文件的路径
    /// - Returns: 如果 true 代表是我们指定后缀的文件 false 代表不是
    static func isSuffixType(typeName:String, filePath:String) -> Bool {
        let pathList = filePath.components(separatedBy: ".")
        guard pathList.count > 1 else {
            return false
        }
        guard let lastPath = pathList.last else {
            return false
        }
        guard lastPath == typeName else {
            return false
        }
        return true
    }
    
    /// 判断一个文件后缀是不是指定的后缀
    /// - Parameter type: 指定的后缀名称
    /// - Returns: 如果 true 代表是我们指定后缀的文件 false 代表不是
    func isSuffix(type:String) -> Bool {
        let pathList = self.components(separatedBy: ".")
        guard pathList.count > 1 else {
            return false
        }
        guard let lastPath = pathList.last else {
            return false
        }
        guard lastPath == type else {
            return false
        }
        return true
    }
}


#if canImport(AppKit)
import AppKit

// MARK: - 文件目录内容获取
public extension String {
    /// 弹窗授权框，返回用户选择的获取目录
    ///
    /// - Returns: 目录的地址
    static func getDirectory() -> String? {
        let openPannel = NSOpenPanel()
        openPannel.canChooseFiles = false
        openPannel.canChooseDirectories = true
        guard openPannel.runModal().rawValue == NSFileHandlingPanelOKButton else {
            return nil;
        }
        guard let path = openPannel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") else {
            return nil;
        }
        return path;
    }
    
    
    /// 弹窗授权框返回用户选择的文件路径
    /// - Parameter fileType: 文件类型
    /// - Returns: 返回用户选择的文件路径
    static func getFile(fileType:String) -> String {
        let openPannel = NSOpenPanel()
        openPannel.allowedFileTypes = [fileType]
        openPannel.canChooseFiles = true
        openPannel.canChooseDirectories = false
        guard openPannel.runModal().rawValue == NSFileHandlingPanelOKButton else {
            return ""
        }
        return openPannel.urls.first?.absoluteString.replacingOccurrences(of: "file://", with: "") ?? ""
    }
    
}

#endif
