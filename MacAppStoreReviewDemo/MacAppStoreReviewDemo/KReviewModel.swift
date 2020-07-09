//
//  KReviewModel.swift
//  MacAppStoreReviewDemo
//
//  Created by kongyulu on 2020/7/9.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa
import StoreKit

class KReviewModel: NSObject {
    let lauchCountUserDefaultskey = "noOfLaunches"
    
    func isNeedShow(review minShowCount:Int) -> Bool {
        let lauchCount =  UserDefaults.standard.integer(forKey: lauchCountUserDefaultskey)
        if lauchCount >= minShowCount {
            return  true
        }
        
        UserDefaults.standard.set((lauchCount+1), forKey: lauchCountUserDefaultskey)
        print(lauchCount)
        return false
    }
    
    func show(review showCount:Int) {
        guard !isNeedShow(review: showCount) else {
            return
        }
        SKStoreReviewController.requestReview()
    }

}
