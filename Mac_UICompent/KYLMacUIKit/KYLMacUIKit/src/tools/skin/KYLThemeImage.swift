//
//  KYLThemeImage.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

private var _cachedImages: NSCache<NSNumber, KYLThemeImage> = NSCache()
private var _cachedThemeImages: NSCache<NSNumber, NSImage> = NSCache()

/**
 ' WSThemeImage '是一个动态改变颜色的NSImage子类
 每当有新的主题出现时。
 
 
 主题感知意味着在选择时不需要检查任何条件
 图像绘制。例如:
 
 ```
 KYLThemeImage.logoImage.draw(in: bounds)
 ```
 
 绘图代码将根据所选对象绘制不同的图像
 主题。除非绘图缓存正在进行，否则不需要刷新
 更改当前主题后的UI。
 
 Defining theme-aware images
 ---------------------------
 
 推荐添加自己的动态图像的方法如下:
 
 1. **添加' KYLThemeImage '类扩展**
 为你的图像添加类方法。例如:
 
     In Swift:
     
     ```
     extension KYLThemeImage {
     
         static var logoImage: ThemeImage {
             return ThemeImage.image(with: #function)
         }
     
     }
     ```
     
 
 2. **在你想要支持的任何' KYLTheme '上添加类扩展(例如' KYLLightTheme ')
 以及“DarkTheme”——
 定义在(1)中的每个主题图像类方法的实例方法。例如:
 
     In Swift:
     
     ```
     extension KYLLightTheme {
     
         var logoImage: NSImage? {
             return NSImage(named: "MyLightLogo")
         }
     
     }
     
     extension KYLDarkTheme {
     
         var logoImage: NSImage? {
             return NSImage(contentsOfFile: "somewhere/MyDarkLogo.png")
         }
     
     }
     ```
    
 
 3. 如果支持' KYLUserTheme '， **定义用户主题文件的属性
 对于定义在(1)中的每个主题图像类方法。例如:
 
     ```
     displayName = Sample User Theme
     identifier = com.kyl.KYLMacUIKit.SampleUserTheme
     darkTheme = false
     
     logoImage = image(named:MyLogo)
     //logoImage = image(file:../some/path/MyLogo.png)
     ```
 
 Fallback images
 ---------------
 目标主题类上未实现的属性/方法默认为
 “fallbackImage”。这也是，可以定制每个主题。
 

 */
@objc(KYLThemeImage)
open class KYLThemeImage: NSImage {

    // MARK: -------------public -----------------
    // MARK: -
    // MARK: public 属性

    /// ' WSThemeImage '图像选择器作为同一个选择器的主题实例方法，如果不存在，则作为主题实例方法' themeAsset(_:) '的参数。
    @objc public var themeImageSelector: Selector? {
        didSet {
            // recache image now and on theme change
            recacheImage()
            registerThemeChangeNotifications()
        }
    }

    /// 从当前主题解析的图像(随当前主题动态更改)。
    @objc public var resolvedThemeImage: NSImage = NSImage(size: NSSize.zero)

    // MARK: -
    // MARK: 创建图片类方法

    /// 为指定的选择器创建一个新的WSThemeImage实例。
    ///
    /// 返回当前主题上调用' selector '返回的图像作为实例方法，如果不可用，则返回当前主题上调用' themeAsset(_:) '返回的结果。
    ///
    /// - parameter selector: 选择图像方法。
    ///
    /// - returns: 指定选择器的' WSThemeImage '实例。
    @objc(imageWithSelector:)
    public class func image(with selector: Selector) -> KYLThemeImage {
        let cacheKey = CacheKey(selector: selector)

        if let cachedImage = _cachedImages.object(forKey: cacheKey) {
            return cachedImage
        } else {
            let image = KYLThemeImage(with: selector)
            _cachedImages.setObject(image, forKey: cacheKey)
            return image
        }
    }

