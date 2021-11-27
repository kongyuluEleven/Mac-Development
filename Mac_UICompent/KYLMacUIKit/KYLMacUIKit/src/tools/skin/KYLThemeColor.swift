//
//  KYLThemeColor.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

private var _cachedColors: NSCache<NSNumber, KYLThemeColor> = NSCache()
private var _cachedThemeColors: NSCache<NSNumber, NSColor> = NSCache()

/**
 ' KYLThemeColor '是一个' NSColor '的子类，它会在任何时候动态地改变它的颜色
 一个新的主题正在流行。
 
 主题感知意味着在选择时不需要检查任何条件
 在控件上绘制或设置的颜色。例如:
 
 ```
 myTextField.textColor = KYLThemeColor.myContentTextColor
 
 KYLThemeColor.myCircleFillColor.setFill()
 NSBezierPath(rect: bounds).fill()
 ```
 
 myTextField的文本颜色会在用户切换时自动改变
 一个主题。同样，绘图代码将根据不同的情况使用不同的颜色绘制
 所选的主题。除非正在进行一些绘图缓存，否则没有必要这样做
 更改当前主题后刷新UI。
 
 您还可以使用' NSColor(patternImage:) '将颜色定义为模式图像。
 
 Defining theme-aware colors
 ---------------------------
 推荐添加自己的动态色彩的方法如下:
 
 1. **添加一个' KYLThemeColor '类扩展**
 为您的颜色添加类方法。例如:
 
     In Swift:
 
     ```swift
     extension KYLThemeColor {
     
       static var brandColor: ThemeColor {
         return ThemeColor.color(with: #function)
       }
     
     }
     ```

 
 2. **在你想要支持的任何' KYLTheme '上添加类扩展(例如' KYLLightTheme ')
 以及“KYLDarkTheme”——
 定义在(1)中的每个主题颜色类方法的实例方法。例如:
    
     In Swift:
 
     ```swift
     extension KYLLightTheme {
     
       var brandColor: NSColor {
         return NSColor.orange
       }
 
     }
 
     extension KYLDarkTheme {
     
       var brandColor: NSColor {
         return NSColor.white
       }
 
     }
     ```
 
 3. 如果支持' KYLUserTheme '， **定义用户主题文件的属性
 对于定义在(1)中的每个主题颜色类方法。例如:
 
     ```swift
     displayName = Sample User Theme
     identifier = com.kyl.KYLMacUIKit.SampleUserTheme
     darkTheme = false
 
     brandColor = rgba(96, 240, 12, 0.5)
     ```
 
 Overriding system colors
 ------------------------
 除了你自己的颜色添加为' KYLThemeColor '类方法，你也可以重写
 NSColor类方法，以返回主题感知的颜色。这个过程是
 完全一样，例如，如果添加一个名为" labelColor "的方法到
 扩展' KYLThemeColor '，那个方法会在' NSColor '和颜色中被覆盖
 从' Theme '将使用子类代替。
 
 总之，调用' NSColor.labelColor '将返回与主题相关的颜色。
 
 你可以得到可用的/可覆盖的颜色方法(类方法)的完整列表
 调用“NSColor.colorMethodNames()”。
 
 在任何时候，您都可以检查系统颜色是否被当前主题覆盖
 by checking the `NSColor.isThemeOverriden` property (e.g., `NSColor.labelColor.isThemeOverriden`).
 
 当主题不覆盖系统颜色时，原始系统颜色将覆盖
 而不是使用。你改写了主题的颜色。labelColor’,但目前
 应用的主题没有实现' labelColor ' ->原来的' labelColor '将
 使用。
 
 Fallback colors
 ---------------
 除了system override named colors，它默认为原始颜色
 当主题没有指定时，系统提供了命名颜色，未实现
 目标主题类的属性/方法默认为' fallbackForegroundColor '
 和fallbackBackgroundColor，分别用于前景色和背景色。
 这些也是，可以定制每个主题。
 

 */
@objc(KYLThemeColor)
open class KYLThemeColor: NSColor {

    // MARK: -------------公用 public 属性-----------------
    // MARK: Properties

