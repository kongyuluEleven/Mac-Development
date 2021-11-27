//
//  KYLThemeGradient.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

private var _cachedGradients: NSCache<NSNumber, KYLThemeGradient> = NSCache()
private var _cachedThemeGradients: NSCache<NSNumber, NSGradient> = NSCache()

/**
 " KYLThemeGradient "是一个动态改变颜色的" NSGradient "子类
 每当有新的主题出现时。
 
 主题感知意味着在选择时不需要检查任何条件
 梯度画。例如:
 
 ```
 KYLThemeGradient.rainbowGradient.draw(in: bounds, angle: 0)
 ```
 
 绘图代码将根据所选对象以不同的梯度绘制
 主题。除非绘图缓存正在进行，否则不需要刷新
 更改当前主题后的UI。
 
 Defining theme-aware gradients
 ------------------------------
 
 推荐添加自己的动态渐变的方法如下:
 
 1. **添加一个' ThemeGradient '类扩展**(或' KYLThemeGradient '类别
 为渐变添加类方法。例如:
 
     In Swift:
 
     ```
     extension KYLThemeGradient {
     
         static var brandGradient: WSThemeGradient {
            return WSThemeGradient.gradient(with: #function)
         }
     
     }
     ```

 
 2. **在你想要支持的任何' Theme '上添加类扩展(例如' LightTheme ')
 以及“DarkTheme”——
 定义在(1)中的每个主题梯度类方法的实例方法。例如:
 
     In Swift:
 
     ```
     extension KYLLightTheme {
     
         var brandGradient: NSGradient {
            return NSGradient(starting: NSColor.white, ending: NSColor.black)
         }
         
    }
         
    extension KYLDarkTheme {
         
         var brandGradient: NSGradient {
            return NSGradient(starting: NSColor.black, ending: NSColor.white)
         }
     
     }
     ```
 
 
 3. 如果支持' KYLUserTheme '， **定义用户主题文件的属性
 对于定义在(1)中的每个主题梯度类方法。例如:
 
     ```
     displayName = Sample User Theme
     identifier = com.kyl.KYLMacUIKit.SampleUserTheme
     darkTheme = false
     
     orangeSky = rgb(160, 90, 45, .5)
     brandGradient = linear-gradient($orangeSky, rgb(200, 140, 60))
     ```
 
 Fallback colors
 ---------------
 目标主题类上未实现的属性/方法默认为
 “fallbackGradient”。这也是，可以定制每个主题。
 

 */

@objc(KYLThemeGradient)
open class KYLThemeGradient: NSGradient {
    
    // MARK: -------------public-----------------

    // MARK: -
    // MARK: Properties

    /// 渐变选择器作为同一个选择器的主题实例方法，如果不存在，则作为主题实例方法themeAsset(_:)的参数。
    @objc public var themeGradientSelector: Selector? {
        didSet {
            // recache梯度现在和主题改变
            recacheGradient()
            registerThemeChangeNotifications()
        }
    }

    /// 从当前主题解析的渐变(随当前主题动态更改)。
    @objc public var resolvedThemeGradient: NSGradient?

    // MARK: -
    // MARK: Creating Gradients

    /// 为指定的选择器创建一个新的WSThemeGradient实例。
    ///
    /// - parameter selector: 选择器的颜色方法。
    ///
    /// - returns: 指定选择器的' WSThemeGradient '实例。
    @objc(gradientWithSelector:)
    public class func gradient(with selector: Selector) -> KYLThemeGradient? {
        let cacheKey = CacheKey(selector: selector)

        if let cachedGradient = _cachedGradients.object(forKey: cacheKey) {
            return cachedGradient
        } else if let gradient = KYLThemeGradient(with: selector) {
            _cachedGradients.setObject(gradient, forKey: cacheKey)
            return gradient
        }
        return nil
    }

    /// 特定主题的渐变。
    ///
    /// - parameter theme:    “主题”的实例。
    /// - parameter selector: 一个梯度选择器。
    ///
    /// - returns: 在给定的主题上为指定的选择器解析梯度。
    @objc(gradientForTheme:selector:)
    public class func gradient(for theme: KYLTheme, selector: Selector) -> NSGradient? {
        let cacheKey = CacheKey(selector: selector, theme: theme)
        var gradient = _cachedThemeGradients.object(forKey: cacheKey)

        if gradient == nil {
            // Theme provides this asset?
            gradient = theme.themeAsset(NSStringFromSelector(selector)) as? NSGradient

            // Otherwise, use fallback gradient
            if gradient == nil {
                gradient = fallbackGradient(for: theme, selector: selector)
            }

            // Cache it
            if let themeGradient = gradient {
                _cachedThemeGradients.setObject(themeGradient, forKey: cacheKey)
            }
        }

        return gradient
    }

    /// 当前主题渐变，但考虑到视图外观和任何窗口特定的主题(如果设置)。
    ///
    /// 如果一个“NSWindow。windowTheme '被设置，它将被代替使用。一些视图可能使用与主题外观不同的外观。在这些情况下，
    /// 渐变不会使用当前主题来解决，而是通过“lightTheme”或“darkTheme”来解决，这取决于视图外观是亮还是暗。
    ///
    /// - parameter view:     “NSView”实例。
    /// - parameter selector: 一个梯度选择器。
    ///
    /// - returns: 在给定的视图中，指定的选择器的解析梯度。
    @objc(gradientForView:selector:)
    public class func gradient(for view: NSView, selector: Selector) -> NSGradient? {
        // 如果设置了自定义窗口主题，请使用适当的资产
        if let windowTheme = view.window?.windowTheme {
            return KYLThemeGradient.gradient(for: windowTheme, selector: selector)
        }

