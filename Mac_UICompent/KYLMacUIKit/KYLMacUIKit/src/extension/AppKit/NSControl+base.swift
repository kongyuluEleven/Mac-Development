//
//  NSControl+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


// MARK: - 通用方法

public extension NSControl {
    
    /// 获取焦点
    func focus() {
        window?.makeFirstResponder(self)
    }
    /// 触发的action '选择器在控件上。
    func triggerAction() {
        sendAction(action, to: target)
    }
}

// MARK: - 方法

extension NSControl {
    typealias ActionClosure = ((NSControl) -> Void)

    private enum AssociatedKeys {
        static let onActionClosure = ObjectAssociation<ActionClosure?>()
    }

    @objc
    private func callClosureGifski(_ sender: NSControl) {
        onAction?(sender)
    }

    /**
    Closure version of `.action`.

    ```
    let button = NSButton(title: "Unicorn", target: nil, action: nil)

    button.onAction = { sender in
        print("Button action: \(sender)")
    }
    ```
    */
    var onAction: ActionClosure? {
        get { AssociatedKeys.onActionClosure[self] }
        set {
            AssociatedKeys.onActionClosure[self] = newValue
            action = #selector(callClosureGifski)
            target = self
        }
    }
}

#endif
