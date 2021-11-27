//
//  NSObject+runtime.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

//MARK: - 运行时方法交换
public extension NSObject {
    
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
