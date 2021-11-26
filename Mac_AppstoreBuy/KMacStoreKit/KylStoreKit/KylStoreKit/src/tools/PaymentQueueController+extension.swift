//
//  PaymentQueueController+extension.swift
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

import Cocoa
import StoreKit

extension PaymentQueueController {
    @available(OSX 10.15, *)
    func paymentQueueDidChangeStorefront(_ queue: SKPaymentQueue) {
        NotificationCenter.default.post(name: kPaymentQueueDidChangeStorefront, object: nil, userInfo: ["userInfo":queue])
        debugPrint("用户改变的商店地区：", queue.storefront?.countryCode as Any)
        
        let postName = NSNotification.Name("AppstoreBuyCountryCodeChangedNotification")
        NotificationCenter.default.post(name: postName, object: nil, userInfo: ["countryCode":queue.storefront?.countryCode ?? ""])
    }
}
