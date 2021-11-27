//
//  String+bookmark.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

// MARK: - 文件路径授权 Method

public extension String {
    /// 是否是沙盒路径
    /// - Returns: 是沙盒路径返回true,否则返回False
    func isPublicAuthed() -> Bool {
        
        let productName = Bundle.name
        let supportPath = NSHomeDirectory().appendingFormat("/Library/Application Support/%@", productName)
        let moviePath = NSHomeDirectory().appending("/Movies")
        let arrPublic: Array = [moviePath,supportPath]
        
        for item in arrPublic {
            if self.contains(item) {
                return true
            }
        }
        return false
    }
    
    
    /// 存储路径的bookmark值到UserDefaults中
    /// - Returns: 保存是否成功，成功返回true
    func saveFileAccessAuthor() -> Bool {
        if self.isPublicAuthed() {
            return true
        }
        
        guard let data = try? URL.init(fileURLWithPath: self).bookmarkData(options: [.withSecurityScope],
                                                     includingResourceValuesForKeys: nil,
                                                     relativeTo: nil) else {
            return false
        }
        UserDefaults.standard.set(data, forKey: self)
        UserDefaults.standard.synchronize()
        return true
    }
    
    
    /// 获取UserDefaults中保存的bookmark，并对要访问的路径进行授权
    /// - Returns: 授权是否成功，成功返回true,否则返回false
    func getFileAccessAuthor() -> Bool {
        if self.isPublicAuthed() {
            return true
        }
        
        var isStale = false
        if let data = UserDefaults.standard.object(forKey: self) as? Data,
            let url = try? URL.init(resolvingBookmarkData: data, options: .withSecurityScope,
                                    relativeTo: nil,
                                    bookmarkDataIsStale: &isStale),
            url == URL.init(fileURLWithPath: self) {
            return url.startAccessingSecurityScopedResource()
        }
        
        return false
    }
}
