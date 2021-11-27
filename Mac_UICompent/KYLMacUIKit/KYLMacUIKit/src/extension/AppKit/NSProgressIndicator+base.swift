//
//  NSProgressIndicator+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

//MARK: - 属性
public extension NSProgressIndicator {
    
}

//MARK: - 方法
public extension NSProgressIndicator {
    
    /// 开始渐变动画
    /// - Parameter duration: 动画执行时间
    
    func startFadeAnimation(_ duration: TimeInterval) {
        if #available(OSX 10.12, *) {
            self.alphaValue = 0.0
            self.startAnimation(nil)
            NSAnimationContext.runAnimationGroup { (context) in
                context.duration = duration
                self.animator().alphaValue = 1.0
            }
        }
    }
    
}


#endif
