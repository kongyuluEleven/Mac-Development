//
//  NSView.swift
//  WSUIKit
//
//  Created by Jim Du on 2020/12/30.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 属性
public extension NSView {

    /// 光标位置
    var mouseLocation: NSPoint? {
        guard let point = window?.mouseLocationOutsideOfEventStream else { return nil }
        return self.convert(point, from: nil)
    }

    
    /// 光标是否在视图上
    var isContainsMouse: Bool {
        guard let point = mouseLocation else { return false }
        return bounds.contains(point)
    }

    var isVisibleRectContainsMouse: Bool {
        guard let point = mouseLocation else { return false }
        return visibleRect.contains(point)
    }

    func location(of event: NSEvent) -> NSPoint {
        return self.convert(event.locationInWindow, from: nil)
    }

    func contains(locationOf event: NSEvent) -> Bool {
        return bounds.contains(self.location(of: event))
    }
    
    /// 以屏幕坐标获取视图帧。
    var boundsInScreenCoordinates: CGRect? {
        window?.convertToScreen(convert(bounds, to: nil))
    }

}

// MARK: - 加载xib
extension NSView {
    
    
    /// 从xib中加载一个视图，得到一个视图对象
    /// - Parameters:
    ///   - nibName: xib 的唯一标识名
    ///   - owner: 拥有者
    /// - Returns: 返回一个视图对象
    public class func loadFromNib(nibName: String, owner: Any? = nil) -> NSView? {
        var arrayWithObjects: NSArray?
        let nibLoaded = Bundle.main.loadNibNamed(NSNib.Name(nibName),
                                                 owner: owner,
                                                 topLevelObjects: &arrayWithObjects)
        if nibLoaded {
            return arrayWithObjects?.first(where: { $0 is NSView }) as? NSView
        }
        return nil
    }
}


// MARK: - 视图操作
public extension NSView {
    
    
    /// 获取第一个匹配的子视图
    /// - Parameters:
    ///   - matches: 匹配过滤条件
    ///   - deep: 是否递归遍历
    /// - Returns: 返回第一个满足条件的子视图
    func firstSubview(where matches: (NSView) -> Bool, deep: Bool = false) -> NSView? {
        for subview in subviews {
            if matches(subview) {
                return subview
            }

            if deep, let match = subview.firstSubview(where: matches, deep: deep) {
                return match
            }
        }

        return nil
    }

    /// 添加一组子视图
    ///
    /// - Parameter subviews: array of subviews to add to self.
    func addSubviews(_ subviews: [NSView]) {
        subviews.forEach { addSubview($0) }
    }

    /// 删除所有子视图
    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    
    /// 将视图移动到第一层
    func bringToFront() {
        if let layer = layer, let superlayer = layer.superlayer {
            layer.removeFromSuperlayer()
            superlayer.addSublayer(layer)
        } else if let superview = superview {
            self.removeFromSuperview()
            superview.addSubview(self)
        }
    }

    
    /// 将视图移动到后面一层
    func sendToBack() {
        if let layer = layer, let superlayer = layer.superlayer {
            layer.removeFromSuperlayer()
            superlayer.insertSublayer(layer, below: superlayer.sublayers?.first)
        } else if let superview = superview {
            self.removeFromSuperview()
            superview.addSubview(self, positioned: .below, relativeTo: superview.subviews.first)
        }
    }

}

// MARK: - 视图插入

public extension NSView {
    ///为界面中的视图添加半透明和活力效果的视图。
    @discardableResult
    func insertVibrancyView(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        appearanceName: NSAppearance.Name? = nil
    ) -> NSVisualEffectView {
        let view = NSVisualEffectView(frame: bounds)
        view.autoresizingMask = [.width, .height]
        view.material = material
        view.blendingMode = blendingMode

        if let appearanceName = appearanceName {
            view.appearance = NSAppearance(named: appearanceName)
        }

        addSubview(view, positioned: .below, relativeTo: nil)

        return view
    }
}


public extension NSView {
    private final class AddedToSuperviewObserverView: NSView {
        var onAdded: (() -> Void)?

        override var acceptsFirstResponder: Bool { false }

        convenience init() {
            self.init(frame: .zero)
        }

        override func viewDidMoveToWindow() {
            guard window != nil else {
                return
            }

            onAdded?()
            removeFromSuperview()
        }
    }

    
    /// 添加一个子视图到父视图上，可以携带一个尾随闭包，当视图被移除时触发回调
    /// - Parameter closure: 尾随闭包
    func onAddedToSuperview(_ closure: @escaping () -> Void) {
        let view = AddedToSuperviewObserverView()
        view.onAdded = closure
        addSubview(view)
    }
}

#endif
