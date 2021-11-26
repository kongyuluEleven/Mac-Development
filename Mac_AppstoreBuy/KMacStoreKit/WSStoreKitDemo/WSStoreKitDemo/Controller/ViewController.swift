//
//  ViewController.swift
//  WSStoreKitDemo
//
//  Created by ws on 2020/6/24.
//  Copyright © 2020 ws. All rights reserved.
//

import Cocoa
import WSStoreKit
import WebKit




/// 已注册的商品
public enum RegisteredPurchase: String {
    /// 终身会员
    case lifetime = "com.wondershare.filmora.app.lifetime"
    /// 订阅型年会员
    case annualPlan = "com.wondershare.filmora.app.annualplan"
    case yuefen = "com.wondershare.filmora.app.yuefen"
    case month = "com.wondershare.filmora.app.month"
    case week = "com.wondershare.filmora.app.week"
    case other = "20200622"
}


class ViewController: NSViewController {

    /// 已检索到的所有商品<SKProduct>
    public private(set) var retrievedProducts: [String : SKProduct]?
    let filePanel = FilePanel.init()

    @IBOutlet weak var indicatorView: NSProgressIndicator!
    
    @IBOutlet weak var annuaBuyTime: NSTextField!
    @IBOutlet weak var annuaExpiredTime: NSTextField!
    @IBOutlet weak var annuaButton: NSButton!
    
    @IBOutlet weak var lifeBuyTime: NSTextField!
    @IBOutlet weak var lifeExpiredTime: NSTextField!
    @IBOutlet weak var lifeButton: NSButton!
    
    @IBOutlet weak var weekBuyTime: NSTextField!
    @IBOutlet weak var weekExpiredTime: NSTextField!
    @IBOutlet weak var weekButton: NSButton!
    