    /// ' WSThemeColor '颜色选择器用作同一个选择器的主题实例方法，或者，如果不存在，作为主题实例方法' themeAsset(_:) '中的参数。
    @objc public var themeColorSelector: Selector = #selector(getter: NSColor.clear) {
        didSet {
            // recache颜色现在和主题改变
            recacheColor()
            registerThemeChangeNotifications()
        }
    }

    /// 从当前主题解析颜色(随当前主题动态更改)。
    @objc public lazy var resolvedThemeColor: NSColor = NSColor.clear



    // MARK: -
    // MARK: Creating Colors

    /// 为指定的选择器创建新的ThemeColor实例。
    ///
    /// 返回当前主题上调用' selector '返回的颜色作为实例方法，如果不可用，则返回当前主题上调用' themeAsset(_:) '返回的结果。
    ///
    /// - parameter selector: 选择器的颜色方法。
    ///
    /// - returns: 指定选择器的' WSThemeColor '实例。
    @objc(colorWithSelector:)
    public class func color(with selector: Selector) -> KYLThemeColor {
        return color(with: selector, colorSpace: nil)
    }

    /// 为指定的颜色名称组件创建一个新的WSThemeColor实例(通常是一个字符串选择器)。
    ///
    /// 然后，Color name组件将作为当前主题的选择器被调用，作为实例方法，如果不可用，则作为调用当前主题的' themeAsset(_:) '的结果。
    ///
    /// - parameter selector: 选择器的颜色方法。
    ///
    /// - returns: 指定选择器的' WSThemeColor '实例。
    @objc(colorWithColorNameComponent:)
    internal class func color(with colorNameComponent: String) -> KYLThemeColor {
        return color(with: Selector(colorNameComponent), colorSpace: nil)
    }

    /// 特定主题的颜色。
    ///
    /// - parameter theme:    “主题”的实例。
    /// - parameter selector: 颜色选择器。
    ///
    /// - returns: 给定主题上指定选择器的已分辨颜色。
    @objc(colorForTheme:selector:)
    public class func color(for theme: KYLTheme, selector: Selector) -> NSColor {
        let cacheKey = CacheKey(selector: selector, theme: theme)
        var color = _cachedThemeColors.object(forKey: cacheKey)

        if color == nil {

            // 主题提供这个资产?
            color = theme.themeAsset(NSStringFromSelector(selector)) as? NSColor

            // 否则，使用备用颜色
            if color == nil {
                color = fallbackColor(for: theme, selector: selector)
            }

            // 如果不是图案图像，存储为校准的RGB
            if color?.colorSpaceName != NSColorSpaceName.pattern {
                color = color?.usingColorSpace(.genericRGB)
            }

            // 缓存颜色
            if let themeColor = color {
                _cachedThemeColors.setObject(themeColor, forKey: cacheKey)
            }
        }

        return color ?? fallbackColor(for: theme, selector: selector)
    }

    /// 当前主题的颜色，但考虑到视图外观和任何窗口特定的主题(如果设置)。
    ///
    /// 如果一个“NSWindow。windowTheme '被设置，它将被代替使用。一些视图可能使用与主题外观不同的外观。
    /// 在这些情况下，颜色将不会使用当前主题来解决，而是分别从“lightTheme”或“darkTheme”来解决，这取决于视图外观是亮还是暗。
    ///
    /// - parameter view:     “NSView”实例。
    /// - parameter selector: 颜色选择器。
    ///
    /// - returns: 在给定的视图上为指定的选择器分辨颜色。
    @objc(colorForView:selector:)
    public class func color(for view: NSView, selector: Selector) -> NSColor {
        // 如果设置了自定义窗口主题，请使用适当的资产
        if let windowTheme = view.window?.windowTheme {
            return KYLThemeColor.color(for: windowTheme, selector: selector)
        }

        let theme = KYLThemeManager.shared.effectiveTheme
        let viewAppearance = view.appearance
        let aquaAppearance = NSAppearance(named: NSAppearance.Name.aqua)
        let lightAppearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        let darkAppearance = NSAppearance(named: NSAppearance.Name.vibrantDark)

        // 使用一个黑暗主题，但控制是在一个光明表面=>使用光明主题代替
        if theme.isDarkTheme &&
            (viewAppearance == lightAppearance || viewAppearance == aquaAppearance) {
            return KYLThemeColor.color(for: KYLThemeManager.lightTheme, selector: selector)
        } else if theme.isLightTheme && viewAppearance == darkAppearance {
            return KYLThemeColor.color(for: KYLThemeManager.darkTheme, selector: selector)
        }

        // 否则，返回当前主题颜色
        return KYLThemeColor.color(with: selector)
    }

    /// 在指定的颜色空间中为给定的选择器返回一个新的' ThemeColor '。
    ///
    /// - parameter selector:   颜色选择器。
    /// - parameter colorSpace: 一个可选的“NSColorSpace”。
    ///
    /// - returns: 指定颜色空间中的' WSThemeColor '实例。
    @objc class func color(with selector: Selector, colorSpace: NSColorSpace?) -> KYLThemeColor {
        let cacheKey = CacheKey(selector: selector, colorSpace: colorSpace)

        if let cachedColor = _cachedColors.object(forKey: cacheKey) {
            return cachedColor
        } else {
            let color = KYLThemeColor(with: selector, colorSpace: colorSpace)
            _cachedColors.setObject(color, forKey: cacheKey)
            return color
        }
    }

  

    /// 强制动态色彩分辨率为“resolvedThemeColor”并缓存它。您不需要手动调用这个函数。
    @objc open func recacheColor() {
        // 如果它是WSUserTheme，我们实际上想要丢弃主题缓存值
        if KYLThemeManager.shared.effectiveTheme.isUserTheme {
            KYLThemeColor.emptyCache()
        }

        // Recache解决颜色
        let newColor = KYLThemeColor.color(for: KYLThemeManager.shared.effectiveTheme, selector: themeColorSelector)
        if let colorSpace = themeColorSpace {
            let convertedColor = newColor.usingColorSpace(colorSpace)
            resolvedThemeColor = convertedColor ?? newColor
        } else {
            resolvedThemeColor = newColor
        }

        // 如果合适，缓存图案图像的平均颜色
        themePatternImageAverageColor = resolvedThemeColor.colorSpaceName == NSColorSpaceName.pattern ? resolvedThemeColor.patternImage.averageColor() : NSColor.clear
    }

    /// 清空缓存
    /// 不需要手动调用这个函数
    @objc class open func emptyCache() {
        _cachedColors.removeAllObjects()
        _cachedThemeColors.removeAllObjects()
    }

    /// 特定主题和选择器的回退颜色。
    @objc class func fallbackColor(for theme: KYLTheme, selector: Selector) -> NSColor {
        var fallbackColor: NSColor?
        let selectorString = NSStringFromSelector(selector)

        if selectorString.contains("Background") {
            // 尝试使用主题提供的“fallbackgroundcolor”方法
            if let themeFallbackColor = theme.fallbackBackgroundColor as? NSColor {
                fallbackColor = themeFallbackColor
            }
            // 尝试使用主题资产“fallbackBackgroundColor”
            if fallbackColor == nil, let themeAsset = theme.themeAsset("fallbackBackgroundColor") as? NSColor {
                fallbackColor = themeAsset
            }
            // 否则就使用默认的回退颜色
            return fallbackColor ?? theme.defaultFallbackBackgroundColor
        } else {
            // 尝试使用主题提供的“fallbackForegroundColor”方法
            if let themeFallbackColor = theme.fallbackForegroundColor as? NSColor {
                fallbackColor = themeFallbackColor
            }
            // 尝试使用主题资产“fallbackForegroundColor”
            if fallbackColor == nil, let themeAsset = theme.themeAsset("fallbackForegroundColor") as? NSColor {
                fallbackColor = themeAsset
            }
            // 否则就使用默认的回退颜色
            return fallbackColor ?? theme.defaultFallbackForegroundColor
        }
    }
    
    
    //MARK: - 构造函数
    /// 为指定颜色空间中的5个选择器返回一个新的' WSThemeColor '。
    ///
    /// - parameter selector:   颜色选择器。
    /// - parameter colorSpace: 一个可选的“NSColorSpace”。
    ///
    /// - returns: 指定颜色空间中的' ThemeColor '实例。
    @objc convenience init(with selector: Selector, colorSpace: NSColorSpace?) {
        self.init()

        // 初始化属性
        themeColorSelector = selector
        themeColorSpace = colorSpace

        // 缓存颜色
        recacheColor()

        // 在主题变化上重新缓存颜色
        registerThemeChangeNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .didChangeTheme, object: nil)
    }

    //MARK: -------------------- private --------------------
    
    /// 注册以回顾主题更改。
    @objc func registerThemeChangeNotifications() {
        NotificationCenter.default.removeObserver(self, name: .didChangeTheme, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recacheColor), name: .didChangeTheme, object: nil)
    }
    
    /// 主题颜色空间(如果指定)。
    private var themeColorSpace: NSColorSpace? {
        didSet {
            // recache color now and on theme change
            recacheColor()
            registerThemeChangeNotifications()
        }
    }

    /// 模式图像分辨颜色的平均颜色(非模式图像颜色为零)
    private var themePatternImageAverageColor: NSColor = NSColor.clear

}

