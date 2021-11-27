//
//  NSMenuItem+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


public extension NSMenuItem {
    typealias ActionClosure = ((NSMenuItem) -> Void)

    private enum AssociatedKeys {
        static let onActionClosure = ObjectAssociation<ActionClosure?>()
    }

    @objc
    private func callClosureGifski(_ sender: NSMenuItem) {
        onAction?(sender)
    }

    /**
    Closure version of `.action`.

    ```
    let menuItem = NSMenuItem(title: "Unicorn")

    menuItem.onAction = { sender in
        print("NSMenuItem action: \(sender)")
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

// MARK: - NSMenuItem 扩展
public extension NSMenuItem {
    convenience init(
        _ title: String,
        action: Selector? = nil,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        data: Any? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false
    ) {
        self.init(title: title, action: action, keyEquivalent: key)
        self.representedObject = data
        self.isEnabled = isEnabled
        self.isChecked = isChecked
        self.isHidden = isHidden

        if let keyModifiers = keyModifiers {
            self.keyEquivalentModifierMask = keyModifiers
        }
    }

    convenience init(
        _ attributedTitle: NSAttributedString,
        action: Selector? = nil,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        data: Any? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false
    ) {
        self.init(
            "",
            action: action,
            key: key,
            keyModifiers: keyModifiers,
            data: data,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden
        )
        self.attributedTitle = attributedTitle
    }

    var isChecked: Bool {
        get { state == .on }
        set {
            state = newValue ? .on : .off
        }
    }
}

#endif
