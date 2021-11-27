//
//  KYLSystemTheme.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

/// 系统皮肤
///
/// 系统皮肤主题将会被动态解析为下面两者之一： 浅色皮肤 `KYLThemeManager.lightTheme` 或 暗黑皮肤 `KYLThemeManager.darkTheme`,
/// 具体是哪种取决于系统偏好设置： **System Preferences > General > Appearance**.
@objc(KYLSystemTheme)
public class KYLSystemTheme: NSObject, KYLTheme {

    //MARK: -----------------public-------------------
    /// 唯一标识符 (static).
    @objc public static var identifier: String = "com.wondershare.WSUIKit.WSSystemTheme"

    /// 唯一标识符
    public var identifier: String = KYLSystemTheme.identifier

    /// 主题名称
    public var displayName: String {
        let systemVersion = OperatingSystemVersion(majorVersion: 10, minorVersion: 12, patchVersion: 0)
        return ProcessInfo.processInfo.isOperatingSystemAtLeast(systemVersion) ? "macOS Theme" : "OS X Theme"
    }

    /// 主题名称缩写
    public var shortDisplayName: String {
        return displayName
    }

    /// 是否是暗黑模式
    public var isDarkTheme: Bool = KYLSystemTheme.isAppleInterfaceThemeDark

    /// 检查苹果用户界面主题是否设置为黑色, as set on **System Preferences > General > Appearance**.
    @objc public static var isAppleInterfaceThemeDark: Bool = KYLSystemTheme.isAppleInterfaceThemeDarkOnUserDefaults()

    /// 主题描述，用于打印信息
    override public var description: String {
        return "<\(KYLSystemTheme.self): \(themeDescription(self))>"
    }
    
    
    //MARK: -----------------private-------------------
    /// 不能在外部通过init()创建对象，使用这种方式获取：`WSThemeManager.systemTheme`
    internal override init() {
        super.init()

        // 观察macOS苹果界面主题
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(appleInterfaceThemeDidChange(_:)), name: .didChangeAppleInterfaceTheme, object: nil)
    }

    /// 苹果用户界面主题改变了。
    @objc func appleInterfaceThemeDidChange(_ notification: Notification) {
        isDarkTheme = KYLSystemTheme.isAppleInterfaceThemeDarkOnUserDefaults()
        KYLSystemTheme.isAppleInterfaceThemeDark = isDarkTheme
        NotificationCenter.default.post(name: .didChangeSystemTheme, object: nil)
    }

    /// 从用户默认值中读取苹果界面主题首选项。
    private static func isAppleInterfaceThemeDarkOnUserDefaults() -> Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") != nil
    }

    
}

#endif