    /// 特定主题的图像。
    ///
    /// - parameter theme:    “主题”的实例。
    /// - parameter selector: 一个图像选择器。
    ///
    /// - returns: 在给定的主题上为指定的选择器解析图像。
    @objc(imageForTheme:selector:)
    public class func image(for theme: KYLTheme, selector: Selector) -> NSImage? {
        let cacheKey = CacheKey(selector: selector, theme: theme)
        var image = _cachedThemeImages.object(forKey: cacheKey)

        if image == nil {
            // 主题提供这个资产?
            image = theme.themeAsset(NSStringFromSelector(selector)) as? NSImage

            // 否则，使用回退映像
            if image == nil {
                image = fallbackImage(for: theme, selector: selector)
            }

            // 缓存图片
            if let themeImage = image {
                _cachedThemeImages.setObject(themeImage, forKey: cacheKey)
            }
        }

        return image
    }

    /// 当前主题图像，但考虑到视图外观和任何窗口特定的主题(如果设置)。
    ///
    /// 如果一个“NSWindow。windowTheme '被设置，它将被代替使用。
    /// 一些视图可能使用与主题外观不同的外观。
    /// 在这些情况下，图像将不能使用当前主题解决，而是从“lightTheme”或“darkTheme”，这取决于视图外观是亮还是暗，分别。
    ///
    /// - parameter view:     “NSView”实例。
    /// - parameter selector: 一个图像选择器。
    ///
    /// - returns: 给定视图下指定选择器的解析图像。
    @objc(imageForView:selector:)
    public class func image(for view: NSView, selector: Selector) -> NSImage? {
        // 如果设置了自定义窗口主题，请使用适当的资产
        if let windowTheme = view.window?.windowTheme {
            return KYLThemeImage.image(for: windowTheme, selector: selector)
        }

        let theme = KYLThemeManager.shared.effectiveTheme
        let viewAppearance = view.appearance
        let aquaAppearance = NSAppearance(named: NSAppearance.Name.aqua)
        let lightAppearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        let darkAppearance = NSAppearance(named: NSAppearance.Name.vibrantDark)

        // 使用一个黑暗主题，但控制是在一个光明表面=>使用光明主题代替
        if theme.isDarkTheme &&
            (viewAppearance == lightAppearance || viewAppearance == aquaAppearance) {
            return KYLThemeImage.image(for: KYLThemeManager.lightTheme, selector: selector)
        } else if theme.isLightTheme && viewAppearance == darkAppearance {
            return KYLThemeImage.image(for: KYLThemeManager.darkTheme, selector: selector)
        }

        // 否则，返回当前主题图像
        return KYLThemeImage.image(with: selector)
    }
    
    /// 情况缓存
    /// 不需要手动调用这个函数
    @objc class open func emptyCache() {
        _cachedImages.removeAllObjects()
        _cachedThemeImages.removeAllObjects()
    }

    /// 特定主题和选择器的回退图像。
    @objc class func fallbackImage(for theme: KYLTheme, selector: Selector) -> NSImage? {
        var fallbackImage: NSImage?

        // 尝试使用主题提供的“fallbackImage”方法
        if let themeFallbackImage = theme.fallbackImage as? NSImage {
            fallbackImage = themeFallbackImage
        }
        // 尝试使用主题资产“fallbackImage”
        if fallbackImage == nil, let themeAsset = theme.themeAsset("fallbackImage") as? NSImage {
            fallbackImage = themeAsset
        }
        // 否则，只使用默认的回退映像
        return fallbackImage ?? theme.defaultFallbackImage
    }
    
    
    /// 强制动态色彩分辨率到“resolvedThemeImage”并缓存它。您不需要手动调用这个函数。
    @objc open func recacheImage() {
        // 如果它是UserTheme，我们实际上想要丢弃主题缓存值
        if KYLThemeManager.shared.effectiveTheme.isUserTheme {
            KYLThemeImage.emptyCache()
        }

        // Recache解决图像
        if let selector = themeImageSelector,
            let newImage = KYLThemeImage.image(for: KYLThemeManager.shared.effectiveTheme, selector: selector) {
            resolvedThemeImage = newImage
        }
    }
    

