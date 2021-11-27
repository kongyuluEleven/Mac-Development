//
//  KYLSequrityscopedURLs.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/*
 
 沙盒下对文件路径授权是使用如下：
 
 _ = KYLSequrityscopedURLs(path: restorePath)
 
 这样调用后，会自动对文件路径授权，保存bookmark值，如果访问时没有授权，会调用授权对话窗口重新授权
 授权的作用主要是 ： 苹果的授权只在当前内存中可以有效，当再次启动app时，之前的授权权限会回收掉，如果下次
 想直接使用，需要在用户授权的时候，一般是通过NSOpenPanel窗口选择路径就授权了，需要在这个时候保存URL的bookmark标签
 返回通过bookmark标签得到一个授权后的新URL，然后再用这个URL去调用startAccessingSecurityScopedResource()
 才可以得到真正的非沙盒路径授权访问。
 
 */

struct KYLSequrityscopedURLs {
    var success: Bool = false
    var urlpath: URL?

    private func accessFiles(fileURL: URL) -> Bool {
        let permissionmanager = KYLPermissionManager(bookmarksManager: KYLBookmarksManager.defaultManager)
        let permission = permissionmanager.accessAndIfNeededAskUserForSecurityScopeForFileAtURL(fileURL: fileURL)
        let success = FileManager.default.isReadableFile(atPath: fileURL.path)
        return permission && success
    }

    init(path: String) {
        self.urlpath = URL(fileURLWithPath: path)
        guard self.urlpath != nil else { return }
        self.success = self.accessFiles(fileURL: self.urlpath!)
    }
}


#endif
