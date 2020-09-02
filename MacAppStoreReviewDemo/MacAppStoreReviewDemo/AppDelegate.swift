//
//  AppDelegate.swift
//  MacAppStoreReviewDemo
//
//  Created by kongyulu on 2020/7/9.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa
import StoreKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var sessionCode: NSApplication.ModalSession?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print("\(#function)")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func btnStarClicked(_ sender: Any) {
        print("\(#function)")
        SKStoreReviewController.requestReview()
    }
    
}

extension AppDelegate {
    @objc func windowClose(window:NSWindow) {
        print("\(#function)")
        stopModel()
    }
    
    func stopModel() {
        NSApplication.shared.stopModal()
    }
    
    func showModel(wnd:NSWindow) {
        NSApplication.shared.runModal(for: wnd)
    }
    
    func show(sessionWnd:NSWindow) {
        sessionCode = NSApplication.shared.beginModalSession(for: sessionWnd)
    }
    
    func stop(sessionWnd:NSWindow) {
        if let sessionCode = sessionCode {
            NSApplication.shared.endModalSession(sessionCode)
        }
        if window == self.window {
            NSApp.terminate(self)
        } else {
            NSApplication.shared.stopModal()
        }
    }
}

