//
//  Thread+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

public extension Thread {

    /// 确保代码块在主线程上执行
    @objc class func onMain(block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }

}

#endif
