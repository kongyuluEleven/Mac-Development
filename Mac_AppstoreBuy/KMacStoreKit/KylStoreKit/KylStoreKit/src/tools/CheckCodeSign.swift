//
//  CheckCodeSign.swift
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

import Cocoa
/// 验证签名类
class CheckCodeSign: NSObject {
    /// 验证签名
    /// - Parameter path: App路径
    /// - Returns: 签名信息
    static func command(path: String) -> SignInfo? {
        let certTask = Process()
        certTask.launchPath = "/usr/bin/codesign"
        certTask.arguments = ["-vv","-d",path]
        
        let pipe = Pipe()
        certTask.standardOutput = pipe
        certTask.standardError = pipe
        
        let handle = pipe.fileHandleForReading
        certTask.launch()
        
        let data = handle.readDataToEndOfFile()
        let _dataString = String(data: data, encoding: .utf8)
        guard let dataString = _dataString else {
            debugPrint("调用签名命令失败！")
            return nil
        }
        
        let dataArr = dataString.components(separatedBy: "\n")
        var dict: [String : String]?

        for (index, element) in dataArr.enumerated() {
            let keyValue = element.components(separatedBy: "=")
            if keyValue.count > 1 {
                if dict == nil {
                    dict = [String : String]()
                }
                let key = keyValue[0]
                let authority = dict?["Authority"]
                if key == "Authority", let _ = authority {
                    dict?.updateValue(keyValue[1], forKey: keyValue[0]+String(index))
                } else {
                    dict?.updateValue(keyValue[1], forKey: keyValue[0])
                }
            }
        }
        guard let _dict = dict else {
            return nil
        }
        let info = SignInfo.init(dict: _dict)
        return info
    }
}
