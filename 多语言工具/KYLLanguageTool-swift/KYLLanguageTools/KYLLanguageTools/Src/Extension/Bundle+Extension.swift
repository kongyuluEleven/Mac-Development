//
//  Bundle+Extension.swift
//  WSUIKit
//
//  Created by kongyulu on 2021/1/6.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit)
import AppKit
#endif

// MARK: - 获取App版本信息
extension Bundle {
    
    /// App名称
    public var appName: String {
        string(forInfoDictionaryKey: "CFBundleDisplayName")
            ?? string(forInfoDictionaryKey: "CFBundleName")
            ?? string(forInfoDictionaryKey: "CFBundleExecutable")
            ?? "<Unknown App Name>"
    }

    private func string(forInfoDictionaryKey key: String) -> String? {
        // `object(forInfoDictionaryKey:)` prefers localized info dictionary over the regular one automatically
        object(forInfoDictionaryKey: key) as? String
    }
    
    
    /// app的 bundleid 唯一标识符，如：com.wondershare.filmora
    public static let id = Bundle.main.bundleIdentifier ?? "<Unknown App bundleIdentifier>"
    
    /// app 显示的名称
    public static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? "<Unknown App CFBundleName>"
    
    /// app主版本号
    public static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ??  "<Unknown App BundleShortVersion>"
    
    /// app副版本号
    public static let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ??  "<Unknown App BundleVersion>"
    
    /// app完整版本号, 主版本号 + 副版本号
    public static let versionWithBuild = "\(version) (\(build))"
    
    /// app应用的icns图标
    public static let icon = NSApp.applicationIconImage ?? nil
    
    /// app bundle路径
    public static let url = Bundle.main.bundleURL

}


// MARK: - 运行信息
public extension Bundle {
    
    /// 记录app是否是首次运行
    static let isFirstLaunch: Bool = {
        let key = "WS_hasLaunched"

        if UserDefaults.standard.bool(forKey: key) {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: key)
            return true
        }
    }()
    
    
    static func runOnceShouldRun(identifier: String) -> Bool {
        let key = "WS_App_runOnce__\(identifier)"

        guard !UserDefaults.standard.bool(forKey: key) else {
            return false
        }

        UserDefaults.standard.set(true, forKey: key)
        return true
    }

    /// 只运行一次闭包，即使是在重新启动应用程序之间。
    static func runOnce(identifier: String, _ execute: () -> Void) {
        guard runOnceShouldRun(identifier: identifier) else {
            return
        }

        execute()
    }
}


#endif
