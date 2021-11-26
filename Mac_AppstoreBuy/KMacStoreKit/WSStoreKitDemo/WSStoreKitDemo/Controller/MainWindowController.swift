//
//  WindowController.swift
//  WSStoreKitDemo
//
//  Created by ws on 2020/6/28.
//  Copyright © 2020 ws. All rights reserved.
//

import Cocoa
import WebKit

class MainWindowController: NSWindowController {

    lazy var progressIndicator: NSProgressIndicator = {
        let toolBar = self.window?.standardWindowButton(NSWindow.ButtonType.closeButton)?.superview
        let y = ((toolBar?.frame.height ?? 20) - 20) * 0.5
        let x = (toolBar?.frame.width ?? 846) * 0.5 + 50
        let progressIndicator = NSProgressIndicator.init(frame: NSRect(x: x, y: y, width: 20, height: 20))
        progressIndicator.style = .spinning
        progressIndicator.controlSize = .regular
        progressIndicator.isDisplayedWhenStopped = false
        toolBar?.addSubview(progressIndicator)
        return progressIndicator
    }()
    
    lazy var openHtmlButton: NSButton = {
        let toolBar = self.window?.standardWindowButton(NSWindow.ButtonType.closeButton)?.superview
        let y: CGFloat = 10
        let x = (toolBar?.frame.width ?? 846) - 120
        let button = NSButton.init(frame: NSRect(x: x, y: y, width: 100, height: 20))
        button.setButtonType(.pushOnPushOff)
        button.title = "帮助"
        toolBar?.addSubview(button)
        return button
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let rect = NSRect(x: self.window?.frame.minX ?? 0, y: self.window?.frame.minY ?? 0, width: 846, height: 632)
        self.window?.setFrame(rect, display: true)
        
        openHtmlButton.action = #selector(openHelpPage(_:))
    }
    
    @objc func openHelpPage(_ sender:NSToolbarItem) {
        HTMLWindowController().showWindow(self)
    }
}
