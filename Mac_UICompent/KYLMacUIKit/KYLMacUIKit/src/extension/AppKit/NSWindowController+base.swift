//
//  NSWindowController+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit



public extension NSWindowController {
    /// 像在NSViewController中一样暴露视图。
    var view: NSView? { window?.contentView }
}

// MARK: - NSViewController xib
public extension NSViewController {
    
    class func loadNib() -> Self {
        return self.init(nibName: NSNib.Name(className()), bundle: nil)
    }
}


// MARK: - NSWindowController xib
public extension NSWindowController {
    
    func nibName() -> NSNib.Name {
        return NSNib.Name( NSWindowController.className())
    }
    
    class func loadNib<T>() -> T {
        return Self.init(windowNibName: NSNib.Name(Self.className()) ) as! T
    }
}


private var controlActionClosureProtocolAssociatedObjectKey: UInt8 = 0

protocol ControlActionClosureProtocol: NSObjectProtocol {
    var target: AnyObject? { get set }
    var action: Selector? { get set }
}

private final class ActionTrampoline<T>: NSObject {
    let action: (T) -> Void

    init(action: @escaping (T) -> Void) {
        self.action = action
    }

    @objc
    func action(sender: AnyObject) {
        action(sender as! T)
    }
}

extension ControlActionClosureProtocol {
    /**
    Closure version of `.action`

    ```
    let button = NSButton(title: "Unicorn", target: nil, action: nil)

    button.onAction { sender in
        print("Button action: \(sender)")
    }
    ```
    */
    func onAction(_ action: @escaping (Self) -> Void) {
        let trampoline = ActionTrampoline(action: action)
        target = trampoline
        self.action = #selector(ActionTrampoline<Self>.action(sender:))
        objc_setAssociatedObject(self, &controlActionClosureProtocolAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
    }
}

extension NSControl: ControlActionClosureProtocol {}
extension NSMenuItem: ControlActionClosureProtocol {}
extension NSToolbarItem: ControlActionClosureProtocol {}
extension NSGestureRecognizer: ControlActionClosureProtocol {}


/**
Creates a window controller that can only ever have one window.

This can be useful when you need there to be only one window of a type, for example, a settings window. If the window already exists, and you call `.showWindow()`, it will instead just focus the existing window.

- Important: Don't create an instance of this. Instead, call the static `.showWindow()` method. Also mark your `convenience init` as `private` so you don't accidentally call it.

```
final class SettingsWindowController: SingletonWindowController {
    private convenience init() {
        let window = NSWindow()
        self.init(window: window)

        window.center()
    }
}

// …

SettingsWindowController.showWindow()
```
*/
class SingletonWindowController: NSWindowController, NSWindowDelegate { // swiftlint:disable:this final_class
//    private static var instances = [HashableType<SingletonWindowController>: SingletonWindowController]()

//    private static var currentInstance: SingletonWindowController {
//        guard let instance = instances[self] else {
//            let instance = self.init()
//            instances[self] = instance
//            return instance
//        }
//
//        return instance
//    }

//    static var window: NSWindow? {
//        get {
//            currentInstance.window
//        }
//        set {
//            currentInstance.window = newValue
//        }
//    }

//    static func showWindow() {
//        // Menu bar apps need to be activated, otherwise, things like input focus doesn't work.
//        if NSApp.activationPolicy() == .accessory {
//            NSApp.activate(ignoringOtherApps: true)
//        }
//
//        window?.makeKeyAndOrderFront(nil)
//    }

    override init(window: NSWindow?) {
        super.init(window: window)
        window?.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func windowWillClose(_ notification: Notification) {
        //Self.instances[Self] = nil
    }

    @available(*, unavailable)
    override func showWindow(_ sender: Any?) {}
}


#endif
