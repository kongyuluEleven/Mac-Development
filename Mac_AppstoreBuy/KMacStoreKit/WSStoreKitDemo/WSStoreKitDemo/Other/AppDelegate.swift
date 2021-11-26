//
//  AppDelegate.swift
//  WSStoreKitDemo
//
//  Created by ws on 2020/6/24.
//  Copyright © 2020 ws. All rights reserved.
//

import Cocoa
import WSStoreKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {

        completeIAPTransactions()

    }
    
    func completeIAPTransactions() {
        Store.shared.completeTransactions(productType: { (pID) -> ProductType in
            if(pID == RegisteredProduct.lifetime.rawValue){
                return .nonConsumable
            }
            return .autoRenewable
        }, verifyResult: { (result) in
            debugPrint(result)

        }) { (purchases) in
            debugPrint(purchases)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
          // Insert code here to tear down your application
          
      }
}

