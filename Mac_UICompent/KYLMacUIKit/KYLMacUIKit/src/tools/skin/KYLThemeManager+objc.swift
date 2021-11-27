//
//  KYLThemeManager+objc.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public extension KYLThemeManager {

    /// 窗口主题策略定义哪些窗口应该被自动主题化(仅限Objective-C变体)。
    @objc(KYLThemeManagerWindowThemePolicy)
    enum KYLThemeManagerWindowThemePolicy: Int {
        /// 主题所有的应用程序窗口(默认)。
        case themeAllWindows
        /// 只有指定类的主题窗口。
        case themeSomeWindows
        /// 不要对指定类的窗口进行主题化。
        case doNotThemeSomeWindows
        /// 不要给任何窗口设置主题。
        case doNotThemeWindows
    }

    /// Current window theme policy.
    @objc(windowThemePolicy)
    var objc_windowThemePolicy: KYLThemeManagerWindowThemePolicy {
        get {
            switch windowThemePolicy {

            case .themeAllWindows:
                return .themeAllWindows

            case .themeSomeWindows:
                return .themeSomeWindows

            case .doNotThemeSomeWindows:
                return .doNotThemeSomeWindows

            case .doNotThemeWindows:
                return .doNotThemeWindows
            }
        }
        set(value) {
            switch value {
            case .themeAllWindows:
                windowThemePolicy = .themeAllWindows
            case .themeSomeWindows:
                windowThemePolicy = .themeSomeWindows(windowClasses: themableWindowClasses ?? [])
            case .doNotThemeSomeWindows:
                windowThemePolicy = .doNotThemeSomeWindows(windowClasses: notThemableWindowClasses ?? [])
            case .doNotThemeWindows:
                windowThemePolicy = .doNotThemeWindows
            }
        }
    }

    /// Windows classes to be excluded from theming with the `KYLThemeManagerWindowThemePolicyDoNotThemeSomeWindows`.
    @objc(notThemableWindowClasses)
    var notThemableWindowClasses: [AnyClass]? {
        get {
            switch windowThemePolicy {

            case .themeAllWindows:
                return nil

            case .themeSomeWindows:
                return []

            case .doNotThemeSomeWindows(let windowClasses):
                return windowClasses

            case .doNotThemeWindows:
                return []
            }
        }
        set(value) {
            if let newValue = value {
                if newValue.count > 0 {
                    // theme some if value > 0
                    windowThemePolicy = .doNotThemeSomeWindows(windowClasses: newValue)
                } else {
                    // theme none if value is 0
                    windowThemePolicy = .doNotThemeWindows
                }
            } else {
                // theme all windows if value is nil
                windowThemePolicy = .themeAllWindows
            }
        }
    }

    /// Windows classes to be themed with the `KYLThemeManagerWindowThemePolicyThemeSomeWindows`.
    @objc(themableWindowClasses)
    var themableWindowClasses: [AnyClass]? {
        get {
            switch windowThemePolicy {

            case .themeAllWindows:
                return nil

            case .themeSomeWindows(let windowClasses):
                return windowClasses

            case .doNotThemeSomeWindows:
                return []

            case .doNotThemeWindows:
                return []
            }
        }
        set(value) {
            if let newValue = value {
                if newValue.count > 0 {
                    // theme some if value > 0
                    windowThemePolicy = .themeSomeWindows(windowClasses: newValue)
                } else {
                    // theme none if value is 0
                    windowThemePolicy = .doNotThemeWindows
                }
            } else {
                // theme all windows if value is nil
                windowThemePolicy = .themeAllWindows
            }
        }
    }

}

#endif

