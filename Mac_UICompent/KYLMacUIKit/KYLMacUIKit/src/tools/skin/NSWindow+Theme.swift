//
//  NSWindow+Theme.swift
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
 `NSWindow` ThemeKit extension.
 */
public extension NSWindow {

    // MARK: -
    // MARK: 属性

    /// 任何窗口特定的主题。
    ///
    /// 这通常是' nil '，这意味着将使用当前的全局主题。请注意,当使用窗口特定主题,只有相关的“NSAppearance”将自动设置。所有主题意识到资产
    /// (“WSThemeColor”、“WSThemeGradient”和“WSThemeImage”)应该调用方法返回一个解决颜色相反
    /// (这意味着它们与主题变化不改变,你需要观察主题手动更改,并设置颜色之后):
    ///
    /// - `KYLThemeColor.color(for view:, selector:)`
    /// - `KYLThemeGradient.gradient(for view:, selector:)`
    /// - `KYLThemeImage.image(for view:, selector:)`
    ///
    /// 另外，请注意system overoverride colors (' NSColor.* ')将始终使用全局主题。
    @objc var windowTheme: KYLTheme? {
        get {
            return objc_getAssociatedObject(self, &themeAssociationKey) as? KYLTheme
        }
        set(newValue) {
            objc_setAssociatedObject(self, &themeAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            theme()
        }
    }

    /// 返回当前有效的主题(只读)。
    @objc var windowEffectiveTheme: KYLTheme {
        return windowTheme ?? KYLThemeManager.shared.effectiveTheme
    }

    /// 返回当前有效外观(只读)。
    @objc var windowEffectiveThemeAppearance: NSAppearance? {
        return windowEffectiveTheme.isLightTheme ? KYLThemeManager.shared.lightAppearance : KYLThemeManager.shared.darkAppearance
    }

    // MARK: -
    // MARK: Theming

    /// 主题窗口，如果需要。
    @objc func theme() {
        if currentTheme == nil || currentTheme! != windowEffectiveTheme {
            // Keep record of currently applied theme
            currentTheme = windowEffectiveTheme

            // Change window tab bar appearance
            themeTabBar()

            // Change window appearance
            themeWindow()
        }
    }

    /// 主题窗口，如果符合WSThemeManager.windowThemePolicy(如果需要的话)。
    @objc func themeIfCompliantWithWindowThemePolicy() {
        if isCompliantWithWindowThemePolicy() {
            theme()
        }
    }

    /// 所有窗口都应用主题，根据WSThemeManager.windowThemePolicy 策略(如果需要的话).
    @objc static func themeAllWindows() {
        for window in windowsCompliantWithWindowThemePolicy() {
            window.theme()
        }
    }

    // MARK: - Private
    // MARK: - Window theme policy compliance

    /// 检测窗口是否符合WSThemeManager.windowThemePolicy. 策略
    @objc internal func isCompliantWithWindowThemePolicy() -> Bool {
        switch KYLThemeManager.shared.windowThemePolicy {

        case .themeAllWindows:
            return !self.isExcludedFromTheming

        case .themeSomeWindows(let windowClasses):
            for windowClass in windowClasses where self.classForCoder === windowClass.self {
                return true
            }
            return false

        case .doNotThemeSomeWindows(let windowClasses):
            for windowClass in windowClasses where self.classForCoder === windowClass.self {
                return false
            }
            return true

        case .doNotThemeWindows:
            return false
        }
    }

    /// 所有符合ThemeManager.windowThemePolicy.策略的窗口列表
    @objc internal static func windowsCompliantWithWindowThemePolicy() -> [NSWindow] {
        var windows = [NSWindow]()

        switch KYLThemeManager.shared.windowThemePolicy {

        case .themeAllWindows:
            windows = NSApplication.shared.windows

        case .themeSomeWindows:
            windows = NSApplication.shared.windows.filter({ (window) -> Bool in
                return window.isCompliantWithWindowThemePolicy()
            })

        case .doNotThemeSomeWindows:
            windows = NSApplication.shared.windows.filter({ (window) -> Bool in
                return window.isCompliantWithWindowThemePolicy()
            })

        case .doNotThemeWindows:
            break
        }

        return windows
    }

    /// 如果当前窗口被排除在主题之外，则返回
    @objc internal var isExcludedFromTheming: Bool {
        return self is NSPanel
    }

    // MARK: - Window screenshots

    /// 把窗口截图，得到一张截图
    @objc internal func takeScreenshot() -> NSImage? {
        guard let cgImage = CGWindowListCreateImage(CGRect.null, .optionIncludingWindow, CGWindowID(windowNumber), .boundsIgnoreFraming) else {
            return nil
        }

        let image = NSImage(cgImage: cgImage, size: frame.size)
        image.cacheMode = NSImage.CacheMode.never
        image.size = frame.size
        return image
    }

    /// 创建一个带有当前窗口截图的窗口。
    @objc internal func makeScreenshotWindow() -> NSWindow {
        // Create "image-window"
        let window = NSWindow(contentRect: frame, styleMask: NSWindow.StyleMask.borderless, backing: NSWindow.BackingStoreType.buffered, defer: true)
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.ignoresMouseEvents = true
        window.collectionBehavior = NSWindow.CollectionBehavior.stationary
        window.titlebarAppearsTransparent = true

        // Take window screenshot
        if let screenshot = takeScreenshot(),
            let parentView = window.contentView {
            // Add image view
            let imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: screenshot.size.width, height: screenshot.size.height))
            imageView.image = screenshot
            parentView.addSubview(imageView)
        }

