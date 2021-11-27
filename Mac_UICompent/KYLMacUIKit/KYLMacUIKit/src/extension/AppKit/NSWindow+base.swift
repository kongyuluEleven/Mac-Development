//
//  NSWindow+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 属性

//public extension NSWindow {
//    var toolbarView: NSView? { standardWindowButton(.closeButton)?.superview }
//    var titlebarView: NSView? { toolbarView?.superview }
//    var titlebarHeight: Double { Double(titlebarView?.bounds.height ?? 0) }
//}

public extension NSWindow {
    private static func centeredOnScreen(rect: CGRect) -> CGRect {
        guard let screen = NSScreen.main else {
            return rect
        }

        // Looks better than perfectly centered.
        let yOffset = 0.12

        return rect.centered(in: screen.visibleFrame, xOffsetPercent: 0, yOffsetPercent: yOffset)
    }

    static let defaultContentSize = CGSize(width: 480, height: 300)

    static var defaultContentRect: CGRect {
        centeredOnScreen(rect: defaultContentSize.cgRect)
    }

    static let defaultStyleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]

    static func centeredWindow(size: CGSize = defaultContentSize) -> Self {
        let window = self.init(
            contentRect: NSWindow.defaultContentRect,
            styleMask: NSWindow.defaultStyleMask,
            backing: .buffered,
            defer: true
        )
        window.setContentSize(size)
        window.centerNatural()
        return window
    }
}


// MARK: - 方法

public extension NSWindow {
    convenience init(contentRect: CGRect) {
        self.init(contentRect: contentRect,
                  styleMask: NSWindow.defaultStyleMask,
                  backing: .buffered,
                  defer: true)
    }

    /// 将窗口移动到屏幕的中央，比' window#center() '稍微居中一些。
    func centerNatural() {
        setFrame(NSWindow.centeredOnScreen(rect: frame), display: true)
    }
}

public extension NSWindow {
    private enum AssociatedKeys {
        static let observationToken = ObjectAssociation<NSKeyValueObservation?>()
    }

    func makeVibrant() {
        // NSWindow似乎已经创建了一个视觉效果视图。
        // 如果我们能把自己和它联系起来，使它充满活力
        // 如果没有，让我们添加我们的视图作为第一个，所以它是充满活力的。
        if let visualEffectView = contentView?.superview?.subviews.lazy.compactMap({ $0 as? NSVisualEffectView }).first {
            visualEffectView.blendingMode = .behindWindow
            if #available(OSX 10.14, *) {
                visualEffectView.material = .underWindowBackground
            } else {
                // Fallback on earlier versions
            }

            AssociatedKeys.observationToken[self] = visualEffectView.observe(\.effectiveAppearance) { _, _ in
                visualEffectView.blendingMode = .behindWindow
                if #available(OSX 10.14, *) {
                    visualEffectView.material = .underWindowBackground
                } else {
                    // Fallback on earlier versions
                }
            }
        } else {
            if #available(OSX 10.14, *) {
                contentView?.superview?.insertVibrancyView(material: .underWindowBackground)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}


#endif
