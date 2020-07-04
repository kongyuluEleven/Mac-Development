//
//  AppDelegate.swift
//  testM1
//
//  Created by kongyulu on 2020/6/8.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    @IBAction func show(_ sender: Any) {
        showTask5()
    }
    
    @IBAction func openFile(_ sender: Any) {
        openFile()
    }
    
    
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
//        guard let path = Bundle.main.resourcePath?.appending("/test.app") else {
//            return
//        }
//        debugPrint("path = \(String(describing: path))")
        guard let path = Bundle.main.url(forResource: "test", withExtension: "app") else {
            return
        }
        debugPrint("path = \(String(describing: path.path))")
        task.launchPath = path.path
        //task.environment = ProcessInfo.processInfo.environment
        task.launch()
        task.waitUntilExit()
    }
    
    func showTask2() {
        
        guard let path = Bundle.main.url(forResource: "test", withExtension: "app") else {
            return
        }
        debugPrint("path = \(path)")
        
        _ = try? NSWorkspace.shared.open(path)
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
        
        guard let path = Bundle.main.url(forResource: "Cutter_debug", withExtension: "app") else {
            return
        }
        debugPrint("path = \(path)")
        
        _ = try? NSWorkspace.shared.open(path)
    }
 
}

