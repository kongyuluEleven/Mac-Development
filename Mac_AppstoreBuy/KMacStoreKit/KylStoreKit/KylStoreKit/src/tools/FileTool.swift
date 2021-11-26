//
//  FileTool.swift
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

import Cocoa

class FileTool: NSObject {
    /// 打开文件
    /// - Parameters:
    ///   - types: 可选中的文件类型
    ///   - handler: 完成回调：成功，将返回（succeed，true），失败：（失败原因， false）
    public static func openFilePanel(types: [String], handler: @escaping(String, Bool) ->Void) {
        
        self.openFilePanel(types: types, completionHandler: { (openPanel) in
            guard let fileURL = openPanel.url else {
                handler("文件路径错误！", false)
                return
            }
            
            #if APP_STORE
            WSFileAccessHelper.saveAuthor(openPanel: openPanel)
            #endif
            
            let temp = fileURL.path.components(separatedBy: "///")
            guard let path = temp.last else {
                handler("文件路径错误！", false)
                return
            }
            let fullPath = path+"/Contents/MacOS/"
            let receiptPath = path+"/Contents/_MASReceipt/receipt"
            if checkInstallerSource(path: receiptPath) == 173 {
                handler("安装包不是来源于AppStore！", false)
                return
            }
            
            self.readAppInfo(path: fullPath, handler: handler)
        }
    )}
    
    /// 从默认的Filmora 8安装路径读取app信息进行验证
    /// - Parameter handler: 完成回调：成功，将返回（succeed，true），失败：（失败原因， false）
    public static func readAppFromDefaultPath(handler: @escaping(String, Bool) ->Void) {
        let defaultAppPath = "/Applications/Filmora Video Editor.app"
        if checkInstallerSource(path: defaultAppPath + "/Contents/_MASReceipt/receipt") == 173 {
            handler("安装包不是来源于AppStore！", false)
        } else {
            readAppInfo(path: defaultAppPath + "/Contents/MacOS/", handler: handler)
        }
    }
    
    private static func readAppInfo(path: String, handler: @escaping(String, Bool) ->Void) {
        let fileMange = FileManager.default
        do {
            let paths = try fileMange.contentsOfDirectory(at: URL(fileURLWithPath: path),
                                                          includingPropertiesForKeys: nil,
                                                          options: .skipsHiddenFiles)
            var status = "验证失败！"
            var result = false
            var signInfo: SignInfo?
            for file in paths {
                // let fileAttributes = try fileMange.attributesOfItem(atPath: file.path)
                // debugPrint("文件属性：\n",file.path,fileOwnerAccountName, macOName)
                do {
                    let fileType = try NSWorkspace.shared.type(ofFile:file.path)
                    if fileType == "public.unix-executable" {
                        signInfo = CheckCodeSign.command(path: file.path)
                        if let _signInfo = signInfo {
                            if _signInfo.format == .appBundleMachO {
                                result = true
                                if _signInfo.teamIdentifier != "YZC2T44ZDX" {
                                    result = false
                                }
                                let auth = "Apple Worldwide Developer Relations Certification Authority"
                                if _signInfo.authority != auth && _signInfo.authority6 != auth && _signInfo.authority7 != auth {
                                    result = false
                                }
                                if _signInfo.identifier != "com.Wondershare.Vivideo" {
                                    result = false
                                }
                            }
                        }
                        
                        if result == true {
                            status = "succeed"
                            return handler(status, result)
                        }
                    }
                } catch let err {
                    return handler("读取文件信息失败：\(err.localizedDescription)", result)
                }
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: signInfo?.orgDict ?? [String : String](), options: .prettyPrinted)
                return handler(status+(String(data: jsonData, encoding: .utf8) ?? ""), result)
            } catch let err {
                return handler("解析签名信息错误：\(err.localizedDescription)", result)
            }
        } catch let err {
            return handler("访问文件错误：\(err.localizedDescription)", false)
        }
    }
    
    /// 检测安装包来源 /Contents/_MASReceipt/receipt
    /// - Parameter path: app path
    /// - Returns: 来自AppStore官方，返回9;  来自非AppStore官方，则返回 173，不直接使用 bool 值是为了增加些破解难度，没有其它原因
    static func checkInstallerSource(path: String = "/Applications/Filmora Video Editor.app/Contents/_MASReceipt/receipt") -> Int {
        //        #if APP_STORE
        if VerifyAppReceipt.validate(atPath: path) == 173 {
//            debugPrint("\(#function) validateReceiptAtPath(path) 失败，不是从appstore下载的应用：path = \(path)")
            return 173
//            exit(173)
        }
        //        #endif
        return 9
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
