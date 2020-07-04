//
//  AppDelegate.swift
//  testM1
//
//  Created by kongyulu on 2020/6/8.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa

let kFilePathKey = "kFilePathKey"

typealias FilePermissionBlock = () -> Void

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var filePathField: NSTextField!
    @IBOutlet weak var scrolTextView: NSScrollView!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!
    
    private var filePathURL:URL?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        readFile()
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
    
    @IBAction func browse(_ sender: Any) {
        openFile()
    }
    
    @IBAction func save(_ sender: Any) {
        saveFile()
    }
}


// MARK: - 测试沙盒权限

extension AppDelegate {
    func readFile() {
        //从UserDefaults中获取文件路径
        let defaults = UserDefaults.standard;
        guard let fileURL = defaults.value(forKey: kFilePathKey) as? String else {
            print("读取kFilePathKey失败，没有获取到fileURL")
            return;
        }
        guard let url = URL(string: fileURL) else {
            print("获取路径url失败")
            return
        }
        _ = accessFileURL(ofURL: url, withBlock: {
             guard let string = try? NSString.init(contentsOf: url, encoding: String.Encoding.utf8.rawValue) else {
                       print("获取路径url失败")
                       return
                   }
                   filePathURL = url
                   filePathField.stringValue = fileURL
                   textView.string = string as String
        })
        
    }
    
    func openFile() {
        let openDlg = NSOpenPanel()
        openDlg.canChooseFiles = true
        openDlg.canChooseDirectories = false
        openDlg.allowsMultipleSelection = false
        openDlg.allowedFileTypes = ["txt"]
        
        openDlg.begin { [weak self] (result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                print("点击了OK按钮")
                
                for url in openDlg.urls {
                    guard let string = try? NSString.init(contentsOf: url, encoding: String.Encoding.utf8.rawValue) else {
                        return
                    }
                    
                    self?.filePathField.stringValue = url.absoluteString
                    self?.textView.string = string as String
                    self?.filePathURL = url
                    
                    UserDefaults.standard.set(url.absoluteString, forKey: kFilePathKey)
                    UserDefaults.standard.synchronize()
                    
                    self?.persistPermissionURL(url)
                }
            }
        }
    }
    
    func saveFile() {
        let text = textView.string
        guard let url = filePathURL else {
            return
        }
        _ = try? text.write(to: url, atomically: true, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
    }
}

// MARK: - 沙盒权限
extension AppDelegate {
    func persistPermissionURL(_ url:URL) {
        //根据url生产bookmarkData
        let bookmarkData =  try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        print("persistPermissionURL bookmarkData\(url) \(String(describing: bookmarkData))")
        //存储bookmarkData
        if let bookmarkData = bookmarkData {
            UserDefaults.standard.set(bookmarkData, forKey: url.path)
            UserDefaults.standard.synchronize()
        }
    }
    
    func accessFileURL(ofURL url:URL, withBlock block:FilePermissionBlock) -> Bool {
        let defaults = UserDefaults.standard
        guard let bookmarkData = defaults.value(forKey: url.path) as? Data else {
            print("bookmakrData = nil")
            return false
        }
        
        var bookmarkDataIsStale = false
        let allowedUrl = try? URL(resolvingBookmarkData: bookmarkData, options: [.withoutUI, .withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
        //bookmarkDataIsStale == true 时，需要重新创建新的bookmarkData
        if bookmarkDataIsStale {
            persistPermissionURL(url)
        }
        if let allowedUrl = allowedUrl, allowedUrl.startAccessingSecurityScopedResource() {
            block()
            allowedUrl.stopAccessingSecurityScopedResource()
            return true
        }
        return false
    }
}


// MARK: - 测试NStask 调取子app
extension AppDelegate {
        
        
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