    // MARK: -------------构造函数-----------------
    
    /// 为给定的选择器返回一个新的' WSThemeImage '。
    ///
    /// - parameter selector:一个图像选择器。
    ///
    /// - returns:“WSThemeImage”实例。
    @objc convenience init(with selector: Selector) {
        self.init(size: NSSize.zero)

        // 初始化属性
        themeImageSelector = selector

        // 缓存图片
        recacheImage()

        // 主题变化是重新缓存
        registerThemeChangeNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .didChangeTheme, object: nil)
    }

    /// 注册主题变化监听通知
    @objc func registerThemeChangeNotifications() {
        NotificationCenter.default.removeObserver(self, name: .didChangeTheme, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recacheImage), name: .didChangeTheme, object: nil)
    }

}

// MARK: -------------覆写父类的属性-----------------
extension KYLThemeImage {
    
    override open var size: NSSize {
        get {
            return resolvedThemeImage.size
        }
        set {
            resolvedThemeImage.size = newValue
        }
    }
    
    override open var backgroundColor: NSColor {
        get {
            return resolvedThemeImage.backgroundColor
        }
        set {
            resolvedThemeImage.backgroundColor = newValue
        }
    }

    override open var usesEPSOnResolutionMismatch: Bool {
        get {
            return resolvedThemeImage.usesEPSOnResolutionMismatch
        }
        set {
            resolvedThemeImage.usesEPSOnResolutionMismatch = newValue
        }
    }

    override open var prefersColorMatch: Bool {
        get {
            return resolvedThemeImage.prefersColorMatch
        }
        set {
            resolvedThemeImage.prefersColorMatch = newValue
        }
    }

    override open var matchesOnMultipleResolution: Bool {
        get {
            return resolvedThemeImage.matchesOnMultipleResolution
        }
        set {
            resolvedThemeImage.matchesOnMultipleResolution = newValue
        }
    }

    override open var matchesOnlyOnBestFittingAxis: Bool {
        get {
            return resolvedThemeImage.matchesOnlyOnBestFittingAxis
        }
        set {
            resolvedThemeImage.matchesOnlyOnBestFittingAxis = newValue
        }
    }
    
    override open var tiffRepresentation: Data? {
        return resolvedThemeImage.tiffRepresentation
    }

    override open func tiffRepresentation(using comp: NSBitmapImageRep.TIFFCompression, factor: Float) -> Data? {
        return resolvedThemeImage.tiffRepresentation(using: comp, factor: factor)
    }

    override open var representations: [NSImageRep] {
        return resolvedThemeImage.representations
    }
    
    override open var isValid: Bool {
        return resolvedThemeImage.isValid
    }

    
    override open var delegate: NSImageDelegate? {
        get {
            return resolvedThemeImage.delegate
        }
        set {
            resolvedThemeImage.delegate = newValue
        }
    }
    
    override open var cacheMode: NSImage.CacheMode {
        get {
            return resolvedThemeImage.cacheMode
        }
        set {
            resolvedThemeImage.cacheMode = newValue
        }
    }
    
    override open var alignmentRect: NSRect {
        get {
            return resolvedThemeImage.alignmentRect
        }
        set {
            resolvedThemeImage.alignmentRect = newValue
        }
    }

    override open var isTemplate: Bool {
        get {
            return resolvedThemeImage.isTemplate
        }
        set {
            resolvedThemeImage.isTemplate = newValue
        }
    }

    override open var accessibilityDescription: String? {
        get {
            return resolvedThemeImage.accessibilityDescription
        }
        set {
            resolvedThemeImage.accessibilityDescription = newValue
        }
    }
    
    override open var capInsets: NSEdgeInsets {
        get {
            return resolvedThemeImage.capInsets
        }
        set {
            resolvedThemeImage.capInsets = newValue
        }
    }

    override open var resizingMode: NSImage.ResizingMode {
        get {
            return resolvedThemeImage.resizingMode
        }
        set {
            resolvedThemeImage.resizingMode = newValue
        }
    }
}


