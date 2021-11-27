//
//  Notification+name.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

//MARK: - 换肤功能通知
public extension Notification.Name {

    /// 当当前皮肤即将更改时发送的通知
    static let willChangeSkin = Notification.Name("KYLMacUIKitWillChangeSkinNotification")

    /// 当前皮肤已经更改时发送的通知
    static let didChangeSkin = Notification.Name("KYLMacUIKitDidChangeSkinNotification")

    /// 当前系统皮肤主题已经修改发送通知 (System Preference > General > Appearance).
    static let didChangeSystemSkin = Notification.Name("KYLMacUIKitDidChangeSystemSkinNotification")

    /// 当系统对暗模式的偏好改变时发送的系统通知的方便性属性。
    static let didChangeAppleInterfaceSkin = Notification.Name("KYLMacAppleInterfaceSkinChangedNotification")
}

#endif
