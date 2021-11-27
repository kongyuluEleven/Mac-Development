//
//  KYLThemeManager.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//


#if canImport(Foundation)
import Foundation

#if !os(watchOS) && !os(Linux) && canImport(QuartzCore)
import QuartzCore
#endif

#if canImport(AppKit)
import AppKit
#endif

/**
 使用' WSThemeManager '单例来执行全应用范围的主题化相关操作，
 如:
 
 - 获取有关当前主题/外观的信息
 - 更改当前的“theme”(也可以从“NSUserDefaults”更改)
 - 列出可用的主题
 - 定义“皮肤”行为
 
 */
@objc(KYLThemeManager)
public class KYLThemeManager: NSObject {
    
    public enum WindowThemePolicy {
        /// 主题所有的应用程序窗口(默认)。
        case themeAllWindows
        /// 只有指定类的主题窗口。
        case themeSomeWindows(windowClasses: [AnyClass])
        /// 不要对指定类的窗口进行主题化。
        case doNotThemeSomeWindows(windowClasses: [AnyClass])
        /// 不要给任何窗口设置主题。
        case doNotThemeWindows
    }

    /// ThemeManager shared manager.
    @objc(sharedManager)
    public static let shared = KYLThemeManager()
    private var obj: NSObjectProtocol?

    // MARK: -
    // MARK: Initialization & Cleanup

    private override init() {
        super.init()

        isEnabled = true
    }

    deinit {
        isEnabled = false
    }

    
    // MARK: -
    // MARK: ------------------ public 接口 ---------------------

    /// 当前窗口主题策略。
    public var windowThemePolicy: WindowThemePolicy = .themeAllWindows
    
