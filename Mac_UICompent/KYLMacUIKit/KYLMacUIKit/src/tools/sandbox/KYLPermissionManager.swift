//
//  KYLPermissionManager.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public class KYLPermissionManager {
    public let bookmarksManager: KYLBookmarksManager
    public lazy var openPanelDelegate: KYLOpenPanelDelegateType = KYLOpenPanelDelegate()
    public lazy var openPanel: NSOpenPanel = KYLOpenPanelBuilder().openPanel()
    public static let defaultManager = KYLPermissionManager()

    public func needsPermissionForFileAtURL(fileURL: URL) -> Bool {
        let reachable = try? fileURL.checkResourceIsReachable()
        let readable = FileManager.default.isReadableFile(atPath: fileURL.absoluteString)
        return reachable ?? false && !readable
    }

    public func askUserForSecurityScopeForFileAtURL(fileURL: URL) -> URL? {
        if !self.needsPermissionForFileAtURL(fileURL: fileURL) { return fileURL }
        let openPanel = self.openPanel
        if openPanel.directoryURL == nil {
            openPanel.directoryURL = fileURL.deletingLastPathComponent()
        }
        let openPanelDelegate = self.openPanelDelegate
        openPanelDelegate.fileURL = fileURL as NSURL
        openPanel.delegate = openPanelDelegate
        var securityScopedURL: URL?
        let closure: () -> Void = {
            NSApplication.shared.activate(ignoringOtherApps: true)
            if openPanel.runModal().rawValue == NSApplication.ModalResponse.OK.rawValue {
                securityScopedURL = openPanel.url as URL?
            }
            openPanel.delegate = nil
        }
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.sync(execute: closure)
        }
        if let pathforcatalog = securityScopedURL {
            self.bookmarksManager.saveSecurityScopedBookmarkForFileAtURL(securityScopedFileURL: pathforcatalog)
        }
        return securityScopedURL
    }

    public func accessSecurityScopedFileAtURL(fileURL: URL) -> Bool {
        let accessible = fileURL.startAccessingSecurityScopedResource()
        if accessible {
            return true
        } else {
            return false
        }
    }

    public func accessAndIfNeededAskUserForSecurityScopeForFileAtURL(fileURL: URL) -> Bool {
        if self.needsPermissionForFileAtURL(fileURL: fileURL) == false { return true }
        let bookmarkedURL = self.bookmarksManager.loadSecurityScopedURLForFileAtURL(fileURL: fileURL)
        let securityScopedURL = bookmarkedURL ?? self.askUserForSecurityScopeForFileAtURL(fileURL: fileURL)
        if securityScopedURL != nil {
            return self.accessSecurityScopedFileAtURL(fileURL: securityScopedURL!)
        }
        return false
    }

    public init(bookmarksManager: KYLBookmarksManager = KYLBookmarksManager()) {
        self.bookmarksManager = bookmarksManager
    }
}

#endif
