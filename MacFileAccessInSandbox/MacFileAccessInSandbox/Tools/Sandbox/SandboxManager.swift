//
//  SandboxManager.swift
//  MacSandoxFileAccess
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

import Foundation

enum BookMarkTypes {
    case normal, media
    /// key值
    var key: String {
        switch self {
        case .normal: return "com.wondershare.customfolderbookmark"
        case .media: return "com.wondershare.mediabookmark"
        }
    }
}

typealias SandboxAccessSecurityScopeHandler = ((URL,Data) -> (Void))
typealias SandboxAccessHandler = (() -> (Void))

class SandboxManager {
    
    private let sandboxTool = SandboxFileAccess()

    /// The default singleton instance.
    static let shared = SandboxManager()
    

    @discardableResult
    func accessFile(path:String, persist:Bool, completion: SandboxAccessHandler?) -> Bool {
        return sandboxTool.accessFilePath(path, persistPermission: persist) {
            completion?()
        }
    }
    
    @discardableResult
    func accessFile(url:URL, persist:Bool, completion: SandboxAccessHandler?) -> Bool {
        return sandboxTool.accessFileURL(url, persistPermission: persist) {
            completion?()
        }
    }
    
    @discardableResult
    func requestPermission(path:String, persist:Bool, completion: SandboxAccessSecurityScopeHandler?) -> Bool {
        return sandboxTool.requestPermissions(forFilePath: path, persistPermission: persist) { (url, data) in
            completion?(url,data)
        }
    }
    
    @discardableResult
    func requestPermission(url:URL, persist:Bool, completion: SandboxAccessSecurityScopeHandler?) -> Bool {
        return sandboxTool.requestPermissions(forFileURL: url, persistPermission: persist) { (reUrl, data) in
            completion?(reUrl,data)
        }
    }
    
    @discardableResult
    func persistPermission(path:String) -> Data {
        return sandboxTool.persistPermissionPath(path)
    }
    
    @discardableResult
    func persistPermission(url:URL) -> Data {
        return sandboxTool.persistPermissionURL(url)
    }
}


extension SandboxManager {
    
    class func isAuthored(path:String) -> Bool {
        return SandBoxAuthorize.isAuthoredFilePath(path)
    }
    
    @discardableResult
    class func storeFileBookmark(url:URL,key:String = BookMarkTypes.normal.key) -> Bool {
        return SandBoxAuthorize.storeFileURL(withBookmark: url, key: key)
    }
    
    @discardableResult
    class func getFileBookmark(path:String, key:String = BookMarkTypes.normal.key) -> URL {
        return SandBoxAuthorize.getPathStoreBookmark(path, key: key)
    }
    
    @discardableResult
    class func addBookmark(path:String, isDirectory:Bool) -> Bool {
        return SandBoxAuthorize.addBookmark(path, isDirectory: isDirectory)
    }
    
    class func authorize(path:String) {
        SandBoxAuthorize.authorizePath(path)
    }
    
    class func unauthorize(path:String) {
        SandBoxAuthorize.deauthorizePath(path)
    }
}
