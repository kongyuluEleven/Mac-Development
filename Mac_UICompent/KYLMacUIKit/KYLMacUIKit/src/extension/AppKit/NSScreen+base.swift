//
//  NSScreen+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit



extension NSScreen: Identifiable {
    public var id: CGDirectDisplayID {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
    }
}

public extension NSScreen {
    static func from(cgDirectDisplayID id: CGDirectDisplayID) -> NSScreen? {
        screens.first { $0.id == id }
    }

    /// 获取包含菜单栏并原点为(0,0)的屏幕。
    static var primary: NSScreen? { screens.first }

    /// 如果你存储了一个对' NSScreen '实例的引用，因为它可能已经被断开连接，这可能会很有用。
    var isConnected: Bool {
        Self.screens.contains { $0 == self }
    }

    /// 如果当前屏幕未连接，则获取主屏幕。
    var withFallbackToMain: NSScreen? { isConnected ? self : .main }

    /// 屏幕是否显示状态栏。
    /// 如果状态栏设置为自动显示/隐藏，则返回' false '，因为它不会占用任何屏幕空间。
    var hasStatusBar: Bool {
        // 当' screensHaveSeparateSpaces == true '时，菜单栏会显示在所有屏幕上。
        !NSStatusBar.isAutomaticallyToggled && (self == .primary || Self.screensHaveSeparateSpaces)
    }

    /// 获取屏幕实际可见部分的框架。这意味着在dock下面，
    /// 但是如果有一个状态栏的话，*而不是*在状态栏下面。这是不同的。这也包括状态栏下的空间。
    var visibleFrameWithoutStatusBar: CGRect {
        var screenFrame = frame

        // 如果窗口在主界面且状态栏永久可见，或者在辅助界面且辅助界面被设置为显示状态栏，则说明状态栏。
        if hasStatusBar {
            screenFrame.size.height -= NSStatusBar.system.thickness
        }

        return screenFrame
    }
}


public struct Display: Hashable, Codable, Identifiable {

    /// 主要的显示。
    static let main = Self(id: CGMainDisplayID())

    /// 所有的显示。
    static var all: [Self] {
        NSScreen.screens.map { self.init(screen: $0) }
    }

    /// 显示的ID。
    public let id: CGDirectDisplayID

    /// “NSScreen”用于显示。
    var screen: NSScreen? { NSScreen.from(cgDirectDisplayID: id) }

    /// 显示的本地化名称。
    var localizedName: String {
        if #available(OSX 10.15, *) {
            return screen?.localizedName ?? "<Unknown name>"
        } else {
            // Fallback on earlier versions
            return "<Unknown name>"
        }
    }

    /// 显示器是否连接。
    var isConnected: Bool { screen?.isConnected ?? false }

    /// 如果当前显示器未连接，则获取主显示器。
    var withFallbackToMain: Self { isConnected ? self : .main }

    init(id: CGDirectDisplayID) {
        self.id = id
    }

    init(screen: NSScreen) {
        self.id = screen.id
    }
}

#endif
