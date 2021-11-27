//
//  NSStatusBar+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


public extension NSStatusBar {
    /// Whether the user has "Automatically hide and show the menu bar" enabled in system preferences.
    static var isAutomaticallyToggled: Bool {
        guard let screen = NSScreen.primary else {
            return false
        }

        // Seems like `NSStatusBar.system.thickness` doesn't include this.
        let menuBarBottomBorder: CGFloat = 1

        let menuBarHeight = system.thickness - menuBarBottomBorder
        let dockHeight = CGFloat(NSWorkspace.shared.dockHeight ?? 0)

        return (screen.frame.height - screen.visibleFrame.height - dockHeight) <= menuBarHeight
    }
}

#endif
