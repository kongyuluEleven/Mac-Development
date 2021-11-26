//
//  HTMLWindow.swift
//  WSStoreKitDemo
//
//  Created by ws on 2020/7/2.
//  Copyright © 2020 ws. All rights reserved.
//

import Cocoa
import WebKit


class HTMLWindow: NSWindow {

    let webView = WKWebView.init()

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        createWebView()
        self.center()
    }
    
    func createWebView() {
        self.contentView?.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        if let contentView = self.contentView  {
            let top = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
            let left = NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
            self.contentView?.addConstraints([ top, left, right, bottom])
        }
        
        let path = Bundle.main.path(forResource: "iap-Help.html", ofType: nil)
        let url = URL.init(fileURLWithPath: path!)
        do {
            let htmlString = try String.init(contentsOf: url, encoding: .utf8)
            webView.loadHTMLString(htmlString, baseURL: url)
        } catch {
            
        }

//        let url2 = URL.init(string: "https://blog-1257063273.cos.ap-chengdu.myqcloud.com/2020/iap-Help.html")
//        webView.load(URLRequest.init(url: url2!))
    }
        
}


class HTMLWindowController: NSWindowController {

    override var windowNibName: NSNib.Name? {
       return NSNib.Name("HTMLWindow")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
    }
    
    
    
}