        return window
    }

    // MARK: - Caching

    /// 当前应用的窗口主题。
    private var currentTheme: KYLTheme? {
        get {
            return objc_getAssociatedObject(self, &currentThemeAssociationKey) as? KYLTheme
        }
        set(newValue) {
            objc_setAssociatedObject(self, &currentThemeAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            purgeTheme()
        }
    }

    private func purgeTheme() {
        tabBar = nil
    }

    // MARK: - Tab bar view

    /// Returns the tab bar view.
    private var tabBar: NSView? {
        get {
            // If cached, return it
            if let storedTabBar = objc_getAssociatedObject(self, &tabbarAssociationKey) as? NSView {
                return storedTabBar
            }

            var _tabBar: NSView?

            // Search on titlebar accessory views if supported (will fail if tab bar is hidden)
            let themeFrame = self.contentView?.superview
            if themeFrame?.responds(to: #selector(getter: titlebarAccessoryViewControllers)) ?? false {
                for controller: NSTitlebarAccessoryViewController in self.titlebarAccessoryViewControllers {
                    if let possibleTabBar = controller.view.deepSubview(withClassName: "NSTabBar") {
                        _tabBar = possibleTabBar
                        break
                    }
                }
            }

            // Search down the title bar view
            if _tabBar == nil {
                let titlebarContainerView = themeFrame?.deepSubview(withClassName: "NSTitlebarContainerView")
                let titlebarView = titlebarContainerView?.deepSubview(withClassName: "NSTitlebarView")
                _tabBar = titlebarView?.deepSubview(withClassName: "NSTabBar")
            }

            // Remember it
            if _tabBar != nil {
                objc_setAssociatedObject(self, &tabbarAssociationKey, _tabBar, .OBJC_ASSOCIATION_RETAIN)
            }

            return _tabBar
        }

        set(newValue) {
            objc_setAssociatedObject(self, &tabbarAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// Check if tab bar is visbile.
    private var isTabBarVisible: Bool {
        return tabBar?.superview != nil
    }

    /// 更新窗口外观(如果需要)。
    private func themeWindow() {
        if appearance != windowEffectiveThemeAppearance {
            // Change window appearance
            appearance = windowEffectiveThemeAppearance

            // 无效的阴影，因为有时它是不正确的绘制或丢失
            invalidateShadow()

            if #available(macOS 10.12, *) {
                // 10.12以上系统可以正常刷新
            } else {
                // 低版本系统需要一个技巧来强制更新视图层次结构中的所有CALayers
                self.titlebarAppearsTransparent = !self.titlebarAppearsTransparent
                DispatchQueue.main.async {
                    self.titlebarAppearsTransparent = !self.titlebarAppearsTransparent
                }
            }
        }
    }

    /// Update tab bar appearance (if needed).
    private func themeTabBar() {
        guard let _tabBar = tabBar,
            isTabBarVisible && _tabBar.appearance != windowEffectiveThemeAppearance else {
            return
        }

        // Change tabbar appearance
        _tabBar.appearance = windowEffectiveThemeAppearance

        // Refresh its subviews
        for tabBarSubview: NSView in _tabBar.subviews {
            tabBarSubview.needsDisplay = true
        }

        // Also, make sure tabbar is on top (this also properly refreshes it)
        if let tabbarSuperview = _tabBar.superview {
            tabbarSuperview.addSubview(_tabBar)
        }
    }

    // MARK: - Title bar view

    /// Returns the title bar view.
    private var titlebarView: NSView? {
        let themeFrame = self.contentView?.superview
        let titlebarContainerView = themeFrame?.deepSubview(withClassName: "NSTitlebarContainerView")
        return titlebarContainerView?.deepSubview(withClassName: "NSTitlebarView")
    }
}

private var currentThemeAssociationKey: UInt8 = 0
private var themeAssociationKey: UInt8 = 1
private var tabbarAssociationKey: UInt8 = 2


//fileprivate extension NSView {
//
//    /// 返回匹配指定类的第一个子视图。
//    @objc func deepSubview(withClassName className: String) -> NSView? {
//
//        // 搜索级别以下(查看子视图)
//        for subview: NSView in self.subviews where subview.className == className {
//            return subview
//        }
//
//        // 搜索更深
//        for subview: NSView in self.subviews {
//            if let foundView = subview.deepSubview(withClassName: className) {
//                return foundView
//            }
//        }
//
//        return nil
//    }
//
//}

#endif
