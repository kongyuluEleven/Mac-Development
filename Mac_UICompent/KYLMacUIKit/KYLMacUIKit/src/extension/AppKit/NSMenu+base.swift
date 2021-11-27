//
//  NSMenu+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension NSWindow.Level {
    private static func level(for cgLevelKey: CGWindowLevelKey) -> Self {
        .init(rawValue: Int(CGWindowLevelForKey(cgLevelKey)))
    }

    static let desktop = level(for: .desktopWindow)
    static let desktopIcon = level(for: .desktopIconWindow)
    static let backstopMenu = level(for: .backstopMenu)
    static let dragging = level(for: .draggingWindow)
    static let overlay = level(for: .overlayWindow)
    static let help = level(for: .helpWindow)
    static let utility = level(for: .utilityWindow)
    static let assistiveTechHigh = level(for: .assistiveTechHighWindow)
    static let cursor = level(for: .cursorWindow)

    static let minimum = level(for: .minimumWindow)
    static let maximum = level(for: .maximumWindow)
}


public final class WSMenu: NSMenu, NSMenuDelegate {
    var onOpen: (() -> Void)?
    var onClose: (() -> Void)?
    var onUpdate: ((NSMenu) -> Void)? {
        didSet {
            // Need to update it here, otherwise it's
            // positioned incorrectly on the first open.
            onUpdate?(self)
        }
    }

    private(set) var isOpen = false

    override init(title: String) {
        super.init(title: title)
        self.delegate = self
        self.autoenablesItems = false
    }

    @available(*, unavailable)
    required init(coder decoder: NSCoder) {
        fatalError("because: .notYetImplemented")
    }

    public func menuWillOpen(_ menu: NSMenu) {
        isOpen = true
        onOpen?()
    }

    public func menuDidClose(_ menu: NSMenu) {
        isOpen = false
        onClose?()
    }

    public func menuNeedsUpdate(_ menu: NSMenu) {
        onUpdate?(menu)
    }
}

// MARK: - CallbackMenuItem 回调
public final class CallbackMenuItem: NSMenuItem {
    private static var validateCallback: ((NSMenuItem) -> Bool)?

    static func validate(_ callback: @escaping (NSMenuItem) -> Bool) {
        validateCallback = callback
    }

    init(
        _ title: String,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        data: Any? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false,
        callback: @escaping (NSMenuItem) -> Void
    ) {
        self.callback = callback
        super.init(title: title, action: #selector(action(_:)), keyEquivalent: key)
        self.target = self
        self.isEnabled = isEnabled
        self.isChecked = isChecked
        self.isHidden = isHidden

        if let keyModifiers = keyModifiers {
            self.keyEquivalentModifierMask = keyModifiers
        }
    }

    @available(*, unavailable)
    required init(coder decoder: NSCoder) {
        fatalError("because: .notYetImplemented")
    }

    private let callback: (NSMenuItem) -> Void

    @objc
    func action(_ sender: NSMenuItem) {
        callback(sender)
    }
}

//extension CallbackMenuItem: NSMenuItemValidation {
//    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
//        Self.validateCallback?(menuItem) ?? true
//    }
//}




// MARK: - NSMenu 扩展
public extension NSMenu {
    /// Get the `NSMenuItem` that has this menu as a submenu.
    var parentMenuItem: NSMenuItem? {
        guard let supermenu = supermenu else {
            return nil
        }

        let index = supermenu.indexOfItem(withSubmenu: self)
        return supermenu.item(at: index)
    }

    /// Get the item with the given identifier.
    func item(withIdentifier identifier: NSUserInterfaceItemIdentifier) -> NSMenuItem? {
        for item in items where item.identifier == identifier {
            return item
        }

        return nil
    }

    /// Remove the first item in the menu.
    func removeFirstItem() {
        removeItem(at: 0)
    }

    /// Remove the last item in the menu.
    func removeLastItem() {
        removeItem(at: numberOfItems - 1)
    }

    func addSeparator() {
        addItem(.separator())
    }

    @discardableResult
    func add(_ menuItem: NSMenuItem) -> NSMenuItem {
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addDisabled(_ title: String) -> NSMenuItem {
        let menuItem = NSMenuItem(title)
        menuItem.isEnabled = false
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addDisabled(_ attributedTitle: NSAttributedString) -> NSMenuItem {
        let menuItem = NSMenuItem(attributedTitle)
        menuItem.isEnabled = false
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addItem(
        _ title: String,
        action: Selector? = nil,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        data: Any? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false
    ) -> NSMenuItem {
        let menuItem = NSMenuItem(
            title,
            action: action,
            key: key,
            keyModifiers: keyModifiers,
            data: data,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden
        )
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addItem(
        _ attributedTitle: NSAttributedString,
        action: Selector? = nil,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        data: Any? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false
    ) -> NSMenuItem {
        let menuItem = NSMenuItem(
            attributedTitle,
            action: action,
            key: key,
            keyModifiers: keyModifiers,
            data: data,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden
        )
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addCallbackItem(
        _ title: String,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        data: Any? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false,
        callback: @escaping (NSMenuItem) -> Void
    ) -> NSMenuItem {
        let menuItem = CallbackMenuItem(
            title,
            key: key,
            keyModifiers: keyModifiers,
            data: data,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden,
            callback: callback
        )
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addCallbackItem(
        _ title: NSAttributedString,
        key: String = "",
        keyModifiers: NSEvent.ModifierFlags? = nil,
        data: Any? = nil,
        isEnabled: Bool = true,
        isChecked: Bool = false,
        isHidden: Bool = false,
        callback: @escaping (NSMenuItem) -> Void
    ) -> NSMenuItem {
        let menuItem = CallbackMenuItem(
            "",
            key: key,
            keyModifiers: keyModifiers,
            data: data,
            isEnabled: isEnabled,
            isChecked: isChecked,
            isHidden: isHidden,
            callback: callback
        )
        menuItem.attributedTitle = title
        addItem(menuItem)
        return menuItem
    }

    @discardableResult
    func addUrlItem(_ title: String, url: URL) -> NSMenuItem {
        addCallbackItem(title) { _ in
            NSWorkspace.shared.open(url)
        }
    }

    @discardableResult
    func addUrlItem(_ title: NSAttributedString, url: URL) -> NSMenuItem {
        addCallbackItem(title) { _ in
            NSWorkspace.shared.open(url)
        }
    }

    @discardableResult
    func addDefaultsItemForBool(
        _ title: String,
        key: String,
        isEnabled: Bool = true,
        callback: ((NSMenuItem) -> Void)? = nil
    ) -> NSMenuItem {
        let bool = UserDefaults.standard.bool(forKey: key)
        return addCallbackItem(
            title,
            isEnabled: isEnabled,
            isChecked: bool
        ) { item in
            UserDefaults.standard.set(!bool, forKey: key)
            callback?(item)
        }
    }

    @discardableResult
    func addAboutItem() -> NSMenuItem {
        addCallbackItem("About") {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.orderFrontStandardAboutPanel($0)
        }
    }

    @discardableResult
    func addQuitItem() -> NSMenuItem {
        addSeparator()

        return addCallbackItem("Quit \(Bundle.name)", key: "q") { _ in
            NSApp.terminate(nil)
        }
    }
}


#endif
