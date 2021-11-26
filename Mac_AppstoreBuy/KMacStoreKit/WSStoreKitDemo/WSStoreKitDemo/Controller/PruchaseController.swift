//
//  PruchaseController.swift
//  WSStoreKitDemo
//
//  Created by ws on 2020/7/24.
//  Copyright © 2020 ws. All rights reserved.
//

import Cocoa
import KStoreKit

public enum RegisteredProduct: String {
    /// 终身会员
    case lifetime = "com.kyl.app.lifetime"
    /// 订阅型年会员
    case annualPlan = "com.kyl.app.annualplan"
    case yuefen = "com.kyl.app.yuefen"
    case month = "com.kyl.app.month"
    case week = "com.kyl.app.week"
    case other = "20200622"
}

class PruchaseController: NSViewController {

    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var logView: NSView!
    @IBOutlet var logInfoView: NSTextView!
    /// 已检索到的所有商品<SKProduct>
    public private(set) var validProducts: [String : Product]?

    let filePanel = FilePanel.init()
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        Store.shared.progressIndicator = (self.view.window?.windowController as? MainWindowController)?.progressIndicator
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(ProductItem.self, forItemWithIdentifier: .itemIdentifie)
        
        // 设置基础调试信息
        Store.shared.needRecordLog = true
        Store.shared.logInfoView = logInfoView
        
        // 获取上次用户支付完成但未处理的交易
        Store.shared.getCompleteTransactionsOnApplicationDidFinishLaunching = {(result) in
            print(result)
            switch result {
            case let .purchased(item):
                self.updateDatasources(item: item, expired: false)
            case let .restored(purchase):
                print("恢复商品：",purchase.productId)
            case let .expired(item):
                self.updateDatasources(item: item, expired: true)
            case .notPurchased:
                print("notPurchased:")
            case let .error(error):
                print("readStoredItems:",error.localizedDescription)
            }
        }
        
        // 请示商品信息
        refreshProductInfo()