    @IBOutlet var logInfoView: NSTextView!
    var openRelease = true
    var sessionCode : NSApplication.ModalSession?
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
    let subTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
    var checking = false
    var subChecking = false

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Wondershare123
        addObserver(sel: #selector(completeTransaction(_:)))
        addObserver(name: NSWindow.didResizeNotification, sel: #selector(self.windowDidResize(_:)))

        getAllProducts()
        
        Store.getKeyInfo(productID: RegisteredPurchase.annualPlan.rawValue) { (item, key, error) in
            debugPrint("getKeyInfo:",item as Any)
            if let safeItem = item, let safeKey = key {
                self.annuaBuyTime.stringValue = safeKey
                self.appedLogInfo("取出已购商品：",safeItem, safeKey)
                self.verifyReceipt(RegisteredPurchase.annualPlan.rawValue)
            }
        }
        
        Store.getKeyInfo(productID: RegisteredPurchase.lifetime.rawValue) { (item, key, error) in
            debugPrint("getKeyInfo:",item as Any)
            if let safeItem = item, let safeKey = key {
                self.lifeBuyTime.stringValue = safeKey
                self.appedLogInfo("取出已购商品：",safeItem, safeKey)
//                self.verifyReceipt(RegisteredPurchase.annualPlan.rawValue)
            }
        }
        
        Store.getKeyInfo(productID: RegisteredPurchase.week.rawValue) { (item, key, error) in
            debugPrint("getKeyInfo:",item as Any)
            if let safeItem = item, let safeKey = key {
                self.weekBuyTime.stringValue = safeKey
                self.appedLogInfo("取出已购商品：",safeItem, safeKey)
                self.verifyReceipt(RegisteredPurchase.week.rawValue)
            }
        }
        
    }
    
    func getAllProducts() {
        retrieveProductsInfo([RegisteredPurchase.annualPlan.rawValue,
                              RegisteredPurchase.lifetime.rawValue,
                              RegisteredPurchase.week.rawValue])
    }
    
    @IBAction func getProductInfo(_ sender: NSButton) {
        retrieveProductsInfo([sender.alternateTitle])
    }
    
    private func retrieveProductsInfo(_ pIds: [String]) {
        startAnimation()
        Store.retrieveProductsInfo(pIds) { (result) in
            debugPrint("请求商品信息结果：",result)
            self.appedLogInfo("请求商品信息：")
            for product in result.retrievedProducts {
                if self.retrievedProducts == nil {
                    self.retrievedProducts = [product.productIdentifier : product]
                } else {
                    self.retrievedProducts?.updateValue(product, forKey: product.productIdentifier)
                }
                self.appedLogInfo("有效商品：",product.productIdentifier,String(product.price.stringValue),product.localizedPrice ?? "0.00")
            }
            for product in result.invalidProductIDs {
                self.appedLogInfo("无效商品：",product)
            }
            self.stopAnimation()
        }
    }
    
    
    @IBAction func purchase(_ sender: NSButton) {
        purchase(productID: sender.alternateTitle)
    }
    func purchase(productID: String) {
        guard let pId = getProductId(productID) else {
            appedLogInfo("你获取商品不存在", productID)
            debugPrint("你获取商品不存在", productID)
            return
        }
        Store.shared.purchaseProduct(pId, atomically: false) { (result) in
            switch result {
            case let .success(purchase):
                // do something eg.: 验证
                // self.verifyReceipt(purchase.productId)
                if purchase.needsFinishTransaction {
                    Store.finishTransaction(purchase.transaction)
                }
                let date = purchase.transaction.transactionDate?.toString() ?? ""
                self.updateButTime(pId: purchase.productId, date: date)
                self.appedLogInfo(purchase.productId, date, purchase.transaction.transactionState.debugDescription)
                debugPrint("购买成功：",purchase)
                if self.openRelease {
                    self.verifyReceipt(purchase.productId)
                }
            case let .error(error):
                self.appedLogInfo(error.localizedDescription)
                debugPrint("购买商品错误：", error, pId)
            }
        }
    }
    
    @IBAction func verifyReceipt(_ sender: NSButton) {
        verifyReceipt(sender.alternateTitle)
    }
    
    private func verifyReceipt(_ productId: String) {
        startAnimation()
        Store.shared.verifyReceipt(using: Store.appleReceipt, forceRefresh: false) { (verifyResult) in
            switch verifyResult {
            case .success(let info):
                var stringJson = info as Dictionary
                stringJson = self.resolvingJsonInDebug(&stringJson)
                if productId == RegisteredPurchase.lifetime.rawValue {
                    let verifyPurchase = Store.verifyPurchase(productId: productId, inReceipt: info)
                    switch verifyPurchase {
                    case .purchased(let item):
                        self.appedLogInfo(item.productId, "purchaseDate:\(item.purchaseDate.toString())")
                        self.updateButTime(pId: item.productId, date: item.purchaseDate.toString())
                        if item.cancellationDate != nil {
                            self.updateExpiredTime(pId: item.productId, date: item.cancellationDate!.toString())
                        } else {
                            self.updateExpiredTime(pId: item.productId, date: "Product is valid")
                        }
                        debugPrint("VerifyResult: Product is valid",item.productId)
                        Store.saveKeyInfo(productID: item.productId, transactionDate: item.purchaseDate) { (saveResult, error) in
                            self.appedLogInfo(saveResult ?? "", error?.localizedDescription ?? "")
                            debugPrint("购买保存结果：", saveResult, error)
                        }
                        self.startAutoCheck()
                    case .notPurchased:
                        self.appedLogInfo(productId)
                        self.updateButTime(pId: productId, date: "Has never been purchased")
                        self.updateExpiredTime(pId: productId, date: "Not Purchased")
                        debugPrint("VerifyResult: This product has never been purchased",productId)
                    }

                } else {
                    let verifySubscription = Store.verifySubscriptions(productIds: [productId], inReceipt: info)
                    switch verifySubscription {
                    case let .purchased(expiryDate, items):
                        self.updateExpiredTime(pId: productId, date: expiryDate.toString())
                        self.updateButtonStatus(pId: productId, enable: false)
                        for (index, item) in items.enumerated() {
                            if index == 0 {
                                self.updateButTime(pId: productId, date: item.purchaseDate.toString())
                                Store.saveKeyInfo(productID: item.productId, transactionDate: item.purchaseDate) { (saveResult, error) in
                                    self.appedLogInfo(saveResult ?? "", error?.localizedDescription ?? "")
                                    debugPrint("购买保存结果：", saveResult, error)
                                }
                            }
                            self.appedLogInfo("expired count:\(items.count) ",item.productId,"Product is expired\(expiryDate.toString())","purchaseDate:\(item.purchaseDate.toString())")
                            print("VerifyResult: Product is valid \(item.productId) \(expiryDate.toString())","purchaseDate:\(item.purchaseDate.toString())","取消订阅：\(String(describing: item.cancellationDate?.toString()))")
                            if item.cancellationDate != nil {
                                self.updateExpiredTime(pId: item.productId, date: item.cancellationDate!.toString())
                                self.appedLogInfo("取消订阅：\(item.cancellationDate!.toString())","expired count:\(items.count) ",item.productId,"Product is expired\(expiryDate.toString())","purchaseDate:\(item.purchaseDate.toString())")
                            }
                        }
                        // 以下为了模拟自动检查订阅时效
                        if productId == RegisteredPurchase.annualPlan.rawValue {
                            self.startAutoCheck()
                        } else {
                            self.startAutoCheckSub()
                        }
                    case let .expired(expiryDate, items):
                        self.updateButtonStatus(pId: productId, enable: true)
                        for (index, item) in items.enumerated() {
                            if index == 0 {
                                self.updateButTime(pId: productId, date: item.purchaseDate.toString())
                                self.updateExpiredTime(pId: productId, date: "已过期"+expiryDate.toString())
                                // 过期就从钥匙串中删除
                                Store.removeKeyInfo(productID: productId) { (date, error) in
                                    // 确认日期是不是一样，返回true进行删除
                                    self.appedLogInfo("删除购习记录：",date ?? "",item.purchaseDate.toString())
                                    return (date == item.purchaseDate.toString())
                                }
                            }
                            self.appedLogInfo("expired count:\(items.count) ",item.productId,"Product is expired\(expiryDate.toString())","purchaseDate:\(item.purchaseDate.toString())")
                            print("VerifyResult: Product is expired \(item.productId) \(expiryDate.toString())","purchaseDate:\(item.purchaseDate.toString())","取消订阅：\(String(describing: item.cancellationDate?.toString()))")
                            if item.cancellationDate != nil {
                                self.updateExpiredTime(pId: item.productId, date: item.cancellationDate!.toString())
                                self.appedLogInfo("取消订阅：\(item.cancellationDate!.toString())","expired count:\(items.count) ",item.productId,"Product is expired\(expiryDate.toString())","purchaseDate:\(item.purchaseDate.toString())")
                            }
                        }
                    case .notPurchased:
                        self.updateExpiredTime(pId: productId, date: "Not Purchased")
                        self.appedLogInfo("VerifyResult: This product has never been purchased", productId)
                        print("VerifyResult: This product has never been purchased", productId)
                    }
                }
               
            case .error(let errors):
                debugPrint("验证错误：",errors.localizedDescription)
                switch errors {
                case let .networkError(error):
                    self.appedLogInfo("VerifyResult: 验证错误", errors.localizedDescription, error.localizedDescription)
                case let .jsonDecodeError(string):
                    self.appedLogInfo("VerifyResult: 验证错误", errors.localizedDescription, (string ?? ""))
                case .noReceiptData:
                    self.appedLogInfo("VerifyResult: 验证错误", errors.localizedDescription, "noReceiptData")
                case .noRemoteData:
                    self.appedLogInfo("VerifyResult: 验证错误", errors.localizedDescription, "noRemoteData")
                case let .receiptInvalid(receipt, status):
                    self.appedLogInfo("VerifyResult: 验证错误", errors.localizedDescription, receipt.debugDescription, status.rawValue.description)
                case let .requestBodyEncodeError(error):
                    self.appedLogInfo("VerifyResult: 验证错误", error.localizedDescription)
                }
            }
            self.stopAnimation()
        }
    }
        
    @IBAction func restorePurchases(_ sender: Any) {
        startAnimation()
        Store.shared.restorePurchases { (results) in
            self.stopAnimation()
            self.resetLogInfo("restorePurchases:")
            
            let restoreFailedPurchases = results.restoreFailedPurchases
            if restoreFailedPurchases.count > 0 {
                let error = results.restoreFailedPurchases.first
                if error?.0 != nil || error?.1 != nil {
                    debugPrint("恢复错误：",String(error!.0.code.rawValue), error!.0.localizedDescription)
                    self.appedLogInfo(String(error!.0.code.rawValue), error!.0.localizedDescription)
                }
            } else {
                for purchase in results.restoredPurchases {
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        Store.finishTransaction(purchase.transaction)
                    }
                    let transaction = purchase.transaction
                    self.verifyReceipt(purchase.productId)
                    
                    self.appedLogInfo(purchase.productId,
                                      "transactionDate:\(transaction.transactionDate?.toString() ?? "")",
                                      transaction.transactionState.debugDescription,
                                      "needsFinish:\(purchase.needsFinishTransaction.description)")
                }
            }
        }
    }
    