//MARK: - 覆写---父类属性
extension KYLThemeColor {
    @objc override open var colorSpaceName: NSColorSpaceName {
        return resolvedThemeColor.colorSpaceName
    }

    override open var colorSpace: NSColorSpace {
        return resolvedThemeColor.colorSpace
    }

    override open var numberOfComponents: Int {
        return resolvedThemeColor.numberOfComponents
    }
    
    override open var redComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let rgbColor = color.usingColorSpace(.genericRGB) {
            return rgbColor.redComponent
        }
        return 0.0
    }

    override open var greenComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let rgbColor = color.usingColorSpace(.genericRGB) {
            return rgbColor.greenComponent
        }
        return 0.0
    }

    override open var blueComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let rgbColor = color.usingColorSpace(.genericRGB) {
            return rgbColor.blueComponent
        }
        return 0.0
    }



    override open var cyanComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let cmykColor = color.usingColorSpace(.genericCMYK) {
            return cmykColor.cyanComponent
        }
        return 0.0
    }

    override open var magentaComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let cmykColor = color.usingColorSpace(.genericCMYK) {
            return cmykColor.magentaComponent
        }
        return 0.0
    }

    override open var yellowComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let cmykColor = color.usingColorSpace(.genericCMYK) {
            return cmykColor.yellowComponent
        }
        return 0.0
    }

    override open var blackComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let cmykColor = color.usingColorSpace(.genericCMYK) {
            return cmykColor.blackComponent
        }
        return 0.0
    }


    override open var whiteComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let grayColor = color.usingColorSpace(.genericGray) {
            return grayColor.whiteComponent
        }
        return 0.0
    }

    override open func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(.genericGray)?.getWhite(white, alpha: alpha)
    }

    override open var hueComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let rgbColor = color.usingColorSpace(.genericRGB) {
            return rgbColor.hueComponent
        }
        return 0.0
    }

    override open var saturationComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let rgbColor = color.usingColorSpace(.genericRGB) {
            return rgbColor.saturationComponent
        }
        return 0.0
    }

    override open var brightnessComponent: CGFloat {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        if let rgbColor = color.usingColorSpace(.genericRGB) {
            return rgbColor.brightnessComponent
        }
        return 0.0
    }

    override open var description: String {
        return "\(super.description): \(NSStringFromSelector(themeColorSelector))"
    }
}

