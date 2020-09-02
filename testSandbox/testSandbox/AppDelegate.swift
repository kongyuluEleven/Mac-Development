//
//  AppDelegate.swift
//  testSandbox
//
//  Created by kongyulu on 2020/7/1.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa
let kFilePathKey = "kFilePathKeyTestSandBox"
typealias FilePermissionBlock = () -> Void

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var filePathField: NSTextField!
    @IBOutlet weak var scrolTextView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    
    private var filePathURL:URL?

    let appName = "testM1"

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        readFile()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func show(_ sender: Any) {
        showTask5()
        //showTask2()
    }
    
    @IBAction func open(_ sender: Any) {
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
            print("读取kFilePathKey失败，没有获取到fileURL,kFilePathKey = \(kFilePathKey)")
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


extension AppDelegate {
        
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
            let task = Process()
            let pathStr  =  "\(Bundle.main.bundlePath)/Contents/Resources/testSandboxSub.app/Contents/MacOS/testSandboxSub"
            debugPrint("path = \(pathStr)")
            task.launchPath = pathStr
            task.environment = ProcessInfo.processInfo.environment
            task.launch()
            task.waitUntilExit()
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
            
//            guard let path = Bundle.main.url(forResource: appName, withExtension: "app") else {
//                return
//            }
//            debugPrint("path = \(path)")
            
            //let pathStr  =  "\(Bundle.main.bundlePath)/Contents/Resources/testM1.app"
            let pathStr  =  "\(Bundle.main.bundlePath)/Contents/Resources/testSandboxSub.app"
            debugPrint("pathStr = \(pathStr)")
            
            _ = try? NSWorkspace.shared.open(URL(fileURLWithPath: pathStr))
        }
}

