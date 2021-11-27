//
//  Bundle+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit)
import AppKit
#endif

// MARK: - 获取App版本信息
public extension Bundle {
    
    /// App名称
    var appName: String {
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
    static let id = Bundle.main.bundleIdentifier ?? "<Unknown App bundleIdentifier>"
    
    /// app 显示的名称
    static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? "<Unknown App CFBundleName>"
    
    /// app主版本号
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ??  "<Unknown App BundleShortVersion>"
    
    /// app副版本号
    static let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ??  "<Unknown App BundleVersion>"
    
    /// app完整版本号, 主版本号 + 副版本号
    static let versionWithBuild = "\(version) (\(build))"
    
    /// app应用的icns图标
    static let icon = NSApp.applicationIconImage ?? nil
    
    /// app bundle路径
    static let url = Bundle.main.bundleURL

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


// MARK: - Mac电脑信息
extension Bundle {
    private static var macSerialNumber: String?

    // 得到mac电脑的序列号
    static func computemacSerialNumber() -> String {
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                                       IOServiceMatching("IOPlatformExpertDevice"))
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
                                                                     kIOPlatformSerialNumberKey as CFString?,
                                                                     kCFAllocatorDefault, 0)
        IOObjectRelease(platformExpert)
        return (serialNumberAsCFString?.takeRetainedValue() as? String) ?? "C00123456789"
    }

    // 返回mac电脑的序列号 字符串
    public static func getMacSerialNumber() -> String? {
        guard let _ = macSerialNumber else {
            macSerialNumber = self.computemacSerialNumber()
            return macSerialNumber!
        }
        return macSerialNumber
    }
}


#endif
