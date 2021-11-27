//
//  NSView+animation.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
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
        timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "default") ),
        animations: @escaping (() -> Void),
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(duration: delay) {
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = duration
                context.timingFunction = timingFunction
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


// MARK: - 核心动画 - CAReplicatorLayer
public extension NSView {
    
    /// 直方图动画
    func histogramAnimation() {
        let lay = CAReplicatorLayer()
        lay.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        lay.position = self.center
        lay.backgroundColor = NSColor.clear.cgColor
        self.layer?.addSublayer(lay)
        let bar = CALayer()
        bar.bounds = CGRect(x: 0, y: 0, width: 8.0, height: 40.0)
        bar.position = CGPoint(x: 10, y: 75)
        bar.cornerRadius = 2.0
        bar.backgroundColor = NSColor.red.cgColor
        lay.addSublayer(bar)
        let move = CABasicAnimation(keyPath: "position.y")
        move.toValue = bar.position.y - 35.0
        move.duration = 0.5
        move.autoreverses = true
        move.repeatCount = Float.infinity
        bar.add(move, forKey: nil)
        lay.instanceCount = 3
        lay.instanceDelay = 0.33
        lay.masksToBounds = true
        lay.instanceTransform = CATransform3DMakeTranslation(10.0, 0, 0)
    }
    
    
    /// 环形转圈动画
    func circleRingAnimation() {
        let lay = CAReplicatorLayer();
        lay.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
        lay.cornerRadius = 10
        lay.backgroundColor = NSColor(white: 0.0, alpha: 0.75).cgColor
        lay.position = self.center
        self.layer?.addSublayer(lay)
        let dot = CALayer()
        dot.bounds = CGRect(x: 0, y: 0, width: 14, height: 14)
        dot.position = CGPoint(x:100,y:40)
        dot.backgroundColor = NSColor(white: 0.8, alpha: 1.0).cgColor
        dot.backgroundColor = NSColor.white.cgColor
        dot.borderWidth = 1.0
        dot.cornerRadius = 2.0
        lay.addSublayer(dot)
        let dot_no:Int = 15
        lay.instanceCount = dot_no
        let dot_angle = CGFloat(2 * CGFloat.pi)/CGFloat(dot_no)
        lay.instanceTransform = CATransform3DMakeRotation(dot_angle, 0, 0, 1.0)
        let duration:CFTimeInterval = 1.5
        let scale_animation = CABasicAnimation(keyPath:"transform.scale")
        scale_animation.fromValue = 1.0
        scale_animation.toValue = 0.1
        scale_animation.duration = duration
        scale_animation.repeatCount = Float.infinity
        dot.add(scale_animation, forKey: nil)
        lay.instanceDelay = duration/Double(dot_no)
        dot.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
    }

    
    /// 粒子贝塞尔曲线动画
    func particleAnimation() {
        let lay = CAReplicatorLayer()
        lay.bounds = self.bounds
        lay.backgroundColor = NSColor(white:0.0,alpha:0.75).cgColor
        lay.position = self.center
        lay.anchorPoint = CGPoint(x: 0.5, y: 0)
        self.layer?.addSublayer(lay)
        let dot = CALayer()
        dot.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        dot.backgroundColor = NSColor(white: 0.8, alpha: 1.0).cgColor
        dot.borderColor = NSColor.white.cgColor
        dot.borderWidth = 1.0
        dot.cornerRadius = 5.0
        dot.shouldRasterize = true
        lay.addSublayer(dot)
        let move = CAKeyframeAnimation(keyPath:"position")
        move.path = particleAnimationpath()
        move.repeatCount = Float.infinity
        move.duration = 4.0
        dot.add(move, forKey: nil)
        lay.instanceCount = 20
        lay.instanceDelay = 0.1
    }
    
    private func particleAnimationpath()->CGPath {
        let pth = NSBezierPath()
        pth.move(to: CGPoint(x: 31.5, y: 71.5))
        pth.line(to: CGPoint(x: 31.5, y: 23.5))
        pth.curve(to: CGPoint(x: 58.5, y: 38.5), controlPoint1: CGPoint(x: 31.5, y: 23.5), controlPoint2: CGPoint(x: 53.5, y: 45.5))

        pth.line(to: CGPoint(x: 43.5, y: 48.5) )
        pth.line(to: CGPoint(x: 53.5, y: 66.5))
        pth.line(to: CGPoint(x: 62.5, y: 51.5))
        pth.line(to: CGPoint(x: 70.5, y: 66.5))
        pth.line(to: CGPoint(x: 86.5, y: 23.5))
        pth.line(to: CGPoint(x: 86.5, y: 78.5))
        pth.line(to: CGPoint(x: 31.5, y: 78.5))
        pth.line(to: CGPoint(x: 31.5, y: 71.5))

        pth.close()
        var t = CGAffineTransform(scaleX: 3.0,y: 3.0)
        return pth.cgPath.copy(using: &t)!
    }
}


// MARK: - 核心动画
public extension NSView {
    
}



#endif