    @objc func completeTransaction(_ notifiy: Notification) {
        let dict = notifiy.userInfo as? [String : [Purchase]]
        let _purchases = dict?["info"]
        guard let purchases = _purchases else {
            debugPrint("completeTransaction error")
            return
        }
        for purchase in purchases {
            switch purchase.transaction.transactionState {
            case .purchased, .restored:
                if purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.appedLogInfo("completeTransaction: \(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                debugPrint("completeTransaction: \(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
            case .failed, .purchasing, .deferred:
                self.appedLogInfo("completeTransaction: \(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                debugPrint("completeTransaction: \(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
            @unknown default:
              break // do nothing
            }
        }
    }
    
    func refreshProductInfo() {
        resetLogInfo("更新商品信息")
        getAllProducts()
    }
    
    @IBAction func clearLogInfo(_ sender: NSButton) {
        logInfoView.string = ""
    }
    
    @IBAction func copyLogInfo(_ sender: NSButton) {
        let board = NSPasteboard.general
        board.declareTypes([.string], owner: self);
        board.setString(logInfoView.string, forType: .string)
    }
    
    func openFilePanel() {
        startAnimation()
        filePanel.openFilePanel(types: ["app"]) {[weak self](result, success) in
            self?.stopAnimation()
            self?.resetLogInfo(result)
        }
    }
    
    @objc func windowDidResize(_ aNotification: NSNotification) {
        
    }
    
    func addObserver(name: NSNotification.Name = kStoreCompleteTransactionNotifiy, sel:Selector) {
        NotificationCenter.default.addObserver(self, selector: sel, name: name, object: nil)
    }
}

extension ViewController {

    func startAutoCheck() {
        debugPrint("timer.setEventHandler.begin")
        if !checking {
            checking = true
        timer.schedule(deadline: DispatchTime.now(), repeating: .seconds(60*60), leeway: .seconds(50*60))
        timer.setEventHandler {
            debugPrint("subTimer.setEventHandler")
            self.verifyReceipt(RegisteredPurchase.annualPlan.rawValue)
        }
        timer.resume()
        }
    }
    
    func startAutoCheckSub() {
        debugPrint("subTimer.setEventHandler.begin")
        if !subChecking {
            subChecking = true
            subTimer.schedule(deadline: DispatchTime.now(), repeating: .seconds(3*60), leeway: .seconds(60))
            subTimer.setEventHandler {
                debugPrint("timer.setEventHandler.begin")
                self.verifyReceipt(RegisteredPurchase.week.rawValue)
            }
            subTimer.resume()
        }
    }
    
    func getProductId(_ key: String) -> SKProduct? {
        guard let products = retrievedProducts else {
            return nil
        }
        return products[key]
    }
    
    func resolvingJsonInDebug(_ stringJson: inout [String : AnyObject]) -> [String : AnyObject] {
        stringJson.updateValue("..." as AnyObject, forKey: "latest_receipt")
        do {
            // debug info
            let data = try JSONSerialization.data(withJSONObject: stringJson as Any, options: .prettyPrinted)
            let jsonString = String(bytes: data, encoding: .utf8) ?? ""
            self.appedLogInfo(jsonString)
            
        } catch let err {
            self.appedLogInfo("解析JSON错误：", err.localizedDescription)
            debugPrint("解析JSON错误：",err)
            return stringJson
        }
        return stringJson
    }
    
    func updateButTime(pId: String, date: String) {
        var timeLabel = annuaBuyTime
        switch pId {
        case RegisteredPurchase.annualPlan.rawValue:
            timeLabel = annuaBuyTime
            
        case RegisteredPurchase.week.rawValue:
            timeLabel = weekBuyTime

        case RegisteredPurchase.lifetime.rawValue:
            timeLabel = lifeBuyTime

        default: break
        }
        if Thread.current == Thread.main {
            timeLabel?.stringValue = date
        } else {
            DispatchQueue.main.sync {
                timeLabel?.stringValue = date
            }
        }
    }
    
    func updateExpiredTime(pId: String, date: String) {
        var timeLabel = annuaExpiredTime
        switch pId {
        case RegisteredPurchase.annualPlan.rawValue:
            timeLabel = annuaExpiredTime
            
        case RegisteredPurchase.week.rawValue:
            timeLabel = weekExpiredTime
            
        case RegisteredPurchase.lifetime.rawValue:
            timeLabel = lifeExpiredTime
            
        default: break
        }
        if Thread.current == Thread.main {
            timeLabel?.stringValue = date
        } else {
            DispatchQueue.main.sync {
                timeLabel?.stringValue = date
            }
        }
    }
    
    func updateButtonStatus(pId: String, enable: Bool) {
        var button = annuaButton
        switch pId {
        case RegisteredPurchase.annualPlan.rawValue:
            button = annuaButton
            
        case RegisteredPurchase.week.rawValue:
            button = weekButton
            
        case RegisteredPurchase.lifetime.rawValue:
            button = lifeButton
            
        default: break
        }
        if Thread.current == Thread.main {
            button?.isEnabled = enable
            button?.title = (enable == true ? "购买" : "已购买")
            
        } else {
            DispatchQueue.main.sync {
                button?.isEnabled = enable
                button?.title = (enable == true ? "购买" : "已购买")
            }
        }
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
             self.indicatorView.startAnimation(nil)
         }
     }
     
     func stopAnimation() {
         DispatchQueue.main.async {
             self.indicatorView.stopAnimation(nil)
         }
     }
}