//MARK: - 覆写---父类方法
extension KYLThemeColor {
    
    override open func setFill() {
        resolvedThemeColor.setFill()
    }

    override open func setStroke() {
        resolvedThemeColor.setStroke()
    }

    override open func set() {
        resolvedThemeColor.set()
    }

    override open func usingColorSpace(_ space: NSColorSpace) -> NSColor? {
        return KYLThemeColor.color(with: themeColorSelector, colorSpace: space)
    }

    override open func usingColorSpaceName(_ colorSpace: NSColorSpaceName?, device deviceDescription: [NSDeviceDescriptionKey: Any]?) -> NSColor? {
        if colorSpace == self.colorSpaceName {
            return self
        }

        let newColorSpace: NSColorSpace
        if colorSpace == NSColorSpaceName.calibratedWhite {
            newColorSpace = .genericGray
        } else if colorSpace == NSColorSpaceName.calibratedRGB {
            newColorSpace = .genericRGB
        } else if colorSpace == NSColorSpaceName.deviceWhite {
            newColorSpace = .deviceGray
        } else if colorSpace == NSColorSpaceName.deviceRGB {
            newColorSpace = .deviceRGB
        } else if colorSpace == NSColorSpaceName.deviceCMYK {
            newColorSpace = .deviceCMYK
        } else if colorSpace == NSColorSpaceName.custom {
            newColorSpace = .genericRGB
        } else {
            /* unsupported colorspace conversion */
            return nil
        }

        return KYLThemeColor.color(with: themeColorSelector, colorSpace: newColorSpace)
    }
    
