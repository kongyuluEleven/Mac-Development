//
//  NotificationName+Theme.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

//MARK: - 主题变化通知
public extension Notification.Name {

    /// 当当前主题即将更改时发送的通知。
    static let willChangeTheme = Notification.Name("KYLUIKitWillChangeThemeNotification")

    /// 当当前主题改变时发送的通知。
    static let didChangeTheme = Notification.Name("KYLUIKitDidChangeThemeNotification")

    /// 当系统主题改变时发送的ThemeKit通知(系统首选项>一般>外观)。
    static let didChangeSystemTheme = Notification.Name("KYLUIKitDidChangeSystemThemeNotification")

    /// 当系统对暗模式的偏好改变时发送的系统通知的方便性属性。
    static let didChangeAppleInterfaceTheme = Notification.Name("AppleInterfaceThemeChangedNotification")
}

#endif
