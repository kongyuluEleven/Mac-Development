//
//  NSColor+Theme.swift
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
 当在' WSThemeColor '扩展中重写颜色时，' NSColor '扩展可以提供帮助。
 */
extension NSColor {

    // MARK: -
    // MARK: Color override

    /// 和NSColor通过运行时做方法交换，这样我们用可主题的颜色替换系统颜色
    @objc static func swizzleNSColor() {
        swizzleNSColorOnce
    }

    /// 执行方法交换，只交换NSDynamicSystemColor的三个方法set，setFill，setStroke，这段代码只执行一次(即使多次调用)。
    private static let swizzleNSColorOnce: Void = {
        // swizzle only if needed
        guard needsSwizzling else { return }

        // swizzle NSColor methods
        swizzleInstanceMethod(cls: NSClassFromString("NSDynamicSystemColor"), selector: #selector(set), withSelector: #selector(themeKitSet))
        swizzleInstanceMethod(cls: NSClassFromString("NSDynamicSystemColor"), selector: #selector(setFill), withSelector: #selector(themeKitSetFill))
        swizzleInstanceMethod(cls: NSClassFromString("NSDynamicSystemColor"), selector: #selector(setStroke), withSelector: #selector(themeKitSetStroke))
    }()

    /// 检查WSThemeColor扩展中是否覆盖了颜色。
    @objc public var isThemeOverriden: Bool {

        // 检查' NSColor '是否提供这种颜色
        let selector = Selector(localizedColorNameComponent)
        let nsColorMethod = class_getClassMethod(NSColor.classForCoder(), selector)
        guard nsColorMethod != nil else {
            return false
        }

        // 获取当前主题
        let theme = KYLThemeManager.shared.effectiveTheme

        // ' 用户自定义主题WSUserTheme ':检查' hasThemeAsset(_:) '方法
        if let userTheme = theme as? KYLUserTheme {
            return userTheme.hasThemeAsset(localizedColorNameComponent)
        } else {
            // 原生主题:查找实例方法
            let themeClass: AnyClass = object_getClass(theme)!
            let themeColorMethod = class_getInstanceMethod(themeClass, selector)
            return themeColorMethod != nil && nsColorMethod != themeColorMethod
        }
    }

    /// 获取所有的NSColor颜色方法。
    /// 可重写的类方法(可在扩展名' WSThemeColor '中重写)
    @objc public class func colorMethodNames() -> [String] {
        let nsColorMethods = NSObject.classMethodNames(for: NSColor.classForCoder()).filter { (methodName) -> Bool in
            return methodName.hasSuffix("Color")
        }
        return nsColorMethods
    }

    // MARK: - Private

    /// 检查我们是否需要调色NSDynamicSystemColor类。
    private class var needsSwizzling: Bool {
        let themeColorMethods = classMethodNames(for: KYLThemeColor.classForCoder()).filter { (methodName) -> Bool in
            return methodName.hasSuffix("Color")
        }
        let nsColorMethods = classMethodNames(for: NSColor.classForCoder()).filter { (methodName) -> Bool in
            return methodName.hasSuffix("Color")
        }

        // 检查NSColor ' *Color '类方法是否被重写
        for colorMethod in themeColorMethods {
            if nsColorMethods.contains(colorMethod) {
                // 使用“colorMethod”选择器的主题颜色覆盖了需要>交换了的“NSColor”方法。
                return true
            }
        }

        return false
    }

    // WSUIKit.set() 替换使用主题感知的颜色
    @objc public func themeKitSet() {
        // 调用原始的 .set() 函数
        themeKitSet()

        // 检查用户是否提供了另一种颜色
        if KYLThemeManager.shared.isEnabled && isThemeOverriden {
            // 调用 WSThemeColor.set() 方法
            KYLThemeColor.color(with: Selector(localizedColorNameComponent)).set()
        }
    }

    // WSUIKit.setFill() 替换使用主题感知的颜色
    @objc public func themeKitSetFill() {
        // 调用原始的 .setFill() 函数
        themeKitSetFill()

        // 检查用户是否提供了另一种颜色
        if KYLThemeManager.shared.isEnabled && isThemeOverriden {
            // 调用 WSThemeColor.setFill() 方法
            KYLThemeColor.color(with: Selector(localizedColorNameComponent)).setFill()
        }
    }

    // WSUIKit.setStroke() 替换使用主题感知的颜色
    @objc public func themeKitSetStroke() {
        // 调用原始的 .setStroke() 函数
        themeKitSetStroke()

        // 检查用户是否提供了另一种颜色
        if KYLThemeManager.shared.isEnabled && isThemeOverriden {
            // 调用 WSThemeColor.setStroke() 方法
            KYLThemeColor.color(with: Selector(localizedColorNameComponent)).setStroke()
        }
    }

}


//MARK: - 运行时方法交换
fileprivate extension NSObject {
    
    /// 交换实例方法
    /// - Parameters:
    ///   - cls: 类名
    ///   - originalSelector: 原始方法
    ///   - swizzledSelector: 需要交换的方法
    @objc  class func swizzleInstanceMethod(cls: AnyClass?, selector originalSelector: Selector, withSelector swizzledSelector: Selector) {
        guard cls != nil else {
            print("Unable to swizzle \(originalSelector): dynamic system color override will not be available.")
            return
        }

        // methods
        let originalMethod = class_getInstanceMethod(cls, originalSelector)
        let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)

        // add new method
        let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))

        // switch implementations
        if didAddMethod {
            class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    
    /// 获取类的类方法名列表
    /// - Parameter cls: 类名
    /// - Returns: 返回该类的类方法列表
    @objc  class func classMethodNames(for cls: AnyClass?) -> [String] {
        var results: [String] = []
        
        //检索类方法列表
        var count: UInt32 = 0
        if let methods: UnsafeMutablePointer<Method> = class_copyMethodList(object_getClass(cls), &count) {
            //枚举类方法
            for i in 0..<count {
                let name = NSStringFromSelector(method_getName(methods[Int(i)]))
                results.append(name)
            }
            //释放内存
            free(methods)
        }
        
        return results
    }
    
    
    /// 获取类列表
    /// - Returns: 返回类列表
    @objc  static func classList() -> [AnyClass] {
        var results: [AnyClass] = []
        
        //获取类数量
        let expectedCount: Int32 = objc_getClassList(nil, 0)
        
        //检索类列表
        let buffer = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedCount))
        let realCount: Int32 = objc_getClassList(AutoreleasingUnsafeMutablePointer<AnyClass>(buffer), expectedCount)
        
        //枚举所有类
        for i in 0..<realCount {
            if let cls: AnyClass = buffer[Int(i)] {
                results.append(cls)
            }
        }
        
        //释放内存
        buffer.deallocate()
        
        return results
    }

    
    /// 获取实现指定协议的类列表
    /// - Parameter aProtocol: 协议
    /// - Returns: 返回所有实现指定协议的类
    @objc  static func classesImplementingProtocol(_ aProtocol: Protocol) -> [AnyClass] {
        let classes = classList()
        var results = [AnyClass]()
        
        //枚举所有类
        for cls  in classes {
            if class_conformsToProtocol(cls, aProtocol) {
                results.append(cls)
            }
        }
        
        return results
    }
}


#endif
