//
//  KYLTheme.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//


#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/**
 皮肤主题协议说明：
 
 其他所有主题都继承这个基础协议
 
 *框架是皮肤生效，不需要额外处理:
 
 - a `KYLLightTheme` (默认的macOS主题)
 - a `KYLDarkTheme` (dark macOS主题，使用' nsappearance enamevibrantdark ')
 - a `KYLSystemTheme` (动态解析为' LightTheme '或' DarkTheme
 取决于macOS首选项at **System Preferences > General > Appearance**)
 
 您可以选择是否使用这些，还可以实现您的自定义
 主题:
 
 - 实现符合这个协议和NSObject的原生' WSTheme '类
 - 使用'提供用户主题(' WSUserTheme ')  使用 `.theme` 格式的配置文件

 */

@objc(KYLTheme)
public protocol KYLTheme: NSObjectProtocol {
    // MARK: 必须实现的属性

    /// 主题唯一标识符
    var identifier: String { get }

    /// 主题名称
    var displayName: String { get }

    /// 主题名称简写
    var shortDisplayName: String { get }

    /// 是否是暗黑模式主题
    var isDarkTheme: Bool { get }

    // MARK: 可选方法和属性

    /// Optional:当主题未提供前景色时要使用的前景色。
    @objc optional var fallbackForegroundColor: NSColor? { get }

    /// Optional:当主题没有提供背景颜色(名称中包含“background”的颜色)时使用的背景颜色。
    @objc optional var fallbackBackgroundColor: NSColor? { get }

    /// Optional: 当主题没有提供渐变时，使用渐变。
    @objc optional var fallbackGradient: NSGradient? { get }

    /// Optional: 当主题不提供图片时，将在上使用。
    @objc optional var fallbackImage: NSImage? { get }
}

// MARK: -  扩展方法或属性 - public
public extension KYLTheme {
    /// 是否是浅色模式主题
    var isLightTheme: Bool {
        return !isDarkTheme
    }

    /// 是否是系统皮肤，如果是系统皮肤，则会根据系统偏好设置的皮肤模式（**System Preferences > General > Appearance**.），
    /// 自动切换为：`WSThemeManager.lightTheme` 或 `WSThemeManager.darkTheme`
    var isSystemTheme: Bool {
        return identifier == KYLSystemTheme.identifier
    }

    /// 是否是用户自定义主题
    var isUserTheme: Bool {
        return self is KYLUserTheme
    }

    /// 应用主题(使其成为当前主题)。
    func apply() {
        KYLThemeManager.shared.theme = self
    }

    /// 根据指定的key得到主题的资源， 支持这些类型：`NSColor`, `NSGradient`, `NSImage` and `NSString`.
    ///
    /// 这个函数需要被 `WSUserTheme` 覆写.
    ///
    /// - parameter key: A color name, gradient name, image name or a theme string
    ///
    /// - returns: 指定键的主题值。
    func themeAsset(_ key: String) -> Any? {
        //因为' WSTheme '是一个@objc协议，我们不能在协议上定义这个方法，
        //并且在这个扩展上提供一个默认的实现，加上另一个在' WSUserTheme '上的实现。这是一种解决方法。
        if let userTheme = self as? KYLUserTheme {
            return userTheme.themeAsset(key)
        }

        let selector = NSSelectorFromString(key)
        if let theme = self as? NSObject,
            theme.responds(to: selector) {
            return theme.perform(selector).takeUnretainedValue()
        }

        return nil
    }

    /// 检查是否为给定的键提供了主题资源。
    ///
    /// 这个函数被 `WSUserTheme` 覆写.
    ///
    ///
    /// - parameter key: 颜色名称、渐变名称、图像名称或主题字符串
    ///
    /// - returns: 如果提供了资源则返回true, 否则返回 false
    func hasThemeAsset(_ key: String) -> Bool {
        return themeAsset(key) != nil
    }

    /// 当主题未指定“fallbackForegroundColor”时，在回退情况下使用的默认前景色。
    var defaultFallbackForegroundColor: NSColor {
        return isLightTheme ? NSColor.black : NSColor.white
    }

    /// 当主题未指定“fallbackbackcolor”时，在回退情况下使用的默认背景颜色(背景颜色是一个名称中包含“background”的颜色方法)。
    var defaultFallbackBackgroundColor: NSColor {
        return isLightTheme ? NSColor.white : NSColor.black
    }

    /// 当主题没有指定' fallbackForegroundColor '时，在回退情况下使用默认渐变。
    var defaultFallbackGradient: NSGradient? {
        return NSGradient(starting: defaultFallbackBackgroundColor, ending: defaultFallbackBackgroundColor)
    }

    /// 当主题未指定图像时，在回退情况下使用的默认图像。
    var defaultFallbackImage: NSImage {
        return NSImage(size: NSSize.zero)
    }

    /// 有效主题，如果它代表了系统主题，就可能与它本身不同, 如果在系统偏好设置里面设置（respecting **System Preferences > General > Appearance**）
    /// (in that case it will be either `WSThemeManager.lightTheme` or `WSThemeManager.darkTheme`).
    ///
    var effectiveTheme: KYLTheme {
        if isSystemTheme {
            return isDarkTheme ? KYLThemeManager.darkTheme : KYLThemeManager.lightTheme
        } else {
            return self
        }
    }

    /// 主题描述，用于打印信息
    func themeDescription(_ theme: KYLTheme) -> String {
        return "\"\(displayName)\" [\(identifier)]\(isDarkTheme ? " (Dark)" : "")"
    }
}

/// 全局函数 检测两个主题是否相同
func == (lhs: KYLTheme, rhs: KYLTheme) -> Bool {
    return lhs.identifier == rhs.identifier
}

/// 全局函数 检测两个主题是否不相同
func != (lhs: KYLTheme, rhs: KYLTheme) -> Bool {
    return lhs.identifier != rhs.identifier
}

#endif
