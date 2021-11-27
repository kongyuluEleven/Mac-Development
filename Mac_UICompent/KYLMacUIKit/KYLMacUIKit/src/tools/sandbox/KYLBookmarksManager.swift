//
//  KYLBookmarksManager.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//


#if canImport(Foundation)
import Foundation

enum KYLFileerrortype {
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
    case filesize
    case sequrityscoped
    case createsshdirectory
}

// Protocol for reporting file errors
protocol KYLFileerror: AnyObject {
    func errormessage(errorstr: String, errortype: KYLFileerrortype)
}

protocol KYLFileErrors {
    var errorDelegate: KYLFileerror? { get }
}

extension KYLFileErrors {
    func error(error: String, errortype: KYLFileerrortype) {
        self.errorDelegate?.errormessage(errorstr: error, errortype: errortype)
    }
}

protocol KYLErrorMessage {
    func errordescription(errortype: KYLFileerrortype) -> String
}

extension KYLErrorMessage {
    func errordescription(errortype: KYLFileerrortype) -> String {
        switch errortype {
        case .writelogfile:
            return "Could not write to logfile"
        case .profilecreatedirectory:
            return "Could not create profile directory"
        case .profiledeletedirectory:
            return "Could not delete profile directory"
        case .filesize:
            return "Filesize of logfile is getting bigger"
        case .sequrityscoped:
            return "Sequrityscoped error"
        case .createsshdirectory:
            return "Error creating ssh directory"
        }
    }
}


public class KYLBookmarksManager: KYLFileErrors {
    
    
    public let userDefaults: UserDefaults
    public static let defaultManager = KYLBookmarksManager()


    public func clearSecurityScopedBookmarks() {
        self.securityScopedBookmarksByFilePath = [:]
    }

    public func fileURLFromSecurityScopedBookmark(bookmark: NSData) -> URL? {
        let options: NSURL.BookmarkResolutionOptions = [.withSecurityScope, .withoutUI]
        var stale: ObjCBool = false
        if let fileURL = try? NSURL(resolvingBookmarkData: bookmark as Data, options: options, relativeTo: nil, bookmarkDataIsStale: &stale) {
            return fileURL as URL
        } else {
            return nil
        }
    }

    public func loadSecurityScopedURLForFileAtURL(fileURL: URL) -> URL? {
        if let bookmark = self.loadSecurityScopedBookmarkForFileAtURL(fileURL: fileURL) {
            return self.fileURLFromSecurityScopedBookmark(bookmark: bookmark)
        }
        return nil
    }

    public func loadSecurityScopedBookmarkForFileAtURL(fileURL: URL) -> NSData? {
        var resolvedFileURL: URL?
        resolvedFileURL = fileURL.standardizedFileURL.resolvingSymlinksInPath()
        let bookmarksByFilePath = self.securityScopedBookmarksByFilePath
        var securityScopedBookmark = bookmarksByFilePath[resolvedFileURL!.path]
        while securityScopedBookmark == nil, resolvedFileURL!.pathComponents.count > 1 {
            resolvedFileURL = resolvedFileURL?.deletingLastPathComponent()
            securityScopedBookmark = bookmarksByFilePath[resolvedFileURL!.path]
        }
        return securityScopedBookmark
    }

    public func securityScopedBookmarkForFileAtURL(fileURL: URL) -> NSData? {
        do {
            let bookmark = try fileURL.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            return bookmark as NSData?
        } catch let e {
            let error = e as NSError
            self.error(error: error.description, errortype: .sequrityscoped)
            return nil
        }
    }

    public func saveSecurityScopedBookmarkForFileAtURL(securityScopedFileURL: URL) {
        if let bookmark = self.securityScopedBookmarkForFileAtURL(fileURL: securityScopedFileURL) {
            self.saveSecurityScopedBookmark(securityScopedBookmark: bookmark)
        }
    }

    public func saveSecurityScopedBookmark(securityScopedBookmark: NSData) {
        if let fileURL = self.fileURLFromSecurityScopedBookmark(bookmark: securityScopedBookmark) {
            var savesecurityScopedBookmarks = self.securityScopedBookmarksByFilePath
            savesecurityScopedBookmarks[fileURL.path] = securityScopedBookmark
            self.securityScopedBookmarksByFilePath = savesecurityScopedBookmarks
        }
    }

    public init() {
        self.userDefaults = UserDefaults.standard
    }
    
    var errorDelegate: KYLFileerror?
    
    private static let userDefaultsBookmarksKey = "com.wondershare.kyl"

    private var securityScopedBookmarksByFilePath: [String: NSData] {
        get {
            let bookmarksByFilePath = self.userDefaults.dictionary(forKey: KYLBookmarksManager.userDefaultsBookmarksKey) as? [String: NSData]
            return bookmarksByFilePath ?? [:]
        }
        set {
            self.userDefaults.set(newValue, forKey: KYLBookmarksManager.userDefaultsBookmarksKey)
        }
    }
}


#endif