        let theme = KYLThemeManager.shared.effectiveTheme
        let viewAppearance = view.appearance
        let aquaAppearance = NSAppearance(named: NSAppearance.Name.aqua)
        let lightAppearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        let darkAppearance = NSAppearance(named: NSAppearance.Name.vibrantDark)

        // 使用一个黑暗主题，但控制是在一个光明表面=>使用光明主题代替
        if theme.isDarkTheme &&
            (viewAppearance == lightAppearance || viewAppearance == aquaAppearance) {
            return KYLThemeGradient.gradient(for: KYLThemeManager.lightTheme, selector: selector)
        } else if theme.isLightTheme && viewAppearance == darkAppearance {
            return KYLThemeGradient.gradient(for: KYLThemeManager.darkTheme, selector: selector)
        }

        // 否则，返回当前主题渐变
        return KYLThemeGradient.gradient(with: selector)
    }
    
    /// 清空缓存
    /// 不需要手动调用这个函数
    @objc class open func emptyCache() {
        _cachedGradients.removeAllObjects()
        _cachedThemeGradients.removeAllObjects()
    }

    /// 特定主题和选择器的后退渐变。
    @objc class func fallbackGradient(for theme: KYLTheme, selector: Selector) -> NSGradient? {
        var fallbackGradient: NSGradient?

        // 尝试使用主题提供的“fallbackGradient”方法
        if let themeFallbackGradient = theme.fallbackGradient as? NSGradient {
            fallbackGradient = themeFallbackGradient
        }
        // 尝试使用主题资产“fallbackGradient”
        if fallbackGradient == nil, let themeAsset = theme.themeAsset("fallbackGradient") as? NSGradient {
            fallbackGradient = themeAsset
        }
        // 否则只使用默认的后退渐变
        return fallbackGradient ?? theme.defaultFallbackGradient
    }
    
    /// 强制动态梯度分辨率到“resolvedThemeGradient”并缓存它。您不需要手动调用这个函数。
    @objc open func recacheGradient() {
        // 如果它是UserTheme，我们实际上想要丢弃主题缓存值
        if KYLThemeManager.shared.effectiveTheme.isUserTheme {
            KYLThemeGradient.emptyCache()
        }

        // Recache解决颜色
        if let selector = themeGradientSelector,
            let newGradient = KYLThemeGradient.gradient(for: KYLThemeManager.shared.effectiveTheme, selector: selector) {
            resolvedThemeGradient = newGradient
        }
    }

    // MARK: -------------构造函数-----------------

    /// 为给定的选择器返回一个新的' WSThemeGradient '。
    ///
    /// - parameter selector:   一个梯度选择器。
    ///
    /// - returns: “WSThemeGradient”实例。
    @objc init?(with selector: Selector) {
        // 初始化属性
        themeGradientSelector = selector
        let defaultColor = KYLThemeManager.shared.effectiveTheme.defaultFallbackBackgroundColor
        resolvedThemeGradient = NSGradient(starting: defaultColor, ending: defaultColor)

        super.init(colors: [defaultColor, defaultColor], atLocations: [0.0, 1.0], colorSpace: NSColorSpace.genericRGB)

        // 缓存渐变色
        recacheGradient()

        // 主题改变时重新缓存
        registerThemeChangeNotifications()
    }

    required public init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .didChangeTheme, object: nil)
    }

    /// 注册主题变化监听通知
    @objc func registerThemeChangeNotifications() {
        NotificationCenter.default.removeObserver(self, name: .didChangeTheme, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recacheGradient), name: .didChangeTheme, object: nil)
    }

    
 
}

// MARK: -------------覆写父类方法或属性-----------------
extension KYLThemeGradient {
    override open func draw(in rect: NSRect, angle: CGFloat) {
        resolvedThemeGradient?.draw(in: rect, angle: angle)
    }

    override open func draw(in path: NSBezierPath, angle: CGFloat) {
        resolvedThemeGradient?.draw(in: path, angle: angle)
    }

    override open func draw(from startingPoint: NSPoint, to endingPoint: NSPoint, options: NSGradient.DrawingOptions = []) {
        resolvedThemeGradient?.draw(from: startingPoint, to: endingPoint, options: options)
    }

    override open func draw(fromCenter startCenter: NSPoint, radius startRadius: CGFloat, toCenter endCenter: NSPoint, radius endRadius: CGFloat, options: NSGradient.DrawingOptions = []) {
        resolvedThemeGradient?.draw(fromCenter: startCenter, radius: startRadius, toCenter: endCenter, radius: endRadius, options: options)
    }

    override open func draw(in rect: NSRect, relativeCenterPosition: NSPoint) {
        resolvedThemeGradient?.draw(in: rect, relativeCenterPosition: relativeCenterPosition)
    }

    override open func draw(in path: NSBezierPath, relativeCenterPosition: NSPoint) {
        resolvedThemeGradient?.draw(in: path, relativeCenterPosition: relativeCenterPosition)
    }

    override open var colorSpace: NSColorSpace {
        return resolvedThemeGradient?.colorSpace ?? .genericRGB
    }

    override open var numberOfColorStops: Int {
        return resolvedThemeGradient?.numberOfColorStops ?? 0
    }

    override open func getColor(_ color: AutoreleasingUnsafeMutablePointer<NSColor>?, location: UnsafeMutablePointer<CGFloat>?, at index: Int) {
        resolvedThemeGradient?.getColor(color, location: location, at: index)
    }

    override open func interpolatedColor(atLocation location: CGFloat) -> NSColor {
        return resolvedThemeGradient?.interpolatedColor(atLocation: location) ?? NSColor.clear
    }
}

#endif