        // 读取存在钥匙串已购买的信息
        
//        Store.shared.readStoredItems(productType: { (pID) -> ProductType in
//            if(pID == RegisteredProduct.lifetime.rawValue){
//                return .nonConsumable
//            }
//            return .autoRenewable
//        }, readCompletion: { (identifier) in
//            debugPrint("readCompletion:",identifier)
//            
//        }, verifyResult: { (result, identifier) in
//            switch result {
//            case let .purchased(item):
//                self.updateDatasources(item: item, expired: false)
////                debugPrint("...1",item.productId, item.purchaseDate.toString())
//                break
//            case let .expired(item):
////                debugPrint("...2",item.productId, item.purchaseDate.toString())
//                self.updateDatasources(item: item, expired: true)
//                break
//            case .notPurchased:
//                print("notPurchased:",identifier)
//               
//            case let .error(error):
//                print("readStoredItems:",error.localizedDescription)
//            }
//        })
    }

    func refreshProductInfo() {
        
        let identifiers = [RegisteredProduct.lifetime.rawValue,
                           RegisteredProduct.annualPlan.rawValue,
                           RegisteredProduct.week.rawValue]
        
        Store.shared.retrieveProducts(identifiers: identifiers) { (products) in
            let _validProducts = products.validProducts
            let sortedProducts = _validProducts.sorted { $0.value.identifier > $1.value.identifier }
            for p in sortedProducts {
                if self.validProducts == nil {
                    self.validProducts = [String : Product]()
                }
                self.validProducts?.updateValue(p.value, forKey: p.key)
            }
            self.collectionView.reloadData()
        }
    }

    func pruchase(identifier: String) {
        
        var type = ProductType.autoRenewable
        
        if identifier == RegisteredProduct.lifetime.rawValue {
            type = .nonConsumable
        }
        
        // 购买方法1，会自动去验证
        Store.shared.pruchaseAutoVerify(productIdentifier: identifier, productType: type) { (result) in
            switch result {
            case let .purchased(item):
                self.updateDatasources(item: item, expired: false)

            case let .restored(purchase):
                print("恢复商品：",purchase.productId)
                
            case let .expired(item):
                self.updateDatasources(item: item, expired: true)

            case .notPurchased:
                print(identifier)

            case let .error(error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func pruchase2(identifier: String) {
        // 购买方法2，需要手动一步步执行
        Store.shared.pruchase(productIdentifier: identifier) { (result) in
            switch result {
            case let .success(purchase):
                Store.shared.verifyReceipt(productIdentifier: purchase.productId, forceRefresh: false) { (result2) in
                    switch result2 {
                    case let .success(receipt):
                        
                        if RegisteredProduct.annualPlan.rawValue == purchase.productId {
                            let verifyResult = Store.shared.verifySubscriptions(productId: purchase.productId, inReceipt: receipt)
                            switch verifyResult {
                            case let .purchased(_ , items):
                                if let item = items.first {
                                    self.updateDatasources(item: item, expired: false)
                                }
                                
                            case let .expired(_ , items):
                                if let item = items.first {
                                    self.updateDatasources(item: item, expired: true)
                                }
                                
                            case .notPurchased:
                                print("notPurchased", purchase.productId)
                            }
                        } else {
                            let verifyResult = Store.shared.verifyPurchase(productId: purchase.productId, inReceipt: receipt)
                            switch verifyResult {
                            case let .purchased(item):
                                self.updateDatasources(item: item, expired: false)
                            case .notPurchased:
                                print("notPurchased", purchase.productId)
                            }
                        }
                        
                    case let .error(error):
                        print("验证购买失败2:",error.localizedDescription)
                    }
                }
                
            case let .error(error):
                print("验证购买失败:",error.localizedDescription)
            }
        }
    }
    
    @IBAction func restorePurchases(_ sender: Any) {
        
        Store.shared.restorePurchases(atomically: true, applicationUsername: "", productType: { (pID) -> ProductType in
            if(pID == RegisteredProduct.lifetime.rawValue){
                return .nonConsumable
            }
            return .autoRenewable
        }, verifyResult: { (result) in
            switch result {
            case let .purchased(item):
                self.updateDatasources(item: item, expired: false)
                
            case let .restored(purchase):
                print("恢复商品：",purchase.productId)
                
            case let .expired(item):
                self.updateDatasources(item: item, expired: true)

            case .notPurchased:
                print("restorePurchases.notPurchased")

            case let .error(error):
                print(error.localizedDescription)
            }
        }, purchases: {(purchase) in
            
        })
        
      }
    
    // 更新数据源
    func updateDatasources(item: ReceiptItem, expired: Bool) {
        if var product = self.validProducts?[item.productId] {
            if item.subscriptionExpirationDate != nil {
                product.expireDate = item.subscriptionExpirationDate
            }
            product.buyDate = item.purchaseDate
            product.expired = expired
            self.validProducts?.updateValue(product, forKey: item.productId)
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func refreshProductInfo(_ sender: Any) {
        logInfoView.string = "..."
        refreshProductInfo()
    }
    
    @IBAction func clearLogInfo(_ sender: NSButton) {
        logInfoView.string = "..."
    }
    
    @IBAction func copyLogInfo(_ sender: NSButton) {
        let board = NSPasteboard.general
        board.declareTypes([.string], owner: self);
        board.setString(logInfoView.string, forType: .string)
    }
    
    @IBAction func openFilePanel(_ sender: NSButton) {
        startAnimation()
        /// 以下验证方式二选一
        let openTyep = false
        if openTyep {
            /// 验证方式一：
            FilePanel.openFilePanel(types: ["app"]) {[weak self](result, success) in
                if success {
                    // 验证成功
                } else {
                    // 验证失败！
                }
                self?.resetLogInfo(result)
            }
            
        } else {
            /// 验证方式二：
            FilePanel.readAppFromDefaultPath { [weak self](result, success) in
                self?.stopAnimation()
                if success {
                    // 验证成功
                } else {
                    // 验证失败！
                }
                self?.resetLogInfo(result)
            }
        }
    }
}


extension PruchaseController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
        return validProducts?.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: .itemIdentifie, for: indexPath) as! ProductItem
        
//        guard let safeValidProducts = validProducts  else {
//            return item
//        }
//        let products = Array(safeValidProducts.values)
//        let product = products[indexPath.item]
//        item.updateSources(product: product)
//
//        item.didClickBuyBlock = {[weak self] in
//            self?.pruchase(identifier: product.identifier)
//        }
        
        return item
    }
}

extension PruchaseController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        debugPrint(#function)
    }
}

extension PruchaseController: NSCollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 68, height: 270)
    }
    
}


extension PruchaseController {

