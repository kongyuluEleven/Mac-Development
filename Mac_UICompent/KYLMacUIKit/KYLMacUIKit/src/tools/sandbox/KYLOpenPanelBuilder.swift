//
//  KYLOpenPanelBuilder.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//


#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public protocol KYLOpenPanelDelegateType: AnyObject, NSOpenSavePanelDelegate {
    var fileURL: NSURL! { get set }
}

public class KYLOpenPanelDelegate: NSObject, KYLOpenPanelDelegateType {
    public var fileURL: NSURL!

    public func panel(sender _: AnyObject, shouldEnableURL url: NSURL) -> Bool {
        let lhsComponents = self.fileURL.pathComponents!
        let rhsComponents = url.pathComponents!
        if lhsComponents.count >= rhsComponents.count {
            let count = rhsComponents.count
            return lhsComponents[0 ..< count] == rhsComponents[0 ..< count]
        }
        return false
    }
}

public class KYLOpenPanelBuilder {
    
    public let title: String
    public let message: String
    public let prompt: String
    var userHomeDirectoryPath: URL {
        let pw = getpwuid(getuid())
        if let homeptr = pw?.pointee.pw_dir {
            let homePath = FileManager.default.string(withFileSystemRepresentation: homeptr, length: Int(strlen(homeptr)))
            return URL(string: homePath) ?? URL(string: "")!
        }
        return URL(string: "")!
    }

    init(applicationName: String? = nil) {
        self.title = KYLOpenPanelBuilder.defaultTitle()
        self.message = KYLOpenPanelBuilder.defaultMessage(applicationName: applicationName)
        self.prompt = KYLOpenPanelBuilder.defaultPrompt()
    }

    init(title: String, message: String, prompt: String) {
        self.title = title
        self.message = message
        self.prompt = prompt
    }

    public func openPanel() -> NSOpenPanel {
        var openPanel: NSOpenPanel!
        let closure: () -> Void = {
            openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = true
            openPanel.canCreateDirectories = false
            openPanel.isExtensionHidden = false
            openPanel.showsHiddenFiles = false
            openPanel.title = self.title
            openPanel.message = self.message
            openPanel.prompt = self.prompt
            openPanel.directoryURL = self.userHomeDirectoryPath
        }
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.sync(execute: closure)
        }
        return openPanel
    }

    public static func applicationName() -> String {
        let mainBundle = Bundle.main
        if let displayName = mainBundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return displayName
        }
        if let bundleName = mainBundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }
        return "Current App"
    }

    private static func defaultTitle() -> String {
        return "Access permissions required"
    }

    private static func defaultMessage(applicationName: String?) -> String {
        let formatString = "Please allow '%@' to access this file or folder to continue."
        let formatArgument = applicationName ?? KYLOpenPanelBuilder.applicationName()
        return String(format: formatString, formatArgument)
    }

    private static func defaultPrompt() -> String {
        return "Allow"
    }
}

#endif