    /// 启用或禁用ThemeKit功能。
    @objc public var isEnabled: Bool {
        get {
            return _isEnabled ?? false
        }
        set {
            guard _isEnabled != newValue else { return }
            _isEnabled = newValue

            
            if newValue {
                //启用主题
                // 初始化自定义NSColor代码(交换NSColor，如果需要的话-只做一次)
                NSColor.swizzleNSColor()

                // 观察和主题新窗口(在屏幕上显示之前)
                self.obj = NotificationCenter.default.addObserver(forName: NSWindow.didUpdateNotification, object: nil, queue: nil) { (notification) in
                    if let window = notification.object as? NSWindow {
                        window.themeIfCompliantWithWindowThemePolicy()
                    }
                }

                // 在用户默认值上观察当前主题
                NSUserDefaultsController.shared.addObserver(self, forKeyPath: themeChangeKVOKeyPath, options: NSKeyValueObservingOptions(rawValue: 0), context: nil)

                // 观察当前系统主题(macOS苹果界面主题)
                NotificationCenter.default.addObserver(self, selector: #selector(systemThemeDidChange(_:)), name: .didChangeSystemTheme, object: nil)
            } else {
                //禁用主题
                
                if let object = self.obj {
                    NotificationCenter.default.removeObserver(object)
                }
                NSUserDefaultsController.shared.removeObserver(self, forKeyPath: themeChangeKVOKeyPath)
                NotificationCenter.default.removeObserver(self, name: .didChangeSystemTheme, object: nil)
            }
        }
    }
    
    
    /// 设置或返回当前主题。
    ///
    /// 该属性与KVO兼容。值存储在用户默认值下的键' userDefaultsThemeKey '下。
    @objc public var theme: KYLTheme {
        get {
            return _theme ?? KYLThemeManager.defaultTheme
        }
        set(newTheme) {
            guard isEnabled else { return }

            // 应用主题
            if _theme == nil || newTheme.effectiveTheme != _theme! || newTheme.effectiveTheme.isUserTheme {
                applyTheme(newTheme)
            }

            // 用户默认值上的存储标识符
            if newTheme.identifier != UserDefaults.standard.string(forKey: KYLThemeManager.userDefaultsThemeKey) {
                _storingThemeOnUserDefaults = true
                UserDefaults.standard.set(newTheme.identifier, forKey: KYLThemeManager.userDefaultsThemeKey)
                _storingThemeOnUserDefaults = false
            }
        }
    }
    
    
    /// 返回当前有效的主题(只读)。
    ///
    /// 该属性与KVO兼容。这可能会返回一个不同于' theme '的结果，如果当前主题设置为' WSSystemTheme '，
    /// 有效的主题将是' lightTheme '或' darkTheme '，尊重用户在**系统首选项>一般>外观**中的首选项。
    @objc public var effectiveTheme: KYLTheme {
        return theme.effectiveTheme
    }

    /// 列出所有可用的主题:
    ///
    /// - Built-in `lightTheme`
    /// - Built-in `darkTheme`
    /// - Built-in `systemTheme`
    /// - 所有本地主题(扩展' NSObject '并符合' KYLTheme '协议)
    /// - 所有的用户主题 ( 从主题配置文件 `.theme` files 加载)
    ///
    /// 此属性与KVO兼容，当用户主题文件夹发生更改时，此属性将更改。
    @objc public var themes: [KYLTheme] {
        if cachedThemes == nil {
            var available = [KYLTheme]()

            // Append theme to the list, reloading if user theme
            func appendTheme(_ theme: KYLTheme) {
                if theme.isUserTheme, let userTheme = theme as? KYLUserTheme {
                    userTheme.reload()
                }
                available.append(theme)
            }

            // 内建默认主题
            appendTheme(KYLThemeManager.lightTheme)
            appendTheme(KYLThemeManager.darkTheme)
            appendTheme(KYLThemeManager.systemTheme)

            // 开发者原生主题(符合NSObject, WSTheme)
            for cls in NSObject.classesImplementingProtocol(KYLTheme.self) {
                if cls !== KYLLightTheme.self && cls !== KYLDarkTheme.self && cls !== KYLSystemTheme.self && cls !== KYLUserTheme.self,
                    let themeClass = cls as? NSObject.Type,
                    let theme = themeClass.init() as? KYLTheme {
                    available.append(theme)
                }
            }

            // 追加用户自定义的主题
            available.append(contentsOf: userThemes)

            cachedThemes = available
        }
        return cachedThemes ?? []
    }
    
    /// 列出所有用户自定义主题(' WSUserTheme '类，从.theme 配置文件加载的主题)
    @objc public var userThemes: [KYLTheme] {
        if cachedUserThemes == nil {
            var available = [KYLTheme]()

            // User provided themes
            for filename in userThemesFileNames {
                if let themeFileURL = userThemesFolderURL?.appendingPathComponent(filename) {
                    available.append(KYLUserTheme(themeFileURL))
                }
            }

            cachedUserThemes = available
        }
        return cachedUserThemes ?? []
    }
    
    /// 获取具有指定标识符的主题。
    ///
    /// - parameter identifier: 主题唯一标识符
    ///
    /// - returns: 返回主题对象
    @objc public func theme(withIdentifier identifier: String?) -> KYLTheme? {
        if let themeIdentifier: String = identifier {
            for theme in themes where theme.identifier == themeIdentifier {
                return theme
            }
        }
        return nil
    }

    /// 用户默认键当前'主题'。
    ///
    /// 当前的主题。标识符'将存储在' "WSUIKitTheme" ' ' NSUserDefaults '键下。
    @objc static public let userDefaultsThemeKey = "WSUIKitTheme"

    /// 应用最后应用的主题，如果没有则为默认值。
    ///
    /// 从用户默认值中获取最后应用的主题并加载它。如果之前没有应用任何主题，则加载默认主题 (`WSsThemeManager.defaultTheme`).
    @objc public func applyLastOrDefaultTheme() {
        guard isEnabled else { return }

        let userDefaultsTheme = theme(withIdentifier: UserDefaults.standard.string(forKey: KYLThemeManager.userDefaultsThemeKey))
        (userDefaultsTheme ?? KYLThemeManager.defaultTheme).apply()
    }

    /// Force-apply当前的“主题”。
    ///
    /// 通常不需要调用此方法，因为这将强制应用相同的主题。
    @objc public func reApplyCurrentTheme() {
        applyTheme(theme)
    }
    
    
    /// 用户提供主题的位置(。主题文件)。
    ///
    /// 理想情况下，这应该在一个共享的位置，像 `Application Support/{app_bundle_id}/Themes`
    /// 下面是一个如何获取这个文件夹(*)的例子:
    ///
    /// ```swift
    /// public var applicationSupportUserThemesFolderURL: URL {
    ///   let applicationSupportURLs = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
    ///   let thisAppSupportURL = URL(fileURLWithPath: applicationSupportURLs.first!).appendingPathComponent(Bundle.main.bundleIdentifier!)
    ///   return thisAppSupportURL.appendingPathComponent("Themes")
    /// }
    /// ```
    ///
    /// *: force wrapping (!) is for illustrative purposes only.
    ///
    /// 如果不希望更改这些文件，还可以将它们与应用程序绑定在一起。
    @objc public var userThemesFolderURL: URL? {
        didSet {
            // 清除之前的内容
            _userThemesFolderSource?.cancel()

            // 通过CGD调度源观察用户主题文件夹
            if let url = userThemesFolderURL, url != oldValue {
                // 如果需要，创建文件夹
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    print("Unable to create `Themes` directory: \(error.debugDescription)")
                    userThemesFolderURL = nil
                    return
                }

                // 初始化文件描述符
                let fileDescriptor = open((url.path as NSString).fileSystemRepresentation, O_EVTONLY)
                guard fileDescriptor >= 0 else { return }

                // 初始化调度队列
                _userThemesFolderQueue = DispatchQueue(label: "com.wondershare.WSUIKit.UserThemesFolderQueue")

                // 观察文件描述符是否有写操作
                _userThemesFolderSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: DispatchSource.FileSystemEvent.write)
                _userThemesFolderSource?.setEventHandler(handler: {
                    self.userThemesFolderChangedContent()
                })

                // 当调度源被取消时进行清理
                _userThemesFolderSource?.setCancelHandler {
                    close(fileDescriptor)
                }

                // 开始监听变化
                willChangeValue(forKey: #keyPath(themes))
                willChangeValue(forKey: #keyPath(userThemes))
                cachedThemes = nil
                cachedUserThemes = nil
                _userThemesFolderSource?.resume()
                didChangeValue(forKey: #keyPath(userThemes))
                didChangeValue(forKey: #keyPath(themes))

                // 如果是用户主题，则重新应用当前主题
                if theme.effectiveTheme.isUserTheme {
                    reApplyCurrentTheme()
                }
            }
        }
    }
    
    
    /// 动画主题转换?
    @objc public var animateThemeTransitions: Bool = true
    
    // MARK: -
    // MARK: ------------------private ------------
    /// ' isEnabled '属性的内部存储。
    private var _isEnabled: Bool?
    /// “主题”属性的内部存储。不会触发' applyTheme() '调用。
    private var _theme: KYLTheme?
    /// 使用用户默认值存储主题时设置的内部变量，以防止无限循环。
    private var _storingThemeOnUserDefaults: Bool = false
    /// 缓存主题列表(私有)。
    private var cachedThemes: [KYLTheme]?

    /// 缓存用户主题列表（私有)
    private var cachedUserThemes: [KYLTheme]?

    /// 用于监视用户主题文件夹的调度队列
    private var _userThemesFolderQueue: DispatchQueue?

    /// 用于监视用户主题文件夹的Filesustem分派源。
    private var _userThemesFolderSource: DispatchSourceFileSystemObject?

    /// Keypath for string `values.WSTheme`.
    private var themeChangeKVOKeyPath: String = "values.\(KYLThemeManager.userDefaultsThemeKey)"
    /// 主题动画过渡过程中使用的截屏窗口。
    private var themeTransitionWindows: Set<NSWindow> = Set()

}



// MARK: - public--系统外观
extension KYLThemeManager {
    /// 为有效的主题使用外观。
    @objc public var effectiveThemeAppearance: NSAppearance {
        return (effectiveTheme.isLightTheme ? lightAppearance : darkAppearance) ?? NSAppearance.current
    }

    /// 获得浅色外观的方便方法。
    @objc public var lightAppearance: NSAppearance? {
        return NSAppearance(named: .aqua)
    }

    /// 获得深色外观的方便方法。
    @objc public var darkAppearance: NSAppearance? {
        if #available(OSX 10.14, *) {
            return NSAppearance(named: .darkAqua)
        } else {
            return NSAppearance(named: .vibrantDark)
        }
    }
}


// MARK: - 用户自定义主题操作 (`.theme` files)
extension KYLThemeManager {
    
    /// 用户主题文件名的列表。
    private var userThemesFileNames: [String] {
        guard let url = userThemesFolderURL, FileManager.default.fileExists(atPath: url.path, isDirectory: nil) else {
            return []
        }
        if let folderFiles = try? FileManager.default.contentsOfDirectory(atPath: url.path) as NSArray {
            let themeFileNames = folderFiles.filtered(using: NSPredicate(format: "self ENDSWITH '.theme'", argumentArray: nil))
            return themeFileNames.map({ (fileName: Any) -> String in
                return fileName as? String ?? ""
            })
        }
        return []
    }
    
    /// 当主题文件夹有文件更改时调用——>刷新修改的用户主题(如果当前)。
    private func userThemesFolderChangedContent() {
        willChangeValue(forKey: #keyPath(themes))
        willChangeValue(forKey: #keyPath(userThemes))
        cachedThemes = nil
        cachedUserThemes = nil

        if effectiveTheme.isUserTheme {
            applyLastOrDefaultTheme()
        }

        didChangeValue(forKey: #keyPath(userThemes))
        didChangeValue(forKey: #keyPath(themes))
    }
}

//MARK: - public--静态属性、方法
extension KYLThemeManager {
    /// 访问浅色主题的方便方法。
    ///
    /// 可以更改此属性，以便' WSSystemTheme '解析为此主题，而不是默认的' WSLightTheme '。
    @objc public static var lightTheme: KYLTheme = KYLLightTheme()

    /// 访问黑暗主题的方便方法。
    ///
    /// 可以更改此属性，以便' WSSystemTheme '解析为此主题，而不是默认的' WSDarkTheme '。
    @objc public static var darkTheme: KYLTheme = KYLDarkTheme()


    ///方便的方法访问主题，动态更改为WSThemeManager.lightTheme` or `WSThemeManager.darkTheme`，尊重用户在**系统首选项>一般>外观**。
    @objc public static let systemTheme = KYLSystemTheme()

    /// 设置/获取在第一次运行时使用的默认主题 (default: `KYLThemeManager.systemTheme`).
    @objc public static var defaultTheme: KYLTheme = KYLThemeManager.systemTheme
}

//MARK: - 通知
extension KYLThemeManager {
    /// 当当前主题即将更改时发送的通知。
    @objc public static let willChangeThemeNotification = Notification.Name.willChangeTheme

    /// 当当前主题改变时发送的通知。
    @objc public static let didChangeThemeNotification = Notification.Name.didChangeTheme

    /// 当系统主题改变时发送的ThemeKit通知(系统首选项>一般>外观)。
    @objc public static let didChangeSystemThemeNotification = Notification.Name.didChangeSystemTheme
    
    /// 苹果界面的主题改变了通知。
    ///
    /// - parameter notification: A `.didChangeSystemTheme` notification.
    @objc private func systemThemeDidChange(_ notification: Notification) {
        if theme.isSystemTheme {
            applyTheme(theme)
        }
    }
}


//MARK: - 切换主题 - private
extension KYLThemeManager {
    
    /// 应用主题和传播更改, 使新的主题生效并应用到所有窗口上
    /// - Parameter newTheme: 新的主题
    private func applyAndPropagate(_ newTheme: KYLTheme) {
        Thread.onMain {
            // Will change...
            self.willChangeValue(forKey: #keyPath(theme))
            let changingEffectiveAppearance = self._theme == nil || self.effectiveTheme != newTheme.effectiveTheme
            if changingEffectiveAppearance {
                self.willChangeValue(forKey: #keyPath(effectiveTheme))
            }
            NotificationCenter.default.post(name: .willChangeTheme, object: newTheme)

            // 改变有效的主题
            self._theme = newTheme

            // Did change!
            self.didChangeValue(forKey: #keyPath(theme))
            if changingEffectiveAppearance {
                self.didChangeValue(forKey: #keyPath(effectiveTheme))
            }
            NotificationCenter.default.post(name: .didChangeTheme, object: newTheme)

            // 所有符合当前“windowThemePolicy”的windows 都应用主题
            NSWindow.themeAllWindows()
        }
    }
    
    /// 使主题生效， 这个函数会让主题真正生效
    /// - Parameter newTheme: 需要生效的主题
    private func makeThemeEffective(_ newTheme: KYLTheme) {
        // 确定新主题
        let oldEffectiveTheme: KYLTheme = effectiveTheme
        let newEffectiveTheme: KYLTheme = newTheme.effectiveTheme

        // 如果我们切换光到光或暗到暗主题，macOS不会刷新控件的外观=>需要“倾斜”外观来强制刷新! 此外，我们在初始主题和切换“WSUserTheme”主题时“强制刷新”。
        if oldEffectiveTheme.isLightTheme == newEffectiveTheme.isLightTheme || _theme == nil || newTheme.isUserTheme {
            // 切换到“倒转”主题(亮->暗，暗->亮)
            applyAndPropagate(oldEffectiveTheme.isLightTheme ? KYLThemeManager.darkTheme : KYLThemeManager.lightTheme)
        }
        // 切换到新主题
        applyAndPropagate(newTheme)
    }


    /// 应用一个新的“主题”。并执行对应的动画
    /// - Parameter newTheme: 需要应用的主题
    private func applyTheme(_ newTheme: KYLTheme) {
        guard isEnabled else { return }
        Thread.onMain { [unowned self] in
            // 动画主题转变
            if self.animateThemeTransitions {
                // 查找窗口动画
                let windows = NSWindow.windowsCompliantWithWindowThemePolicy()
                guard windows.count > 0 else {
                    // 在没有动画的情况下改变主题
                    self.makeThemeEffective(newTheme)
                    return
                }

                // 在屏幕外创建转换窗口
                var transitionWindows = [Int: NSWindow]()
                for window in windows {
                    let windowNumber = window.windowNumber
                    //确保窗口有一个编号，并且它不是我们现有的转换窗口之一
                    if windowNumber > 0 && !self.themeTransitionWindows.contains(window) {
                        let transitionWindow = window.makeScreenshotWindow()
                        transitionWindows[windowNumber] = transitionWindow
                        self.themeTransitionWindows.insert(transitionWindow)
                    }
                }

                // 显示(如果我们至少有一个窗口需要动画)
                if transitionWindows.count > 0 {
                    // 全部展示(隐藏)
                    for (windowNumber, transitionWindow) in transitionWindows {
                        transitionWindow.alphaValue = 0.0
                        let parentWindow = NSApp.window(withWindowNumber: windowNumber)
                        parentWindow?.addChildWindow(transitionWindow, ordered: .above)
                    }

                    // 设置动画
                    NSAnimationContext.beginGrouping()
                    let ctx = NSAnimationContext.current
                    ctx.duration = 0.3
                    if #available(macOS 10.15, *) {
                        ctx.timingFunction = CAMediaTimingFunction(name:  .easeInEaseOut)
                    } else {
                        ctx.timingFunction = CAMediaTimingFunction(name:  .easeInEaseOut)
                    }
                    //ctx.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    ctx.completionHandler = {() -> Void in
                        for transitionWindow in transitionWindows.values {
                            transitionWindow.orderOut(self)
                            self.themeTransitionWindows.remove(transitionWindow)
                        }
                    }

                    // 把它们全部展示出来，然后淡出
                    for transitionWindow in transitionWindows.values {
                        transitionWindow.alphaValue = 1.0
                        transitionWindow.animator().alphaValue = 0.0
                    }
                    NSAnimationContext.endGrouping()

                }
            }

            // 真正改变主题
            self.makeThemeEffective(newTheme)
        }
    }
    
    // 当主题在' NSUserDefaults '上改变时调用。
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == themeChangeKVOKeyPath && !_storingThemeOnUserDefaults else { return }

        // 用户默认选择的主题
        let userDefaultsThemeIdentifier = UserDefaults.standard.string(forKey: KYLThemeManager.userDefaultsThemeKey)

        // 主题改变了用户默认值->应用
        if userDefaultsThemeIdentifier != theme.identifier {
            applyLastOrDefaultTheme()
        }
    }
}


//fileprivate extension Thread {
//    /// 确保代码块在主线程上执行
//    @objc class func onMain(block: @escaping () -> Void) {
//        if Thread.isMainThread {
//            block()
//        } else {
//            DispatchQueue.main.async {
//                block()
//            }
//        }
//    }
//}

////MARK: - 运行时方法交换
//fileprivate extension NSObject {
//
//    /// 交换实例方法
//    /// - Parameters:
//    ///   - cls: 类名
//    ///   - originalSelector: 原始方法
//    ///   - swizzledSelector: 需要交换的方法
//    @objc  class func swizzleInstanceMethod(cls: AnyClass?, selector originalSelector: Selector, withSelector swizzledSelector: Selector) {
//        guard cls != nil else {
//            print("Unable to swizzle \(originalSelector): dynamic system color override will not be available.")
//            return
//        }
//
//        // methods
//        let originalMethod = class_getInstanceMethod(cls, originalSelector)
//        let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
//
//        // add new method
//        let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
//
//        // switch implementations
//        if didAddMethod {
//            class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
//        } else {
//            method_exchangeImplementations(originalMethod!, swizzledMethod!)
//        }
//    }
//
//
//    /// 获取类的类方法名列表
//    /// - Parameter cls: 类名
//    /// - Returns: 返回该类的类方法列表
//    @objc  class func classMethodNames(for cls: AnyClass?) -> [String] {
//        var results: [String] = []
//
//        //检索类方法列表
//        var count: UInt32 = 0
//        if let methods: UnsafeMutablePointer<Method> = class_copyMethodList(object_getClass(cls), &count) {
//            //枚举类方法
//            for i in 0..<count {
//                let name = NSStringFromSelector(method_getName(methods[Int(i)]))
//                results.append(name)
//            }
//            //释放内存
//            free(methods)
//        }
//
//        return results
//    }
//
//
//    /// 获取类列表
//    /// - Returns: 返回类列表
//    @objc  static func classList() -> [AnyClass] {
//        var results: [AnyClass] = []
//
//        //获取类数量
//        let expectedCount: Int32 = objc_getClassList(nil, 0)
//
//        //检索类列表
//        let buffer = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedCount))
//        let realCount: Int32 = objc_getClassList(AutoreleasingUnsafeMutablePointer<AnyClass>(buffer), expectedCount)
//
//        //枚举所有类
//        for i in 0..<realCount {
//            if let cls: AnyClass = buffer[Int(i)] {
//                results.append(cls)
//            }
//        }
//
//        //释放内存
//        buffer.deallocate()
//
//        return results
//    }
//
//
//    /// 获取实现指定协议的类列表
//    /// - Parameter aProtocol: 协议
//    /// - Returns: 返回所有实现指定协议的类
//    @objc  static func classesImplementingProtocol(_ aProtocol: Protocol) -> [AnyClass] {
//        let classes = classList()
//        var results = [AnyClass]()
//
//        //枚举所有类
//        for cls  in classes {
//            if class_conformsToProtocol(cls, aProtocol) {
//                results.append(cls)
//            }
//        }
//
//        return results
//    }
//}

#endif