    func startAutoCheck() {
//        debugPrint("timer.setEventHandler.begin")
//        if !checking {
//            checking = true
//        timer.schedule(deadline: DispatchTime.now(), repeating: .seconds(60*60), leeway: .seconds(50*60))
//        timer.setEventHandler {
//            debugPrint("subTimer.setEventHandler")
//            self.verifyReceipt(RegisteredPurchase.annualPlan.rawValue)
//        }
//        timer.resume()
//        }
    }
    
    func startAutoCheckSub() {
        debugPrint("subTimer.setEventHandler.begin")
//        if !subChecking {
//            subChecking = true
//            subTimer.schedule(deadline: DispatchTime.now(), repeating: .seconds(3*60), leeway: .seconds(60))
//            subTimer.setEventHandler {
//                debugPrint("timer.setEventHandler.begin")
//                self.verifyReceipt(RegisteredPurchase.week.rawValue)
//            }
//            subTimer.resume()
//        }
    }
    
    func updateButTime(pId: String, date: String) {
//        var timeLabel = annuaBuyTime
//        switch pId {
//        case RegisteredPurchase.annualPlan.rawValue:
//            timeLabel = annuaBuyTime
//
//        case RegisteredPurchase.week.rawValue:
//            timeLabel = weekBuyTime
//
//        case RegisteredPurchase.lifetime.rawValue:
//            timeLabel = lifeBuyTime
//
//        default: break
//        }
//        if Thread.current == Thread.main {
//            timeLabel?.stringValue = date
//        } else {
//            DispatchQueue.main.sync {
//                timeLabel?.stringValue = date
//            }
//        }
    }
    
    func updateExpiredTime(pId: String, date: String) {
//        var timeLabel = annuaExpiredTime
//        switch pId {
//        case RegisteredPurchase.annualPlan.rawValue:
//            timeLabel = annuaExpiredTime
//
//        case RegisteredPurchase.week.rawValue:
//            timeLabel = weekExpiredTime
//
//        case RegisteredPurchase.lifetime.rawValue:
//            timeLabel = lifeExpiredTime
//
//        default: break
//        }
//        if Thread.current == Thread.main {
//            timeLabel?.stringValue = date
//        } else {
//            DispatchQueue.main.sync {
//                timeLabel?.stringValue = date
//            }
//        }
    }
    
    func updateButtonStatus(pId: String, enable: Bool) {
//        var button = annuaButton
//        switch pId {
//        case RegisteredPurchase.annualPlan.rawValue:
//            button = annuaButton
//
//        case RegisteredPurchase.week.rawValue:
//            button = weekButton
//
//        case RegisteredPurchase.lifetime.rawValue:
//            button = lifeButton
//
//        default: break
//        }
//        if Thread.current == Thread.main {
//            button?.isEnabled = enable
//            button?.title = (enable == true ? "购买" : "已购买")
//
//        } else {
//            DispatchQueue.main.sync {
//                button?.isEnabled = enable
//                button?.title = (enable == true ? "购买" : "已购买")
//            }
//        }
    }
    
    func resetLogInfo(_ info: String...) {
        var tempInfo = ""
        for sub in info {
            tempInfo.append(sub)
        }
        if Thread.current == Thread.main {
            self.logInfoView.string = tempInfo
            logInfoView.scrollRangeToVisible(NSRange(location: logInfoView.string.lengthOfBytes(using: .utf8), length: 0))
        } else {
            DispatchQueue.main.sync {
                self.logInfoView.string = tempInfo
                logInfoView.scrollRangeToVisible(NSRange(location: logInfoView.string.lengthOfBytes(using: .utf8), length: 0))
            }
        }
    }
    
    func appedLogInfo(_ info: String...) {
        var tempInfo = "\n"
        for sub in info {
            tempInfo.append(" - ")
            tempInfo.append(sub)
        }
        if Thread.current == Thread.main {
            var oldInfo = logInfoView.string
            oldInfo.append(tempInfo)
            self.logInfoView.string = oldInfo
        } else {
            DispatchQueue.main.sync {
                var oldInfo = logInfoView.string
                oldInfo.append(tempInfo)
                self.logInfoView.string = oldInfo
            }
        }
        DispatchQueue.main.async {
            self.logInfoView.scrollRangeToVisible(NSRange(location: self.logInfoView.string.lengthOfBytes(using: .utf8), length: 0))
        }
    }
    
    func startAnimation() {
         DispatchQueue.main.async {
//             self.indicatorView.startAnimation(nil)
         }
     }
     
     func stopAnimation() {
         DispatchQueue.main.async {
//             self.indicatorView.stopAnimation(nil)
         }
     }
}
