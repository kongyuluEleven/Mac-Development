//
//  AppDelegate.swift
//  MacFileAccessInSandbox
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

extension AppDelegate {
    private func recoverFilePath() {
        guard let path = UserDefaults.standard.value(forKey: LastSaveFilePathKey) as? String else {
            return
        }
    }
}

