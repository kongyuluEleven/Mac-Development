//
//  NSView+layer.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


// MARK: - Properties

public extension NSView {
    /// 边框颜色
    var layerBorderColor: NSColor? {
        get {
            guard let color = layer?.borderColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.borderColor = newValue?.cgColor
        }
    }

    /// 边框宽度
    var layerBorderWidth: CGFloat {
        get {
            return layer?.borderWidth ?? 0
        }
        set {
            wantsLayer = true
            layer?.borderWidth = newValue
        }
    }

    /// 圆角大小
    var layerCornerRadius: CGFloat {
        get {
            return layer?.cornerRadius ?? 0
        }
        set {
            wantsLayer = true
            layer?.masksToBounds = true
            layer?.cornerRadius = newValue.magnitude
        }
    }


    /// 阴影颜色
    var layerShadowColor: NSColor? {
        get {
            guard let color = layer?.shadowColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.shadowColor = newValue?.cgColor
        }
    }

    /// 阴影偏移值
    var layerShadowOffset: CGSize {
        get {
            return layer?.shadowOffset ?? CGSize.zero
        }
        set {
            wantsLayer = true
            layer?.shadowOffset = newValue
        }
    }

    /// 阴影透明度
    var layerShadowOpacity: Float {
        get {
            return layer?.shadowOpacity ?? 0
        }
        set {
            wantsLayer = true
            layer?.shadowOpacity = newValue
        }
    }

    /// 阴影圆角
    var layerShadowRadius: CGFloat {
        get {
            return layer?.shadowRadius ?? 0
        }
        set {
            wantsLayer = true
            layer?.shadowRadius = newValue
        }
    }

    /// 背景颜色
    var layerBackgroundColor: NSColor? {
        get {
            if let colorRef = layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }

}

// MARK: 圆角，背景
extension NSView {
    
    func blur(material: NSVisualEffectView.Material) {
        unBlur()
        let blurEffectView = NSVisualEffectView()
        blurEffectView.material = material
        addSubview(blurEffectView)
    }

    func unBlur() {
        subviews.filter { (view) -> Bool in
            view as? NSVisualEffectView != nil
        }.forEach { (view) in
            view.removeFromSuperview()
        }
    }
    
}


#endif
