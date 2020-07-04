//
//  AppDelegate.swift
//  testSandbox
//
//  Created by kongyulu on 2020/7/1.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let appName = "testM1"

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func show(_ sender: Any) {
        showTask()
    }
    
    @IBAction func open(_ sender: Any) {
        openFile()
    }

}

extension AppDelegate {
       func openFile() {
            let openDlg = NSOpenPanel()
            openDlg.canChooseFiles = true
            openDlg.canChooseDirectories = true
            openDlg.begin { (result) in
                if result.rawValue == NSFileHandlingPanelOKButton {
                    print("点击了OK按钮")
                }
            }
        }
        
        func showTask() {
            let task = Process()
            let pathStr  =  "\(Bundle.main.bundlePath)/Contents/Resources/testM1.app/Contents/MacOS/testM1"
            debugPrint("path = \(pathStr)")
            task.launchPath = pathStr
            task.environment = ProcessInfo.processInfo.environment
            task.launch()
            task.waitUntilExit()
        }
        
        func showTask2() {
            
            guard let path = Bundle.main.url(forResource: appName, withExtension: "app") else {
                return
            }
            debugPrint("path = \(path)")
            
            let task = Process()
        }
        
        func showTask3() {
            
            guard let path = Bundle.main.url(forResource: "ScreenRecord-debug", withExtension: "app") else {
                return
            }
            debugPrint("path = \(path)")
            
            _ = try? NSWorkspace.shared.open(path)
        }
        
        func showTask4() {
            
            guard let path = Bundle.main.url(forResource: "MediaBrowser-release", withExtension: "app") else {
                return
            }
            debugPrint("path = \(path)")
            
            _ = try? NSWorkspace.shared.open(path)
        }
        
        func showTask5() {
            
            guard let path = Bundle.main.url(forResource: appName, withExtension: "app") else {
                return
            }
            debugPrint("path = \(path)")
            
            _ = try? NSWorkspace.shared.open(path)
        }
}

