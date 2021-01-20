//
//  NSView+Animation.swift
//  WSUIKit
//
//  Created by kongyulu on 2021/1/19.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

#if canImport(QuartzCore)
import QuartzCore
#endif



// MARK: - 基础动画
public extension NSView {
    func shake(duration: TimeInterval = 0.3, direction: NSUserInterfaceLayoutOrientation) {
        let translation = direction == .horizontal ? "x" : "y"
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.\(translation)")
        //animation.timingFunction = .linear
        animation.duration = duration
        animation.values = [-5, 5, -2.5, 2.5, 0]
        layer?.add(animation, forKey: nil)
    }
}

//@available(macOS 10.5, *)
//extension CAMediaTimingFunction {
//    static let `default` = CAMediaTimingFunction(name: .default)
//    static let linear = CAMediaTimingFunction(name: .linear)
//    static let easeIn = CAMediaTimingFunction(name: .easeIn)
//    static let easeOut = CAMediaTimingFunction(name: .easeOut)
//    static let easeInOut = CAMediaTimingFunction(name: .easeInEaseOut)
//}


public extension NSView {
    
    static func animate(
        duration: TimeInterval = 1,
        delay: TimeInterval = 0,
        //timingFunction: CAMediaTimingFunction = .default,
        animations: @escaping (() -> Void),
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(duration: delay) {
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = duration
                //context.timingFunction = timingFunction
                animations()
            }, completionHandler: completion)
        }
    }

    func fadeIn(
        duration: TimeInterval = 1,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        isHidden = true

        NSView.animate(
            duration: duration,
            delay: delay,
            animations: { [self] in
                self.isHidden = false
            },
            completion: completion
        )
    }

    func fadeOut(
        duration: TimeInterval = 1,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        isHidden = false

        NSView.animate(
            duration: duration,
            delay: delay,
            animations: { [self] in
                self.alphaValue = 0
            },
            completion: { [self] in
                self.isHidden = true
                self.alphaValue = 1
                completion?()
            }
        )
    }
}


// MARK: - 核心动画
public extension NSView {
    
}



#endif
