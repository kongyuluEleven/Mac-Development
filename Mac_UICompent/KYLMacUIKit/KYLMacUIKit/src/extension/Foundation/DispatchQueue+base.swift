//
//  DispatchQueue+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Cocoa)
import Cocoa

extension DispatchQueue {
    
    /// 延迟执行闭包
    ///
    ///
    ///    ```
    ///    DispatchQueue.main.asyncAfter(duration: 100.milliseconds) {
    ///         print("100 ms later")
    ///    }
    ///    ```
    /// - Parameters:
    ///   - duration: 延迟的时间毫秒数
    ///   - execute: 延迟执行的闭包
    func asyncAfter(duration: TimeInterval, execute: @escaping () -> Void) {
        asyncAfter(deadline: .now() + duration, execute: execute)
    }
}

extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    /// 确保闭包块只运行一次
    /// - Parameters:
    ///   - token: 标识符，可以不填
    ///   - block: 需要运行的闭包
    /// - Returns: 返回空的闭包
    public class func once(token: String =  "\(#file):\(#function):\(#line)", block: () -> ()) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
    
    
    /// 延迟在主线程中执行
    /// - Parameters:
    ///   - seconds: 需要延迟的秒数，单位秒
    ///   - closure: 延迟执行的闭包
    public class func delay(seconds: TimeInterval, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
    }
    

    
    /// 确保在主线程中执行
    /// 如果我们在主线程上，则立即执行' execute '闭包，否则同步地将其放到主线程上。
    /// - Parameter work: 需要运行的闭包
    /// - Throws: 发生异常时抛出异常
    /// - Returns: 返回模板T
    @discardableResult
    
    static func mainSafeSync<T>(execute work: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try work()
        } else {
            return try main.sync(execute: work)
        }
    }
}


#endif