// MARK: -------------覆写父类的方法-----------------
extension KYLThemeImage {
    
    
    override open func setName(_ string: NSImage.Name?) -> Bool {
        return resolvedThemeImage.setName(string)
    }

    override open func name() -> NSImage.Name? {
        return resolvedThemeImage.name()
    }
    
    override open func draw(at point: NSPoint, from fromRect: NSRect, operation op: NSCompositingOperation, fraction delta: CGFloat) {
        resolvedThemeImage.draw(at: point, from: fromRect, operation: op, fraction: delta)
    }

    override open func draw(in rect: NSRect, from fromRect: NSRect, operation op: NSCompositingOperation, fraction delta: CGFloat) {
        resolvedThemeImage.draw(in: rect, from: fromRect, operation: op, fraction: delta)
    }

    override open func draw(in dstSpacePortionRect: NSRect, from srcSpacePortionRect: NSRect, operation op: NSCompositingOperation, fraction requestedAlpha: CGFloat, respectFlipped respectContextIsFlipped: Bool, hints: [NSImageRep.HintKey: Any]?) {
        resolvedThemeImage.draw(in: dstSpacePortionRect, from: srcSpacePortionRect, operation: op, fraction: requestedAlpha, respectFlipped: respectContextIsFlipped, hints: hints)
    }

    override open func drawRepresentation(_ imageRep: NSImageRep, in rect: NSRect) -> Bool {
        return resolvedThemeImage.drawRepresentation(imageRep, in: rect)
    }

    override open func draw(in rect: NSRect) {
        resolvedThemeImage.draw(in: rect)
    }

    override open func recache() {
        resolvedThemeImage.recache()
    }
    
    override open func addRepresentations(_ imageReps: [NSImageRep]) {
        resolvedThemeImage.addRepresentations(imageReps)
    }

    override open func addRepresentation(_ imageRep: NSImageRep) {
        resolvedThemeImage.addRepresentation(imageRep)
    }

    override open func removeRepresentation(_ imageRep: NSImageRep) {
        resolvedThemeImage.removeRepresentation(imageRep)
    }
    
    override open func lockFocus() {
        resolvedThemeImage.lockFocus()
    }

    override open func lockFocusFlipped(_ flipped: Bool) {
        resolvedThemeImage.lockFocusFlipped(flipped)
    }

    override open func unlockFocus() {
        resolvedThemeImage.unlockFocus()
    }

    override open func cancelIncrementalLoad() {
        resolvedThemeImage.cancelIncrementalLoad()
    }

    
    override open func cgImage(forProposedRect proposedDestRect: UnsafeMutablePointer<NSRect>?, context referenceContext: NSGraphicsContext?, hints: [NSImageRep.HintKey: Any]?) -> CGImage? {
        return resolvedThemeImage.cgImage(forProposedRect: proposedDestRect, context: referenceContext, hints: hints)
    }

    override open func bestRepresentation(for rect: NSRect, context referenceContext: NSGraphicsContext?, hints: [NSImageRep.HintKey: Any]?) -> NSImageRep? {
        return resolvedThemeImage.bestRepresentation(for: rect, context: referenceContext, hints: hints)
    }

    override open func hitTest(_ testRectDestSpace: NSRect, withDestinationRect imageRectDestSpace: NSRect, context: NSGraphicsContext?, hints: [NSImageRep.HintKey: Any]?, flipped: Bool) -> Bool {
        return resolvedThemeImage.hitTest(testRectDestSpace, withDestinationRect: imageRectDestSpace, context: context, hints: hints, flipped: flipped)
    }

    override open func recommendedLayerContentsScale(_ preferredContentsScale: CGFloat) -> CGFloat {
        return resolvedThemeImage.recommendedLayerContentsScale(preferredContentsScale)
    }

    override open func layerContents(forContentsScale layerContentsScale: CGFloat) -> Any {
        return resolvedThemeImage.layerContents(forContentsScale: layerContentsScale)
    }
}

#endif