    override open func getComponents(_ components: UnsafeMutablePointer<CGFloat>) {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(.genericRGB)?.getComponents(components)
    }
    
    override open func getRed(_ red: UnsafeMutablePointer<CGFloat>?, green: UnsafeMutablePointer<CGFloat>?, blue: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(.genericRGB)?.getRed(red, green: green, blue: blue, alpha: alpha)
    }
    
    override open func getCyan(_ cyan: UnsafeMutablePointer<CGFloat>?,
                               magenta: UnsafeMutablePointer<CGFloat>?,
                               yellow: UnsafeMutablePointer<CGFloat>?,
                               black: UnsafeMutablePointer<CGFloat>?,
                               alpha: UnsafeMutablePointer<CGFloat>?) {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(.genericCMYK)?.getCyan(cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
    }

    
    
    override open func getHue(_ hue: UnsafeMutablePointer<CGFloat>?, saturation: UnsafeMutablePointer<CGFloat>?, brightness: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        color.usingColorSpace(.genericRGB)?.getHue(hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    override open func highlight(withLevel val: CGFloat) -> NSColor? {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        return color.highlight(withLevel: val)
    }

    override open func shadow(withLevel val: CGFloat) -> NSColor? {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        return color.shadow(withLevel: val)
    }

    override open func withAlphaComponent(_ alpha: CGFloat) -> NSColor {
        let color = resolvedThemeColor.colorSpaceName != NSColorSpaceName.pattern ? resolvedThemeColor : themePatternImageAverageColor
        return color.withAlphaComponent(alpha)
    }
}

// MARK: - 获取图片中的颜色

//fileprivate extension NSImage {
//    
//    /// 找出图像的平均颜色
//    /// - Returns: 返回图片的平均颜色
//    @objc func averageColor() -> NSColor {
//        //1. 设置一个单像素的图像
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bitmap = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
//                                    | CGBitmapInfo.byteOrder32Big.rawValue)
//        
//        guard let bitmapData = malloc(4),
//              let context = CGContext(data: bitmapData,
//                                      width: 1,
//                                      height: 1,
//                                      bitsPerComponent: 8,
//                                      bytesPerRow: 4,
//                                      space: colorSpace,
//                                      bitmapInfo: bitmap.rawValue),
//              let cgImage = self.cgImage(forProposedRect: nil,
//                                         context: NSGraphicsContext(cgContext: context, flipped: false),
//                                         hints: nil) else {
//            //没有符合条件，则返回默认的白色
//            return .white
//        }
//        
//        //2. 绘制一张1个像素的图片
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
//        
//        //3. 从单像素图像中提取字节颜色
//        let r = bitmapData.load(fromByteOffset: 0, as: UInt8.self)
//        let g = bitmapData.load(fromByteOffset: 1, as: UInt8.self)
//        let b = bitmapData.load(fromByteOffset: 2, as: UInt8.self)
//        let a = bitmapData.load(fromByteOffset: 3, as: UInt8.self)
//        
//        //4. 生成一个平均颜色值对象
//        let modifier = a > 0 ? CGFloat(a) / 255.0 : 1.0
//        let red = CGFloat(r) * modifier / 255.0
//        let green = CGFloat(g) * modifier / 255.0
//        let blue = CGFloat(b) * modifier / 255.0
//        let alpha = CGFloat(a) / 255.0
//    
//        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
//    }
//}


#endif
