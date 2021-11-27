//
//  CALayer+Animation.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if !os(watchOS) && !os(Linux) && canImport(QuartzCore)
import QuartzCore

#if canImport(AppKit)
import AppKit
#endif

// MARK: - 添加动画
public extension CALayer {
    
    /// 添加渐变颜色动画
    /// - Parameters:
    ///   - color: 颜色
    ///   - keyPath: 关键路径
    ///   - duration: 执行时间
    func addColorAnimate(color: NSColor, for keyPath: String, with duration: Double) {
        if color.cgColor != value(forKey: keyPath) as! CGColor  {return}
        
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.toValue = color.cgColor
        animation.fromValue = value(forKey: keyPath)
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        add(animation, forKey: keyPath)
        setValue(color.cgColor, forKey: keyPath)
    }
    
    
    /// 缩放移动动画
    /// - Parameters:
    ///   - fromScale: 缩放比例
    ///   - fromX: 移动的X坐标
    ///   - fromY: 移动的Y坐标
    func animateScaleMove(fromScale: Double, fromX: Double? = nil, fromY: Double? = nil) {
        let fromX = fromX?.cgFloat ?? bounds.size.width / 2
        let fromY = fromY?.cgFloat ?? bounds.size.height / 2

        let springAnimation = CASpringAnimation(keyPath: #keyPath(CALayer.transform))

        var tr = CATransform3DIdentity
        tr = CATransform3DTranslate(tr, fromX, fromY, 0)
        tr = CATransform3DScale(tr, CGFloat(fromScale), CGFloat(fromScale), 1)
        tr = CATransform3DTranslate(tr, -bounds.size.width / 2, -bounds.size.height / 2, 0)

        springAnimation.damping = 15
        springAnimation.mass = 0.9
        springAnimation.initialVelocity = 1
        springAnimation.duration = springAnimation.settlingDuration

        springAnimation.fromValue = NSValue(caTransform3D: tr)
        springAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)

        add(springAnimation, forKey: "")
    }
}


#endif
